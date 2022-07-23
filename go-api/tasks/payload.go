package tasks

import (
	"encoding/json"

	"github.com/hibiken/asynq"
)

const (
    TypeChatCreation = "chat:create"
    TypeMessageCreation = "message:create"
)

type ChatPayload struct {
    ApplicationID int
    Number int
}

type MessagePayload struct {
    ChatID int
    Number int
    Body string
}

func NewChatCreationTask(application_id int, number int)  (*asynq.Task, error) {
    
    payload, err := json.Marshal(ChatPayload{ApplicationID: application_id, Number: number})
    if err != nil {
        return nil, err
    }
    
    return asynq.NewTask(TypeChatCreation, payload), nil
}

func NewMessageCreationTask(chat_id int, number int, body string)  (*asynq.Task, error) {

    payload, err := json.Marshal(MessagePayload{ChatID: chat_id, Number: number, Body: body})
    if err != nil {
        return nil, err
    }

    // Return a new task with given type and payload.
    return asynq.NewTask(TypeMessageCreation, payload), nil
}