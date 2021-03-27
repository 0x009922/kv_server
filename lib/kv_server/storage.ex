defmodule KvServer.Storage do
  @moduledoc """
  Здесь реализуется сама логика хранения данных. Можно записывать значения по ключу,
  читать и удалять.

  Реализовано через ETS.

  При записи и удалении чего-либо вызывает dispatch в другом модуле - Registry.

  Важно - при обновлении не надо уведомлять никого, если ничего не поменялось.

  Как сделать так, чтобы по истечении TTL ключ удалялся? Нужно использовать таймеры. При этом использовать в строгой связке,
  ибо если упадут таймеры, то и хранилище должно упасть, иначе нарушится политика TTL.
  """

  use GenServer
  # use TypedStruct

  # typedstruct do
  #   field(:table, any(), enforce: true)
  #   # field(:table, any(), enforce: true)
  # end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  @doc """
  Чтение значения по ключу. Результат будет либо `{:ok, value}`, либо `:no_data`
  """
  def get_item(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  @doc """
  Запись значения по ключу. В случае, если такого значения не было, или если значение отличается от предыдущего,
  будет выслано уведомление в регистр.
  Также есть возможность указать TTL. Если 0, то бесконечно долгое хранение.
  """
  def set_item(pid, key, value, ttl \\ 0) when ttl >= 0 do
    GenServer.call(pid, {:set, {key, value, ttl}})
  end

  @doc """
  Удаление записи в хранилище. Всегда `:ok`
  """
  def delete_item(pid, key) do
    GenServer.call(pid, {:delete, key})
  end

  @doc """
  Инициализация сервера-хранилища. Создаётся ETS-таблица.
  """
  @impl true
  def init(_) do
    table = :ets.new(:storage, [:set, :protected])
    {:ok, %{table: table}}
  end

  @impl true
  def handle_call({:get, key}, _from, %{table: table}) do
    result =
      case :ets.lookup(table, key) do
        # TODO ttl
        [{^key, value, _}] -> {:ok, value}
        _ -> :no_data
      end

    {:reply, result, %{table: table}}
  end

  @impl true
  def handle_call({:set, {key, value, ttl}}, _from, %{table: table}) do
    # нужно посмотреть, есть ли там что-нибудь сейчас
    # если есть и отлично от нового, или если нет, то обновить и уведомить об обновлении
    # если нет, то то

    need_update =
      case :ets.lookup(table, key) do
        [{_key, old_value, _ttl}] when old_value != value -> true
        [] -> true
        _ -> false
      end

    if need_update do
      :ets.insert(table, {key, value, ttl})
      KvServer.Registry.dispatch(KvServer.Registry, key, {:updated, value})
    end

    {:reply, :ok, %{table: table}}
  end

  @impl true
  def handle_call({:delete, key}, _from, %{table: table}) do
    case :ets.lookup(table, key) do
      [{_key, _val, _ttl}] ->
        :ets.delete(table, key)
        KvServer.Registry.dispatch(KvServer.Registry, key, :deleted)

      _ ->
        nil
    end

    {:reply, :ok, %{table: table}}
  end
end
