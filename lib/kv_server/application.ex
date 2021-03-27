defmodule KvServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      {
        Plug.Cowboy,
        scheme: :http,
        plug: KvServer.Endpoint,
        port: 3000,
        dispatch: [
          {:_,
           [
             {"/ws", KvServer.SocketHandler, []},
             {:_, Plug.Adapters.Cowboy.Handler, {KvServer.Endpoint, []}}
           ]}
        ]
      },
      {KvServer.Storage, [name: KvServer.Storage]},
      {KvServer.Registry, [name: KvServer.Registry]}
    ]

    Logger.info("Starting application...")

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KvServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
