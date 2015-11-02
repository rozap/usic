defmodule Usic.Model.Util do
  def sanitize(instance, whitelist) do
    Enum.map(whitelist, fn name ->
      {name, Map.get(instance, name)}
    end) |> Enum.into(%{})
  end
end