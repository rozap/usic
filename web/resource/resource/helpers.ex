defmodule Usic.Resource.Helpers do
  require Logger
  import Ecto.Query
  alias Usic.Repo
  alias Usic.Resource.Read

  def ensure_session(socket) do
    case socket.assigns[:session] do
      nil ->
        {:error, {%{"session" => "not_logged_in"}, socket}}
      _ -> {:ok, socket}
    end
  end

  defmacro with_session(socket, expr) do
    quote do
      case unquote(__MODULE__).ensure_session(unquote(socket)) do
        {:error, _} = err -> err
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
    |> apply_filters(params)
  end


  def as_list_result_for(query, model, params, socket) do
    query_result = try do
      {:ok, Repo.all(query)}
    rescue
      e in [Ecto.QueryError] ->
        {:error, %{query: e.message}}
    end

    case query_result do
      {:ok, models} ->
        count_q = from(m in model.__struct__)
        |> apply_filters(params)
        c = Usic.Repo.one(count_q |> select([m], count(m.id)))

        resp = %{}
        |> Dict.put("items", models)
        |> Dict.put("count", c)

        {:ok, {resp, socket}}

      {:error, reason} -> {:error, {reason, socket}}
    end
  end


  def filter(query, {name, value}) do
    fname = String.to_atom(name)
    query |> where([m], field(m, ^fname) == ^value)
  end

  def apply_filters(query, %{"where" => wheres}) do
    Enum.reduce(wheres, query, fn clause, q ->
      filter(q, clause)
    end)
  end

  def apply_filters(query, _), do: query


  defp run_list(model, params) do
    try do
      offset = Dict.get(params, "offset", 0)
      limit = Dict.get(params, "limit", 16)

      query = from(m in model.__struct__)
      |> limit([m], ^limit)
      |> offset([m], ^offset)
      |> order_by([m], [desc: m.updated_at])
      |> apply_filters(params)

      {:ok, Usic.Repo.all(query |> select([m], m))}
    rescue
      e in [Ecto.QueryError] ->
        {:error, %{query: e.message}}
    end
  end

  def list(model, params, socket) do
    case run_list(model, params) do
      {:ok, models} ->
        count_q = from(m in model.__struct__)
        |> apply_filters(params)
        c = Usic.Repo.one(count_q |> select([m], count(m.id)))
        resp = %{}
        |> Dict.put("items", models)
        |> Dict.put("count", c)
        {:ok, {resp, socket}}

      {:error, reason} -> {:error, {reason, socket}}
    end
  end

  ##
  # Read and List should be able to send a where query
  # Read will just ensure this returns one thing
  #

  def as_single_result_for(query, model, params, socket) do
    [id_name] = model.__struct__.__schema__(:primary_key)
    case Map.get(params, Atom.to_string(id_name)) do
      nil ->
        {:error, {%{id: :not_found}, socket}}
      id ->
        results = query
        |> where([m], m.id == ^id)
        |> select([m], m)
        |> Usic.Repo.one

        case results do
          nil -> {:error, {%{id: :not_found}, socket}}
          m -> {:ok, {m, socket}}
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

  def update(model, params, socket) do
    case read(model, params, socket) do
      {:ok, {instance, _}} ->
        session = Map.get(socket.assigns, :session, nil)
        cset = model.__struct__.changeset(
          instance,
          params,
          session: session
        )
        case Usic.Repo.update(cset) do
          {:ok, _} ->
            Read.read(model, params, socket)
          {:error, reason} -> {:error, {reason, socket}}
        end
      err -> err
    end
  end

  def do_delete(instance, socket) do
    case Usic.Repo.delete(instance) do
      {:ok, result} -> {:ok, {result, socket}}
      {:error, reason} -> {:error, {reason, socket}}
    end
  end

  def delete(model, params, socket) do
    case read(model, params, socket) do
      {:ok, {instance, _}} -> do_delete(instance, socket)
      err -> err
    end
  end
end