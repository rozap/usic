defmodule Usic.User do
  use Ecto.Model

  @whitelist [:id, :email, :inserted_at, :updated_at]

  schema "user" do
    field :email, :string, primary_key: true
    field :password, :string
    timestamps
  end

  def changeset(user, params \\ :empty, _opts \\ []) do
    user
    |> cast(params, ~w(email password))
    |> unique_constraint(:email)
    |> validate_length(:password, min: 6)
    |> update_change(:password, &(hash_password &1))

  end

  def hash_password(password) do
    Comeonin.Pbkdf2.hashpwsalt(password)
  end

  ##
  # this is stupid but it's simple
  def readable(instance) do
    Usic.Model.Util.sanitize(instance, @whitelist)
  end

end