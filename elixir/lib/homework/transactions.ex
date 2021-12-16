defmodule Homework.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo

  alias Homework.Transactions.Transaction
  alias Homework.Companies

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions([])
      [%Transaction{}, ...]

  """
  def list_transactions(_args) do
    Repo.all(Transaction) |> Enum.map(&cents_to_dollars/1)
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
  def get_transaction!(id), do: Repo.get!(Transaction, id) |> cents_to_dollars()

  # I created this null guard function just to pass the invalid attrs test case, but a better
  # solution is needed here. This check is necessary because the Decimal library can't handle
  # nil input, but this approach quickly gets out of hand if there are multiple properties
  # to check for nil. There must be a better way to do this.
  def create_transaction(%{amount: nil}=attrs) do
    %Transaction{}
    |> Transaction.changeset(dollars_to_cents(attrs))
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
        |> Transaction.changeset(dollars_to_cents(attrs))
        |> Repo.insert()

      case code do
        :error ->
          {code, res}
        :ok ->
          {code, res |> cents_to_dollars()}
      end
    end
  end

  def update_transaction(%Transaction{} = transaction, %{amount: nil}=attrs) do
    transaction
    |> Transaction.changeset(attrs)
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
    cmpy = Companies.get_company!(transaction.company_id)
    # Credit the original transaction amount back to the available balance, and then charge the new amount.
    # If our available balance dips below zero, abort mission.
    # NOTE: This is a starting point toward protecting against a negative balance, but it is not complete.
    # It is possible for the transaction's company id to be switched, in which case this can potentially fail.
    diff = Decimal.sub(Decimal.add(cmpy.available_credit, transaction.amount), Decimal.round(new_amount,2))

    case Decimal.compare(diff, 0) do
      :lt ->
        {:error, "could not update transaction: company has insufficient available balance"}

      _ ->
        {code, res} = transaction
        |> Transaction.changeset(dollars_to_cents(attrs))
        |> Repo.update()

        case code do
          :error ->
            {code, res}
          :ok ->
            {code, res |> cents_to_dollars()}
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

  defp cents_to_dollars(%{amount: cents}=tx) do
    case cents do
      nil ->
        tx
      _ ->
        %{tx| amount: Decimal.div(cents, 100) |> Decimal.round(2)}
    end
  end

  defp dollars_to_cents(%{amount: dollars}=query) do
    case dollars do
      nil ->
        query
      _ ->
        %{query| amount: Decimal.mult(Decimal.round(dollars,2), 100) |> Decimal.to_integer()}
    end
  end
end
