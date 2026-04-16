defmodule InvestmentWalletWeb.WalletJSON do
  alias InvestmentWallet.Core.Wallet
  alias InvestmentWalletWeb.StockJSON
  alias InvestmentWalletWeb.WishStockJSON

  @doc """
  Renders a list of wallets.
  """
  def index(%{wallets: wallets}) do
    %{data: for(wallet <- wallets, do: data(wallet))}
  end

  @doc """
  Renders a single wallet.
  """
  def show(%{wallet: wallet}) do
    %{wallet: data(wallet)}
  end

  defp data(%Wallet{} = wallet) do
    %{
      name: wallet.name,
      to_sell_stocks: wallet.to_sell_stocks,
      to_buy_stocks: wallet.to_buy_stocks,
      balance_cents: wallet.balance_cents,
      balance: wallet.balance_cents / 100,
      assigned_stocks: Enum.map(wallet.assigned_stocks, fn stock -> StockJSON.data(stock) end),
      wish_stocks: Enum.map(wallet.wish_stocks, fn w_stock -> WishStockJSON.data(w_stock) end)
    }
  end
end
