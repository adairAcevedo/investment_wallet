defmodule InvestmentWalletWeb.WishStockView do
  alias InvestmentWallet.Core.WishStock

  @doc """
  Renders a list of wish_stocks.
  """
  def index(%{wish_stocks: wish_stocks}) do
    %{data: for(wish_stock <- wish_stocks, do: data(wish_stock))}
  end

  @doc """
  Renders a single wish_stock.
  """
  def show(%{wish_stock: wish_stock}) do
    %{data: data(wish_stock)}
  end

  defp data(%WishStock{} = wish_stock) do
    %{
      percentaje: wish_stock.percentaje,
      code: wish_stock.code,
      stock: wish_stock.stock
    }
  end
end
