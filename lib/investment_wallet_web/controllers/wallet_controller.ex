defmodule InvestmentWalletWeb.WalletController do
  use InvestmentWalletWeb, :controller

  alias InvestmentWallet.Core.{Investment}

  action_fallback InvestmentWalletWeb.FallbackController


  def rebalance(conn, %{"wallet" => wallet_params}) do
    with {:ok, wallet} <- Investment.wallet_from_map(wallet_params),
         {:ok, updated_wallet} <- Investment.rebalance_wallet(wallet) do
      render(conn, :show, wallet: updated_wallet)
    else
      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{status: "error", message: reason})

    end
  end

end
