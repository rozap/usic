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
    Logger.info("Create #{inspect model} :: #{inspect params}")

    user = Map.get(socket.assigns, :user, nil)
    cset = model.changeset(struct(model), params, user: user)

    if cset.valid? do
      case Usic.Repo.insert(cset) do
        {:error, attempt} ->
          {{:error, format_cset_errors(attempt.errors)}, socket}
        {:ok, inserted} ->
          {{:ok, inserted}, socket}
      end
    else
      {{:error, format_cset_errors(cset.errors)}, socket}
    end
  end

  def list(model, params, socket) do
    user = Map.get(socket.assigns, :user, nil)

    %{"offset" => offset, "limit" => limit} = params

    models = Usic.Repo.all(from m in model,
      limit: ^limit,
      offset: ^offset,
      select: m)

    resp = Dict.put(%{}, "items", models)
    {{:ok, resp}, socket}
  end
end