defmodule InvestmentWalletWeb.RebalanceController do
  use InvestmentWalletWeb, :controller
  # import Phoenix.Controller

  alias InvestmentWallet.Core.{Investment}


  def rebalance(conn, %{"wallet" => wallet_params}) do
    with {:ok, wallet} <- {:ok, Investment.wallet_from_map(wallet_params)},
         {:ok, updated_wallet} <- Investment.rebalance_wallet(wallet) do
      json(conn, %{status: "success", data: updated_wallet})
    else
      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{status: "error", message: reason})
    end
  end

end
