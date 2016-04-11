defmodule Usic.Resource.ListAny do
  import Usic.Resource.Helpers
  import Ecto.Query
  alias Usic.Resource.State

  def query(model, %State{params: params} = state) do
    query = from(m in model.__struct__)
    |> order_by([m], [desc: m.updated_at])
    |> apply_filters(params)

    struct(state, query: query)
  end

  def evaluate(_, %State{query: query, params: params} = state) do
    offset = Dict.get(params, "offset", 0)
    limit = Dict.get(params, "limit", 16)

    try do
      query = query
      |> limit([m], ^limit)
      |> offset([m], ^offset)
      struct(state, model: Usic.Repo.all(query |> select([m], m)))
    rescue
      e in [Ecto.QueryError] ->
        struct(state, error: %{query: e.message})
      e in [Postgrex.Error] ->
        struct(state, error: %{query: e.postgres.message or e.postgres.hint})
    end
  end

  def meta(model, %State{params: params, model: models, query: query} = state) do
    count = query
    |> exclude(:order_by)
    |> select([m], count(m.id))
    |> Usic.Repo.one
    
    resp = %{}
    |> Dict.put("items", models)
    |> Dict.put("count", count)
    
    struct(state, resp: resp)
  end
end

defimpl Usic.Resource.List, for: Any do
  use Usic.Resource
  stage :query,    mod: Usic.Resource.ListAny
  stage :evaluate, mod: Usic.Resource.ListAny
  stage :meta,     mod: Usic.Resource.ListAny
end
