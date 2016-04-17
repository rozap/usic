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
    Usic.DryMetaserver.start_link

    Ecto.Adapters.SQL.restart_test_transaction(Usic.Repo)
  end

  defp make_socket() do
    {:ok, _, socket} = socket("something", %{})
    |> subscribe_and_join(Usic.PersistenceChannel, "session", %{})
    socket
  end

  defp make_authed_songs(n \\ 0) do
    socket = make_socket
    ref = push(socket, "create:user", %{
      "email" => "sessiontest#{n}@bar.com", "password"=> "blahblah"
    })
    user = receive do
      %Reply{payload: p, ref: ^ref} ->
        assert p.email == "sessiontest#{n}@bar.com"
        p
    end

    ref = push(socket, "create:session", %{
      "email" => "sessiontest#{n}@bar.com", "password"=> "blahblah"
    })
    receive do
      %Reply{payload: p, ref: ^ref} -> assert p.token != nil
    end

    songs = Enum.map(1..8, fn i ->
      ref = push(socket, "create:song", %{
        "url" => @url, "name" => "something #{i}"
      })
      receive do
        %Reply{payload: p, ref: ^ref} ->
          assert p.url == @url
          p
      end
    end)

    {socket, user, songs}
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

  test "can create an anonymous song and read it" do
    socket = make_socket
    ref = push(socket, "create:song", %{
      "url" => @url
    })
    song_id = receive do
      %Reply{payload: p, ref: ^ref} -> p.id
    end

    ref = push(socket, "read:song", %{
      "id" => song_id
    })

    receive do
      %Reply{payload: p, ref: ^ref} ->
        %{"url" => "https://www.youtube.com/watch?v=lVKBRF4gu54"} = p
        |> Poison.encode!
        |> Poison.decode!
    end
  end

  test "can get a list of songs" do
    socket = make_socket
    Enum.each(1..20, fn _ ->
      ref = push(socket, "create:song", %{
        "url" => @url
      })
      receive do
        %Reply{payload: p, ref: ^ref} ->
          assert p.url == @url
      end
    end)

    ref = push(socket, "list:song", %{})

    receive do
      %Reply{payload: p, ref: ^ref} ->
        Enum.each(p["items"], fn song ->
          assert song.user == nil
        end)
        assert length(p["items"]) == 16
        assert p["count"] == 20
    end
  end

  test "can get a list of songs by name" do
    socket = make_socket

    names = [
      "foo",
      "foo bar",
      "bar",
      "baz"
    ]

    Enum.each(names, fn name ->
      ref = push(socket, "create:song", %{
        "url" => @url,
        "name" => name
      })
      receive do
        %Reply{payload: p, ref: ^ref} ->
          assert p.url == @url
          assert p.name == name
      end
    end)

    ref = push(socket, "list:song", %{
      "where" => %{
        "name" => "foo"
      }
    })

    receive do
      %Reply{payload: p, ref: ^ref} ->
        assert length(p["items"]) == 2
        assert Enum.sort(Enum.map(p["items"], fn i -> i.name end)) == ["foo", "foo bar"]
    end
  end


  test "can get a list of songs by region meta tag" do
    socket = make_socket

    names = [
      "foo",
      "foo bar",
      "bar",
      "baz"
    ]

    song_ids = Enum.map(names, fn name ->
      ref = push(socket, "create:song", %{
        "url" => @url,
        "name" => name
      })
      receive do
        %Reply{payload: p, ref: ^ref} ->
          song_id = p.id
          ref = push(socket, "create:region", %{
            "song_id" => song_id,
            "name" => "##{name}",
            "loop" => true,
            "start" => 0,
            "end" => 0
          })

          assert_reply ref, :ok, %Usic.Region{}
      end
    end)

    ref = push(socket, "list:song", %{
      "where" => %{
        "regions" => ["foo"]
      }
    })

    receive do
      %Reply{payload: p, ref: ^ref} ->
        songs = p["items"]
        assert length(songs) == 2

        Enum.each(songs, fn %Usic.Song{regions: [region]} ->
          assert "foo" in region.meta["tags"]
        end)
    end
  end


  test "tags are applied with OR" do
    socket = make_socket

    names = [
      "foo",
      "foo bar",
      "bar",
      "baz"
    ]

    song_ids = Enum.map(names, fn name ->
      ref = push(socket, "create:song", %{
        "url" => @url,
        "name" => name
      })
      receive do
        %Reply{payload: p, ref: ^ref} ->
          song_id = p.id
          ref = push(socket, "create:region", %{
            "song_id" => song_id,
            "name" => "##{name}",
            "loop" => true,
            "start" => 0,
            "end" => 0
          })

          assert_reply ref, :ok, %Usic.Region{}
      end
    end)

    ref = push(socket, "list:song", %{
      "where" => %{
        "regions" => ["foo", "baz"]
      }
    })

    receive do
      %Reply{payload: p, ref: ^ref} ->
        songs = p["items"]
        assert length(songs) == 3

        Enum.each(songs, fn %Usic.Song{regions: [region]} ->
          assert (("foo" in region.meta["tags"]) or ("baz" in region.meta["tags"]))
        end)
    end
  end


  test "can page a list of songs" do
    socket = make_socket
    Enum.each(1..8, fn _ ->
      p = %{
        "url" => @url
      }
      push(socket, "create:song", p)
      receive do
        %Reply{payload: %Song{}} -> :ok
      end
    end)

    ref = push(socket, "list:song", %{
      "limit" => 2,
      "offset" => 2
    })

    receive do
      %Reply{payload: p, ref: ^ref} ->
        assert length(p["items"]) == 2
    end
  end

  test "logged in user should have songs made by them" do
    {socket, user, _} = make_authed_songs

    ref = push(socket, "list:song", %{})

    receive do
      %Reply{ref: ^ref, payload: %{"items" => [item | _]}} ->
        assert item.user.id == user.id
    end
  end

  test "can select by user" do
    anon = make_socket
    Enum.each(1..8, fn _ ->
      push(anon, "create:song", %{
        "url" => @url
      })
      receive do
        _ -> :ok
      end
    end)


    {socket, user, _} = make_authed_songs
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
      %Reply{ref: ^ref, payload: p} -> :ok
    end

    meta_update = receive do
      %Message{event: "update:song", payload: p} -> p
    after
      40 -> raise "nope!"
    end
    assert meta_update.name == "foobar"

    location_update = receive do
      %Message{event: "update:song", payload: p} ->
        p
    after
      40 -> raise "nope!"
    end

    assert location_update.location == "/media/lVKBRF4gu54.m4a"
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
      %Reply{ref: ^ref, payload: _} ->
        assert Usic.Repo.get!(Song, song.id).state["rate"] == 0.8
    end
  end

  test "cant update another user's song" do
    {_, _, [song0 | _]} = make_authed_songs(0)
    {socket1, _, _} = make_authed_songs(1)

    state = song0.state
    |> Poison.encode!
    |> Poison.decode!
    |> Dict.put("rate", 0.8)

    ref = push(socket1, "update:song", %{
      "id" => song0.id,
      "state" => state
    })

    receive do
      %Reply{ref: ^ref, payload: p} ->
        js = p
        |> Poison.encode!
        |> Poison.decode!

        assert js == %{"user_id" => "song_update_not_allowed"}
    end
  end

  test "cant update users song if anon" do
    {_, _, [song | _]} = make_authed_songs(0)

    anon_sock = make_socket

    state = song.state
    |> Poison.encode!
    |> Poison.decode!
    |> Dict.put("rate", 0.8)

    ref = push(anon_sock, "update:song", %{
      "url" => @url,
      "id" => song.id,
      "state" => state
    })

    receive do
      %Reply{ref: ^ref, payload: p} ->
        js = p
        |> Poison.encode!
        |> Poison.decode!

        assert js == %{"user_id" => "song_update_not_allowed"}
    end
  end

  test "can delete a song " do
    {socket, _, [song | _]} = make_authed_songs(0)

    ref = push(socket, "create:region", %{
      "song_id" => song.id,
      "name" => "foobar",
      "start" => 23.4,
      "end" => 42.4,
      "loop" => true
    })

    receive do
      %Reply{ref: ^ref} -> :ok
    end

    ref = push(socket, "delete:song", %{
      "id" => song.id
    })

    receive do
      %Reply{ref: ^ref} -> :ok
    end

    Usic.Repo.get(Song, song.id)
  end


  test "cant delete another user's song" do
    {_, _, [song0 | _]} = make_authed_songs(0)
    {socket1, _, _} = make_authed_songs(1)

    state = song0.state
    |> Poison.encode!
    |> Poison.decode!
    |> Dict.put("rate", 0.8)

    ref = push(socket1, "delete:song", %{
      "id" => song0.id
    })

    receive do
      %Reply{ref: ^ref, payload: p} ->
        js = p
        |> Poison.encode!
        |> Poison.decode!

        assert js == %{"user_id" => "song_update_not_allowed"}
    end
  end

end