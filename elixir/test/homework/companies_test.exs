defmodule Homework.CompaniesTest do
  use Homework.DataCase

  alias Ecto.UUID
  alias Homework.Companies

  describe "companies" do
    alias Homework.Companies.Company

    setup do
      valid_attrs = %{
        name: "Panucci's Pizza",
        credit_line: Decimal.from_float(5000.00)
      }

      update_attrs = %{
        name: "Not Panucci's Pizza",
        credit_line: Decimal.from_float(4500.00)
      }

      invalid_attrs = %{
        name: nil,
        credit_line: nil
      }

      {:ok,
      %{
        valid_attrs: valid_attrs,
        update_attrs: update_attrs,
        invalid_attrs: invalid_attrs,

      }}
    end

    def company_fixture(valid_attrs, attrs \\ %{}) do
      {:ok, company} =
        attrs
        |> Enum.into(valid_attrs)
        |> Companies.create_company()

      company
    end

    test "list_companies/1 returns all companies", %{valid_attrs: valid_attrs} do
      company = company_fixture(valid_attrs)
      assert Companies.list_companies([]) == [company]
    end

    test "get_company/1 returns the company with the given id", %{valid_attrs: valid_attrs} do
      company = company_fixture(valid_attrs)
      assert Companies.get_company!(company.id) == company
    end

    test "create_company/1 with valid data creates a company", %{valid_attrs: valid_attrs} do
      assert {:ok, %Company{}=company} = Companies.create_company(valid_attrs)
      assert company.name == "Panucci's Pizza"
      assert Decimal.equal?(company.credit_line, Decimal.from_float(5000.00)) == true
    end

    test "create_company/1 with invalid data returns error changeset", %{invalid_attrs: invalid_attrs} do
      assert {:error, %Ecto.Changeset{}} = Companies.create_company(invalid_attrs)
    end

    test "update_company/2 with valid data updates the company", %{valid_attrs: valid_attrs, update_attrs: update_attrs} do
      company = company_fixture(valid_attrs)
      assert {:ok, %Company{}=new_company} = Companies.update_company(company, update_attrs)
      assert new_company.name == "Not Panucci's Pizza"
      assert Decimal.equal?(new_company.credit_line, Decimal.from_float(4500.00)) == true
    end

    test "update_company/2 with invalid data returns error changeset", %{valid_attrs: valid_attrs, invalid_attrs: invalid_attrs} do
      company = company_fixture(valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Companies.update_company(company, invalid_attrs)
    end

    test "delete_company/1 delets the company", %{valid_attrs: valid_attrs} do
      company = company_fixture(valid_attrs)
      assert {:ok, %Company{}} = Companies.delete_company(company)
      assert_raise Ecto.NoResultsError, fn -> Companies.get_company!(company.id) end
    end

    test "change_company/1 returns a company changeset", %{valid_attrs: valid_attrs} do
      company = company_fixture(valid_attrs)
      assert %Ecto.Changeset{} = Companies.change_company(company)
    end
  end
end
