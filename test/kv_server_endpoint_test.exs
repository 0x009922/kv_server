defmodule KvServerEndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias KvServer.Endpoint

  @opts Endpoint.init([])

  test "returns 404 if nested path" do
    # Create a test connection
    conn = conn(:get, "/hello/world")

    # Invoke the plug
    conn = Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Requested path (/hello/world) not found"
  end

  # test "returns 404 if nested path" do
  #   # Create a test connection
  #   conn = conn(:get, "/hello/world")

  #   # Invoke the plug
  #   conn = Endpoint.call(conn, @opts)

  #   # Assert the response and status
  #   assert conn.state == :sent
  #   assert conn.status == 404
  #   assert conn.resp_body == "Requested path (/hello/world) not found"
  # end
end
