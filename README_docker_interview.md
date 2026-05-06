# 🎯 Docker Interview Questions & Scenarios

---

## 📐 Basic Concepts & Architecture

### Q0: Can you provide a simple Dockerfile example for a Python application?

**Answer:** A Dockerfile is a text file containing step-by-step instructions to build a Docker image. For a simple Python app:

```dockerfile
# Step 1: Set the base image
FROM python:3.11-slim

# Step 2: Set the working directory inside the container
WORKDIR /app

# Step 3: Copy only the source file (or requirements first for caching)
COPY app.py /app

# Step 4: Specify the default command to run the app
CMD ["python", "app.py"]
```

- `FROM` — defines the base OS/runtime layer.
- `WORKDIR` — creates and sets the home directory inside the container.
- `COPY` — brings your local code into the container's filesystem.
- `CMD` — the default command executed when the container starts.

### Q1: What is Docker and how is it fundamentally different from a VM?

**Answer:** Docker is a containerization platform that packages an application along with all its dependencies so it can run consistently anywhere.

- **VMs** require a full Guest OS per application — heavy on memory/CPU and take minutes to boot.
- **Containers** share the host's OS kernel — they boot in seconds, consume far fewer resources, and let you run many more apps on the same hardware.
- **Key Isolation Tools:** Docker uses **Namespaces** (PID, Network, User, Mount, IPC) for process isolation and **Cgroups** for resource limiting (CPU, RAM).

### Q2: What are the main components of Docker's architecture?

**Answer:** Docker uses a client-server architecture:

- **Docker Client:** The CLI you type commands into (`docker run`, `docker build`).
- **Docker Daemon (Dockerd):** The background engine on the host that builds, runs, and destroys containers.
- **Docker Images:** Read-only blueprints built from a `Dockerfile`. Contains your code, libraries, and settings.
- **Docker Registry (e.g., Docker Hub):** Cloud or local storage where images are stored, shared, and distributed.

### Q3: What is a Docker Namespace?

**Answer:** A namespace is a Linux kernel feature that provides the core layer of isolation for containers. It partitions OS resources in a mutually exclusive manner so containers cannot interfere with the host or each other.

- **Examples:** PID (process IDs), Mount (filesystem), User (user IDs), Network, IPC.

---

## 🖼️ Images & Dockerfile Instructions

### Q4: Why is the order of `COPY` and `RUN` instructions critical?

**Answer:** Because of **Layer Caching**. Docker builds from top to bottom. If a layer changes, all subsequent layers are rebuilt. By copying `requirements.txt` before `COPY . .`, we ensure that code changes don't trigger a re-install of all packages.

### Q5: What are Multi-Stage Builds and Distroless images?

**Answer:**

- **Multi-Stage Builds:** Use multiple `FROM` statements. Stage 1 uses a heavy compiler image to build the code. Stage 2 uses a tiny base image and copies only the final binary — leaving all build tools behind.
- **Distroless/Scratch images:** Contain only the runtime needed (no bash, no package managers). This gives maximum security because attackers have no OS tools to exploit.

### Q6: CMD vs. ENTRYPOINT — What is the real difference?

**Answer:**

- `ENTRYPOINT` defines the **primary, fixed executable** the container will always run. It is not meant to be easily overridden.
- `CMD` provides **default arguments** to the entrypoint. Unlike `ENTRYPOINT`, `CMD` is completely overridden if the user adds a command at the end of `docker run`.
- *Pro Tip:* Use `ENTRYPOINT ["python", "main.py"]` and `CMD ["--port", "80"]` for flexible, production-ready containers.

### Q7: What is the difference between `COPY` and `ADD`?

**Answer:**

- `COPY` is the simpler, preferred choice — it only copies files from your local machine into the container.
- `ADD` has extra features: it can download files from internet URLs and automatically extract `.tar` archives inside the container.
- **Best Practice:** Always use `COPY` unless you specifically need `ADD`'s features.

### Q8: What is the difference between "Shell form" and "Exec form" in CMD?

**Answer:**

- **Exec form** `["executable", "param"]` is preferred for production. It runs the process directly without a shell, meaning `SIGTERM` signals are passed directly to your app (Graceful Shutdown).
- **Shell form** `executable param` wraps the command in `/bin/sh -c`. Useful for shell operators like `&&` or `|`, but prevents correct signal handling unless you use `exec`.

---

## ⚙️ Essential Commands & Container Management

### Q9: What is the difference between `docker create`, `docker start`, and `docker run`?

**Answer:**

- `docker create`: Sets up the container in a **stopped state**, saving the container ID for later.
- `docker start`: Resumes a container that already exists but was previously stopped.
- `docker run`: Combines both — creates a brand new container from an image and immediately starts it.

### Q10: What are the most common commands for managing and troubleshooting containers?

**Answer:**

- `docker ps -a` — Lists all containers (running and stopped).
- `docker exec -it <id> /bin/sh` — Opens an interactive shell inside a running container (use `sh` for Alpine, `bash` for Debian/Ubuntu).
- `docker inspect <id>` — Returns detailed JSON config: network IPs, volumes, environment variables.
- `docker stats <id>` — Real-time CPU, memory, and network metrics.
- `docker network create <name>` — Creates a custom isolated network for secure inter-container communication.

### Q11: How do you safely clean up disk space when Docker runs out of space?

**Answer:**

1. **Diagnose first:** `docker system df` — shows what is eating space.
2. **Surgical cleanup:** `docker image prune` (removes dangling images), `docker container prune` (removes stopped containers).
3. **Nuclear option (careful in prod):** `docker system prune` — wipes all unused data permanently.

---

## 🌐 Networking & Storage

### Q12: What are the Docker Networking modes?

**Answer:**

- **Bridge (Default):** Creates an isolated internal network for containers on the same host to communicate securely.
- **Host:** Removes network isolation completely — the container shares the host's network stack directly (fast, less isolated).
- **Overlay:** For multi-machine clusters (Docker Swarm). Creates a VXLAN tunnel so containers on different servers talk as if on the same LAN.
- **Macvlan:** Assigns a real MAC address to a container, making it appear as a physical device on the network.

### Q13: Bind Mounts vs. Named Volumes — When to use which?

**Answer:**

- **Named Volumes:** Managed by Docker, stored in `/var/lib/docker/volumes`. Preferred for production and databases — more secure, portable, and performant.
- **Bind Mounts:** Map a specific host folder directly into the container. Best for local development (instant code sync, no rebuild needed).

### Q14: What happens when a container exceeds its Memory vs. CPU limits?

**Answer:**

- **Memory (RAM):** The container is **Killed** by the OOM (Out Of Memory) Killer.
- **CPU:** The container is **Throttled** — slowed down to stay within the limit, but not killed.

---

## 🔒 Logging, Security & Troubleshooting

### Q15: What is the difference between Daemon-level and Container-level logging?

**Answer:**

- **Daemon-level:** Configures logging behavior for the global Docker Daemon — affects ALL containers on the host.
- **Container-level:** Logs specific to one container's stdout/stderr. Viewed with `docker logs <container_id>`.

### Q16: Why is running a container as `root` dangerous, and how do you prevent it?

**Answer:** If a hacker exploits a vulnerability, they could break out of the container and gain root access to the entire host machine.

- **Prevention:** Use the `USER` instruction in your `Dockerfile` to create a restricted non-root user.
- **Enterprise Practice:** Use `USER 1001` (UID) instead of `USER myuser` — numeric IDs are more portable across Kubernetes and OpenShift environments.
- **Extra hardening:** Use `--cap-drop=ALL` flag to strip all Linux capabilities from the container.

### Q17: How do you debug a failing container?

**Answer:** Follow these steps:

1. `docker logs <id>` — Read error stack traces and stdout.
2. `docker exec -it <id> /bin/sh` — Jump inside and manually test connections or inspect files.
3. `docker inspect <id>` — Verify environment variables, mounts, and network setup.
4. `docker stats <id>` — Check if it's starving for CPU or memory.

### Q18: How does Docker handle Signal Handling (SIGTERM)?

**Answer:** When you run `docker stop`, Docker sends `SIGTERM` to PID 1. If the app doesn't handle it, it is forcefully killed (`SIGKILL`) after 10 seconds. This is why using **exec form** `["python", "main.py"]` is critical — it ensures your app receives the signal for a graceful shutdown.

### Q19: Your container has a "Zombie Process" (Defunct). What causes this?

**Answer:** PID 1 is not properly "reaping" finished child processes. Use a tiny init system like `tini` (`--init` flag) inside your container to handle this correctly.

---

## 🚀 Advanced Architecture (Compose, Swarm & Kubernetes)

### Q20: What is Docker Compose and when would you use it?

**Answer:** Docker Compose uses a YAML file (`docker-compose.yml`) to define and run multi-container applications. Instead of running multiple `docker run` commands manually, you define all services (frontend, backend, database) and launch the entire stack with a single command: `docker-compose up`.

### Q21: Does `depends_on` wait for a database to be "ready"?

**Answer:** No. By default, it only waits for the container to **start**, not to be **ready** (accepting connections). To wait for readiness, combine `depends_on` with a `healthcheck` and `condition: service_healthy`.

### Q22: How do you scale a service in Docker Compose?

**Answer:** `docker-compose up --scale <service>=<n>`. Note: fixed port mappings (e.g., `80:80`) prevent scaling beyond 1 unless you use a Load Balancer or dynamic port assignment.

### Q23: What is the difference between Docker Swarm and Kubernetes (K8s)?

**Answer:** Both are container orchestration tools for managing and scaling containers across multiple servers.

- **Docker Swarm:** Native to Docker, simple to set up, great for basic clustering. Integrated seamlessly with the Docker ecosystem.
- **Kubernetes (K8s):** The industry standard for enterprise applications. Much more complex but vastly superior — better auto-scaling, self-healing, flexibility, and a massive community ecosystem.

---

## 🏗️ Real-World Scenarios

**Scenario: Your Docker build is taking 10 minutes every time, even for a 1-line code change.**

- **Action:** Reorder layers. Move heavy `RUN` commands (`pip install`, `apt install`) above `COPY . .`. This protects the heavy layer from being busted on code changes.

**Scenario: Your FastAPI app can't connect to Postgres, but both containers are running.**

- **Action:** Confirm they are on the same **User-Defined Network**. Connect using the **container name** (`db:5432`), not `localhost:5432`.

**Scenario: You need Dev and Production environments to be identical but with different credentials.**

- **Action:** Use a `.env` file for local secrets. Docker Compose injects them as environment variables, overriding the image's default `ENV` values.

**Scenario: A container is repeatedly crashing and restarting.**

- **Action:** Use `docker logs <id>` to read the crash error. Then `docker inspect <id>` to check for misconfigured environment variables or mounts.

---

## 🧩 Additional Frequently Asked Questions

### Q24: What is a Docker Image Layer and how is it shared?

**Answer:** Every instruction in a Dockerfile (`RUN`, `COPY`, `ADD`) creates a new read-only layer. These layers are **shared across images** — if two images use the same `FROM python:3.11-slim` base, that base layer is stored only once on disk. This makes Docker highly storage-efficient. When a container runs, Docker adds a thin writable layer on top; when the container is deleted, only this writable layer is removed.

### Q25: What is the difference between `docker stop` and `docker kill`?

**Answer:**

- `docker stop`: Sends `SIGTERM` first, giving the app time to shut down gracefully. After 10 seconds, sends `SIGKILL`.
- `docker kill`: Sends `SIGKILL` immediately — brutal, no grace period. Used when a container is frozen and unresponsive.

### Q26: What is a Dangling Image and how do you remove it?

**Answer:** A dangling image is an image that has no tag (shows as `<none>:<none>`) — typically created when you rebuild an image with the same tag, making the old one untagged.

- **Remove all dangling images:** `docker image prune`
- **View dangling images:** `docker images -f "dangling=true"`

### Q27: What is the purpose of `.dockerignore`?

**Answer:** Similar to `.gitignore`, it tells Docker which files to **exclude** from the build context sent to the Docker daemon. This speeds up builds and prevents sensitive files from being accidentally baked into the image.

- **Common entries:** `.git`, `__pycache__`, `*.pyc`, `.env`, `node_modules`

### Q28: What is Docker Content Trust (DCT)?

**Answer:** DCT is a security feature that uses digital signatures to verify the integrity and publisher of Docker images. When enabled (`DOCKER_CONTENT_TRUST=1`), Docker will only pull and run images that have been cryptographically signed — preventing supply chain attacks from tampered images.

### Q29: What is the difference between `EXPOSE` and publishing a port (`-p`)?

**Answer:**

- `EXPOSE` in the Dockerfile is **documentation only** — it tells other developers which port the app listens on, but does not actually publish it to the host.
- `-p 8000:8000` in `docker run` actually **maps** the container port to a host port, making it accessible from outside.

### Q30: How does Docker handle container restart policies?

**Answer:** You set a restart policy with `--restart` flag:

- `no` (default): Never restart.
- `always`: Always restart, even after `docker stop`.
- `on-failure`: Only restart if the exit code is non-zero (app crashed).
- `unless-stopped`: Restart always, except when manually stopped with `docker stop`.
- **Example:** `docker run -d --restart=on-failure:3 myapp` (max 3 retries).

### Q31: What is the difference between `docker image build` cache and `--no-cache`?

**Answer:** Docker caches each layer. If the instruction and files are unchanged, it reuses the cached layer (fast builds). Using `--no-cache` forces Docker to rebuild every single layer from scratch — useful when you want to ensure fresh package installs (e.g., `apt-get update` pulling latest packages).

### Q32: What are the security risks of mounting the Docker socket (`/var/run/docker.sock`)?

**Answer:** Mounting the Docker socket into a container gives it **full control over the Docker daemon** — effectively making it root on the host. This is one of the most dangerous misconfigurations in Docker. A compromised container with socket access can spawn new containers, delete images, or escape to the host entirely. Avoid it in production; use dedicated APIs or Docker-in-Docker (`dind`) as safer alternatives.

---

## 💻 Docker Commands Cheatsheet (With Examples)

### 📦 Image Management

```powershell
# Build an image from the current directory Dockerfile
docker build -t my-fastapi-app:1.0 .

# Build without using the cache
docker build --no-cache -t my-fastapi-app:1.0 .

# List all images
docker images

# Remove a specific image
docker rmi my-fastapi-app:1.0

# Remove all dangling (untagged) images
docker image prune

# Pull an image from Docker Hub
docker pull python:3.11-slim

# Push an image to Docker Hub
docker tag my-fastapi-app:1.0 myusername/my-fastapi-app:1.0
docker push myusername/my-fastapi-app:1.0

# Show image layer history and sizes
docker history my-fastapi-app:1.0
```

### 🚀 Container Lifecycle

```powershell
# Run a container (detached, named, with port mapping)
docker run -d --name fastapi-app -p 8000:8000 my-fastapi-app:1.0

# Run with resource limits
docker run -d --name fastapi-app --cpus="0.5" --memory="512m" my-fastapi-app:1.0

# Run with a restart policy
docker run -d --restart=on-failure:3 --name fastapi-app my-fastapi-app:1.0

# Run with environment variables
docker run -d -e DATABASE_URL=postgresql://user:pass@db:5432/mydb my-fastapi-app:1.0

# Run an interactive shell (Alpine uses sh, Debian/Ubuntu uses bash)
docker run -it --rm alpine sh
docker run -it --rm python:3.11-slim bash

# List running containers
docker ps

# List ALL containers (including stopped)
docker ps -a

# Stop, start, and remove a container
docker stop fastapi-app
docker start fastapi-app
docker rm fastapi-app

# Force remove a running container
docker rm -f fastapi-app

# View logs (follow mode)
docker logs -f fastapi-app

# Execute a command inside a running container
docker exec -it fastapi-app sh

# Check what user the container is running as
docker exec fastapi-app whoami

# Copy a file from container to host
docker cp fastapi-app:/app/logs/error.log ./error.log
```

### 🌐 Network Management

```powershell
# Create a custom bridge network
docker network create my-app-net

# List all networks
docker network ls

# Run containers on the same custom network (they can talk by name)
docker run -d --name db --network my-app-net postgres:15-alpine
docker run -d --name web --network my-app-net -p 8000:8000 my-fastapi-app:1.0

# Inspect a network (see which containers are attached and their IPs)
docker network inspect my-app-net

# Connect a running container to a network
docker network connect my-app-net fastapi-app

# Disconnect a container from a network
docker network disconnect my-app-net fastapi-app

# Remove a network (only works if no containers are attached)
docker network rm my-app-net
```

### 💾 Volume Management

```powershell
# Create a named volume
docker volume create my-db-data

# List all volumes
docker volume ls

# Run a container with a named volume (persists data across container restarts/deletes)
docker run -d --name db -v my-db-data:/var/lib/postgresql/data postgres:15-alpine

# Inspect a volume (see where Docker stores it on disk)
docker volume inspect my-db-data

# Write to a volume from one container
docker run --rm -v my-db-data:/data alpine sh -c "echo 'hello' > /data/test.txt"

# Read from the same volume in a NEW container (proves persistence)
docker run --rm -v my-db-data:/data alpine cat /data/test.txt

# Remove a volume (WARNING: permanent data loss)
docker volume rm my-db-data

# Remove all unused volumes
docker volume prune
```

### 🩺 Monitoring & Diagnostics

```powershell
# Live CPU, memory, network stats for all running containers
docker stats

# Deep JSON inspection of a container (network, mounts, env vars)
docker inspect fastapi-app

# Show running processes inside a container
docker top fastapi-app

# Show disk usage by images, containers, and volumes
docker system df

# Full system cleanup (removes stopped containers, unused networks, dangling images)
docker system prune

# Also remove unused volumes (DANGEROUS in production)
docker system prune --volumes
```

### 🐙 Docker Compose

```powershell
# Start the entire stack (detached)
docker-compose up -d

# Start and force rebuild images
docker-compose up -d --build

# Scale a specific service to 3 instances
docker-compose up -d --scale web=3

# View logs for a specific service
docker-compose logs -f web

# Stop all services (containers stay)
docker-compose stop

# Stop and REMOVE containers, networks
docker-compose down

# Stop and REMOVE containers, networks, AND volumes (DANGEROUS)
docker-compose down -v

# List running services in the compose stack
docker-compose ps
```

---

## 🔍 Image Security Scanning

### Q33: Why do we scan Docker images and when should it happen?

**Answer:** Docker images often include OS packages and libraries with known **CVEs (Common Vulnerabilities and Exposures)**. Scanning catches these before a vulnerable image reaches production. The ideal place to scan is in the **CI/CD pipeline** — right after `docker build` and before `docker push`. This enforces a "shift-left" security model.

### Q34: What are the most common Docker image scanning tools?

| Tool | Who Makes It | Key Feature |
|---|---|---|
| **Docker Scout** | Docker Inc. | Built into Docker CLI (`docker scout cves`) |
| **Trivy** | Aqua Security | Fast, open-source, scans OS packages + language libs |
| **Snyk** | Snyk | Deep language-level scanning, great GitHub integration |
| **Grype** | Anchore | Open-source, pairs well with Syft (SBOM generator) |
| **Clair** | Quay/Red Hat | Used in enterprise registries like Quay.io |

### Q35: How do you scan an image using Docker Scout and Trivy?

**Answer:**

**Docker Scout (built-in):**

```powershell
# Scan a local image for CVEs
docker scout cves my-fastapi-app:1.0

# Get a quick summary
docker scout quickview my-fastapi-app:1.0
```

**Trivy (open-source, most popular in CI):**

```powershell
# Install via package manager or binary, then scan:
trivy image my-fastapi-app:1.0

# Fail CI if CRITICAL vulnerabilities are found
trivy image --exit-code 1 --severity CRITICAL my-fastapi-app:1.0

# Scan a tarball (useful in airgapped environments)
docker save my-fastapi-app:1.0 | trivy image --input -
```

### Q36: What is a Software Bill of Materials (SBOM) in Docker context?

**Answer:** An SBOM is a complete inventory of all packages, libraries, and components inside a Docker image. Tools like **Syft** generate it, and **Grype** can scan it for vulnerabilities. In regulated industries (finance, healthcare), generating an SBOM is often a compliance requirement.

```powershell
# Generate SBOM for an image
syft my-fastapi-app:1.0 -o json > sbom.json

# Scan the SBOM for vulnerabilities
grype sbom:./sbom.json
```

---

## 🤖 Docker + GitHub Actions (CI/CD Pipeline)

### Q37: What is the typical Docker CI/CD flow in GitHub Actions?

**Answer:** The standard pipeline is:

1. **Code Push** → triggers the workflow
2. **Build** the Docker image
3. **Test** (run unit tests inside the container)
4. **Scan** for vulnerabilities
5. **Push** to Docker Hub or a private registry (ACR, ECR, GCR)
6. **Deploy** to the target environment

### Q38: Show a complete GitHub Actions pipeline that builds, scans, and pushes a Docker image

**Answer:**

```yaml
# .github/workflows/docker-ci.yml
name: Docker CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-scan-push:
    runs-on: ubuntu-latest

    steps:
      # Step 1: Check out the code
      - name: Checkout code
        uses: actions/checkout@v4

      # Step 2: Set up Docker Buildx (enables multi-platform builds & cache)
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      # Step 3: Log in to Docker Hub using GitHub Secrets
      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Step 4: Build the image (but don't push yet — scan first)
      - name: Build Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: false
          tags: myusername/my-fastapi-app:${{ github.sha }}
          load: true   # Load into local Docker daemon for scanning

      # Step 5: Scan for vulnerabilities with Trivy
      - name: Scan image with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: myusername/my-fastapi-app:${{ github.sha }}
          format: table
          exit-code: 1             # Fail the pipeline on CRITICAL issues
          severity: CRITICAL,HIGH

      # Step 6: Push to Docker Hub (only if scan passed)
      - name: Push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            myusername/my-fastapi-app:latest
            myusername/my-fastapi-app:${{ github.sha }}
```

### Q39: How do you use GitHub Actions built-in actions for Docker?

**Answer:** GitHub provides official and community-maintained actions on the **GitHub Actions Marketplace**:

| Action | Purpose |
| --- | --- |
| `actions/checkout@v4` | Checks out your repository code |
| `docker/setup-buildx-action@v3` | Sets up Docker Buildx for advanced builds (multi-platform, caching) |
| `docker/login-action@v3` | Authenticates to Docker Hub, ACR, ECR, or GCR |
| `docker/build-push-action@v5` | Builds and pushes Docker images with cache support |
| `aquasecurity/trivy-action@master` | Scans images for CVEs using Trivy |
| `docker/metadata-action@v5` | Automatically generates image tags and labels |

### Q40: How do you use GitHub Actions with Azure Container Registry (ACR)?

**Answer:** Replace the login step with Azure-specific credentials:

```yaml
- name: Log in to Azure Container Registry
  uses: docker/login-action@v3
  with:
    registry: myregistry.azurecr.io
    username: ${{ secrets.ACR_USERNAME }}
    password: ${{ secrets.ACR_PASSWORD }}

- name: Build and Push to ACR
  uses: docker/build-push-action@v5
  with:
    context: .
    push: true
    tags: myregistry.azurecr.io/my-fastapi-app:${{ github.sha }}
```

### Q41: How do you speed up Docker builds in GitHub Actions using layer caching?

**Answer:** Use the `cache-from` and `cache-to` arguments in `build-push-action` to cache layers in GitHub's cache or in the registry itself:

```yaml
- name: Build with cache
  uses: docker/build-push-action@v5
  with:
    context: .
    push: true
    tags: myusername/my-fastapi-app:latest
    cache-from: type=gha          # Read cache from GitHub Actions cache
    cache-to: type=gha,mode=max   # Write cache back to GitHub Actions cache
```

---

## ☸️ Docker vs Kubernetes (Senior Comparison)

### Q42: When should you use Docker Compose vs Kubernetes?

**Answer:**

| Factor | Docker Compose | Kubernetes |
|---|---|---|
| **Scale** | Single host, small stack | Multi-node clusters, thousands of pods |
| **Setup Complexity** | Simple YAML, minutes | Complex, steep learning curve |
| **Auto-healing** | No (manual restart policies) | Yes (automatically reschedules failed pods) |
| **Auto-scaling** | Manual (`--scale`) | Yes (HPA — Horizontal Pod Autoscaler) |
| **Load Balancing** | Basic (internal) | Advanced (Ingress controllers, external LBs) |
| **Best For** | Local dev, small projects | Production enterprise workloads |

### Q43: What is the Kubernetes equivalent of Docker Compose concepts?

**Answer:**

| Docker Compose | Kubernetes Equivalent |
|---|---|
| `service` | `Deployment` + `Service` |
| `volumes` | `PersistentVolumeClaim (PVC)` |
| `networks` | `Namespace` + `NetworkPolicy` |
| `depends_on` | `InitContainers` or `readinessProbe` |
| `docker-compose.yml` | Multiple YAML manifests or `Helm Chart` |
| `docker-compose up` | `kubectl apply -f` |

### Q44: Interview Scenario — "How would you containerize and deploy a FastAPI app to production?"

**Answer (Senior-level response):**

1. **Dockerize:** Write a multi-stage `Dockerfile` (builder + slim runner, non-root user).
2. **Compose locally:** Use `docker-compose.yml` with Postgres, healthchecks, and `.env` for secrets.
3. **CI/CD Pipeline:** GitHub Actions to build → Trivy scan → push to ACR/ECR.
4. **Production:** Deploy to Kubernetes (or Azure App Service / AWS ECS for simpler setups) using the pushed image.
5. **Persistence:** Use managed database (Azure PostgreSQL) instead of a DB container in production.
6. **Monitoring:** Use `docker stats` locally; Prometheus + Grafana or Azure Monitor in production.
