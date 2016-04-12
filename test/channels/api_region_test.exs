defmodule Usic.ApiRegionTest do
  use Phoenix.ChannelTest
  use ExUnit.Case
  alias Usic.Region
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

  test "can create a region" do
    socket = make_socket
    ref = push(socket, "create:song", %{
      "url" => @url
    })

    song_id = receive do
      %Reply{ref: ^ref, payload: p} -> p.id
    end

    ref = push(socket, "create:region", %{
      "song_id" => song_id,
      "name" => "foobar",
      "start" => 23.4,
      "end" => 42.4,
      "loop" => true
    })

    assert_reply ref, :ok, %Usic.Region{
      end: 42.4,
      loop: true,
      name: "foobar",
      song_id: _,
      start: 23.4
    }

    ref = push(socket, "list:song", %{
        "where" => %{
          "id" => song_id
        }
    })

    receive do 
      %Reply{ref: ^ref, payload: %{"items" => [song]}} ->
        assert length(song.regions) == 1
    end
  end


  test "can add meta tags to region from name" do
    socket = make_socket
    ref = push(socket, "create:song", %{
      "url" => @url
    })

    song_id = receive do
      %Reply{ref: ^ref, payload: p} -> p.id
    end

    ref = push(socket, "create:region", %{
      "song_id" => song_id,
      "name" => "foobar #baz buz #biz #butts",
      "start" => 23.4,
      "end" => 42.4,
      "loop" => true
    })

    assert_reply ref, :ok, %Usic.Region{
      end: 42.4,
      loop: true,
      name: "foobar #baz buz #biz #butts",
      song_id: _,
      start: 23.4,
      meta: %{
        tags: ["baz", "biz", "butts"]
      }
    }
  end

  test "can filter by meta tag" do
    socket = make_socket
    ref = push(socket, "create:song", %{
      "url" => @url
    })

    song_id = receive do
      %Reply{ref: ^ref, payload: p} -> p.id
    end

    push(socket, "create:region", %{
      "song_id" => song_id,
      "name" => "#bass #guitar",
      "start" => 23.4,
      "end" => 42.4,
      "loop" => true
    })
    push(socket, "create:region", %{
      "song_id" => song_id,
      "name" => "#horns #bass",
      "start" => 23.4,
      "end" => 42.4,
      "loop" => true
    })
    ref = push(socket, "list:region", %{
      "where" => %{
        "meta.tags" => ["horns"]
      }
    })

    receive do 
      %Reply{ref: ^ref, payload: %{"items" => items, "count" => count}} ->

        assert count == 1
        assert items = [
          %Usic.Region{
            meta: %{"tags" => ["horns", "bass"]}
          }
        ]
    end
    
  end

  test "can update a region" do
    socket = make_socket
    ref = push(socket, "create:song", %{
      "url" => @url
    })

    song_id = receive do
      %Reply{ref: ^ref, payload: p} -> p.id
    end

    ref = push(socket, "create:region", %{
      "song_id" => song_id,
      "name" => "foobar",
      "start" => 23.4,
      "end" => 42.4,
      "loop" => true
    })

    region_id = receive do
      %Reply{ref: ^ref, payload: p} -> p.id
    end

    ref = push(socket, "update:region", %{
      "id" => region_id,
      "song_id" => song_id,
      "name" => "new name",
      "start" => 26.4,
      "end" => 42.4,
      "loop" => false
    })

    assert_reply ref, :ok, %Usic.Region{
      end: 42.4,
      loop: false,
      name: "new name",
      song_id: _,
      start: 26.4
    }
  end

  test "can delete a region" do
    socket = make_socket
    ref = push(socket, "create:song", %{
      "url" => @url
    })

    song_id = receive do
      %Reply{ref: ^ref, payload: p} -> p.id
    end

    ref = push(socket, "create:region", %{
      "song_id" => song_id,
      "name" => "foobar",
      "start" => 23.4,
      "end" => 42.4,
      "loop" => true
    })

    region_id = receive do
      %Reply{ref: ^ref, payload: p} -> p.id
    end

    ref = push(socket, "delete:region", %{
      "id" => region_id,
    })

    assert_reply ref, :ok, %{}

    assert Usic.Repo.get(Region, region_id) == nil
  end

end