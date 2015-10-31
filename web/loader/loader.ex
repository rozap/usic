defmodule Usic.Loader do
  require Logger
  alias Usic.Executor

  @format "m4a"

  defp media_dir, do: Application.get_env(:usic, :media_dir)

  def get_song_id(location) do
    case URI.parse(location) do
      %URI{
        authority: "www.youtube.com",
        host: "www.youtube.com",
        path: "/watch",
        scheme: "https",
        query: "v=" <> song_id
      } ->
        Logger.info("Found song_id #{song_id}")
        {:ok, song_id}
      parsed ->
        Logger.info("Cannot parse link #{location} #{parsed} as downloadable")
        {:error, "invalid_link"}
    end
  end

  defp to_media_location(log_lines) do

    final_write = log_lines
    |> Enum.reverse
    |> Enum.find_value(fn line ->
      Regex.run(~r/Destination: (.*)/, line)
    end)

    case final_write do
      [_, abs_path] -> {:ok, Path.join("/media", Path.basename(abs_path))}
      _ -> {:error, "Unable to locate audio track"}
    end
  end

  defp fetch({:ok, song_id}, location) do
    download_song(song_id, location)
  end
  defp fetch(err, _), do: err


  defp gen_template(song_id) do
    media_dir
    |> Path.join(song_id <> ".%(ext)s")
  end

  defp get_executor() do
    Application.get_env(:usic, :executor)
  end

  defp download_song(song_id, url) do
    output_loc = gen_template(song_id)

    {log_out, result} = get_executor().get(url, output_loc)

    lines = String.split(log_out, "\n")
    |> Enum.map(fn line -> "[youtube-dl] [#{song_id}] #{line}" end)

    case result do
      0 ->
        Enum.each(lines, &(Logger.info &1))
        Logger.info("[youtube-dl] Download complete")
        IO.inspect to_media_location(lines)
        to_media_location(lines)
      _ ->
        failure = "youtube-dl failed with #{result}"
        Logger.error(failure)
        Enum.each(lines, &(Logger.error &1))
        {:error, failure}
    end

  end


  def get_song(sketch_id, url) do
    get_song_id(url) |> fetch(url)
  end

end