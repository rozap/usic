defmodule Usic.Repo.Migrations.CreateRegion do
  use Ecto.Migration

  def change do
    create table(:region) do
      add :name,  :text
      add :start, :float
      add :end,   :float
      add :loop,  :boolean
      add :song_id, references(:song)
      timestamps
    end
  end
end
