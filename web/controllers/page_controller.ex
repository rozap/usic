defmodule Usic.PageController do
  use Usic.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
