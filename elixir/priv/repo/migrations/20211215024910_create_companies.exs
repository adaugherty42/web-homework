defmodule Homework.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false)
      add(:credit_line, :integer, null: false)

      timestamps()
    end

    # These may be better in their own migration? Not sure on ideal granularity per migration
    alter table(:users) do
      add(:company_id, references(:companies, type: :uuid))
    end

    alter table(:transactions) do
      add(:company_id, references(:companies, type: :uuid))
    end
  end
end
