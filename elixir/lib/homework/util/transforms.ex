defmodule Homework.Util.Transforms do
  @doc """
    Transform an integer number of cents into a decimal amount of dollars.
  """
  def cents_to_dollars(cents) do
    case cents do
      nil ->
        cents
      _ ->
        Decimal.div(cents, 100) |> Decimal.round(2)
    end
  end

  @doc """
    Transform a decimal amount of dollars into an integer number of cents.
  """
  def dollars_to_cents(dollars) do
    case dollars do
      nil ->
        dollars
      _ ->
        Decimal.mult(Decimal.round(dollars,2), 100) |> Decimal.to_integer()
    end
  end
end
