defmodule Usic.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :email, :string, size: 64
      add :password, :string, size: 255
      timestamps
    end
    create index(:user, [:email], unique: true)
  end
end
