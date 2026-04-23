defmodule InvestmentWallet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      InvestmentWalletWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:investment_wallet, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: InvestmentWallet.PubSub},
      InvestmentWallet.Repo,
      # Start a worker by calling: InvestmentWallet.Worker.start_link(arg)
      # {InvestmentWallet.Worker, arg},
      # Start to serve requests, typically the last entry
      InvestmentWalletWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: InvestmentWallet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    InvestmentWalletWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
