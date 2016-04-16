defmodule Usic.Repo.Migrations.CreateSession do
  use Ecto.Migration

  def change do
   create table(:session) do
      add :token, :string, size: 255
      add :user_id, references(:user)
      timestamps
    end
  end
end
