defmodule Usic.Repo.Migrations.AddSong do
  use Ecto.Migration

  def change do
   create table(:song) do
      add :name, :string, size: 255
      add :url, :text
      add :user_id, references(:user)
      timestamps
    end
  end
end
