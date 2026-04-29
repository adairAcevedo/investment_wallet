defmodule InvestmentWallet.Manager.ManagerApiToken do
  @moduledoc """
  Provides repository functions for managing API tokens.
  """

  alias InvestmentWallet.Core.ApiToken
  alias InvestmentWallet.Repo

  def generate_api_token() do
    random_string = :crypto.strong_rand_bytes(100) |> Base.encode64()
    key_hash = :crypto.hash(:sha256, random_string) |> Base.encode64()

    %ApiToken{key_hash: key_hash}
    |> ApiToken.changeset(%{})
    |> Repo.insert!()
  end

  def get_api_token(key_hash) do
    Repo.get(ApiToken, key_hash)
  end

  def update_api_token(api_token, attrs) do
    api_token
    |> ApiToken.changeset(attrs)
    |> Repo.update!()
  end

  def delete_api_token(api_token) do
    Repo.delete!(api_token)
  end
end
