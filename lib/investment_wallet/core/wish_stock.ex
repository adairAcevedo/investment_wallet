defmodule InvestmentWallet.Core.WishStock do
  @moduledoc """
  Represents a target allocation entry.

  `percentaje` is an integer percentage (0..100).
  A valid wallet must have wish stocks whose percentages sum to exactly 100.

  `stock` is populated during rebalance using the price database.
  """
  alias InvestmentWallet.Core.Stock

  @typedoc "WishStock struct type."

  @type t :: %{
    percentaje: non_neg_integer(),
    code: String.t(),
    stock: %Stock{}
  }

  defstruct percentaje: 0, code: "", stock: %Stock{}
end
