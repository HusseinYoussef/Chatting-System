package tasks

import (
	"context"
	"encoding/json"
	"fmt"
	"go-api/config"
	"go-api/database"
	"log"
	"strconv"
	"time"

	"github.com/olivere/elastic/v7"

	"github.com/hibiken/asynq"
	"gorm.io/datatypes"
)

func HandleChatCreationTask(c context.Context, t *asynq.Task) error {
    
    var chat_payload ChatPayload
    if err := json.Unmarshal(t.Payload(), &chat_payload); err != nil {
        return fmt.Errorf("json.Unmarshal failed: %v: %w", err, asynq.SkipRetry)
    }

    connectionString := database.GetConnectionString()
	err := database.Connect(connectionString)
	if err != nil {
		panic(err.Error())
	}
	defer database.Connector.Close()

    var chat database.Chat
    
    chat.Number = chat_payload.Number
    chat.ApplicationToken = chat_payload.ApplicationToken
    chat.MessagesCount = 0
    chat.CreatedAt = datatypes.Date(time.Now())
    chat.UpdatedAt = datatypes.Date(time.Now())
    
    database.Connector.Create(&chat)

    log.Printf("Chat Creating Task: application_token=%s, chat_number=%d", chat.ApplicationToken, chat.Number)
    
    return nil
}

func HandleMessageCreationTask(c context.Context, t *asynq.Task) error {
    var message_payload MessagePayload
    if err := json.Unmarshal(t.Payload(), &message_payload); err != nil {
        return fmt.Errorf("json.Unmarshal failed: %v: %w", err, asynq.SkipRetry)
    }
    
    connectionString := database.GetConnectionString()
	err := database.Connect(connectionString)
	if err != nil {
		panic(err.Error())
	}
	defer database.Connector.Close()

    var message database.Message
    
    message.Number = message_payload.Number
    message.ChatId = message_payload.ChatID
    message.Body = message_payload.Body
    message.CreatedAt = datatypes.Date(time.Now())
    message.UpdatedAt = datatypes.Date(time.Now())
    
    database.Connector.Create(&message)

    log.Printf("Message Creating Task: chat_id=%d, message_number=%d, body=%s", message.ChatId, message.Number, message.Body)

    InsertIntoElasticSearchIndex(message)

    return nil
}

func InsertIntoElasticSearchIndex(message database.Message){

    esclient, err :=  elastic.NewClient(elastic.SetURL(config.ElasticSearchUrl),
    elastic.SetSniff(false),
    elastic.SetHealthcheck(false))

    if err != nil {
		fmt.Println("Error initializing : ", err)
		panic("Client fail ")
	} else {
        fmt.Println("ES initialized...")
    }
    
	es_payload, _ := json.Marshal(map[string]interface{}{
        "number": message.Number,
        "body": message.Body,
        "chat_id": message.ChatId,
    })

	data := string(es_payload)
	ind, err := esclient.Index().
		Index("messages").
        Id(strconv.Itoa(message.ID)).
		BodyJson(data).
		Do(context.Background())

    if err != nil {
		panic(err)
	}

    log.Printf("Done Inserting into Elastic Search Index, Result: %s", ind.Result)
}