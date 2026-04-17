defmodule InvestmentWallet.Core.Stock do
  @moduledoc """
  Represents a tradable asset.

  `current_price_cents` stores the last known price in cents.
  In this project, prices are loaded from an in-memory list (see `Investment.load_stocks/0`).
  """

  @typedoc "Stock struct type."
  @type t :: %{
    name: String.t(),
    code: String.t(),
    current_price_cents: integer()
  }

  defstruct name: "", code: "", current_price_cents: 0
end
