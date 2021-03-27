defmodule Mix.Tasks.TestHttp do
  use Mix.Task
  require HTTPoison

  @impl true

  def run(_) do
    HTTPoison.start()
    get("test")
    set("test")
    get("test")
    delete("test")
    get("test")
  end

  defp get(key) do
    HTTPoison.get!(build_url(key))
    |> inspect_resp()
  end

  defp set(key) do
    HTTPoison.post!(build_url(key), Poison.encode!(%{"value" => "nyan"}), [
      {"Content-Type", "application/json"}
    ])
    |> inspect_resp()
  end

  defp delete(key) do
    HTTPoison.delete!(build_url(key))
    |> inspect_resp()
  end

  defp build_url(url), do: "http://localhost:3000/" <> url

  defp inspect_resp(%HTTPoison.Response{status_code: code, body: body}) do
    IO.inspect({code, body})
  end
end
