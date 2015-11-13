defmodule Usic.Resource.User do
  import Phoenix.Socket
  import Ecto.Query
  import Ecto.Model
  alias Usic.Session
  alias Usic.User
  alias Usic.Repo

  def read(model, params, socket) do
    Usic.Resource.read(model, params, socket)
  end

end