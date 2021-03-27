defmodule KvServer.Registry do
  @moduledoc """
  Через этот модуль проходят события приложения. Модуль Storage делает здесь dispatch
  при изменении данных, а обработчик сокетов подписывается/отписывается от изменений. Ну, в сущности, кто угодно может
  подписываться и диспетчить
  """

  use GenServer
  alias Registry, as: NativeReg
  require Logger

  # Клиентское апи

  @doc """
  Регистрация процесса на событие по какому-то ключу
  """
  def register(registry, key, callback) do
    GenServer.cast(registry, {:register, self(), key, callback})
  end

  @doc """
  Снятие всех регистраций с процесса
  """
  def unregister(registry) do
    GenServer.cast(registry, {:unregister, self()})
  end

  @doc """
  Триггер всех слушателей по ключу и передача им некоего payload
  """
  def dispatch(registry, key, payload) do
    GenServer.cast(registry, {:dispatch, key, payload})
  end

  # Сервер

  @impl true
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  @impl true
  def init(_) do
    table = :ets.new(__MODULE__, [:bag, :protected, :named_table])
    {:ok, table}
  end

  @impl true
  def handle_cast({:register, listener, key, callback}, table) do
    :ets.insert(table, {key, listener, callback})
    {:noreply, table}
  end

  def handle_cast({:unregister, listener}, table) do
    :ets.match_object(table, {:"$1", listener, :"$3"})
    |> Enum.each(fn obj ->
      :ets.delete_object(table, obj)
    end)

    {:noreply, table}
  end

  def handle_cast({:dispatch, key, payload}, table) do
    :ets.match_object(table, {key, :"$2", :"$3"})
    |> Enum.each(fn {_key, _pid, callback} ->
      callback.(payload)
    end)

    {:noreply, table}
  end
end
