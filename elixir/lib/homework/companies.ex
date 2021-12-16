defmodule Homework.Companies do
    @moduledoc """
  The Companies context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo
  alias Homework.Companies.Company

  def list_companies(_args) do
    Repo.all(from c in Company, preload: [:transactions]) |> Enum.map(&cents_to_dollars/1) |> Enum.map(&calculate_available_credit/1)
  end

  @doc """
    Retrieves a single company.

    Raises `Ecto.NoResultsError` if the Company does not exist.
  """
  def get_company!(id) do
    Repo.get!(Company, id) |> Repo.preload([:transactions]) |> cents_to_dollars() |> calculate_available_credit()
  end

  @doc """
    Creates a company.
  """
  def create_company(attrs) do
    {code, res} = %Company{}
    |> Company.changeset(dollars_to_cents(attrs))
    |> Repo.insert()

    case code do
      :error ->
        {code, res}
      :ok ->
        {code, res |> Repo.preload([:transactions]) |> cents_to_dollars() |> calculate_available_credit()}
    end
  end

  @doc """
    Updates a company.
  """
  def update_company(%Company{} = company, attrs) do
    {code, res} = company
    |> Company.changeset(dollars_to_cents(attrs))
    |> Repo.update()

    case code do
      :error ->
        {code,res}

      :ok ->
        {code, res |> Repo.preload([:transactions]) |> cents_to_dollars() |> calculate_available_credit()}
    end
  end

  @doc """
    Deletes a company.
  """
  def delete_company(%Company{} = company) do
    Repo.delete(company)
  end

  defp cents_to_dollars(%{credit_line: cents}=company) do
    %{company| credit_line: Decimal.div(cents, 100) |> Decimal.round(2)}
  end

  defp dollars_to_cents(%{credit_line: dollars}=query) do
    %{query| credit_line: Decimal.mult(Decimal.round(dollars,2), 100) |> Decimal.to_integer()}
  end

  # I gravitated toward a normalized database and ended up with this suboptimal approach. We pull
  # all transactions associated with a company, sum them, and subtract that total from the base
  # credit line. In retrospect, this should probably be refactored to use a denormalized approach
  # where we just store available credit as a field in the companies table, and update it while
  # working with a transaction.
  defp calculate_available_credit(%{credit_line: amt}=company) do
    txs_sum = company.transactions |> Enum.map(fn(tx) -> tx.amount end) |> Enum.sum()
    # Credit line is already a decimal at this point
    diff = Decimal.sub(amt, Decimal.div(txs_sum, 100) |> Decimal.round(2))
    %{company| available_credit: diff}
  end
end
