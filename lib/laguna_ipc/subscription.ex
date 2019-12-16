defmodule LagunaIpc.Core.Subscription do
  alias LagunaIpc.Core.MessageStore

  use GenServer

  def start_link(%__MODULE__{} = configuration, message_store \\ MessageStore) do
    GenServer.start_link(__MODULE__, [configuration, message_store])
  end

  def init(configuration, message_store) do
    send(self(), :poll)

    {:ok, %{configuration: configuration, message_store: message_store},
     {:continue, :load_cursor}}
  end

  def handle_continue(:load_cursor, %{configuration: c} = state) do
    current_position =
      case load_position(read_last_message, subscriber_stream_name) do
        nil -> 0
        message -> message.data.position
      end

    subscriber_stream_name = "subscriber_position-#{c.subscriber_id}"
    messages_since_last_position_write = 0

    {
      :noreply,
      Map.put(
        state,
        :cursor,
        %{
          subscriber_stream_name: subscriber_stream_name,
          current_position: current_position,
          messages_since_last_position_write: messages_since_last_position_write
        }
      )
    }
  end

  def handle_info(:poll, state) do
    state = case get_next_batch_of_messages(state) do
      [] ->
        Process.send_after(self(), :poll, state.config.tick_interval_ms)
        state
      messages ->
        Process.send(self(), :poll)
        process_batch(messages, state)
    end
    {:noreply, state}
  end

  def write_position(position, subscriber_stream_name, ms) do
    position_event = %{
      id: Ecto.UUID.generate(),
      type: "Read",
      data: %{
        position: position
      }
    }

    ms.write(subscriber_stream_name, position_event)
  end

  def update_read_position(%{configuration: config, message_store: ms, cursor: cursor} = state) do
    cursor =
      Map.put(
        cursor,
        :messages_since_last_position_write,
        cursor.messages_since_last_position_write + 1
      )

    cursor =
      if cursor.messages_since_last_position_write == config.position_update_interval do
        write_position(position, cursor.subscriber_stream_name, ms)
        cursor = Map.put(cursor, :messages_since_last_position_write, 0)
      else
        cursor
      end

    Map.put(state, :cursor, cursor)
  end

  def load_position(read_last_message, subscriber_stream_name) do
    case read_last_message.(subscriber_stream_name) do
      nil -> 0
      position -> position
    end
  end

  def get_next_batch_of_messages(%{configuration: config, message_store: ms, cursor: cursor}) do
    ms.read(c.stream_name, cursor.current_position + 1, c.messages_per_tick)
  end

  def handle_message(message, handler_module) do
    handler_module.handle_in(message)
  end

  def process_batch([], state), do: state

  def process_batch(
        [message | messages],
        %{configuration: config, message_store: ms, cursor: cursor}
      ) do
    state = process_message(message, state)
    process_batch(messages, state)
  end

  def process_message(message, %{configuration: config, message_store: ms, cursor: cursor}) do
    handle_message(message, config.handler_module)
    update_read_position(state)
  end
end
