defmodule InvestmentWallet.Core.ApiToken do
  @moduledoc """
  Represents an API token.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "api_tokens" do
    field :key_hash, :string
    field :request_per_hour, :integer, default: 100
    field :is_active, :boolean, default: true
    timestamps()
  end

  def changeset(api_token, attrs) do
    api_token
    |> cast(attrs, [:key_hash, :request_per_hour, :is_active])
    |> validate_required([:key_hash, :request_per_hour, :is_active])
  end
end
