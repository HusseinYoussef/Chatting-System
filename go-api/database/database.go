package database

import (
	"fmt"
	"go-api/config"
	"log"

	"gorm.io/datatypes"

	"github.com/jinzhu/gorm"
)

type Application struct {
	ID    int `json:"id"`
	Token string `json:"token"`
	Name  string `json:"name"`
}

type Chat struct {
	ID    int `json:"chat_id"`
	ApplicationToken string `json:"application_token"`
	Number int `json:"number"`
	MessagesCount int
	CreatedAt datatypes.Date
	UpdatedAt datatypes.Date
}

type Message struct{
	ID int
	Number int
	ChatId int
	Body string `json:"body"`
	CreatedAt datatypes.Date
	UpdatedAt datatypes.Date
}

//Connector variable used for CRUD operation's
// var connectorOnce sync.Once
var Connector *gorm.DB

func GetConnectionString() string {
	connectionString := fmt.Sprintf("%s:%s@tcp(%s)/%s?charset=utf8mb4&collation=utf8mb4_unicode_ci&parseTime=true&multiStatements=true", config.User, config.Password, config.HOST, config.DB)
	return connectionString
}

//Connect creates MySQL connection
func Connect(connectionString string) error {
	var err error

	// connectorOnce.Do(func() {
	// })
	Connector, err = gorm.Open("mysql", connectionString)
	if err != nil {
		return err
	}
	log.Println("DB Connection was successful!!")

	return nil
}