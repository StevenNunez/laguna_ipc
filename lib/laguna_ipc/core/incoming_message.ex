defmodule LagunaIpc.Core.Message do
  defstruct [:uuid, :stream_name, :message_type, :message, :context, :expected_version]

  def new(protobuf)
end

