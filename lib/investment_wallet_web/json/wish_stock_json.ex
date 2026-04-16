defmodule InvestmentWalletWeb.WishStockJSON do
  alias InvestmentWallet.Core.WishStock

  @doc """
  Renders a list of wish_stocks.
  """
  def index(%{wish_stocks: wish_stocks}) do
    for(wish_stock <- wish_stocks, do: data(wish_stock))
  end

  @doc """
  Renders a single wish_stock.
  """
  def show(%{wish_stock: wish_stock}) do
    data(wish_stock)
  end

  def data(%WishStock{} = wish_stock) do
    %{
      percentaje: wish_stock.percentaje,
      code: wish_stock.code
    }
  end
end
