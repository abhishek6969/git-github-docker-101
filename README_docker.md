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

## ⚡ 3. Advanced Optimization Tips

- **.dockerignore:** Always exclude `.git`, `__pycache__`, and `.env` files.
- **USER Instruction:** Never run as root.

  ```dockerfile
  RUN useradd -m myuser
  USER myuser
  ```
