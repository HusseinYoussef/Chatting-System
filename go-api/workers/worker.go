package main

import (
	"log"

	"go-api/tasks"

	"github.com/hibiken/asynq"
)

func main() {
    // Create and configuring Redis connection.
    redisConnection := asynq.RedisClientOpt{
        Addr: "localhost:6379", // Redis server address
		DB: 0,
    }

    // Create and configuring Asynq worker server.
    worker := asynq.NewServer(redisConnection, asynq.Config{})

    // Create a new task's mux instance.
    mux := asynq.NewServeMux()

    // Define a task handler for the chat task.
    mux.HandleFunc(
        tasks.TypeChatCreation,       // task type
        tasks.HandleChatCreationTask, // handler function
    )

    // Define a task handler for the message task.
    mux.HandleFunc(
        tasks.TypeMessageCreation,       // task type
        tasks.HandleMessageCreationTask, // handler function
    )

    // Run worker server.
    if err := worker.Run(mux); err != nil {
        log.Fatal(err)
    }
}