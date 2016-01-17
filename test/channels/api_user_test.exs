defmodule Usic.ApiUserTest do
  use Phoenix.ChannelTest
  use ExUnit.Case
  alias Usic.User
  import Usic.TestHelpers
  @endpoint Usic.Endpoint

  setup do
    Ecto.Adapters.SQL.restart_test_transaction(Usic.Repo)
  end

  defp make_socket() do
    {:ok, _, socket} = socket("something", %{})
    |> subscribe_and_join(Usic.PersistenceChannel, "session", %{})
    socket
  end

  test "can create a user" do
    socket = make_socket
    push(socket, "create:user", %{
      "email" => "wow@bar.com", "password"=> "blahblah"
    })
    receive do
      %{payload: p} ->
        user = Usic.Repo.get!(User, p.id)
        assert user.email == "wow@bar.com"
        assert Comeonin.Pbkdf2.checkpw("blahblah", user.password)
    end
  end

  test "can update a user" do
    socket = make_socket
    push(socket, "create:user", %{
      "email" => "wow@bar.com", "password" => "blahblah"
    })
    user_id = receive do
      %{payload: p} -> p.id
    end

    push(socket, "create:session", %{
      "email" => "wow@bar.com", "password" => "blahblah"
    })

    receive do
      %{payload: _} -> :ok
    end

    push(socket, "update:user", %{
      "id" => user_id, "display_name" => "new name"
    })

    receive do
      %{payload: _} ->
        user = Usic.Repo.get!(User, user_id)
        assert user.email == "wow@bar.com"
        assert user.display_name == "new name"
        assert Comeonin.Pbkdf2.checkpw("blahblah", user.password)
    end
  end

  test "cannot update a different user" do
    socket = make_socket
    push(socket, "create:user", %{
      "email" => "foo@foo.com", "password" => "foofoofoo"
    })
    foo_id = receive do
      %{payload: p} -> p.id
    end

    push(socket, "create:user", %{
      "email" => "bar@bar.com", "password" => "barbarbar"
    })
    receive do
      %{payload: _} -> :ok
    end


    push(socket, "create:session", %{
      "email" => "bar@bar.com", "password" => "barbarbar"
    })

    receive do
      %{payload: _} -> :ok
    end

    ref = push(socket, "update:user", %{
      "id" => foo_id, "display_name" => "new name"
    })

    assert_reply ref, :error, %{
      "id" => "unauthorized"
    }

  end

  test "can't create with a bad password" do
    socket = make_socket
    push(socket, "create:user", %{
      "email" => "www@bar.com", "password" => "lol"
    })
    receive do
      %{payload: p} ->
        e = p
        |> Poison.encode!
        |> Poison.decode!
        assert e ==  %{"password" => ["should be at least 6 characters"]}
    end
  end

  test "can't create user with same email" do
    socket = make_socket
    push(socket, "create:user", %{
      "email" => "foo@bar.com", "password" => "blahblah"
    })
    receive do
      %{payload: _} -> :ok
    end

    push(socket, "create:user", %{
      "email" => "foo@bar.com", "password" => "blahblah"
    })
    receive do
      %{payload: p} ->
        assert js(p) == %{"email" => ["has already been taken"]}
    end

  end

end