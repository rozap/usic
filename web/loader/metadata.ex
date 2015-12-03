defmodule Usic.Loader.Metadata do
  require HTTPoison.Base
  use HTTPoison.Base

  @streams "url_encoded_fmt_stream_map"
  @adaptive "adaptive_fmts"

  @meta ~w(thumbnail_url title keywords)

  def process_url(id) do
    "https://www.youtube.com/get_video_info?video_id=#{id}"
  end


  def process_response_body(body) do
    d = body
    |> URI.decode_query
    |> Dict.take(@meta)
  end

end