defmodule Usic.TestHelpers do
  def media_loc do
    Usic.Endpoint.config(:static)
    |> Path.join("media")
  end

  def clear_media do
    media_loc
    |> File.ls!
    |> Enum.each(fn media ->
      media_loc
      |> Path.join(media)
      |> File.rm!
    end)
  end
end

Code.load_file("dry_executor.exs", "./test/helpers")
Code.load_file("dry_metaserver.exs", "./test/helpers")

ExUnit.start

Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]
Ecto.Adapters.SQL.begin_test_transaction(Usic.Repo)

