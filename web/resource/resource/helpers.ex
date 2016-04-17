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
    |> order_by([m], [desc: m.updated_at])
  end


  def as_list_result_for(query, model, %State{params: params} = state, counter) do
    query_result = try do
      {:ok, Repo.all(query)}
    rescue
      e in [Ecto.QueryError] ->
        {:error, %{query: e.message}}
    end

    case query_result do
      {:ok, models} ->
        c = counter
        |> exclude(:preload)
        |> select([s], count(s.id))
        |> Usic.Repo.one

        resp = %{}
        |> Dict.put("items", models)
        |> Dict.put("count", c)

        struct(state, resp: resp)
      {:error, reason} -> struct(state, error: reason)
    end
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




  ##
  # Read and List should be able to send a where query
  # Read will just ensure this returns one thing
  #

  def as_single_result_for(query, model, params, state) do
    [id_name] = model.__struct__.__schema__(:primary_key)
    case Map.get(params, Atom.to_string(id_name)) do
      nil ->
        struct(state, error: %{id: :not_found})
      id ->
        results = query
        |> where([m], m.id == ^id)
        |> select([m], m)
        |> Usic.Repo.one

        case results do
          nil -> struct(state, error: %{id: :not_found})
          instance -> struct(state, resp: instance)
        end
    end
  end

  def create(model, params, socket) do
    session = Map.get(socket.assigns, :session, nil)
    cset = model.__struct__.changeset(model, params, session: session)
    Logger.info("Create #{inspect model} :: #{inspect params}")

    case Usic.Repo.insert(cset) do
      {:error, reason} ->
        {:error, {reason, socket}}
      {:ok, inserted} ->
        Read.read(model, %{"id" => inserted.id}, socket)
    end
  end


  def read(model, params, socket) do
    from(m in model.__struct__)
    |> as_single_result_for(model, params, socket)
  end


end