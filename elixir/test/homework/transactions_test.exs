defmodule Homework.TransactionsTest do
  use Homework.DataCase

  alias Ecto.UUID
  alias Homework.Merchants
  alias Homework.Transactions
  alias Homework.Users
  alias Homework.Companies

  describe "transactions" do
    alias Homework.Transactions.Transaction

    setup do
      {:ok, company1} =
        Companies.create_company(%{name: "some company", credit_line: Decimal.from_float(500.00)})

      {:ok, company2} =
        Companies.create_company(%{name: "some other company", credit_line: Decimal.from_float(40.00)})

      {:ok, merchant1} =
        Merchants.create_merchant(%{description: "some description", name: "some name"})

      {:ok, merchant2} =
        Merchants.create_merchant(%{
          description: "some updated description",
          name: "some updated name"
        })

      {:ok, user1} =
        Users.create_user(%{
          dob: "some dob",
          first_name: "some first_name",
          last_name: "some last_name",
          company_id: company1.id
        })

      {:ok, user2} =
        Users.create_user(%{
          dob: "some updated dob",
          first_name: "some updated first_name",
          last_name: "some updated last_name",
          company_id: company1.id
        })

      valid_attrs = %{
        amount: Decimal.from_float(42.00),
        credit: true,
        debit: true,
        description: "some description",
        merchant_id: merchant1.id,
        user_id: user1.id,
        company_id: company1.id
      }

      update_attrs = %{
        amount: Decimal.from_float(43.00),
        credit: false,
        debit: false,
        description: "some updated description",
        merchant_id: merchant2.id,
        user_id: user2.id,
        company_id: company1.id
      }

      insufficient_funds_attrs = %{
        amount: Decimal.from_float(550.00),
        credit: true,
        debit: true,
        description: "some description",
        merchant_id: merchant1.id,
        user_id: user1.id,
        company_id: company1.id
      }

      insufficient_funds_update_attrs = %{
        amount: Decimal.from_float(43.00),
        credit: false,
        debit: false,
        description: "some updated description",
        merchant_id: merchant2.id,
        user_id: user2.id,
        company_id: company2.id
      }

      invalid_attrs = %{
        amount: nil,
        credit: nil,
        debit: nil,
        description: nil,
        merchant_id: nil,
        user_id: nil,
        company_id: nil
      }

      {:ok,
       %{
         valid_attrs: valid_attrs,
         update_attrs: update_attrs,
         insufficient_funds_attrs: insufficient_funds_attrs,
         insufficient_funds_update_attrs: insufficient_funds_update_attrs,
         invalid_attrs: invalid_attrs,
         merchant1: merchant1,
         merchant2: merchant2,
         user1: user1,
         user2: user2,
         company1: company1
       }}
    end

    def transaction_fixture(valid_attrs, attrs \\ %{}) do
      {:ok, transaction} =
        attrs
        |> Enum.into(valid_attrs)
        |> Transactions.create_transaction()

      transaction
    end

    test "list_transactions/1 returns all transactions", %{valid_attrs: valid_attrs} do
      transaction = transaction_fixture(valid_attrs)
      assert Transactions.list_transactions([]) == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id", %{valid_attrs: valid_attrs} do
      transaction = transaction_fixture(valid_attrs)
      assert Transactions.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction", %{
      valid_attrs: valid_attrs,
      merchant1: merchant1,
      user1: user1,
      company1: company1
    } do
      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert Decimal.equal?(transaction.amount, Decimal.from_float(42.00)) == true
      assert transaction.credit == true
      assert transaction.debit == true
      assert transaction.description == "some description"
      assert transaction.merchant_id == merchant1.id
      assert transaction.user_id == user1.id
      assert transaction.company_id == company1.id
    end

    test "create_transaction/1 with invalid data returns error changeset", %{
      invalid_attrs: invalid_attrs
    } do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(invalid_attrs)
    end

    test "create_transaction/1 fails when the company does not have sufficient credit availabie", %{
      insufficient_funds_attrs: insufficient_funds_attrs
    } do
      assert {:error, "could not create transaction: company has insufficient available balance"} =
              Transactions.create_transaction(insufficient_funds_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction", %{
      valid_attrs: valid_attrs,
      update_attrs: update_attrs,
      merchant2: merchant2,
      user2: user2,
      company1: company1
    } do
      transaction = transaction_fixture(valid_attrs)

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, update_attrs)

      assert Decimal.equal?(transaction.amount, Decimal.from_float(43.00)) == true
      assert transaction.credit == false
      assert transaction.debit == false
      assert transaction.description == "some updated description"
      assert transaction.merchant_id == merchant2.id
      assert transaction.user_id == user2.id
      assert transaction.company_id == company1.id
    end

    test "update_transaction/2 with invalid data returns error changeset", %{
      valid_attrs: valid_attrs,
      invalid_attrs: invalid_attrs
    } do
      transaction = transaction_fixture(valid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               Transactions.update_transaction(transaction, invalid_attrs)

      assert transaction == Transactions.get_transaction!(transaction.id)
    end

    test "update_transaction/2 fails when the amount is changed to exceed the company's available credit", %{
      valid_attrs: valid_attrs,
      insufficient_funds_attrs: insufficient_funds_attrs
    } do
      transaction = transaction_fixture(valid_attrs)
      assert {:error, "could not update transaction: company has insufficient available balance"} =
              Transactions.update_transaction(transaction, insufficient_funds_attrs)
    end

    test "update_transaction/2 fails when the company is switched to a company with insufficient credit", %{
      valid_attrs: valid_attrs,
      insufficient_funds_update_attrs: insufficient_funds_update_attrs
    } do
      transaction = transaction_fixture(valid_attrs)
      assert {:error, "could not update transaction: company has insufficient available balance"} =
              Transactions.update_transaction(transaction, insufficient_funds_update_attrs)
    end

    test "delete_transaction/1 deletes the transaction", %{valid_attrs: valid_attrs} do
      transaction = transaction_fixture(valid_attrs)
      assert {:ok, %Transaction{}} = Transactions.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset", %{valid_attrs: valid_attrs} do
      transaction = transaction_fixture(valid_attrs)
      assert %Ecto.Changeset{} = Transactions.change_transaction(transaction)
    end
  end
end
