defmodule KvServer.Endpoint do
  use Plug.Router
  # import Plug.Conn

  # Using Plug.Logger for logging request information
  plug(Plug.Logger)

  # responsible for matching routes
  plug(:match)

  # Using Poison for JSON decoding
  # Note, order of plugs is important, by placing this _after_ the 'match' plug,
  # we will only parse the request AFTER there is a route match.
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)

  # responsible for dispatching responses
  plug(:dispatch)

  # @impl true

  # def init(opts) do
  #   opts |> IO.inspect()
  # end

  # todo фетчить storage откуда-то?

  get "/:key" do
    %{"key" => key} = conn.path_params

    IO.inspect("WTF")

    case KvServer.Storage.get_item(:storage, key) do
      {:ok, value} ->
        conn
        |> send_json_resp(200, %{"value" => value})

      :no_data ->
        conn
        |> send_resp(204, "")
    end
  end

  post "/:key" do
    %{"key" => key} = conn.path_params

    # данные беру из body_params. Там обязательно должен быть value и необязательно ttl.
    case Map.fetch(conn.body_params, "value") do
      {:ok, value} ->
        ttl_parse =
          case Map.fetch(conn.body_params, "ttl") do
            {:ok, ttl} ->
              if is_integer(ttl) and ttl >= 0 do
                {:ok, ttl}
              else
                {:error, ttl}
              end

            :error ->
              {:ok, 0}
          end

        case ttl_parse do
          {:ok, ttl} ->
            # данные есть, провалидированы
            KvServer.Storage.set_item(:storage, key, value, ttl)

            conn
            |> send_resp(202, "Accepted")

          {:error, invalid_ttl} ->
            conn
            |> send_resp(400, "Invalid ttl provided: " <> inspect(invalid_ttl))
        end

      :error ->
        conn
        |> send_resp(400, "No value field")
    end
  end

  delete "/:key" do
    %{"key" => key} = conn.path_params

    KvServer.Storage.delete_item(:storage, key)

    conn
    |> send_resp(200, "OK")
  end

  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.
  match _ do
    send_resp(conn, 404, "Requested path (#{conn.request_path}) not found")
  end

  defp send_json_resp(conn, code, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, Poison.encode!(data))
  end
end
