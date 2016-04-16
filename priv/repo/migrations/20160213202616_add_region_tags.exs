defmodule Usic.Repo.Migrations.AddRegionTags do
  use Ecto.Migration

  def change do
    alter table(:region) do
      add :meta, :map
    end
  end
end
