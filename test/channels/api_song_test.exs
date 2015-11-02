defmodule Usic.ApiSongTest do
  use Phoenix.ChannelTest
  use ExUnit.Case
  alias Usic.Song
  @endpoint Usic.Endpoint

  defp make_socket() do
    {:ok, _, socket} = socket("something", %{})
    |> subscribe_and_join(
      Usic.PersistenceChannel, "hi", %{}
    )

    socket
  end

  test "can create an anonymous song" do
    socket = make_socket
    push(socket, "create:song", %{
      "url": "foo", "name": "something"
    })
    receive do
      %{payload: p} ->
        song = Usic.Repo.get!(Song, p.id)
        assert song.name == "something"
        assert song.url == "foo"
    end
  end

  # test "can create an non-anon song" do
  #   socket = make_socket
  #   ref = push(socket, "create:user", %{
  #     "email": "foo@bar.com", "password": "blahblah"
  #   })
  #   user_id = receive do
  #     %{payload: p} -> p.id
  #   end

  #   ref = push(socket, "create:song", %{
  #     "url": "foo", "name": "something",
  #   })
  #   receive do
  #     %{payload: p} ->
  #       song = Usic.Repo.get!(Song, p.id)
  #       assert song.name == "something"
  #       assert song.url == "foo"
  #   end
  # end

end