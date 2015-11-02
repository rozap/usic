defmodule Usic.Song do
  use Ecto.Model

  @whitelist [:id, :name, :url]

  schema "song" do
    field :name, :string
    field :url, :string
    belongs_to :user, Usic.User
    timestamps
  end


  def changeset(song, params \\ :empty, user: user) do
    params = case user do
      nil -> Dict.put(params, :user_id, nil)
      _ -> Dict.put(params, :user_id, user.id)
    end

    song |> cast(params, ~w(name url))
  end

  ##
  # this is stupid but it's simple
  def readable(instance) do
    Usic.Model.Util.sanitize(instance, @whitelist)
  end

end