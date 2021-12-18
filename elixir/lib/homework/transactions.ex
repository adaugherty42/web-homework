defmodule Homework.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo

  alias Homework.Transactions.Transaction
  alias Homework.Companies
  alias Homework.Util.Transforms
  alias Homework.Util.Paginator

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions([])
      [%Transaction{}, ...]

  """
  def list_transactions(params) do
    base_query()
    |> build_query(params)
    |> Repo.all
    |> Enum.map(fn(t) -> %{t| amount: Transforms.cents_to_dollars(t.amount)} end)
  end

  def list_transactions_paged(params) do
    {:ok, results, page_info} =
      base_query()
      |> Paginator.page(params)

    results = Enum.map(results, fn(t) -> %{t| amount: Transforms.cents_to_dollars(t.amount)} end)
    Paginator.finalize(results, page_info)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id) do
    Repo.get!(Transaction, id)
    |> (fn(t) -> %{t| amount: Transforms.cents_to_dollars(t.amount)} end).()
  end

  # I created this null guard function just to pass the invalid attrs test case, but a better
  # solution is needed here. This check is necessary because the Decimal library can't handle
  # nil input, but this approach quickly gets out of hand if there are multiple properties
  # to check for nil. There must be a better way to do this.
  def create_transaction(%{amount: nil}=attrs) do
    %Transaction{}
    |> Transaction.changeset(%{attrs| amount: Transforms.dollars_to_cents(attrs.amount)})
    |> Repo.insert()
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(%{company_id: company_id, amount: amount}=attrs) do
    cmpy = Companies.get_company!(company_id)
    diff = Decimal.sub(cmpy.available_credit, Decimal.round(amount,2))

    # If we don't have enough available balance, the transaction cannot be posted
    case Decimal.compare(diff, 0) do
      :lt ->
        {:error, "could not create transaction: company has insufficient available balance"}

      _ ->
        {code, res} = %Transaction{}
        |> Transaction.changeset(%{attrs| amount: Transforms.dollars_to_cents(attrs.amount)})
        |> Repo.insert()

      case code do
        :error ->
          {code, res}
        :ok ->
          {code, res |> (fn(t) -> %{t| amount: Transforms.cents_to_dollars(t.amount)} end).()}
      end
    end
  end

  def update_transaction(%Transaction{} = transaction, %{amount: nil}=attrs) do
    transaction
    |> Transaction.changeset(%{attrs| amount: Transforms.dollars_to_cents(attrs.amount)})
    |> Repo.update()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, %{amount: new_amount}=attrs) do

    # Credit the original transaction amount back to the available balance, and then charge the new amount.
    # If our available balance dips below zero, abort mission.
    # However, we must also guard against the case when the transaction's company id is switched, in which case
    # we simply want to deduct the transaction amount from this new company's available credit
    diff =  if transaction.company_id == attrs.company_id do
              cmpy = Companies.get_company!(transaction.company_id)
              Decimal.sub(Decimal.add(cmpy.available_credit, transaction.amount), Decimal.round(new_amount,2))
            else
              new_cmpy = Companies.get_company!(attrs.company_id)
              Decimal.sub(new_cmpy.available_credit, Decimal.round(new_amount,2))
            end

    case Decimal.compare(diff, 0) do
      :lt ->
        {:error, "could not update transaction: company has insufficient available balance"}

      _ ->
        {code, res} = transaction
        |> Transaction.changeset(%{attrs| amount: Transforms.dollars_to_cents(attrs.amount)})
        |> Repo.update()

        case code do
          :error ->
            {code, res}
          :ok ->
            {code, res |> (fn(t) -> %{t| amount: Transforms.cents_to_dollars(t.amount)} end).()}
      end
    end
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  defp base_query do
    from t in Transaction
  end

  defp build_query(query, criteria) do
    Enum.reduce(criteria, query, &compose_query/2)
  end

  defp compose_query({:min_amount, min_amount}, query) do
    amt = Transforms.dollars_to_cents(min_amount)
    where(query, [t], ^amt <= t.amount)
  end

  defp compose_query({:max_amount, max_amount}, query) do
    amt = Transforms.dollars_to_cents(max_amount)
    where(query, [t], ^amt >= t.amount)
  end

  defp compose_query(_bad_param, query) do
    query
  end
end
