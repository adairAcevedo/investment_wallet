defmodule InvestmentWallet.Repo.Migrations.CreateApiTokens do
  use Ecto.Migration

  def up do
    create table(:api_tokens, primary_key: false ) do
      add :id, :binary_id, primary_key: true
      add :key_hash, :string, null: false
      add :request_per_hour, :integer, default: 100, null: false
      add :is_active, :boolean, default: true, null: false
      timestamps()
    end

    create unique_index(:api_tokens, [:key_hash])
  end

  def down do
    drop table(:api_tokens)
  end
end
