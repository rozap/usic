defmodule Usic.Repo do
  use Ecto.Repo, otp_app: :usic
  alias Usic.Model.Dispatcher

  def push_update(any), do: push_update(any, [])
  def push_update(%Ecto.Changeset{} = cset, opts) do
    with {:ok, model} <- update(cset, opts) do
      Dispatcher.after_update(cset)
      {:ok, model}
    end
  end

  def push_update(model, opts) do
    model
    |> Ecto.Changeset.change
    |> push_update(opts)
  end


  def push_insert(any), do: push_insert(any, [])
  def push_insert(%Ecto.Changeset{} = cset, opts) do
    Logger.info("Creating #{inspect cset}")
    with {:ok, model} <- insert(cset, opts) do
      Dispatcher.after_insert(cset)
      {:ok, model}
    end
  end

  def push_insert(model, opts) do
    Logger.info("Inserting #{inspect model}")
    model
    |> Ecto.Changeset.change
    |> push_insert(opts)
  end
end
