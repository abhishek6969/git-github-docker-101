# --- STAGE 1: The Builder (300MB+) ---
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY hello.go .

# Compile the code into a static binary named 'hello'
RUN go build -o hello hello.go


# --- STAGE 2: The Production Image (~5MB) ---
FROM alpine:latest

WORKDIR /root/

# We ONLY take the compiled binary. We leave the Go compiler behind!
COPY --from=builder /app/hello .

CMD ["./hello"]
