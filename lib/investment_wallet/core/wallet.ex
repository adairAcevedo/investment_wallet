defmodule InvestmentWallet.Core.Wallet do
  @moduledoc """
    Represents an investment wallet.

    The wallet contains:
      - `assigned_stocks`: the *current* holdings. Each `Stock` struct represents **one unit** owned.
      - `wish_stocks`: the target allocation as integer percentages that must sum to 100.
      - `to_sell_stocks` / `to_buy_stocks`: output instructions produced by the rebalance step.
      - `balance_cents`: computed total value (in cents) of the current holdings using current prices.

    ## Notes
      - Money is represented in **cents** to avoid floating-point inaccuracies.
  """

  @typedoc "A trade instruction entry (symbol + number of units)."
  @type entry :: %{
    code: String.t(),
    units: integer()
  }

  @typedoc "Wallet struct type."
  @type t :: %{
    name: String.t(),
    assigned_stocks: [InvestmentWallet.Core.Stock.t()],
    wish_stocks: [InvestmentWallet.Core.WishStock.t()],
    to_sell_stocks: [entry()],
    to_buy_stocks: [entry()],
    balance_cents: integer()
  }
  defstruct name: "",
            assigned_stocks: [],
            wish_stocks: [],
            to_sell_stocks: [],
            to_buy_stocks: [],
            balance_cents: 0
end
