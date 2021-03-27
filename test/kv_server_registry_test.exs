# defmodule KvServerRegistryTest do
#   use ExUnit.Case, async: true
#   alias KvServer.Registry

#   setup do
#     start_supervised!(Registry)
#   end

#   test "register/3 returns :ok", reg do
#     assert :ok == Registry.register(reg, "some_key", fn -> nil end)
#   end

#   test "dispatch after registration works fine", reg do
#     # создаю агента с флагом
#     # регистрирую колбек, который обновляет агента
#     # вызываю диспетч
#     # смотрю, чтобы в агенте что-то поменялось
#     # проблема только в том, что диспетч происходит асинхронно, так что...
#     # надо поставить таймер?

#     test_pid = self()

#     callback = fn {key, payload} ->
#       # посылаю в родительский процесс данные
#       send(test_pid, {:dispatched, key, payload})
#     end

#     # подписка
#     Registry.register(reg, "testing_key", callback)

#     # Отправка
#     payload = %{"some_payload" => false}
#     Registry.dispatch(reg, "testing_key", payload)

#     # Жду сообщение
#     receive do
#       {:dispatched, "testing_key", ^payload} -> :ok
#     end

#     # assert Storage.set_item(store, "key", 0) == :ok
#   end

#   # test "register to 2 keys, dispatch only one", %{store: store} do
#   #   Storage.set_item(store, "key", 5)
#   #   assert Storage.get_item(store, "key") == {:ok, 5}
#   # end

#   # test "register 2 keys, unregister, dispatch of each key do nothing", %{store: store} do
#   #   assert Storage.delete_item(store, "test") == :ok
#   # end
# end
