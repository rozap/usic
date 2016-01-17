defmodule Usic.Session do
  use Ecto.Model
  alias Usic.User

  schema "session" do
    field :token, :string
    belongs_to :user, User
    timestamps
  end


  def changeset(session, params \\ :empty, _opts \\ []) do
    params = Dict.put(params, "token", UUID.uuid4)
    email = Dict.get(params, "email", "")
    cset = cast(session, params, ~w(token))

    query = from u in User, where: u.email == ^email
    case {Usic.Repo.one(query), params["password"]} do
      {nil, _} -> add_error(cset, :email, "unknown_user")
      {_, nil} -> add_error(cset, :password, "empty_password")
      {user, pass} ->
        params = Dict.put(params, "user_id", user.id)
        cset = cast(cset, params, ~w(token user_id))
        pw_match = Comeonin.Pbkdf2.checkpw(pass, user.password)
        if pw_match do
          cset
        else
          add_error(cset, :password, "invalid_password")
        end
    end
  end
end


defimpl Poison.Encoder, for: Usic.Session do
  @attributes ~w(token user inserted_at updated_at)a

  def encode(session, _options) do
    session
    |> Map.take(@attributes)
    |> Poison.encode!
  end
end