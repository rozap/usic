defmodule Usic.ApiSessionTest do
  use Phoenix.ChannelTest
  use ExUnit.Case
  alias Usic.User
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
      "email": "sessiontest@bar.com", "password": "blahblah"
    })
    receive do
      %{payload: p} -> :ok

    end
  end


end