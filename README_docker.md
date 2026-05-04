# 🐳 Docker Mastery: Architecture & Optimization

> "A container is not a VM; it's a isolated process on a shared kernel."

---

## 🏗️ 1. The Layered Filesystem (UnionFS)

Docker images are built using a stack of read-only layers.

- **Instruction-to-Layer:** Every `RUN`, `COPY`, and `ADD` creates a new layer.
- **Cache Logic:** Docker reuses layers if the instruction and the files involved haven't changed.
- **The "Bust":** If a layer is "busted" (changed), every single layer following it must be rebuilt.

---

## 🛠️ 2. Standard Operating Procedures (Walkthroughs)

### 📂 Phase 1: FastAPI Cache Optimization

**Goal:** Prevent `pip install` from re-running on every code change.

#### ❌ The Unoptimized Way (Slow Builds)

In this version, any change to your Python code will "bust" the cache at line 3, forcing a re-install of all dependencies.

```dockerfile
FROM python:3.11-slim
WORKDIR /code
COPY . . 
RUN pip install -r requirements.txt
CMD ["uvicorn", "main:app"]
```

#### ✅ The Optimized Way (Fast Builds)

By splitting the `COPY` commands, we protect the `pip install` layer.

```dockerfile
FROM python:3.11-slim
WORKDIR /code

# Step 1: Copy only requirements
COPY requirements.txt .

# Step 2: Install dependencies (This layer is CACHED unless requirements.txt changes)
RUN pip install -r requirements.txt

# Step 3: Copy the rest of the code
COPY . .

CMD ["uvicorn", "main:app"]
```

---

### 📂 Phase 2: Multi-Stage Builds (The "Builder" Pattern)

**Goal:** Reduce image size and improve security by removing build tools from the final image.

#### ❌ The Single-Stage Way (Heavy Image: ~300MB)

This image is huge because it contains the entire Go compiler and source code.

```dockerfile
FROM golang:1.21-alpine
WORKDIR /app
COPY hello.go .
RUN go build -o hello hello.go
CMD ["./hello"]
```

#### ✅ The Multi-Stage Way (Tiny Image: ~10MB)

This version produces a tiny final image by discarding the compiler stage.

```dockerfile
# --- STAGE 1: The Builder ---
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY hello.go .
RUN go build -o hello hello.go

# --- STAGE 2: The Production Image ---
FROM alpine:latest
WORKDIR /root/
# We ONLY take the compiled binary from the builder
COPY --from=builder /app/hello .
CMD ["./hello"]
```

**The Proof:** After building both, you can see the difference using `docker images`. The multi-stage version is ~95% smaller.

---

### 📂 Phase 3: Networking & Service Discovery

**The Simulation:**
We wanted to prove that containers can "see" each other by name if they share a network namespace.

**The Commands:**

1. **Create the custom network:**

   ```powershell
   docker network create lab-net
   ```

2. **Start the "Server" container:**

   ```powershell
   docker run -d --name my-server --network lab-net alpine sleep 3600
   ```

3. **Start the "Client" and ping by name:**

   ```powershell
   docker run --rm --network lab-net alpine ping -c 4 my-server
   ```

**The Conceptual Nuance:**

- **Network Namespaces:** By default, every container is isolated in its own network namespace. If you don't use the `--network` flag, they are like separate computers on separate routers. They cannot communicate by name.
- **Internal DNS:** When you create a custom bridge network, Docker runs a small internal DNS server. It automatically maps the **Container Name** (`my-server`) to its internal IP address.
- **Docker Compose Advantage:** You mentioned using this with FastAPI—`docker-compose` simplifies this by creating a default network for your project and attaching all services to it automatically. This is why your FastAPI app could talk to `db` without manual network commands.

---

### 📂 Phase 4: Persistence & Data Management

**The Goal:** Prevent data loss when a container is deleted by moving it from the "Writable Layer" to a managed "Volume."

**The Simulation (Data Loss):**

1. **Start a container and create data:**
   `docker run --name temp-node alpine sh -c "echo 'gone' > /file.txt"`
2. **Delete the container:**
   `docker rm temp-node`
3. **Result:** The data is destroyed because it lived in the container's temporary Writable Layer.

**The Resolution (The Named Volume):**

1. **Create a Managed Volume:**
   `docker volume create my-safe-data`
2. **Mount the Volume to a container:**
   `docker run --name persistent-node -v my-safe-data:/data alpine sh -c "echo 'saved' > /data/file.txt"`
3. **Delete container and verify with a NEW one:**
   `docker rm persistent-node`
   `docker run --rm -v my-safe-data:/data alpine cat /data/file.txt`
**The Result:** The second container successfully reads the data. The volume has a separate lifecycle from the container.

**The Internal Logic:**

- **Bypassing UnionFS:** Volumes do not use the layered filesystem. They map directly to a directory on the host's disk. This provides **Native I/O Speed** and prevents "White-out" deletion issues.
- **Bind Mounts vs Volumes:** Use Bind Mounts for local code (source code syncing); use Named Volumes for databases (performance and portability).

---

### 📂 Phase 5: Orchestration with Docker Compose
**The Goal:** Manage a multi-container stack (FastAPI + Postgres) as a single unit with a declarative "Blueprint."

**The Simulation (The Race Condition):**
If a FastAPI app starts and tries to connect to Postgres before the DB is ready, the app will crash.
1. **The Fix:** Use `healthcheck` in the Postgres service.
2. **The link:** Use `depends_on` with `condition: service_healthy` in the FastAPI service.

**The Internal Logic:**
- **Project Isolation:** Compose prefixes all resources (networks, volumes) with your project name. This allows multiple environments (Dev/Test) to run on the same host without clashing.
- **Scaling:** You can scale services horizontally using `docker-compose up --scale <service>=<n>`. Docker Compose handles the internal load balancing across the network.
- **Environment Parity:** By using a `.env` file and Docker Compose, we ensure the "Dev" environment is identical to "Production," reducing the "it works on my machine" bugs.

#### ✅ The Production-Ready Example (`docker-compose.yml`)
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy  # Wait for DB to be READY, not just started
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/fastapi_db

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=fastapi_db
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d fastapi_db"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  db-data:  # Named volume for persistence
```

---

### 📂 Phase 6: Security & Production Hardening
**The Goal:** Prevent "Container Escape" attacks by removing root privileges and setting resource guardrails.

#### ❌ The Unoptimized Way (Running as Root)
Running as root is dangerous; if the app is compromised, the attacker has full system access.
```dockerfile
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/hello .
CMD ["./hello"]
```

#### ✅ The Optimized Way (Hardened User & Resource Limits)
We create a custom user and ensure we use the correct shell form for complex commands.
```dockerfile
FROM alpine:latest
WORKDIR /app

# Step 1: Copy binary
COPY --from=builder /app/hello .

# Step 2: Create a non-privileged user
RUN adduser -D myuser

# Step 3: Fix permissions for the app folder
RUN chown -R myuser:myuser /app

# Step 4: Switch to the non-root user
USER myuser

# Step 5: Execute with shell if using operators like &&
CMD ["sh", "-c", "./hello && sleep 10000"]
```

**The Simulation (Resource Limits):**
To prevent a single container from crashing the host, we set physical hardware limits:
- **Command:** `docker run -d --cpus="0.5" --memory="512m" tiny-go-app`

**The Internal Logic:**
- **Namespaces (User Isolation):** Switches the "ID" of the process inside the container so it doesn't match the host's root ID.
- **Cgroups (Control Groups):** The Linux kernel feature that physically limits how much hardware (CPU/RAM) a process can touch.
- **Exec vs Shell Form:** The "Exec form" `["..."]` is preferred for production because it passes signals (like `SIGTERM`) directly to your app. If you use `&&`, you MUST use `["sh", "-c", "..."]`.

---

---

---

## ⚡ 3. Advanced Optimization Tips

- **.dockerignore:** Always exclude `.git`, `__pycache__`, and `.env` files.
- **USER Instruction:** Never run as root.

  ```dockerfile
  RUN useradd -m myuser
  USER myuser
  ```
