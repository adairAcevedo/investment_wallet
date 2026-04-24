import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/investment_wallet start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :investment_wallet, InvestmentWalletWeb.Endpoint, server: true
end
string_envs = String.split(System.get_env("ENVIROMENTS_CONFIG", "|||"),"|")
port = Enum.at(string_envs, 1) || System.get_env("PORT","4000")

config :investment_wallet, InvestmentWalletWeb.Endpoint,
  http: [port: String.to_integer(port)]

if config_env() == :prod do
  pool_size = String.to_integer(Enum.at(string_envs, 3) || "10")
  db_user_name = Enum.at(string_envs, 4)
  db_password = Enum.at(string_envs, 5)
  db_hostname = Enum.at(string_envs, 6)
  db_database = Enum.at(string_envs, 7)
  db_maybe_ipv6 = Enum.at(string_envs, 8)

  redis_host = Enum.at(string_envs, 9)
  redis_port = Enum.at(string_envs, 10)
  redis_password = Enum.at(string_envs, 11)
  db_url = "ecto://#{db_user_name}:#{db_password}@#{db_hostname}/#{db_database}"

  database_url = if(String.length(db_url) > 11, do: db_url, else:
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """)

  maybe_ipv6 = if db_maybe_ipv6 in ~w(true 1), do: [:inet6], else: []

  config :api, Api.Repo,
    ssl: true,
    url: database_url,
    pool_size: pool_size,
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.

  phx_host = Enum.at(string_envs,0)
  secret_key_base_env = Enum.at(string_envs,2)

  secret_key_base =
    secret_key_base_env ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  # host = System.get_env("PHX_HOST") || "localhost"
  host = phx_host || "example.com"

  config :investment_wallet, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :investment_wallet, InvestmentWalletWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0}
    ],
    secret_key_base: secret_key_base

  config :investment_wallet, :redis,
    host: redis_host, #System.get_env("REDIS_HOST") || "localhost",
    password: redis_password,
    port: String.to_integer(redis_port || "6379") #String.to_integer(System.get_env("REDIS_PORT") || "6379")
  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :investment_wallet, InvestmentWalletWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :investment_wallet, InvestmentWalletWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Here is an example configuration for Mailgun:
  #
  #     config :investment_wallet, InvestmentWallet.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # Most non-SMTP adapters require an API client. Swoosh supports Req, Hackney,
  # and Finch out-of-the-box. This configuration is typically done at
  # compile-time in your config/prod.exs:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Req
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
