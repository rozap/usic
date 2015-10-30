defmodule Usic.Loader do
  require Logger
  alias Usic.Executor

  @format "m4a"

  defp media_dir do
    Usic.Endpoint.config(:static)
    |> Path.join("media")
  end

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


  defp load_local(song_id) do
    abs_path = Path.join(media_dir, "#{song_id}.#{@format}")
    if File.exists?(abs_path) do
      Logger.info("Already have #{song_id}, returning local copy")
      {:ok, to_media_location(abs_path)}
    else
      {:error, :not_found}
    end
  end

  defp to_media_location(absolute_path) do
    filename = String.replace(absolute_path, ".%(ext)s", ".m4a")
    |> Path.basename

    Path.join("/media", filename)
  end

  defp fetch({:ok, song_id}, location) do
    case load_local(song_id) do
      {:error, :not_found} ->
        download_song(song_id, location)
      local -> local
    end
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
        {:ok, to_media_location(output_loc)}
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