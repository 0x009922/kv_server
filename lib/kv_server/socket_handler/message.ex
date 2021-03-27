defmodule KvServer.SocketHandler.Message do
  use TypedStruct
  alias KvServer.SocketHandler.Message

  typedstruct enforce: true do
    field(:type, String.t())
    field(:payload, any())
  end

  @spec new(String.t(), any) :: t()
  def new(type, payload) do
    %Message{type: type, payload: payload}
  end

  @doc ~S"""
  Построение сообщения с ошибкой. Shorthand

    iex> KvServer.SocketHandler.Message.msg_error("no body provided")
    %KvServer.SocketHandler.Message{type: "error", payload: "no body provided"}
  """
  @spec msg_error(String.t()) :: t()
  def msg_error(message) do
    %Message{type: "error", payload: message}
  end

  @doc ~S"""
  Сообщение со значением по ключу

    iex> KvServer.SocketHandler.Message.msg_value("foo", "bar")
    %KvServer.SocketHandler.Message{type: "value", payload: %{key: "foo", value: "bar"}}
  """
  @spec msg_value(any, any) :: KvServer.SocketHandler.Message.t()
  def msg_value(key, value) do
    %Message{type: "value", payload: %{key: key, value: value}}
  end

  @doc ~S"""
  Сообщение о том, что значения по ключу нет

    iex> KvServer.SocketHandler.Message.msg_no_value("some_key")
    %KvServer.SocketHandler.Message{type: "no-value", payload: %{key: "some_key"}}
  """
  def msg_no_value(key) do
    %Message{type: "no-value", payload: %{key: key}}
  end

  @doc ~S"""
  Получает строкое сообщение и парсит его в структуру, либо возвращает ошибку

  ## Examples

    iex> KvServer.SocketHandler.Message.parse("{\"type\": \"test\", \"payload\": null}")
    {:ok, %KvServer.SocketHandler.Message{type: "test", payload: nil}}

    iex> KvServer.SocketHandler.Message.parse("Unknown stuff")
    :error
  """
  @spec parse(some_text_msg: String.t()) :: {:ok, t()} | :error
  def parse(some_text_msg) do
    case Poison.decode(some_text_msg) do
      {:ok, %{"type" => type, "payload" => payload}} when is_binary(type) ->
        {:ok, new(type, payload)}

      _ ->
        :error
    end
  end

  @doc ~S"""
  Перевод структуры в JSON-строчку

  ## Examples

    iex> msg = KvServer.SocketHandler.Message.new("nya", %{"mur" => "myav"})
    iex> KvServer.SocketHandler.Message.stringify(msg)
    "{\"type\":\"nya\",\"payload\":{\"mur\":\"myav\"}}"
  """
  @spec stringify(t()) ::
          binary
          | maybe_improper_list(
              binary | maybe_improper_list(any, binary | []) | byte,
              binary | []
            )
  def stringify(%Message{} = msg) do
    Poison.encode!(msg)
  end
end

defimpl Inspect, for: KvServer.SocketHandler.Message do
  import Inspect.Algebra

  def inspect(%KvServer.SocketHandler.Message{type: t, payload: p}, opts) do
    concat(["#Message<", to_doc({t, p}, opts), ">"])
  end
end
