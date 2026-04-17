defmodule InvestmentWalletWeb.StockJSON do
  alias InvestmentWallet.Core.Stock

  @doc """
  Renders a list of stocks.
  """
  def index(%{stocks: stocks}) do
    for(stock <- stocks, do: data(stock))
  end

  @doc """
  Renders a single stock.
  """
  def show(%{stock: stock}) do
    data(stock)
  end

  def data(%Stock{} = stock) do
    %{
      name: stock.name,
      code: stock.code,
      current_price_cents: stock.current_price_cents
    }
  end
end
