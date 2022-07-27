FROM golang:1.18.2-alpine

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY . .

RUN go build -o /build

EXPOSE 8000

CMD [ "/build" ]