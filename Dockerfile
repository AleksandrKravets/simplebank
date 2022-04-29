#Build stage
FROM golang:1.18-alpine AS builder
# Set current working directory
WORKDIR /app
# First dot - copy everything from current folder (our app, where we run a "docker build" command)
# Second dot - current working directory inside the image (/app)
COPY . .
RUN go build -o main main.go
RUN apk add curl
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.14.1/migrate.linux-amd64.tar.gz | tar xvz

# Run stage
FROM alpine
WORKDIR /app
# Copy .exe file from builder stage that we defined above (from /app/main to . (/app (current working dir)))
COPY --from=builder /app/main .
COPY --from=builder /app/migrate.linux-amd64 ./migrate
# Copy config file
COPY app.env .
COPY start.sh .
COPY wait-for.sh .
COPY db/migration ./migration



# Run main.exe from working directory
EXPOSE 8080
CMD [ "/app/main" ]
ENTRYPOINT [ "/app/start.sh" ]