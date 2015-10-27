defmodule UsicTest.Loader do
  use ExUnit.Case
  import Usic.TestHelpers
  @youtube_song "https://www.youtube.com/watch?v=5DNVSHm5zr4"
  @invalid_song "https://www.youtube.com/watch?v=5DNV"

  setup_all do
    clear_media()

    :ok
  end

  test "will give an error for invalid links" do
    res = Usic.Loader.get_song_id("echo \"bad stuff\"")
    assert res = {:error, "invalid_link"}
  end

  test "can get the song id from a youtube video" do
    res = Usic.Loader.get_song_id(@youtube_song)
    assert res == {:ok, "5DNVSHm5zr4"}
  end

  test "can download the song to the static dir" do
    res = Usic.Loader.get_song(UUID.uuid4, @youtube_song)

    output_loc = Usic.Endpoint.config(:static)
    |> Path.join("media")
    |> Path.join("5DNVSHm5zr4.m4a")
    assert res == {:ok, output_loc}
  end

end