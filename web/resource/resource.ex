defprotocol Usic.Resource.Create do
  @fallback_to_any true
  def handle(model, state)
end

defprotocol Usic.Resource.Read do
  @fallback_to_any true
  def handle(model, state)
end

defprotocol Usic.Resource.Update do
  @fallback_to_any true
  def handle(model, state)
end

defprotocol Usic.Resource.Delete do
  @fallback_to_any true
  def handle(model, state)
end

defprotocol Usic.Resource.List do
  @fallback_to_any true
  def handle(model, state)
end

defmodule Usic.Resource.State do
  defstruct params: nil, socket: nil, assigns: nil, resp: nil, error: nil
end