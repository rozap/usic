defmodule Usic.Loader do
  require Logger

  defp media_dir, do: Application.get_env(:usic, :media_dir)

  ##
  # clean this up
  # def unload(uid) do
  #   media_dir
  #   |> File.ls!
  #   |> Enum.filter(fn f -> String.contains?(f, uid) end)
  #   |> Enum.each(fn f ->
  #     track = Path.join(media_dir, f)
  #     Logger.info("Cleaned up #{track}")
  #     File.rm!(track)
  #   end)
  #   :ok
  # end

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

  defp gen_template() do
    song_id = UUID.uuid4()
    media_dir
    |> Path.join(song_id <> ".%(ext)s")
  end

  defp get_executor() do
    Application.get_env(:usic, :executor)
  end

  defp get_metaserver() do
    Application.get_env(:usic, :metaserver)
  end

  defp get_metadata(id, song) do
    case get_metaserver().get(id) do
      {:ok, metadata} ->
        name = Dict.get(metadata, "title", "untitled")
        song = %{song | name: name}
        Logger.info("Fetched metadata #{id} name: #{name}")
        Usic.Repo.update(song)
      err -> err
    end
  end

  defp download_song({:ok, song}) do
    output_loc = gen_template()

    case get_executor().get(song.url, output_loc) do
      {:error, reason} -> put_err({:error, reason}, song)
      {log_out, result} ->
        lines = String.split(log_out, "\n")
        |> Enum.map(fn line -> "[youtube-dl] [#{song.id}] #{line}" end)

        case result do
          0 ->
            Enum.each(lines, &(Logger.info &1))
            Logger.info("[youtube-dl] Download complete")
            to_media_location(lines) |> update_location(song)
          _ ->
            failure = "youtube-dl failed with #{result}"
            Logger.error(failure)
            Enum.each(lines, &(Logger.error &1))
            put_err({:error, failure}, song)
        end
    end
  end

  defp download_song(err), do: err


  defp update_location({:ok, location}, song) do
    state = %{song.state | load_state: "success"}
    song = %{song | location: location, state: state}
    Usic.Repo.update(song)
  end

  defp update_location(err, song), do: put_err(err, song)


  defp put_err({:error, reason} = err, song) do
    state = %{song.state | load_state: "error", error: reason}
    song = %{song | state: state}
    Usic.Repo.update(song)
    err
  end


  def get_song(song) do
    case get_song_id(song.url) do
      {:ok, id} ->
        Task.start_link(fn ->
          get_metadata(id, song)
          |> download_song
        end)
      err -> put_err(err, song)
    end
  end

end