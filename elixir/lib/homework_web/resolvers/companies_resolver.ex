defmodule HomeworkWeb.Resolvers.CompaniesResolver do
  alias Homework.Companies

  @doc """
    Get a list of companies
  """
  def companies(_root, args, _info) do
    res = Companies.list_companies(args)
    {:ok, res}
  end

  def create_company(_root, args, _info) do
    case Companies.create_company(args) do
      {:ok, company} ->
        {:ok, company}

      error ->
        {:error, "could not create transaction: #{inspect(error)}"}
    end
  end
end
