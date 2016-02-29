defmodule Usic.Resource.ListAny do
  import Usic.Resource.Helpers
  import Ecto.Query
  alias Usic.Resource.State

  defp list_query(model, params) do
    offset = Dict.get(params, "offset", 0)
    limit = Dict.get(params, "limit", 16)

    query = from(m in model.__struct__)
    |> limit([m], ^limit)
    |> offset([m], ^offset)
    |> order_by([m], [desc: m.updated_at])
    |> apply_filters(params)

    {:ok, query}
  end

  defp run_list_query(query, state) do
    try do
      {:ok, Usic.Repo.all(query |> select([m], m))}
    rescue
      e in [Ecto.QueryError] ->
        struct(state, error: %{query: e.message})
      e in [Postgrex.Error] ->
        struct(state, error: %{query: e.postgres.message or e.postgres.hint})
    end
  end

  def handle(model, %State{params: params} = state) do
    with {:ok, query} <- list_query(model, params),
    {:ok, models} <- run_list_query(query, state) do
      count_q = from(m in model.__struct__)
      |> apply_filters(params)
      c = Usic.Repo.one(count_q |> select([m], count(m.id)))
      
      resp = %{}
      |> Dict.put("items", models)
      |> Dict.put("count", c)
      
      struct(state, resp: resp)
    end
  end
end

defimpl Usic.Resource.List, for: Any do
  defdelegate handle(model, state), to: Usic.Resource.ListAny
end
