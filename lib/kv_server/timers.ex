defmodule KvServer.Timers do
  @moduledoc """
  Модуль для постановки таймаутов.

  Даёт возможность ставить, переставлять и отменять таймеры по определённым ключам.
  """

  @doc """
  Установка таймера с ключом key, который сработает через `ms` миллисекунд и сделает вызов колбека - анонимной функции.
  Если таймер по данному ключу уже был выставлен, то прошлый будет отменён
  """
  @spec set_timeout(String.t(), number(), fun()) :: :ok
  def set_timeout(key, ms, callback) do
    :ok
  end

  @doc """
  Отмена таймера по ключу
  """
  @spec cancel(String.t()) :: :ok
  def cancel(key) do
    :ok
  end
end
