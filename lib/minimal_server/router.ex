defmodule MinimalServer.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(message()))
  end

  defp message do
    persy_account = System.get_env("PERSY_ACCOUNT")
    persy_token = System.get_env("PERSY_TOKEN")
    from_phone = System.get_env("FROM_PHONE")
    to_phone = System.get_env("TO_PHONE")

    :inets.start()
    :ssl.start()

    {:ok, {_status, _headers, body}} =
      :httpc.request(
        :post,
        {'https://www.persephony.com/apiserver/Accounts/#{persy_account}/Messages',
         [
           {'Authorization',
            'Basic ' ++ :base64.encode_to_string('#{persy_account}:#{persy_token}')}
         ], 'application/json',
         '{"to":"#{to_phone}", "from":"#{from_phone}", "text":"test message from me"}'},
        [],
        []
      )

    %{
      text: "#{body}"
    }
  end
end
