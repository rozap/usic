defmodule Usic.Session do
  use Ecto.Model
  alias Usic.User

  @whitelist [:token]

  schema "session" do
    field :token, :string
    belongs_to :user, User
    timestamps
  end


  def changeset(session, params \\ :empty, opts \\ []) do
    params = Dict.put(params, "token", UUID.uuid4)
    email = Dict.get(params, "email", "")
    cset = cast(session, params, ~w(token))
    query = from u in User, where: u.email == ^email
    case {Usic.Repo.one(query), params["password"]} do
      {nil, _} -> add_error(cset, :email, "unknown_email")
      {_, nil} -> add_error(cset, :password, "empty_password")
      {user, pass} ->
        pw_match = Comeonin.Pbkdf2.checkpw(pass, user.password)
        if pw_match do
          IO.puts "YAY"
          cset
        else
          add_error(cset, :password, "invalid_password")
        end
    end
  end

  ##
  # this is stupid but it's simple
  def readable(instance) do
    Usic.Model.Util.sanitize(instance, @whitelist)
  end

end