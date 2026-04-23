defmodule InvestmentWallet.Repo do
  use Ecto.Repo,
    otp_app: :investment_wallet,
    adapter: Ecto.Adapters.Postgres
end
