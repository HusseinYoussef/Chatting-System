package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"sync"

	"go-api/config"
	"go-api/database"
	"go-api/tasks"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql" // Required for MySQL dialect, _ import a package solely for its side-effects (initialization),

	"github.com/go-redis/redis"

	"github.com/gorilla/mux"
	"github.com/hibiken/asynq"
)

type Application struct {
	ID    int `json:"id"`
	Token string `json:"token"`
	Name  string `json:"name"`
}

type Chat struct {
	ID    int `json:"chat_id"`
	Number int `json:"number"`
}

type Message struct{
	Body string `json:"body"`
}

var redisClientOnce sync.Once
var asyncClientOnce sync.Once

var Connector *gorm.DB
var redisClient *redis.Client
var client *asynq.Client

func main() {

	router := mux.NewRouter()

	// Connect to Database
	connectionString := database.GetConnectionString()
	err := database.Connect(connectionString)
	if err != nil {
		panic(err.Error())
	}
	defer database.Connector.Close()
	//

	// Connect to Redis
	redisClientOnce.Do(func() {
		redisClient = redis.NewClient(&redis.Options{
			Addr: config.RedisUrl,
			DB: config.RedisDB,
		})
	})
	defer redisClient.Close()
	//

	// Connect to Asynq queuing system
    asyncClientOnce.Do(func() {
		client = asynq.NewClient(asynq.RedisClientOpt{Addr: config.RedisUrl, DB: config.RedisDB})
	}) 
    defer client.Close()
	//

    router.HandleFunc("/ping", Pong).Methods("GET")
    router.HandleFunc("/api/v1/applications/{application_token}/chats", ChatsHandler).Methods("POST")
    router.HandleFunc("/api/v1/applications/{application_token}/chats/{chat_number}/messages", MessagesHandler).Methods("POST")

	fmt.Println("Listening on 8000")
    log.Fatal(http.ListenAndServe(":8000", router))
}

func Pong(response http.ResponseWriter, req *http.Request) {
	payload := map[string]interface{} {
		"message": "Pong!! I am still here!",
	}
	
	response.Header().Set("Content-Type", "application/json")
	json.NewEncoder(response).Encode(payload)
}

func ChatsHandler(response http.ResponseWriter, req *http.Request) {
	params := mux.Vars(req)
	response.Header().Set("Content-Type", "application/json")
	
	var app Application
	results := database.Connector.First(&app, "token = ?", params["application_token"])
	
	if results.RowsAffected == 0 {
		response.WriteHeader(http.StatusNotFound)
		json.NewEncoder(response).Encode(map[string]string{"message": "Couldn't find Application"})
		return
	}

	// ENQUEUE TASK
	chat_number := redisClient.Incr(app.Token).Val()
	log.Printf("Chat number: %d", chat_number)

    task, err := tasks.NewChatCreationTask(app.ID, int(chat_number))
    if err != nil {
        log.Fatalf("could not create task: %v", err)
    }
    info, err := client.Enqueue(task)
    if err != nil {
        log.Fatalf("could not enqueue task: %v", err)
    }
    log.Printf("enqueued chat_creation task: id=%s queue=%s", info.ID, info.Queue)

    response.WriteHeader(http.StatusOK)
    json.NewEncoder(response).Encode(map[string]interface{}{
		"message": "Chat is to be created!",
		"chat_number": chat_number,
	})
}


func MessagesHandler(response http.ResponseWriter, req *http.Request) {
	params := mux.Vars(req)
	response.Header().Set("Content-Type", "application/json")

	var msg Message
	_ = json.NewDecoder(req.Body).Decode(&msg)

	if len(msg.Body) == 0 {
		response.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(response).Encode(map[string]string{"message": "Body can't be blank!"})
		return
	}
	
	var app Application
	results := database.Connector.First(&app, "token = ?", params["application_token"])

	if results.RowsAffected == 0 {
		response.WriteHeader(http.StatusNotFound)
		json.NewEncoder(response).Encode(map[string]string{"message": "Couldn't find Application"})
		return
	}
	
	var chat Chat
	results = database.Connector.First(&chat, "application_id = ? AND number = ?", app.ID, params["chat_number"])
	
	if results.RowsAffected == 0 {
		response.WriteHeader(http.StatusNotFound)
		json.NewEncoder(response).Encode(map[string]string{"message": "Couldn't find Chat"})
		return
	}

	// ENQUEUE TASK
	redisKey := fmt.Sprintf("%s_chat%d", app.Token, chat.Number)
	log.Printf("Message creation: %s", redisKey)
	message_number := redisClient.Incr(redisKey).Val()
	task, err := tasks.NewMessageCreationTask(chat.ID, int(message_number), msg.Body)
	if err != nil {
		log.Fatalf("could not create task: %v", err)
	}
	info, err := client.Enqueue(task)
	if err != nil {
		log.Fatalf("could not enqueue task: %v", err)
	}
	log.Printf("enqueued message_creation task: id=%s queue=%s", info.ID, info.Queue)
	
    response.WriteHeader(http.StatusOK)

    json.NewEncoder(response).Encode(map[string]interface{}{
		"message": "Message is to be created!",
		"message_number": message_number,
	})
}