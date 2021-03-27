defmodule KvServer.SocketHandler.Router do
  @moduledoc """
  Роутер сокетов. Содержит приёмник всех сообщений.
  """

  alias KvServer.SocketHandler.Message
  alias KvServer.Storage
  alias KvServer.Registry, as: MyReg

  @storage Storage
  @reg MyReg

  @doc """
  Обработчик входящих сообщений
  """
  @spec handle(Message.t()) :: {:reply, Message.t()} | :ok
  def handle(msg)

  def handle(%Message{type: "get", payload: %{"key" => key}}) when is_binary(key) do
    reply =
      case Storage.get_item(@storage, key) do
        {:ok, value} -> Message.msg_value(key, value)
        :no_data -> Message.msg_no_value(key)
      end

    {:reply, reply}
  end

  def handle(%Message{type: "set", payload: %{"key" => key, "value" => value} = payload})
      when is_binary(key) do
    ttl_parsed =
      case Map.fetch(payload, "ttl") do
        :error -> 0
        {:ok, value} when is_integer(value) and value >= 0 -> value
        _ -> :error
      end

    case ttl_parsed do
      :error ->
        {:reply, Message.msg_error("Invalid TTL. It must be a non-negative value")}

      ttl ->
        Storage.set_item(@storage, key, value, ttl)
        :ok
    end
  end

  def handle(%Message{type: "delete", payload: %{"key" => key}})
      when is_binary(key) do
    Storage.delete_item(@storage, key)
  end

  def handle(%Message{type: "subscribe", payload: %{"key" => key}})
      when is_binary(key) do
    # подписка на изменения ключа

    # беру текущий процесс - процесс сокета
    me = self()

    # регаю колбек, в котором отправлю себе же особое сообщение
    MyReg.register(@reg, key, fn payload ->
      msg =
        case payload do
          {:updated, new_value} -> Message.msg_value(key, new_value)
          :deleted -> Message.msg_no_value(key)
        end

      send(me, msg)
    end)

    :ok
  end

  def handle(%Message{}) do
    {:reply, Message.msg_error("Unknown message")}
  end
end
