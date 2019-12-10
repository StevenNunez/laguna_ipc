defmodule LagunaIpc.MessageStore do
  use Ecto.Repo,
      otp_app: :laguna_ipc,
      adapter: Ecto.Adapters.Postgres

  alias LagunaIpc.Core.{Message, ResultMessage}

  def write_message(%Message{uuid: nil} = message) do
    message
    |> Map.put(:uuid, Ecto.UUID.generate())
    |> write_message
  end
  def write_message(
        %Message{
          uuid: uuid,
          stream_name: stream_name,
          message_type: message_type,
          message: message,
          context: context,
          expected_version: nil
        }
      ) do
    Ecto.Adapters.SQL.query(
      __MODULE__,
      "SELECT write_message($1, $2, $3, $4, $5)",
      [uuid, stream_name, message_type, message, context]
    )
  end

  def write_message(
        %Message{
          uuid: uuid,
          stream_name: stream_name,
          message_type: message_type,
          message: message,
          context: context,
          expected_version: expected_version
        }
      ) do
    Ecto.Adapters.SQL.query(
      __MODULE__,
      "SELECT write_message($1, $2, $3, $4, $5, $6)",
      [uuid, stream_name, message_type, message, context, expected_version]
    )
  end

  def get_stream_messages(
        %{stream_name: stream_name, position: position, batch_size: batch_size, condition: condition}
      ) do
    {:ok, %{rows: rows}} = Ecto.Adapters.SQL.query(
      __MODULE__,
      "SELECT get_stream_messages($1, $2, $3, $4)",
      [stream_name, position, batch_size, condition]
    )

    rows |> Enum.map(fn [row] -> ResultMessage.new(row) end)
  end
end
