defmodule Usic.Util do
  def to_atom_map(m) do
    m
    |> Enum.map(fn
      {key, val} when is_atom(key) -> {key, val}
      {key, val} -> {String.to_atom(key), val}
    end)
    |> Enum.into(%{})
  end
end