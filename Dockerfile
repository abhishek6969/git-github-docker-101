# --- STAGE 1: The Builder (300MB+) ---
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY hello.go .

# Compile the code into a static binary named 'hello'
RUN go build -o hello hello.go


# --- STAGE 2: The Production Image (~5MB) ---
FROM alpine:latest

WORKDIR /app

# We ONLY take the compiled binary. We leave the Go compiler behind!
COPY --from=builder /app/hello .

# Create a non-privileged user
RUN adduser -D myuser

# Change ownership of the app directory
RUN chown -R myuser:myuser /app

# Switch to the new user
USER myuser


CMD ["sh", "-c", "./hello && sleep 10000"]
