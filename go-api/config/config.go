package config

import "os"

func GetEnv(key string, default_value string) string {
	value, exists := os.LookupEnv(key)
	if !exists{
		return default_value
	}
	return value
}

var HOST = GetEnv("HOST", "localhost:3306")
var RedisUrl = GetEnv("RedisUrl", "localhost:6379") 
var ElasticSearchUrl = GetEnv("ElasticSearchUrl", "http://localhost:9200")

const (
	User     		 = "goapp"
	Password         = "password"
	DB               = "chat-api_development"
	RedisDB  		= 0
)
