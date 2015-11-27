defmodule Usic.Resource do
  require Logger
  import Ecto.Query
  ## wtf why
  defp format_cset_errors(errors) do
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


  def create(model, params, socket) do
    session = Map.get(socket.assigns, :session, nil)
    cset = model.changeset(struct(model), params, session: session)

    Logger.info("Create #{inspect model} :: #{inspect params}")

    if cset.valid? do
      case Usic.Repo.insert(cset) do
        {:error, attempt} ->
          {:error, {format_cset_errors(attempt.errors), socket}}
        {:ok, inserted} ->
          {:ok, {inserted, socket}}
      end
    else
      {:error, {format_cset_errors(cset.errors), socket}}
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

      query = from(m in model)
      |> limit([m], ^limit)
      |> offset([m], ^offset)
      |> apply_filters(params)

      {:ok, Usic.Repo.all(query |> select([m], m))}
    rescue
      e in [Ecto.QueryError] ->
        {:error, %{query: e.message}}
    end
  end

  def list(model, params, socket) do
    user = Map.get(socket.assigns, :user, nil)

    case run_list(model, params) do
      {:ok, models} ->
        c = Usic.Repo.one(from m in model, select: count(m.id))
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

  def read(model, params, socket) do
    user = Map.get(socket.assigns, :user, nil)
    [id_name] = model.__schema__(:primary_key)
    case Map.get(params, Atom.to_string(id_name)) do
      nil ->
        {:error, {%{"id" => :not_found}, socket}}
      id ->
        model = Usic.repo.one(from m in model, where: m.id == ^id, select: m)
        {:ok, {model, socket}}
    end
  end
end