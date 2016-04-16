defmodule Usic.Repo.Migrations.AddSongFields do
  use Ecto.Migration

  def change do
    alter table(:song) do
      add :uid, :string, size: 64
      add :location, :text
      add :state, :map
    end
  end
end
