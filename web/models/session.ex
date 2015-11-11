defmodule Usic.Session do
  use Ecto.Model
  alias Usic.User

  @whitelist [:token]

  schema "session" do
    field :token, :string
    belongs_to :user, User, references: :email, type: :string
    timestamps
  end


  def changeset(session, params \\ :empty, opts \\ []) do
    params = Dict.put(params, "token", UUID.uuid4)
    email = Dict.get(params, "user_id", "")
    cset = cast(session, params, ~w(token user_id))

    query = from u in User, where: u.email == ^email
    case {Usic.Repo.one(query), params["password"]} do
      {nil, _} -> add_error(cset, :user_id, "unknown_user")
      {_, nil} -> add_error(cset, :password, "empty_password")
      {user, pass} ->
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
  @attributes ~W(token)

  def encode(song, _options) do
    IO.puts "ENCODE Session"
    song
    |> Map.take(@attributes)
    |> Poison.encode!
  end
end