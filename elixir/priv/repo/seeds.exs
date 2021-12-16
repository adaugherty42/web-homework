# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Homework.Repo.insert!(%Homework.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Homework.Companies.Company
alias Homework.Merchants.Merchant
alias Homework.Users.User
alias Homework.Transactions.Transaction

planet_express = Homework.Repo.insert!(%Company{
  name: "Planet Express",
  credit_line: 10000
})

mom_corp = Homework.Repo.insert!(%Company{
  name: "MomCorp",
  credit_line: 500000000
})

calculon = Homework.Repo.insert!(%Merchant{
  name: "Calculon",
  description: "Has unholy acting talent"
})

robot_devil = Homework.Repo.insert!(%Merchant{
  name: "Robot Devil",
  description: "Dishing out tortures, most of which rhyme"
})

fry = Homework.Repo.insert!(%User{
  dob: "1980-01-01",
  first_name: "Phillip",
  last_name: "Fry",
  company: planet_express
})

leela = Homework.Repo.insert!(%User{
  dob: "1981-05-05",
  first_name: "Leela",
  last_name: "Turanga",
  company: planet_express
})

farnsworth = Homework.Repo.insert!(%User{
  dob: "1920-09-14",
  first_name: "Hubert",
  last_name: "Farnsworth",
  company: planet_express
})

tx1 = Homework.Repo.insert!(%Transaction{
  user: farnsworth,
  merchant: robot_devil,
  company: planet_express,
  amount: 2892,
  credit: true,
  description: "Finglonger"
})

tx2 = Homework.Repo.insert!(%Transaction{
  user: fry,
  merchant: calculon,
  company: planet_express,
  amount: 750,
  debit: true,
  description: "Pizza Delivered"
})
