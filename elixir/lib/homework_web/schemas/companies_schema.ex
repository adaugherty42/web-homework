defmodule HomeworkWeb.Schemas.CompaniesSchema do
  @moduledoc """
  Defines the graphql schema for companies.
  """
  use Absinthe.Schema.Notation

  alias HomeworkWeb.Resolvers.CompaniesResolver

  object :company do
    field(:id, non_null(:id))
    field(:name, :string)
    field(:credit_line, :decimal)
    field(:available_credit, :decimal)
    field(:transactions, list_of(:transaction))
    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)
  end

  object :companies_paged do
    field(:total_rows, :integer)
    field(:entries, list_of(:company))
  end

  object :company_mutations do
    @desc "Create a new company"
    field :create_company, :company do
      arg(:name, non_null(:string))
      arg(:credit_line, non_null(:decimal))

      resolve(&CompaniesResolver.create_company/3)
    end

    @desc "Update a company"
    field :update_company, :company do
      arg(:name, non_null(:string))
      arg(:credit_line, non_null(:decimal))

      resolve(&CompaniesResolver.update_company/3)
    end

    @desc "Delete a company"
    field :delete_company, :company do
      arg(:id, non_null(:id))

      resolve(&CompaniesResolver.delete_company/3)
    end
  end

end
