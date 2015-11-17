defmodule Usic.ApiSongTest do
  use Phoenix.ChannelTest
  use ExUnit.Case
  alias Usic.Song
  @endpoint Usic.Endpoint

  setup do
    Ecto.Adapters.SQL.restart_test_transaction(Usic.Repo)
  end

  defp make_socket() do
    {:ok, _, socket} = socket("something", %{})
    |> subscribe_and_join(Usic.PersistenceChannel, "session", %{})
    socket
  end

  defp make_authed_songs() do
    socket = make_socket
    push(socket, "create:user", %{
      "email" => "sessiontest@bar.com", "password"=> "blahblah"
    })
    user = receive do
      %{payload: p} ->
        assert p.email == "sessiontest@bar.com"
        p
    end

    push(socket, "create:session", %{
      "email" => "sessiontest@bar.com", "password"=> "blahblah"
    })
    receive do
      %{payload: p} -> assert p.token != nil
    end

    Enum.each(1..8, fn i ->
      push(socket, "create:song", %{
        "url" => "foo"
      })
      receive do
        %{payload: p} ->
          assert p.url == "foo"
      end
    end)

    {socket, user}
  end

  test "can create an anonymous song" do
    socket = make_socket
    push(socket, "create:song", %{
      "url" => "foo"
    })
    receive do
      %{payload: p} ->
        song = Usic.Repo.get!(Song, p.id)
        assert song.url == "foo"
    end
  end

 test "can get a list of songs" do
    socket = make_socket
    Enum.each(1..40, fn i ->
      push(socket, "create:song", %{
        "url" => "foo", "name" => "something #{i}"
      })
      receive do
        %{payload: p} ->
          assert p.name == "something #{i}"
      end
    end)

    push(socket, "list:song", %{})

    receive do
      %{payload: p} ->
        assert length(p["items"]) == 16
        assert p["count"] == 40
    end
  end



 test "can page a list of songs" do
    socket = make_socket
    Enum.each(1..8, fn i ->
      push(socket, "create:song", %{
        "url" => "foo", "name" => "something #{i}"
      })
      receive do
        %{payload: p} ->
          assert p.name == "something #{i}"
      end
    end)

    push(socket, "list:song", %{
      "limit" => 2,
      "offset" => 2
    })

    receive do
      %{payload: p} ->
        assert length(p["items"]) == 2

        [s3, s4] = p["items"]
        assert s3.name == "something 3"
        assert s4.name == "something 4"
    end
  end


  test "can select by name for" do
    {socket, _} = make_authed_songs

    push(socket, "list:song", %{
      "where" => %{
        "name" => "something 4"
      }
    })

    receive do
      %{payload: %{"items" => [item]}} ->
        assert item.name == "something 4"
    end
  end

  test "logged in user should have songs made by them" do
    {socket, user} = make_authed_songs

    push(socket, "list:song", %{})

    receive do
      %{payload: %{"items" => [item | _]}} ->
        assert item.user_id == user.id
    end
  end

  # test "can select by user" do
  #   socket = make_authed_songs

  #   push(socket, "list:song", %{
  #     "where" => %{
  #       "user" => "foo"
  #     }
  #   })

  #   receive do
  #     %{payload: %{"items" => [item]}} ->
  #       assert item.name == "something 4"
  #     err -> throw err

  #   end
  # end

  # test "can create an non-anon song" do
  #   socket = make_socket
  #   ref = push(socket, "create:user", %{
  #     "email": "foo@bar.com", "password": "blahblah"
  #   })
  #   email = receive do
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