# 🎯 Interview Questions & Scenarios

## 🧠 Git Conceptual Level
*(Refer to README_git.md for full details)*

### Q1: Is Git a "Diff" or "Snapshot" system?
**Answer:** Snapshot. Git captures the state of all files at each commit. Unchanged files are referenced via their existing hashes, ensuring no data duplication.

### Q2: Explain the "Three Trees" of Git.
**Answer:** 
1. **Working Directory:** The files you see and edit.
2. **Index (Staging Area):** A "draft" snapshot for the next commit.
3. **HEAD:** The snapshot of your last commit.

### Q3: What makes a Merge Commit special in the Git DAG?
**Answer:** A merge commit has **at least two parents**. This allows Git to trace the history back through multiple lines of development.

### Q4: What is the "Common Ancestor" and why is it important for merging?
**Answer:** The Common Ancestor is the last commit shared by two diverged branches. Git uses it to calculate what changed on both sides, allowing it to intelligently combine the changes (Three-Way Merge).

### Q5: Textual vs. Semantic Conflicts — What's the difference?
**Answer:** 
- **Textual Conflict:** Git detects that the same line was changed differently on two branches and stops the merge.
- **Semantic Conflict:** Git successfully merges the code (no line overlaps), but the code is logically broken (e.g., a function you call was renamed in another branch). Git **cannot** detect semantic conflicts; only tests/compilation can.

---

## 🚀 DevOps-Grade Git Questions

### Q6: What is the "Golden Rule of Rebasing"?
**Answer:** Never rebase a public/shared branch. Rebasing rewrites history (changes hashes), which will break the local repositories of anyone else working on that branch.

### Q7: How do you find which commit introduced a bug in a history of 1,000 commits?
**Answer:** Use **`git bisect`**. It performs a binary search through the history. You mark a "good" commit and a "bad" commit, and Git automatically checks out commits in between for you to test until the culprit is found.

### Q8: What are Git Hooks and how are they used in DevOps?
**Answer:** Hooks are scripts that Git executes automatically when specific events happen (e.g., `pre-commit`, `pre-push`). In DevOps, they are used to enforce code linting, run unit tests, or check for secrets before code ever leaves the developer's machine.

### Q9: What is the difference between `git pull` and `git fetch`?
**Answer:** 
- `fetch` only updates your **Remote Tracking Branches** (`origin/master`). It doesn't touch your local code.
- `pull` is `fetch` + `merge`. It downloads the data AND tries to join it with your local branch.
- *Pro Tip:* Use `git pull --rebase` to keep a clean history.

### Q10: How do you recover a branch that was accidentally deleted?
**Answer:** Use **`git reflog`**. It keeps a log of every movement of the HEAD pointer. You can find the hash of the last commit on the deleted branch and run `git branch <name> <hash>` to bring it back from the dead.

---

## 🐳 Docker Mastery

### Q11: What is the difference between a Container and a VM?
**Answer:** A VM includes a full Guest OS and runs on a hypervisor (Hardware-level isolation). A Container shares the host's OS kernel and uses **Namespaces** (for isolation) and **Cgroups** (for resource limiting). Containers are processes; VMs are computers.

### Q12: Why is the order of `COPY` and `RUN` instructions critical?
**Answer:** Because of **Layer Caching**. Docker builds from top to bottom. If a layer changes, all subsequent layers are rebuilt. By copying dependencies (`requirements.txt`) before the source code, we ensure that code changes don't trigger a re-install of all packages.

### Q13: What are Multi-Stage Builds and why use them?
**Answer:** It's a way to use multiple `FROM` statements in one Dockerfile. We use one stage to build/compile and a second, lighter stage to run the app. This results in smaller images and better security (no build tools in production).

### Q14: Explain "Namespaces" and "Cgroups".
**Answer:** 
- **Namespaces:** Provide the "illusion" of isolation (Process IDs, Network, User IDs).
- **Cgroups (Control Groups):** Limit the actual hardware resources (CPU, RAM) a container can use.

### Q15: Bind Mounts vs. Named Volumes — When to use which?
**Answer:** 
- **Bind Mounts:** Best for development. You map a host folder to the container to see code changes instantly.
- **Named Volumes:** Best for production/databases. Docker manages the storage area. They are more portable, have better performance on Windows/Mac, and are more secure.

### Q16: CMD vs. ENTRYPOINT — What is the real difference?
**Answer:** 
- `ENTRYPOINT` sets the command that **always** runs when the container starts.
- `CMD` provides **default arguments** to that entrypoint. 
- *Pro Tip:* Use `ENTRYPOINT ["python", "main.py"]` and `CMD ["--port", "80"]`. This allows the user to easily override the port without rewriting the whole command.

### Q17: Why is it bad to run a container as `root`?
**Answer:** If an attacker escapes the container, they would have `root` access to the host machine. Always use the `USER` instruction to switch to a non-privileged user.

---

## 🏗️ Real-World Scenarios

**Scenario: A commit was pushed to master that broke production. You need to undo it immediately without rewriting history.**
- **Action:** Use `git revert <hash>`. This adds a *new* commit that undoes the changes. This is safer than `reset` because it preserves the audit trail.

**Scenario: Your Docker build is taking 10 minutes every time, even for a 1-line code change.**
- **Action:** Check the order of layers. Move heavy `RUN` commands (like `apt install` or `pip install`) to the top and `COPY . .` to the bottom.

**Scenario: Your FastAPI app can't connect to Postgres, but both are running.**
- **Action:** Check if they are on the same **User-Defined Network**. Also, ensure you are connecting to the **container name** (e.g., `db:5432`) and not `localhost:5432`.
