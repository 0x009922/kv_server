defmodule KvServer.SocketHandler do
  @moduledoc """
  Работа с сокетами здесь. Приём сообщений на чтение, запись и подписку на изменение.
  Также отписка от всех подписок в случае, если соединение разрывается
  """

  require Logger
  require Poison
  alias KvServer.SocketHandler.Message
  alias KvServer.SocketHandler.Router

  @behaviour :cowboy_websocket_handler

  # terminate if no activity for one minute
  @timeout 60000

  def init(request, state) do
    Logger.info("Connection init, request: #{inspect(request)}")
    {:cowboy_websocket, request, state, %{idle_timeout: @timeout}}
  end

  # Called on websocket connection initialization.
  def websocket_init(_type, req, _opts) do
    state = %{}
    {:ok, req, state, @timeout}
  end

  # Handle 'ping' messages from the browser - reply
  def websocket_handle({:text, msg}, state) do
    # парсинг сообщений
    case Message.parse(msg) do
      {:ok, msg} ->
        Logger.info("Received message: " <> inspect(msg))

        case Router.handle(msg) do
          {:reply, msg} ->
            Logger.info("Repliying with message: " <> inspect(msg))
            {:reply, {:text, Message.stringify(msg)}, state}

          :ok ->
            {:ok, state}
        end

      :error ->
        Logger.error("Bad message received")
        {:reply, {:text, Message.msg_error("Invalid message") |> Message.stringify()}, state}
    end
  end

  # Format and forward elixir messages to client
  def websocket_info(%Message{} = msg, state) do
    Logger.info("Forwading message: " <> inspect(msg))
    {:reply, {:text, msg |> Message.stringify()}, state}
  end

  # No matter why we terminate, remove all of this pids subscriptions
  def websocket_terminate(_reason, _state) do
    :ok
  end
end
