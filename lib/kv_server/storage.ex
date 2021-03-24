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

  @doc """
  Чтение значения по ключу
  """
  def get_item(key) do
  end

  @doc """
  Запись значения по ключу. В случае, если такого значения не было, или если значение отличается от предыдущего,
  будет выслано уведомление в регистр.
  Также есть возможность указать TTL. Если 0, то бесконечно долгое хранение.
  """
  def set_item(key, value, ttl \\ 0) when ttl >= 0 do
  end

  @doc """
  Удаление записи в хранилище
  """
  def delete_item(key) do
  end
end
