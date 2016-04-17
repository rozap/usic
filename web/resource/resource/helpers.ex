defmodule Usic.Resource.Helpers do
  require Logger
  import Ecto.Query
  alias Usic.Repo
  alias Usic.Resource.Read
  alias Usic.Resource.State

  def ensure_session(state) do
    case state.socket.assigns[:session] do
      nil ->
        {:error, struct(state, error: %{"session" => "not_logged_in"})}
      _ ->
        {:ok, state}
    end
  end

  defmacro with_session(state, expr) do
    quote do
      case unquote(__MODULE__).ensure_session(unquote(state)) do
        {:error, state} -> state
        {:ok, _} -> unquote(expr[:do])
      end
    end
  end


  ## wtf why
  def format_cset_errors(errors) do
    errors
    |> Enum.map(
      fn {name, {msg, bindings}} ->
            message = Enum.reduce(bindings, msg, fn {k, v}, acc ->
              String.replace(acc, "%{#{k}}", "#{v}")
            end)
            {name, message}
         {name, value} -> {name, value}
    end)
    |> Enum.into(%{})
  end


  def slice(query, params) do
    offset = Dict.get(params, "offset", 0)
    limit = Dict.get(params, "limit", 16)

    query
    |> limit([m], ^limit)
    |> offset([m], ^offset)
    |> order_by([s], [desc: s.updated_at])
  end

  def eval_q(query) do
    try do
      {:ok, Repo.all(query)}
    rescue
      e in [Ecto.QueryError] ->
        {:error, %{query: e.message}}
    end
  end


  def enum_meta(_, {:error, reason}, state) do
    struct(state, error: reason)
  end

  def enum_meta(query, {:ok, items}, state) do
    count = query
    |> exclude(:preload)
    |> select([s], count(s.id, :distinct))
    |> Usic.Repo.one

    resp = %{}
    |> Dict.put("items", items)
    |> Dict.put("count", count)

    struct(state, resp: resp)
  end


  def filter(query, {name, value}) do
    case String.split(name, ".") do
      [name] ->
        fname = String.to_atom(name)
        query |> where([m], field(m, ^fname) == ^value)
      _ -> query
    end
  end

  def apply_filters(query, %{"where" => wheres}) do
    Enum.reduce(wheres, query, fn clause, q ->
      filter(q, clause)
    end)
  end

  def apply_filters(query, _), do: query

end