defmodule Usic.ApiUserTest do
  use Phoenix.ChannelTest
  use ExUnit.Case
  alias Usic.User
  @endpoint Usic.Endpoint

  setup do
    Ecto.Adapters.SQL.restart_test_transaction(Usic.Repo)
  end

  defp make_socket() do
    {:ok, _, socket} = socket("something", %{})
    |> subscribe_and_join(Usic.PersistenceChannel, "anon", %{})
    socket
  end

  test "can create a user" do
    socket = make_socket
    push(socket, "create:user", %{
      "email": "wow@bar.com", "password": "blahblah"
    })
    receive do
      %{payload: p} ->
        user = Usic.Repo.get!(User, p.id)
        assert user.email == "wow@bar.com"
        assert Comeonin.Pbkdf2.checkpw("blahblah", user.password)
    end
  end

  test "can't create with a bad password" do
    socket = make_socket
    push(socket, "create:user", %{
      "email": "www@bar.com", "password": "lol"
    })
    receive do
      %{payload: p} ->
        assert p == %{password: "should be at least 6 characters"}
    end
  end

  test "can't create user with same email" do
    socket = make_socket
    push(socket, "create:user", %{
      "email": "foo@bar.com", "password": "blahblah"
    })
    receive do
      %{payload: _} -> :ok
    end

    push(socket, "create:user", %{
      "email": "foo@bar.com", "password": "blahblah"
    })
    receive do
      %{payload: p} ->
        assert p == %{email: "has already been taken"}
    end

  end

end