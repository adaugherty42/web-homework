defmodule Homework.Merchants do
  @moduledoc """
  The Merchants context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo

  alias Homework.Merchants.Merchant
  alias Homework.Util.Paginator

  @doc """
  Returns the list of merchants.

  ## Examples

      iex> list_merchants([])
      [%Merchant{}, ...]

  """
  def list_merchants(params) do
    base_query()
    |> build_query(params)
    |> Repo.all()
  end

  def list_paged_merchants(params) do
    {:ok, res, page_info} =
    base_query()
    |> build_query(params)
    |> Paginator.page(params)

    Paginator.finalize(res, page_info)
  end

  @doc """
  Gets a single merchant.

  Raises `Ecto.NoResultsError` if the Merchant does not exist.

  ## Examples

      iex> get_merchant!(123)
      %Merchant{}

      iex> get_merchant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_merchant!(id), do: Repo.get!(Merchant, id)

  @doc """
  Creates a merchant.

  ## Examples

      iex> create_merchant(%{field: value})
      {:ok, %Merchant{}}

      iex> create_merchant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_merchant(attrs \\ %{}) do
    %Merchant{}
    |> Merchant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a merchant.

  ## Examples

      iex> update_merchant(merchant, %{field: new_value})
      {:ok, %Merchant{}}

      iex> update_merchant(merchant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_merchant(%Merchant{} = merchant, attrs) do
    merchant
    |> Merchant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a merchant.

  ## Examples

      iex> delete_merchant(merchant)
      {:ok, %Merchant{}}

      iex> delete_merchant(merchant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_merchant(%Merchant{} = merchant) do
    Repo.delete(merchant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking merchant changes.

  ## Examples

      iex> change_merchant(merchant)
      %Ecto.Changeset{data: %Merchant{}}

  """
  def change_merchant(%Merchant{} = merchant, attrs \\ %{}) do
    Merchant.changeset(merchant, attrs)
  end

  defp base_query do
    from m in Merchant
  end

  defp build_query(query, criteria) do
    Enum.reduce(criteria, query, &compose_query/2)
  end

  defp compose_query({:name, name}, query) do
    where(query, [m], ilike(m.name, ^"%#{name}%"))
  end

  defp compose_query(_bad_param, query) do
    query
  end
end
