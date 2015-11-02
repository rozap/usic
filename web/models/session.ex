defmodule Usic.Session do
  use Ecto.Model

  @whitelist [:token]

  schema "session" do
    field :token, :string
    belongs_to :user, Usic.User
    timestamps
  end


  def changeset(session, params \\ :empty, user: user) do
    params = Dict.put(params, :token, UUID.uuid4)
    cast(session, params, ~w(token))
  end

  ##
  # this is stupid but it's simple
  def readable(instance) do
    Usic.Model.Util.sanitize(instance, @whitelist)
  end

end