defmodule InvestmentWallet.Manager.ManagerApiTokenTest do
  use ExUnit.Case
  alias InvestmentWallet.Manager.ManagerApiToken
  alias InvestmentWallet.Core.ApiToken

  setup do
    :ok
  end

  test "generates a new API token with a valid key hash" do
    api_token = ManagerApiToken.generate_api_token()
    assert %ApiToken{key_hash: key_hash} = api_token
    assert is_binary(key_hash)
    assert String.length(key_hash) > 0
  end
end
