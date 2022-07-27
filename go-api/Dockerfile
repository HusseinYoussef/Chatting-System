FROM golang:1.18.2-alpine

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY . ./

RUN go build -o /worker ./workers/worker.go
RUN go build -o /api

EXPOSE 8000
