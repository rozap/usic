defmodule Usic.PageControllerTest do
  use Usic.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "μsic"
  end
end
