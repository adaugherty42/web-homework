defmodule HomeworkWeb.Schema do
  @moduledoc """
  Defines the graphql schema for this project.
  """
  use Absinthe.Schema

  alias HomeworkWeb.Resolvers.MerchantsResolver
  alias HomeworkWeb.Resolvers.TransactionsResolver
  alias HomeworkWeb.Resolvers.UsersResolver
  alias HomeworkWeb.Resolvers.CompaniesResolver
  import_types(HomeworkWeb.Schemas.Types)

  query do
    @desc "Get all Transactions"
    field(:transactions, list_of(:transaction)) do
      arg(:min_amount, :decimal)
      arg(:max_amount, :decimal)
      resolve(&TransactionsResolver.transactions/3)
    end

    @desc "Get paged Transactions"
    field(:transactions_paged, :transactions_paged) do
      arg(:min_amount, :decimal)
      arg(:max_amount, :decimal)
      arg(:page, non_null(:integer))
      arg(:page_size, non_null(:integer))
      resolve(&TransactionsResolver.transactions_paged/3)
    end

    @desc "Get all Users"
    field(:users, list_of(:user)) do
      arg(:first_name, :string)
      arg(:last_name, :string)
      resolve(&UsersResolver.users/3)
    end

    @desc "Get paged Users"
    field(:users_paged, :users_paged) do
      arg(:first_name, :string)
      arg(:last_name, :string)
      arg(:page, non_null(:integer))
      arg(:page_size, non_null(:integer))
      resolve(&UsersResolver.users_paged/3)
    end

    @desc "Get all Merchants"
    field(:merchants, list_of(:merchant)) do
      arg(:name, :string)
      resolve(&MerchantsResolver.merchants/3)
    end

    @desc "Get paged Merchants"
    field(:merchants_paged, :merchants_paged) do
      arg(:name, :string)
      arg(:page, non_null(:integer))
      arg(:page_size, non_null(:integer))
      resolve(&MerchantsResolver.merchants_paged/3)
    end

    @desc "Get all Companies"
    field(:companies, list_of(:company)) do
      arg(:name, :string)
      resolve(&CompaniesResolver.companies/3)
    end

    @desc "Get paged Companies"
    field(:companies_paged, :companies_paged) do
      arg(:name, :string)
      arg(:page, non_null(:integer))
      arg(:page_size, non_null(:integer))
      resolve(&CompaniesResolver.companies_paged/3)
    end
  end

  mutation do
    import_fields(:transaction_mutations)
    import_fields(:user_mutations)
    import_fields(:merchant_mutations)
    import_fields(:company_mutations)
  end
end
