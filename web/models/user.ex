defmodule Usic.User do
  use Ecto.Model

  schema "user" do
    field :email, :string
    field :password, :string
    field :display_name, :string
    has_many :sessions, Usic.Session
    timestamps
  end

  def changeset(user, params \\ :empty, _opts \\ []) do
    user
    |> cast(params, [], ~w(email password display_name))
    |> unique_constraint(:email)
    |> validate_length(:password, min: 6)
    |> update_change(:password, &(hash_password &1))

  end

  def hash_password(password) do
    Comeonin.Pbkdf2.hashpwsalt(password)
  end
end


defimpl Poison.Encoder, for: Usic.User do
  @attributes ~W(id email inserted_at updated_at display_name)a

  def encode(user, _options) do
    user
    |> Map.take(@attributes)
    |> Poison.encode!
  end
end