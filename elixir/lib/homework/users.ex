defmodule Homework.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo

  alias Homework.Users.User
  alias Homework.Util.Paginator

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users([])
      [%User{}, ...]

  """
  def list_users(params) do
    base_query()
    |> build_query(params)
    |> Repo.all()
  end

  @doc """
    Returns a paginated list of users.
  """
  def list_users_paged(params) do
    {:ok, results, page_info} =
      base_query()
      |> build_query(params)
      |> Paginator.page(params)

      Paginator.finalize(results, page_info)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  # Originally I just shoehorned the possible filter parameters into the query and provided default values,
  # but this solution feels like awesome, idiomatic Elixir.
  # From: https://elixirschool.com/blog/ecto-query-composition/
  defp base_query do
    from u in User
  end

  defp build_query(query, criteria) do
    Enum.reduce(criteria, query, &compose_query/2)
  end

  defp compose_query({:first_name, first_name}, query) do
    where(query, [u], ilike(u.first_name, ^"%#{first_name}%"))
  end

  defp compose_query({:last_name, last_name}, query) do
    where(query, [u], ilike(u.last_name, ^"%#{last_name}%"))
  end

  defp compose_query(_bad_param, query) do
    query
  end
end
