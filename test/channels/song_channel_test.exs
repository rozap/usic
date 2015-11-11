defmodule Usic.SongChannelTest do
  use Phoenix.ChannelTest
  use ExUnit.Case
  import Usic.TestHelpers

  @endpoint Usic.Endpoint

  @youtube_song "https://www.youtube.com/watch?v=lVKBRF4gu54"
  @invalid_song "https://www.youtube.com/watch?v=5DNV"

  setup_all do
    clear_media
    Ecto.Adapters.SQL.restart_test_transaction(Usic.Repo)
    Usic.DryExecutor.start_link
    :ok
  end

  defp make_socket() do
    {:ok, _, socket} = socket("something", %{})
    |> subscribe_and_join(Usic.SongChannel, "song:" <> UUID.uuid4, %{})

    socket
  end

  test "can give back errors" do
    socket = make_socket
    ref = push(socket, "search", %{"term" => "invalid"})
    assert_reply ref, :ok, %{event: "search", state: "error", message: "invalid_youtube"}
  end

  test "can give back loading" do
    socket = make_socket
    ref = push(socket, "search", %{"term" => @youtube_song})
    assert_reply ref, :ok, %{event: "search", state: "loading", message: "getting_song"}
  end

  test "can give back song when done" do
    socket = make_socket
    push(socket, "search", %{"term" => @youtube_song})
    assert_push "search", %{status: :ok, response: %{
      state: "success",
      message: "video_retrieved",
      location: "/media/lVKBRF4gu54.m4a"
    }}, 10_000
  end

  test "can send back errors on invalid yotubelike links" do
    socket = make_socket

    push(socket, "search", %{"term" => @invalid_song})
    assert_push "search", %{status: :ok, response: %{
      state: "error",
      message: "download_failed",
    }}, 10_000
  end




end