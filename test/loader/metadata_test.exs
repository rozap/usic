defmodule UsicTest.Metadata do
  use ExUnit.Case
  alias Usic.Loader.Metadata
  @send_receive "5DNVSHm5zr4"

  test "can get the metadata using an ID" do
    Metadata.start

    {:ok, meta} = Metadata.get(@send_receive)
    assert meta.body["title"] =~ "Tycho"
    assert meta.body["keywords"] =~ "Tycho"
  end

end