defmodule Homework.Companies do
    @moduledoc """
  The Companies context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo
  alias Homework.Companies.Company
  alias Homework.Util.Transforms

  def list_companies(_args) do
    Repo.all(from c in Company, preload: [:transactions])
    |> Enum.map(&process_company/1)
  end

  @doc """
    Retrieves a single company.

    Raises `Ecto.NoResultsError` if the Company does not exist.
  """
  def get_company!(id) do
    Repo.get!(Company, id)
    |> Repo.preload([:transactions])
    |> process_company()
  end

  @doc """
    Creates a company.
  """
  def create_company(attrs) do
    {code, res} = %Company{}
    |> Company.changeset(%{attrs| credit_line: Transforms.dollars_to_cents(attrs.credit_line)})
    |> Repo.insert()

    case code do
      :error ->
        {code, res}
      :ok ->
        {code, res
              |> Repo.preload([:transactions])
              |> process_company()}
    end
  end

  @doc """
    Updates a company.
  """
  def update_company(%Company{} = company, attrs) do
    {code, res} = company
    |> Company.changeset(%{attrs| credit_line: Transforms.dollars_to_cents(attrs.credit_line)})
    |> Repo.update()

    case code do
      :error ->
        {code,res}

      :ok ->
        {code, res
              |> Repo.preload([:transactions])
              |> process_company()}
    end
  end

  @doc """
    Deletes a company.
  """
  def delete_company(%Company{} = company) do
    Repo.delete(company)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking company changes.

  ## Examples

      iex> change_company(company)
      %Ecto.Changeset{data: %Company{}}

  """
  def change_company(%Company{} = company, attrs \\ %{}) do
    Company.changeset(company, attrs)
  end

  defp process_company(company) do
    company
    |> (fn(c) -> %{c| transactions: Enum.map(c.transactions, fn(t) -> %{t| amount: Transforms.cents_to_dollars(t.amount)} end)} end).()
    |> (fn(c) -> %{c| credit_line: Transforms.cents_to_dollars(c.credit_line)} end).()
    |> calculate_available_credit()
  end

  # I gravitated toward a normalized database and ended up with this suboptimal approach. We pull
  # all transactions associated with a company, sum them, and subtract that total from the base
  # credit line. In retrospect, this should probably be refactored to use a denormalized approach
  # where we just store available credit as a field in the companies table, and update it while
  # working with a transaction.
  defp calculate_available_credit(%{credit_line: amt}=company) do
    txs_sum = Enum.reduce(company.transactions, Decimal.from_float(0.0), fn(t, curr) -> Decimal.add(t.amount, curr) end)
    # Credit line is already a decimal at this point
    diff = Decimal.sub(amt, txs_sum)
    %{company| available_credit: diff}
  end
end
