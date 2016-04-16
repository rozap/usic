defmodule Usic.Repo.Migrations.AddDisplayName do
  use Ecto.Migration

  def change do
    alter table(:user) do
      add :display_name, :text
    end
  end
end
