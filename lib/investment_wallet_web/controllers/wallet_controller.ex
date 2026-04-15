defmodule InvestmentWalletWeb.WalletController do
  use InvestmentWalletWeb, :controller

  alias InvestmentWallet.Core.{Investment}

  action_fallback InvestmentWalletWeb.FallbackController


  def rebalance(conn, %{"wallet" => wallet_params}) do
    with {:ok, wallet} <- Investment.wallet_from_map(wallet_params),
         {:ok, updated_wallet} <- Investment.rebalance_wallet(wallet) do
      render(conn, :show, wallet: updated_wallet)
      # json(conn, %{status: "success", data: updated_wallet})
    else
      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{status: "error", message: reason})
        # conn
        # |> put_status(:not_found)
        # |> put_view(html: InvestmentWalletWeb.ErrorHTML, json: InvestmentWalletWeb.ErrorJSON)
        # |> render(:"404")
    end
  end

end
