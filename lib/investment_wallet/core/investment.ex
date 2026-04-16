defmodule InvestmentWallet.Core.Investment do
  @moduledoc """
  Core rebalancing logic.

  Public entry point: `rebalance_wallet/1`.

  The algorithm:
  1) Validates the wallet.
  2) Validates allocation sums to 100.
  3) Loads prices and enriches `wish_stocks` with `%Stock{current_price_cents: ...}`.
  4) Computes current wallet `balance_cents`.
  5) For each wished stock:
     - calculates target money amount (`percentaje * balance / 100`)
     - converts it into target units (`amount_assigned / price`)
     - compares with current owned units and emits buy/sell instructions.

  ## Important assumptions
  - No fees, taxes, slippage.
  - No cash position.
  - No fractional shares (units are integers).
  - Price source is deterministic in-memory (`load_stocks/0`).
  """
  require Logger
  alias InvestmentWallet.Core.{Wallet, Stock, WishStock}

  @type error_reason ::
          :entity_not_process
          | :wish_stocks_empty
          | :allocation_not_one

  defguard is_valid_wallet(wallet) when is_list(wallet.assigned_stocks)

  @doc """
  Validates that the allocation percentages sum to exactly 100.

  Returns `true` when valid; otherwise `false`.

  ## Rationale
  Percentages are integers to keep validation deterministic (no float epsilon needed).
  """
  def validate_allocation(wallet) do
    sum = Enum.reduce(wallet.wish_stocks, 0, fn wish_stock, sum ->
      sum + wish_stock.percentaje
    end)
    sum == 100
  end

  @doc """
  Rebalances a wallet.

  On success, returns an updated `%Wallet{}` containing:
    - `balance_cents`
    - `wish_stocks` enriched with stock prices
    - `to_sell_stocks` and `to_buy_stocks` instructions

  On failure, returns `{:error, reason}`.

  ## Errors
    - `:wish_stocks_empty` when the desired allocation list is empty
    - `:allocation_not_one` when the allocation does not sum to 100
    - `:entity_not_process` when input is not a valid `%Wallet{}`
  """
  @spec rebalance_wallet(Wallet.t() | any()) :: Wallet.t() | {:error, atom()}
  def rebalance_wallet(%Wallet{} = wallet) when is_valid_wallet(wallet)  do
    cond do
      Enum.empty?(wallet.wish_stocks) ->
        {:error, :wish_stocks_empty}
      !validate_allocation(wallet) ->
        {:error, :allocation_not_one}
      true ->
        asigned_stocks_group = Enum.group_by(wallet.assigned_stocks, &(&1.code))
        wish_stocks_with_price = filter_stocks(wallet.wish_stocks)
        {:ok, distribute_wallet(wallet, asigned_stocks_group, wish_stocks_with_price)}
    end
  end

  def rebalance_wallet(_) do
    {:error, :entity_not_process}
  end

  @doc """
  Produces buy/sell instructions to approximate the target allocation.

  Inputs:
    - `wallet`: base wallet
    - `assigned_stocks_group`: grouped holdings by code
    - `wish_stocks_with_price`: desired stocks enriched with current price data

  Returns an updated wallet with:
    - `balance_cents`
    - `to_sell_stocks`
    - `to_buy_stocks`
    - `wish_stocks` updated with prices
  """
  @spec distribute_wallet(Wallet.t(), [Stock.t()], [WishStock.t()]) :: Wallet.t()
  def distribute_wallet(wallet, asigned_stocks_group, wish_stocks_with_price) do
    wallet = Map.put(wallet, :balance_cents, calculate_balance(asigned_stocks_group))
    distribute = Enum.reduce(wish_stocks_with_price, %{to_sell_stocks: [], to_buy_stocks: []}, fn wish_stock, acc ->
      amount_assigned = trunc((wish_stock.percentaje * wallet.balance_cents)/100)
      unit_stock_wish = trunc(amount_assigned / wish_stock.stock.current_price_cents)
      Logger.info("[Investment.distribute_wallet/3], stock #{wish_stock.code}, unit wish: #{unit_stock_wish}, amount_assigned: #{amount_assigned}")

      {_code, list_group}  = Enum.find(asigned_stocks_group,{"none",[]}, fn {code, _list_group} ->
        String.equivalent?(code, wish_stock.code)
      end)
      current_unit_stock = Enum.count(list_group)

      cond do
        current_unit_stock > unit_stock_wish ->
          %{acc | to_sell_stocks: [%{units: current_unit_stock - unit_stock_wish, code: wish_stock.code, } | acc.to_sell_stocks] }
        current_unit_stock < unit_stock_wish ->
        %{acc | to_buy_stocks: [%{units: unit_stock_wish - current_unit_stock, code: wish_stock.code} | acc.to_buy_stocks] }
        true ->
          acc
      end

    end)

    Map.merge(wallet, %{wish_stocks: wish_stocks_with_price, to_sell_stocks: distribute.to_sell_stocks, to_buy_stocks: distribute.to_buy_stocks, assigned_stocks: set_price_stocks(wallet.assigned_stocks)})
  end

  @doc """
  Enriches wish stocks with their current price data.

  It searches each wish stock by `code` in `load_stocks/0`, sets the `:stock` field,
  and sorts the list by descending price.

  ## Note
  This function assumes the wished codes exist in the local price database.
  A production version should return an error if a price is missing.
  """
  @spec filter_stocks(list()) :: list()
  def filter_stocks(wish_stocks) do
    stocks = load_stocks()
    Enum.map(wish_stocks, fn a_stock ->
      stock = Enum.find(stocks, fn find_stock -> find_stock.code == a_stock.code end)
      Map.put(a_stock, :stock, stock)
    end)
    |> Enum.sort_by(&(&1.stock.current_price_cents), :desc)
  end

  @spec set_price_stocks(list()) :: list()
  def set_price_stocks(stocks) do
    db_stocks = load_stocks()
    Enum.map(stocks, fn stock ->
      stock_find = Enum.find(db_stocks, fn db_stock -> db_stock.code == stock.code end)
      Map.put(stock, :current_price_cents, stock_find.current_price_cents)
    end)
  end

  @doc """
  The current portfolio balance is calculated to obtain the future amount available after selling

  Each list entry in `assigned_stocks_group` represents one owned unit.
  This function multiplies unit count by the current price for that symbol.

  ## Note
  This function assumes all assigned stock codes exist in the price database.
  """
  @spec calculate_balance(list()) :: list()
  def calculate_balance(asigned_stocks_group) do
    Enum.reduce(asigned_stocks_group, 0, fn {code, list_stocks_group}, acc ->
      stock = Enum.find(load_stocks(), fn find_stock -> find_stock.code == code end)
      total = Enum.count(list_stocks_group) * stock.current_price_cents
      acc + total
    end)
  end


  @doc """
  Local in-memory stock database.

  In this take-home style implementation, we keep prices deterministic.
  Replace this with an external provider (API) for production usage.
  """
  def load_stocks do
    [
      %Stock{name: "Apple Inc.", code: "AAPL", current_price_cents: 22_937},
      %Stock{name: "Meta Platforms, Inc.", code: "META", current_price_cents: 65_306},
      %Stock{name: "Netflix, Inc.", code: "NFLX", current_price_cents: 8_944},
      %Stock{name: "AT&T Inc.", code: "T", current_price_cents: 2_374},
      %Stock{name: "Bitcoin USD Price ", code: "BTC-USD", current_price_cents: 9_429_700}
    ]
  end

  @spec wallet_from_map(nil | maybe_improper_list() | map()) :: InvestmentWallet.Core.Wallet.t()
  def wallet_from_map(%{"assigned_stocks" => _, "wish_stocks" => _} = params) do
    {:ok, %Wallet{
        name: params["name"],
        assigned_stocks: parse_stocks(params["assigned_stocks"]),
        wish_stocks: parse_wish_stocks(params["wish_stocks"])
      }
    }
  end

  def wallet_from_map(_params) do
    {:error, "some field of wallet are missed, please verified to send assigned_stocks and wish_stocks"}
  end

  defp parse_stocks(stocks_params) do
    Enum.map(stocks_params, fn stock ->
      %Stock{
        name: stock["name"],
        code: stock["code"]
      }
    end)
  end

  defp parse_wish_stocks(wish_stocks_params) do
    Enum.map(wish_stocks_params, fn wish_stock ->
      %WishStock{
        percentaje: String.to_integer(wish_stock["percentaje"]),
        code: wish_stock["code"],
        stock: %Stock{}
      }
    end)
  end

end
