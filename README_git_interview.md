# 🎯 Git & GitHub Interview Questions & Scenarios

---

## 📐 Basic Concepts & Architecture

### Q1: What is Git, and how does it differ from centralized VCS?
**Answer:** Git is a **Distributed Version Control System (DVCS)**. Unlike centralized systems like SVN that rely on a single server, Git gives every developer a **complete local copy** of the repository including its full history.
- Work and commit **offline**
- Operations are **significantly faster** (local)
- **No single point of failure** — every clone is a full backup
- Git stores data as **snapshots** of the complete repo state, not file diffs

### Q2: What are the core advantages and key features of Git?
**Answer:**
- **Distributed architecture:** Every developer has a full clone
- **High performance:** Most operations are local
- **Robust branching/merging:** Lightweight and cheap branch operations
- **Data integrity:** SHA-1 hashing on every object
- **Non-linear workflows:** Thousands of developers can collaborate simultaneously
- **Resilient backup:** Every clone acts as a full repository backup

### Q3: What is the difference between Git and GitHub?
**Answer:**
- **Git** is the underlying VCS installed locally — it tracks code changes and manages history independently.
- **GitHub** is a web-based hosting platform that adds collaboration features on top of Git: pull requests, issue tracking, code review, access control, and CI/CD integrations.
- *Simple rule:* Git is the **tool**; GitHub is the **platform**.

### Q4: What language is Git primarily written in and why?
**Answer:** Git is primarily written in **C**. C is highly performant and reduces the runtime overhead of higher-level languages, making Git's operations incredibly fast — critical for large repositories with long histories.

### Q5: Explain Git's core object model.
**Answer:** Git stores data using four primary objects:
- **Blob:** Stores raw file contents.
- **Tree:** Represents filesystem hierarchy (directories) — references blobs and subtrees.
- **Commit:** A snapshot — contains a SHA-1 hash, author metadata, commit message, parent pointer(s), and a tree reference.
- **Tag:** A static label pointing to a specific commit (used for releases).

### Q6: How does Git ensure data integrity?
**Answer:** Git uses **SHA-1 hashing** to checksum every object (blob, tree, commit). Every object is assigned a unique 40-character hash based on its contents. If even a single bit is altered or corrupted, the hash changes — Git can instantly detect tampering or corruption.
> 📌 **Modern Note:** Git has been transitioning to **SHA-256** (since Git 2.29, 2020) for stronger collision resistance. Most enterprise environments still use SHA-1 in practice, but SHA-256 is the future standard.

### Q7: What is a Git repository, and what is the `.git` directory?
**Answer:** A Git repository is the core database storing all version-controlled files, branches, and commit history. The hidden `.git` directory is the "control center" containing:
- **Object database** (blobs, trees, commits)
- **References** (branches, tags)
- **Configuration** settings
- **Logs**
> Deleting `.git` removes all version history for the project.

### Q8: What is the difference between a bare and a non-bare repository?
**Answer:**
- **Non-bare:** Has a working directory where files are checked out for editing. Used locally by developers.
- **Bare:** Contains only the `.git` data — no working directory. Used as **central servers** (like GitHub or CI/CD) to prevent accidental direct edits on the server.

---

## 🌳 Three-Tree Architecture & Core Workflow

### Q9: Explain the Three-Tree Architecture in Git.
**Answer:** Git's local environment has three tiers:
1. **Working Directory:** Your active filesystem — files you view and edit.
2. **Staging Area (Index):** An intermediate buffer — selectively gather changes ready for the next commit.
3. **Repository (Commit History):** The local database storing permanent commit snapshots.

### Q10: What is `.gitignore` and why is it necessary?
**Answer:** `.gitignore` specifies files and directories Git should completely ignore. Critical for:
- Excluding **build artifacts** and temp files
- Keeping **IDE settings** out of the repo
- Protecting **sensitive data** (passwords, API keys, `.env` files)

### Q11: What is `HEAD` in Git, and what does "detached HEAD" mean?
**Answer:**
- **HEAD** is a symbolic reference pointing to the most recent commit on the currently active branch.
- **Detached HEAD** occurs when HEAD points directly to a specific commit hash instead of a branch. Any new commits in this state are **orphaned** — not associated with any branch and may be lost if you switch away without creating a new branch.

### Q12: What exactly happens during `git commit`?
**Answer:** Git:
1. Creates a **Tree object** from the staging area.
2. Creates a **Commit object** with: SHA-1 hash, author metadata, commit message, and parent pointer(s).
3. Moves the **HEAD pointer** forward to the new commit.

### Q13: How do you write a good commit message?
**Answer:**
- Use **imperative mood** in subject line ("Add feature" not "Added feature")
- Keep subject under **50 characters**
- Separate subject from body with a **blank line**
- Body explains **what and why**, not how
- Include **Jira ticket/bug IDs** for traceability in enterprise environments

---

## 🔄 Branching & Merging

### Q14: What is a Git branch and why is it important?
**Answer:** A branch is a lightweight, independent line of development — a pointer to a specific commit. Branching allows multiple developers to work concurrently in **isolated environments** on features or bug fixes without disrupting the stable `main` codebase.

### Q15: How do you create and switch between branches?
**Answer:**
```bash
# Create a branch
git branch feature/login

# Switch to it
git checkout feature/login
# OR (modern way)
git switch feature/login

# Create AND switch in one command
git checkout -b feature/login
git switch -c feature/login  # modern equivalent
```

### Q16: What is `git merge`?
**Answer:** `git merge` integrates the development history of two branches into one. When merging a feature branch into `main`, Git creates a new **merge commit** that ties the histories together.

### Q17: What is the difference between `git merge` and `git rebase`?
**Answer:**
- **`git merge`:** Preserves exact chronological history — results in a non-linear history with a merge commit.
- **`git rebase`:** Rewrites history by replaying your feature branch commits at the tip of the target branch — produces a **linear, cleaner history** without merge commits.

### Q18: What is the "Golden Rule" of rebasing?
**Answer:** **Never rebase a public or shared branch.** Rebasing rewrites commit hashes, which will break the local repositories of every developer who has already pulled that branch — causing massive synchronization chaos.

### Q19: What is a fast-forward merge vs. a three-way merge?
**Answer:**
- **Fast-Forward:** The base branch has no new commits since branching — Git simply moves the pointer forward. No merge commit created.
- **Three-Way Merge:** The base branch has new commits since branching — Git must reconcile the diverged lines and create a new merge commit.

### Q20: What is an octopus merge?
**Answer:** Merging **multiple branches simultaneously** (e.g., 5 feature branches into `main` at once). Prevents the clutter of creating 5 separate merge commits.

### Q21: How do merge conflicts arise, and how do you resolve them?
**Answer:** Conflicts occur when two branches edit the **same lines** of a file, or one branch deletes a file the other edits.
**Resolution steps:**
1. Open conflicting files. Git marks the conflict zone like this:
   ```
   <<<<<<< HEAD
   your changes
   =======
   incoming changes
   >>>>>>> feature/branch
   ```
2. Edit the file to keep the correct code and remove the markers.
3. `git add <file>` to stage the fix.
4. `git merge --continue` or `git commit` to finalize.

### Q22: What is Squash and Merge vs. Rebase and Merge on GitHub?
**Answer:**
- **Squash and Merge:** Combines all commits from a feature branch into **one single clean commit** on `main`.
- **Rebase and Merge:** Replays each individual commit from the feature branch onto `main` — maintains individual commit details without a merge commit.

---

## 🔧 Remote & Sync Operations

### Q23: What is the difference between `git fetch` and `git pull`?
**Answer:**
- **`git fetch`:** Safely downloads new commits and refs from the remote — does **not** touch your local working directory. Lets you review changes first.
- **`git pull`:** `fetch` + `merge`. Downloads AND merges into your active branch automatically.
- *Pro Tip:* Use `git pull --rebase` to keep a linear history.

### Q24: What is the difference between `git clone` and `git fork`?
**Answer:**
- **`git clone`:** Downloads a local copy of a repository from a server to your machine.
- **`git fork`:** A GitHub platform feature that duplicates someone else's repository into your own GitHub account — allows free experimentation without affecting the original.

### Q25: What is the difference between `git clone` and `git remote`?
**Answer:**
- **`git clone`:** Creates a brand-new local repository by downloading an existing remote one.
- **`git remote`:** Manages remote aliases (like `origin`) on an **already existing** local repository.

### Q26: What is the difference between `main` and `origin/main`?
**Answer:**
- **`main`:** Your local branch on your machine.
- **`origin/main`:** A **remote tracking branch** — Git's local cached memory of what `main` looks like on the remote server (`origin`). Updated when you `fetch` or `pull`.

### Q27: How do you push a newly initialized local repository to GitHub?
**Answer:**
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin <url>
git push -u origin main
```

### Q28: What is a shallow clone and why use it?
**Answer:** `git clone --depth 1` downloads only the **most recent commit** — not the full history. Saves time and bandwidth. Preferred in **CI/CD pipelines** where only the latest code is needed to run tests.

---

## ⏪ History Rewriting & Recovery

### Q29: What is `git stash` and when should you use it?
**Answer:** `git stash` temporarily saves uncommitted changes into a hidden drawer. Use it when you're mid-task but urgently need to switch branches (e.g., to hotfix a bug) without committing unfinished work.

### Q30: What is the difference between `stash apply`, `stash pop`, and `stash drop`?
**Answer:**
- **`git stash apply`:** Restores stashed files but **keeps** the stash saved in the list.
- **`git stash pop`:** Restores files AND **deletes** the stash from the list.
- **`git stash drop`:** **Deletes** the stash without restoring it.

### Q31: What is `git cherry-pick` and when would you use it?
**Answer:** `git cherry-pick <hash>` applies a **single specific commit** from one branch onto another. Use cases:
- Apply a critical bug fix to multiple release branches
- Port a specific feature without merging a messy branch

### Q32: What is the difference between `git reset` and `git revert`?
**Answer:**
- **`git reset`:** Moves the branch pointer backward — **rewrites/erases** local history. Never push to shared branches.
- **`git revert`:** Creates a **new commit** that undoes the effects of a previous commit — preserves history. Safe for public repositories.

### Q33: Explain the difference between Soft, Mixed, and Hard resets.
**Answer:**
- **`--soft`:** Removes commit from history — keeps changes in **Staging Area**.
- **`--mixed` (default):** Removes commit — unstages changes, keeps edits in **Working Directory**.
- **`--hard`:** Completely obliterates the commit, unstages files, and **trashes local edits**.

### Q34: How do you amend a commit or fix a broken commit message?
**Answer:** `git commit --amend` — bundles staged changes or a message fix into the **previous commit** instead of creating a new one.
> ⚠️ Only use on commits that haven't been pushed to a shared branch.

### Q35: How do you squash multiple commits into one?
**Answer:**
- **Interactive Rebase:** `git rebase -i HEAD~n` → mark commits as `squash`
- **Soft Reset:** `git reset --soft HEAD~n` → then `git commit -m "Clean message"`

### Q36: What is `git reflog` and how do you recover a deleted branch?
**Answer:** `git reflog` maintains a local log of **every movement of HEAD** — even after resets and deletions.
```bash
# Find the lost commit hash
git reflog

# Restore the deleted branch
git checkout -b recovered-branch <commit-hash>
```

### Q37: What is `git bisect`?
**Answer:** A debugging tool that uses **binary search** to find the exact commit that introduced a bug. You mark a known "good" and "bad" commit — Git halves the commit range until the faulty commit is isolated.

---

## 🏗️ Advanced Git Features

### Q38: What are Git Tags?
**Answer:** Tags are **static labels** on specific commits, used to mark release milestones (e.g., `v1.0`, `v2.0`).
- **Lightweight tag:** Simple alias pointer.
- **Annotated tag:** Stores extra metadata (author, date, message). Preferred for releases.
```bash
git tag -a v1.0 -m "Release 1.0"
git push origin v1.0
```

### Q39: How does Git handle large binary files?
**Answer:** Git natively struggles with large binaries (videos, databases) — it stores full copies causing repository bloat. Solution: **Git LFS (Large File Storage)** — replaces large files with tiny text pointers in Git history, storing actual binaries on a separate remote server.

### Q40: What are Git Submodules vs Subtrees?
**Answer:**
- **Submodule:** A pointer/link to a separate external repository. Maintains strict isolation but is harder to manage.
- **Subtree:** Physically embeds a copy of the external repo's code directly into your project. Easier to manage but less isolated.

### Q41: What are Git Hooks and Webhooks?
**Answer:**
- **Git Hooks:** Shell scripts in `.git/hooks` that trigger automatically on **local** Git events (e.g., `pre-commit` runs linting before every commit).
- **Webhooks:** Configured on GitHub to trigger **external HTTP actions** after remote events (e.g., trigger a CI/CD pipeline after a push).

### Q42: What is the difference between `git status` and `git diff`?
**Answer:**
- **`git status`:** High-level state — shows which files are untracked, modified, or staged.
- **`git diff`:** Deep line-by-line code changes between working directory, index, or commits.

### Q43: How do you remove a file from Git without deleting it locally?
**Answer:**
```bash
git rm --cached <file>
# Then add to .gitignore to prevent re-tracking
```

### Q44: How do you find files that changed in a particular commit?
**Answer:**
```bash
git diff-tree -r <commit-hash>
# -r flag recurses into subdirectories
```

### Q45: How can you tell if a branch has already been merged?
**Answer:**
```bash
git branch --merged      # branches merged INTO current branch
git branch --no-merged   # branches NOT yet merged
```

### Q46: What is `git clean`?
**Answer:** Recursively deletes **untracked files** from the working directory.
```bash
git clean -fd    # remove untracked files and directories
git clean -fdx   # also remove ignored files (build outputs)
```

### Q47: What is `git grep`?
**Answer:** Searches for a string or regex **within tracked files** in the repository — faster than searching the entire filesystem.
```bash
git grep "DATABASE_URL"
```

### Q48: How do you rename a remote connection?
**Answer:**
```bash
git remote rename origin upstream
```

### Q49: What is `git instaweb`?
**Answer:** A built-in script that launches a **local web server** with a browser-based GUI to browse the repository, commits, and diffs.

### Q50: What is SubGit?
**Answer:** A tool for **migrating SVN repositories to Git**. It can create a bi-directional mirror allowing teams to use both SVN and Git concurrently during transition.

---

## 🔀 Branching Strategies

### Q51: Explain the GitFlow branching strategy.
**Answer:** GitFlow uses multiple long-lived branches:
- **`main`:** Production-ready code only.
- **`develop`:** Integration branch for features.
- **`feature/*`:** Short-lived branches for new features.
- **`release/*`:** Prep branches before production.
- **`hotfix/*`:** Emergency fixes directly from `main`.

Best for: **versioned software** (desktop/mobile apps, regulated industries).

### Q52: Explain GitHub Flow.
**Answer:** A minimalist strategy with one rule: **`main` must always be deployable**.
1. Create a short-lived feature branch.
2. Open a Pull Request.
3. Review and merge to `main`.
4. Deploy immediately.

Best for: **SaaS and modern web applications** with continuous deployment.

### Q53: Explain Trunk-Based Development (TBD).
**Answer:** All developers commit **directly to `main`** (trunk) at least once a day. Incomplete features are hidden using **Feature Flags** instead of long-lived branches. Requires rigorous automated testing.
Best for: **Elite DevOps teams** practicing continuous integration.

### Q54: What are Feature Flags?
**Answer:** Conditional code switches that allow merging and deploying **incomplete code** to production with the feature "turned off" for users until it's fully ready. Heavily used in Trunk-Based Development.

---

## 🛡️ GitHub Features & Enterprise

### Q55: What is a Pull Request (PR) and code review?
**Answer:** A PR is a formal proposal on GitHub to merge a branch into `main`. It initiates a **code review** where team members inspect for bugs, style issues, and improvements via threaded comments before a maintainer approves and merges.

### Q56: How can you automate checks in a PR using GitHub Actions?
**Answer:** Define YAML workflows in `.github/workflows/` triggered by PR creation. Automate:
- **Test suites** (pytest, jest)
- **Linters** (Super-Linter, flake8)
- **Security scanning** (CodeQL, Trivy)
- **Block merging** if checks fail via branch protection rules

### Q57: What is GitHub Advanced Security (GHAS)?
**Answer:** Enterprise-level security tools inside GitHub:
- **Secret Protection:** Scans for accidentally committed passwords/API keys. **Push Protection** blocks commits containing secrets.
- **Code Security (CodeQL):** Scans PRs for vulnerabilities before they merge.

### Q58: What metrics should teams track for Pull Request performance?
**Answer:**
- **Time to First Review:** Delays blocking developer progress
- **Average Review Time:** PR creation to merge duration
- **Cycle Time:** Idea to production
- **PR Size:** Smaller PRs → faster and more effective reviews

### Q59: How do you integrate Git with Jenkins?
**Answer:** Install the **Git plugin** via Manage Jenkins → Manage Plugins. Configure Jenkins jobs to automatically pull code from your repository and trigger builds on push events or PRs.

### Q60: What is Git's "index" and why does it matter?
**Answer:** The **index** (staging area) is a binary file (`.git/index`) that acts as a proposed next commit. It allows you to **selectively stage** specific files or even specific lines (with `git add -p`) — giving you fine-grained control over exactly what goes into each commit.

---

## ⭐ Additional Frequently Asked Questions

### Q61: What is the difference between `git pull --rebase` and `git pull`?
**Answer:**
- **`git pull`:** Fetches and **merges** — creates a merge commit, preserving the branch history.
- **`git pull --rebase`:** Fetches and **rebases** your local commits on top of the remote — keeps a **linear history** without a merge commit. Preferred in teams using rebase workflows.

### Q62: How do you undo the last commit without losing your changes?
**Answer:**
```bash
# Keep changes staged
git reset --soft HEAD~1

# Keep changes unstaged (in working directory)
git reset --mixed HEAD~1  # or just git reset HEAD~1

# Completely discard changes
git reset --hard HEAD~1
```

### Q63: How do you see the full commit history with a graph?
**Answer:**
```bash
git log --oneline --graph --all --decorate
```
This shows a visual ASCII-art graph of all branches and their merge points.

### Q64: What is `git worktree` and when is it useful?
**Answer:** `git worktree` allows you to check out **multiple branches simultaneously** in separate directories from the same repository. Useful when you need to work on a hotfix while keeping your current feature branch untouched — without stashing or committing half-finished work.
```bash
git worktree add ../hotfix-branch hotfix/login-bug
```

### Q65: Explain the difference between textual and semantic merge conflicts.
**Answer:**
- **Textual Conflict:** Git detects the same lines were changed differently on two branches — it stops and asks you to resolve.
- **Semantic Conflict:** Git merges successfully (no overlapping lines), but the code is **logically broken** (e.g., a function you call was renamed on another branch). Git **cannot** detect this — only tests/compilation can.

### Q66: What happens to commits when you delete a branch?
**Answer:** Deleting a branch only removes the **pointer/label** — the actual commits remain in the object database. They become **unreachable** and will eventually be garbage collected. You can recover them with `git reflog` before that happens.

### Q67: What is the difference between `git revert` and `git reset` in a team context?
**Answer:**
- **`git revert`:** Safe for shared branches — creates a new commit undoing changes. Preserves audit trail.
- **`git reset`:** Rewrites history — **dangerous on shared branches** because it changes commit hashes, breaking team members' local copies.

### Q68: How do you set up branch protection rules on GitHub?
**Answer:** In GitHub → Repository Settings → Branches → Add Rule:
- Require **pull request reviews** before merging
- Require **status checks** to pass (CI tests)
- Require **branches to be up to date**
- **Restrict who can push** directly to `main`
- **Prevent force pushes**

### Q69: What is `git archive` and when is it used?
**Answer:** Creates a **zip/tar archive** of a repository at a specific commit or tag — without including the `.git` directory. Useful for distributing source code releases.
```bash
git archive --format=zip HEAD > release.zip
```

### Q70: What is the difference between `origin` and `upstream` in a fork workflow?
**Answer:**
- **`origin`:** Your own fork on GitHub.
- **`upstream`:** The **original repository** you forked from.
```bash
git remote add upstream <original-repo-url>
git fetch upstream
git rebase upstream/main  # sync your fork with the original
```

---

## 🏗️ Common Git Commands Cheatsheet

```bash
# --- Repository Setup ---
git init                          # Initialize a new repository
git clone <url>                   # Clone an existing repository
git clone --depth 1 <url>         # Shallow clone (latest commit only)

# --- Staging & Committing ---
git status                        # Check working tree status
git add <file>                    # Stage a specific file
git add .                         # Stage all changes
git add -p                        # Interactively stage specific hunks
git commit -m "message"           # Commit with message
git commit --amend                # Amend the last commit

# --- Branching ---
git branch                        # List local branches
git branch -a                     # List all branches (including remote)
git switch -c feature/login       # Create and switch to new branch
git branch -d feature/login       # Delete a merged branch
git branch -D feature/login       # Force delete a branch

# --- Merging & Rebasing ---
git merge feature/login           # Merge branch into current
git rebase main                   # Rebase current branch onto main
git rebase -i HEAD~3              # Interactive rebase (last 3 commits)
git cherry-pick <hash>            # Apply a specific commit

# --- Remote Operations ---
git remote -v                     # List remote connections
git remote add origin <url>       # Add a remote
git fetch origin                  # Fetch without merging
git pull --rebase origin main     # Pull with rebase (clean history)
git push origin feature/login     # Push a branch

# --- Inspection ---
git log --oneline --graph --all   # Visual branch history
git diff                          # Show unstaged changes
git diff --staged                 # Show staged changes
git show <hash>                   # Show a specific commit

# --- Undo & Recovery ---
git reset --soft HEAD~1           # Undo last commit, keep staged
git reset --hard HEAD~1           # Undo last commit, discard changes
git revert <hash>                 # Safe undo (new commit)
git stash                         # Save uncommitted changes
git stash pop                     # Restore saved changes
git reflog                        # Full history of HEAD movements
git bisect start                  # Begin binary bug search

# --- Cleanup ---
git clean -fd                     # Remove untracked files/dirs
git gc                            # Garbage collect loose objects
git remote prune origin           # Remove stale remote branches
```
