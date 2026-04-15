defmodule InvestmentWalletWeb.WalletJSON do
  alias InvestmentWallet.Core.Wallet

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
    %{data: data(wallet)}
  end

  defp data(%Wallet{} = wallet) do
    %{
      name: wallet.name,
      assigned_stocks: wallet.assigned_stocks,
      wish_stocks: wallet.wish_stocks,
      to_sell_stocks: wallet.to_sell_stocks,
      to_buy_stocks: wallet.to_buy_stocks,
      balance_cents: wallet.balance_cents,
      balance: wallet.balance_cents / 100
    }
  end
end
