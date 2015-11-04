defmodule Usic.ApiSessionTest do
  use Phoenix.ChannelTest
  use ExUnit.Case
  @endpoint Usic.Endpoint

  defp make_socket() do
    {:ok, _, socket} = socket("something", %{})
    |> subscribe_and_join(
      Usic.PersistenceChannel, "hi", %{}
    )

    socket
  end

  test "can create session" do
    socket = make_socket

    push(socket, "create:user", %{
      "email"=> "sessiontest@bar.com", "password"=> "blahblah"
    })
    receive do
      %{payload: _} -> :ok
    end

    push(socket, "create:session", %{
      "email"=> "sessiontest@bar.com", "password"=> "blahblah"
    })
    receive do
      %{payload: p} -> assert p.token != nil
    end
  end

  test "cannot create session with bad credentials" do
    socket = make_socket

    push(socket, "create:user", %{
      "email"=> "sessiontest@bar.com", "password"=> "blahblah"
    })
    receive do
      %{payload: _} -> :ok
    end

    push(socket, "create:session", %{
      "email"=> "sessiontest@bar.com", "password"=> "foobar"
    })
    receive do
      %{payload: p} -> assert p == %{password: "invalid_password"}
    end

    push(socket, "create:session", %{
      "email"=> "wtfwhy@bar.com", "password"=> "blahblah"
    })
    receive do
      %{payload: p} -> assert p == %{email: "unknown_email"}
    end

  end
end