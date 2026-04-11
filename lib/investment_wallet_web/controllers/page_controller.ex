defmodule InvestmentWalletWeb.PageController do
  use InvestmentWalletWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
