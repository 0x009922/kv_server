defmodule KvServer.Registry do
  @moduledoc """
  Через этот модуль проходят события приложения. Модуль Storage делает здесь dispatch
  при изменении данных, а обработчик сокетов подписывается/отписывается от изменений. Ну, в сущности, кто угодно может
  подписываться и диспетчить
  """

  @doc """
  Регистрация процесса на событие по какому-то ключу
  """
  def register(pid, key, {module, function}) do
  end

  @doc """
  Снятие всех регистраций с процесса
  """
  def unregister(pid) do
  end

  @doc """
  Триггер всех слушателей по ключу и передача им некоего payload
  """
  def dispatch(key, payload) do
  end
end
