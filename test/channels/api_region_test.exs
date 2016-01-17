defmodule Usic.ApiRegionTest do
  use Phoenix.ChannelTest
  use ExUnit.Case
  alias Usic.Region
  alias Phoenix.Socket.Reply
  import Usic.TestHelpers
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

  defp login(n \\ 0) do
    socket = make_socket
    ref = push(socket, "create:user", %{
      "email" => "sessiontest#{n}@bar.com", "password"=> "blahblah"
    })
    receive do
      %Reply{payload: p, ref: ^ref} ->
        assert p.email == "sessiontest#{n}@bar.com"
    end

    ref = push(socket, "create:session", %{
      "email" => "sessiontest#{n}@bar.com", "password"=> "blahblah"
    })
    receive do
      %Reply{payload: p, ref: ^ref} -> assert p.token != nil
    end

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
      song_id: ^song_id,
      start: 23.4
    }
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
      start: 26.4
    }
  end

  test "cannot create region on some elses song" do
    authed_socket = login
    anon_socket = make_socket

    ref = push(authed_socket, "create:song", %{
      "url" => @url
    })

    song_id = receive do
      %Reply{ref: ^ref, payload: p} -> p.id
    end

    ref = push(anon_socket, "create:region", %{
      "song_id" => song_id,
      "name" => "foobar",
      "start" => 23.4,
      "end" => 42.4,
      "loop" => true
    })

    receive do
      %Reply{ref: ^ref, payload: p} ->

        assert js(p) == %{"user_id" => ["song_update_not_allowed"]}
    end


    ref = push(authed_socket, "create:region", %{
      "song_id" => song_id,
      "name" => "foobar",
      "start" => 23.4,
      "end" => 42.4,
      "loop" => true
    })
    receive do
      %Reply{ref: ^ref, payload: p} ->
        assert p.end == 42.4
    end

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


  test "cannot delete region on some elses song" do
    authed_socket = login
    anon_socket = make_socket

    ref = push(authed_socket, "create:song", %{
      "url" => @url
    })

    song_id = receive do
      %Reply{ref: ^ref, payload: p} -> p.id
    end

    ref = push(authed_socket, "create:region", %{
      "song_id" => song_id,
      "name" => "foobar",
      "start" => 23.4,
      "end" => 42.4,
      "loop" => true
    })
    region_id = receive do
      %Reply{ref: ^ref, payload: p} ->
        assert p.end == 42.4
        p.id
    end

    ref = push(anon_socket, "delete:region", %{
      "id" => region_id,
    })
    receive do
      %Reply{ref: ^ref, payload: p} ->
        assert p == %{delete: %{user_id: "song_update_not_allowed"}}
    end
  end
end