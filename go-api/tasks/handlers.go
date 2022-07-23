package tasks

import (
	"context"
	"encoding/json"
	"fmt"
	"go-api/database"
	"log"

	"github.com/hibiken/asynq"
)

func HandleChatCreationTask(c context.Context, t *asynq.Task) error {
    
    var chat ChatPayload
    if err := json.Unmarshal(t.Payload(), &chat); err != nil {
        return fmt.Errorf("json.Unmarshal failed: %v: %w", err, asynq.SkipRetry)
    }

    database.Connector.Create(chat)
    log.Printf("Chat Creating Task: application_id=%d, chat_number=%d", chat.ApplicationID, chat.Number)
    
    return nil
}

func HandleMessageCreationTask(c context.Context, t *asynq.Task) error {
    var message MessagePayload
    if err := json.Unmarshal(t.Payload(), &message); err != nil {
        return fmt.Errorf("json.Unmarshal failed: %v: %w", err, asynq.SkipRetry)
    }
    
    database.Connector.Create(message)
    log.Printf("Message Creating Task: chat_id=%d, message_number=%d, body=%s", message.ChatID, message.Number, message.Body)

    return nil
}