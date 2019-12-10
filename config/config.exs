import Config
config :laguna_ipc, LagunaIpc.MessageStore,
       database: "message_store",
       username: "postgres",
       password: "postgres",
       hostname: "localhost"
