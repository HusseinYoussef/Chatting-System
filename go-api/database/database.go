package database

import (
	"fmt"
	"go-api/config"
	"log"
	"sync"

	"github.com/jinzhu/gorm"
)

//Connector variable used for CRUD operation's
var connectorOnce sync.Once
var Connector *gorm.DB

func GetConnectionString() string {
	connectionString := fmt.Sprintf("%s:%s@tcp(%s)/%s?charset=utf8mb4&collation=utf8mb4_unicode_ci&parseTime=true&multiStatements=true", config.User, config.Password, config.ServerName, config.DB)
	return connectionString
}

//Connect creates MySQL connection
func Connect(connectionString string) error {
	var err error

	connectorOnce.Do(func() {
		Connector, err = gorm.Open("mysql", connectionString)
	})
	if err != nil {
		return err
	}
	log.Println("DB Connection was successful!!")

	return nil
}