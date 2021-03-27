defmodule KvServerStorageTest do
  use ExUnit.Case
  alias KvServer.Storage
  # doctest KvServer

  setup do
    store = start_supervised!(Storage)
    %{store: store}
  end

  test "get without action returns :no_data", %{store: store} do
    assert Storage.get_item(store, "key") == :no_data
  end

  test "set returns :ok", %{store: store} do
    assert Storage.set_item(store, "key", 0) == :ok
  end

  test "get after set returns result", %{store: store} do
    Storage.set_item(store, "key", 5)
    assert Storage.get_item(store, "key") == {:ok, 5}
  end

  test "deletion :ok on unexisted key", %{store: store} do
    assert Storage.delete_item(store, "test") == :ok
  end

  test "deletion :ok on existed key", %{store: store} do
    Storage.set_item(store, "key", false)
    assert Storage.delete_item(store, "key") == :ok
  end

  test "deletion works - :no_data after it", %{store: store} do
    Storage.set_item(store, "hey", "ya")
    assert Storage.get_item(store, "hey") == {:ok, "ya"}

    Storage.delete_item(store, "hey")
    assert Storage.get_item(store, "hey") == :no_data
  end
end
