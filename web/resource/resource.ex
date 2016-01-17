defprotocol Usic.Resource.Create do
  @fallback_to_any true
  def create(model, params, socket)
end

defprotocol Usic.Resource.Read do
  @fallback_to_any true
  def read(model, params, socket)
end

defprotocol Usic.Resource.Update do
  @fallback_to_any true
  def update(model, params, socket)
end

defprotocol Usic.Resource.Delete do
  @fallback_to_any true
  def delete(model, params, socket)
end

defprotocol Usic.Resource.List do
  @fallback_to_any true
  def list(model, params, socket)
end

defimpl Usic.Resource.Create, for: Any do
  alias Usic.Resource.Helpers
  defdelegate create(model, params, socket), to: Helpers
end

defimpl Usic.Resource.Read, for: Any do
  alias Usic.Resource.Helpers
  defdelegate read(model, params, socket),   to: Helpers
end

defimpl Usic.Resource.Update, for: Any do
  alias Usic.Resource.Helpers
  defdelegate update(model, params, socket), to: Helpers
end

defimpl Usic.Resource.Delete, for: Any do
  alias Usic.Resource.Helpers
  defdelegate delete(model, params, socket), to: Helpers
end

defimpl Usic.Resource.List, for: Any do
  alias Usic.Resource.Helpers
  defdelegate list(model, params, socket), to: Helpers
end
