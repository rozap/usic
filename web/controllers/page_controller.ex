defmodule Usic.PageController do
  use Usic.Web, :controller

  plug :set_x_frame_headers


  def set_x_frame_headers(conn, _) do
    merge_resp_headers(conn, [
      {"x-frame-options", "allow-from *"}
    ])
  end

  def index(conn, _params) do
    render conn, "index.html"
  end
end
