defmodule Usic do
  use Application
  require Usic.Executor
  require Usic.Metaserver
  require Usic.Model.Dispatcher

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Usic.Endpoint, []),
      # Start the Ecto repository
      worker(Usic.Repo, []),
      worker(Usic.Executor, []),
      worker(Usic.Metaserver, []),
      worker(Usic.Model.Dispatcher, [])

      # Here you could define other workers and supervisors as children
      # worker(Usic.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Usic.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Usic.Endpoint.config_change(changed, removed)
    :ok
  end
end
