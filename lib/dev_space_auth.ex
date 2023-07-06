defmodule DevSpaceAuth do
  @moduledoc """
  `DevSpaceAuth`.is a wrapper around `Plug.BasicAuth` with a rate limiting
  """
  @behaviour Plug
  import Plug.Conn
  @bucket_name "dev_space_auth"
  @attempts 5
  @period :timer.seconds(60)

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    with {:ok, credentials} <- credentials(),
         {:allow, _} <- Hammer.check_rate_inc(@bucket_name, @period, @attempts, 0) do
      case Plug.BasicAuth.basic_auth(conn, credentials) do
        %Plug.Conn{halted: true, status: 401} = conn ->
          Hammer.check_rate_inc(@bucket_name, @period, @attempts, 1)
          conn

        conn ->
          conn
      end
    else
      {:deny, _} ->
        conn
        |> send_resp(429, "Too many failed attempts")
        |> halt()

      _error ->
        conn
        |> send_resp(401, "Unauthorized")
        |> halt()
    end
  end

  defp credentials do
    with {:ok, username} <- :username |> config() |> ensure_not_blank_binary(),
         {:ok, password} <- :password |> config() |> ensure_not_blank_binary() do
      {:ok, [username: username, password: password]}
    else
      :error -> {:error, :not_configured}
    end
  end

  defp ensure_not_blank_binary(value) do
    value = String.trim(to_string(value))

    if value == "" do
      :error
    else
      {:ok, value}
    end
  end

  defp config(param) do
    Application.get_env(:dev_space_auth, param)
  end
end
