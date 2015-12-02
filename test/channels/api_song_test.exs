defmodule Usic.ApiSongTest do
  use Phoenix.ChannelTest
  use ExUnit.Case
  alias Usic.Song
  alias Phoenix.Socket.Message
  alias Phoenix.Socket.Reply
  @endpoint Usic.Endpoint

  @url "https://www.youtube.com/watch?v=lVKBRF4gu54"

  setup do
    Usic.DryExecutor.start_link
    Ecto.Adapters.SQL.restart_test_transaction(Usic.Repo)
  end

  defp make_socket() do
    {:ok, _, socket} = socket("something", %{})
    |> subscribe_and_join(Usic.PersistenceChannel, "session", %{})
    socket
  end

  defp make_authed_songs() do
    socket = make_socket
    ref = push(socket, "create:user", %{
      "email" => "sessiontest@bar.com", "password"=> "blahblah"
    })
    user = receive do
      %Reply{payload: p, ref: ^ref} ->
        assert p.email == "sessiontest@bar.com"
        p
    end

    ref = push(socket, "create:session", %{
      "email" => "sessiontest@bar.com", "password"=> "blahblah"
    })
    receive do
      %Reply{payload: p, ref: ^ref} -> assert p.token != nil
    end

    Enum.each(1..8, fn i ->
      ref = push(socket, "create:song", %{
        "url" => @url, "name" => "something #{i}"
      })
      receive do
        %Reply{payload: p, ref: ^ref} ->
          assert p.url == @url
      end
    end)

    {socket, user}
  end

  test "can create an anonymous song" do
    socket = make_socket
    ref = push(socket, "create:song", %{
      "url" => @url
    })
    receive do
      %Reply{payload: p, ref: ^ref} ->
        song = Usic.Repo.get!(Song, p.id)
        assert song.url == @url
    end
  end

  test "can get a list of songs" do
    socket = make_socket
    Enum.each(1..40, fn i ->
      ref = push(socket, "create:song", %{
        "url" => @url, "name" => "something #{i}"
      })
      receive do
        %Reply{payload: p, ref: ^ref} ->
          assert p.name == "something #{i}"
      end
    end)

    ref = push(socket, "list:song", %{})

    receive do
      %Reply{payload: p, ref: ^ref} ->
        assert length(p["items"]) == 16
        assert p["count"] == 40
    end
  end


  test "can page a list of songs" do
    socket = make_socket
    Enum.each(1..8, fn i ->
      p = %{
        "url" => @url, "name" => "something #{i}"
      }
      ref = push(socket, "create:song", p)
      assert_reply ref, :ok, p
    end)

    ref = push(socket, "list:song", %{
      "limit" => 2,
      "offset" => 2
    })

    receive do
      %Reply{payload: p, ref: ^ref} ->
        assert length(p["items"]) == 2

        [s3, s4] = p["items"]
        assert s3.name == "something 3"
        assert s4.name == "something 4"
    end
  end


  test "can select by name for" do
    {socket, _} = make_authed_songs

    ref = push(socket, "list:song", %{
      "where" => %{
        "name" => "something 4"
      }
    })

    receive do
      %Reply{ref: ^ref, payload: %{"items" => [item]}} ->
        assert item.name == "something 4"
    after
      200 -> raise "NOPE"
    end
  end


  test "logged in user should have songs made by them" do
    {socket, user} = make_authed_songs

    ref = push(socket, "list:song", %{})

    receive do
      %Reply{ref: ^ref, payload: %{"items" => [item | _]}} ->
        assert item.user_id == user.id
    end
  end

  test "can select by user" do
    anon = make_socket
    Enum.each(1..8, fn _ ->
      ref = push(anon, "create:song", %{
        "url" => @url
      })
      assert_reply ref, :ok, %{}
    end)


    {socket, user} = make_authed_songs
    ref = push(socket, "list:song", %{
      "where" => %{
        "user_id" => user.id
      }
    })

    receive do
      %Reply{ref: ^ref, payload: %{"items" => items}} ->
        assert length(items) == 8
    end
  end

  test "can create an anonymous song and load should be populated with lifecycle" do
    socket = make_socket
    ref = push(socket, "create:song", %{
      "url" => @url
    })
    receive do
      %Reply{ref: ^ref, payload: p} -> assert p.location == nil
    end

    update_dispatch = receive do
      %Message{event: "update:song", payload: p} ->
        p
    after
      40 -> raise "nope!"
    end

    assert update_dispatch.location == "/media/lVKBRF4gu54.m4a"
  end

  test "can update a song state" do
    socket = make_socket
    ref = push(socket, "create:song", %{
      "url" => @url
    })
    song = receive do
      %Reply{ref: ^ref, payload: p} -> p
    end

    state = song.state
    |> Poison.encode!
    |> Poison.decode!
    state = %{state | "rate" => 0.8}
    ref = push(socket, "update:song", %{
      "url" => @url,
      "id" => song.id,
      "state" => state
    })

    receive do
      %Reply{ref: ^ref, payload: p} ->
        assert Usic.Repo.get!(Song, song.id).state.rate == 0.8
    end
  end

end