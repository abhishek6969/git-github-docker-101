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

### Q5: Explain Git's core object model

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

### Q9: Explain the Three-Tree Architecture in Git

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

### Q33: Explain the difference between Soft, Mixed, and Hard resets

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

### Q51: Explain the GitFlow branching strategy

**Answer:** GitFlow uses multiple long-lived branches:

- **`main`:** Production-ready code only.
- **`develop`:** Integration branch for features.
- **`feature/*`:** Short-lived branches for new features.
- **`release/*`:** Prep branches before production.
- **`hotfix/*`:** Emergency fixes directly from `main`.

Best for: **versioned software** (desktop/mobile apps, regulated industries).

### Q52: Explain GitHub Flow

**Answer:** A minimalist strategy with one rule: **`main` must always be deployable**.

1. Create a short-lived feature branch.
2. Open a Pull Request.
3. Review and merge to `main`.
4. Deploy immediately.

Best for: **SaaS and modern web applications** with continuous deployment.

### Q53: Explain Trunk-Based Development (TBD)

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

### Q65: Explain the difference between textual and semantic merge conflicts

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

**Answer:** Creates a **zip/tar archive** of a repository at a specific commit or tag — without including the `.git` directory. Useful for distributing source code releases or packaging for deployment.

```bash
# Basic archive of HEAD
git archive --format=zip HEAD > release.zip

# Archive a specific branch with a folder prefix
git archive master --prefix='project/' --format=zip > project.zip

# Archive a specific tag
git archive --format=tar.gz v1.0 > v1.0.tar.gz
```

> The `--prefix` flag adds a top-level folder name inside the archive — clean for release packages.

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

---

## 🧠 Expert-Level Git Questions

### Q71: What is `git bundle` and when would you use it?

**Answer:** `git bundle` packages everything that would normally be transferred over a network into a **single binary file**. Primary use case is sharing repository data **completely offline** — air-gapped environments, server outages, or USB transfers.

```bash
# Create a bundle of the full repo
git bundle create repo.bundle HEAD master

# Recipient can clone directly from the bundle file
git clone repo.bundle my-project

# Or fetch from it into an existing repo
git fetch repo.bundle master
```

```powershell
# --- Simulate offline repo transfer via bundle ---
git init bundle-src; cd bundle-src
"v1" > app.txt; git add .; git commit -m "Commit 1"
"v2" > app.txt; git add .; git commit -m "Commit 2"
"v3" > app.txt; git add .; git commit -m "Commit 3"

# Pack the entire repo into one portable file (copy to USB / email)
git bundle create ../repo.bundle HEAD main

# Verify the bundle is intact before handing it over
git bundle verify ../repo.bundle
# Output: The bundle contains 1 ref: main

# Recipient side: clone directly from the file — no network needed
cd ..
git clone repo.bundle bundle-dest
cd bundle-dest
git log --oneline       # All 3 commits present
Get-Content app.txt     # v3

# Alternatively, fetch incrementally into an existing repo
git remote add offline ../repo.bundle
git fetch offline main
```
> **Air-gap use case:** Copy `repo.bundle` to a USB stick, walk it to a secure network, clone there — zero internet required.

### Q72: What is `git rerere` and how does it assist in conflict resolution?

**Answer:** `rerere` stands for **"Reuse Recorded Resolution"**. When enabled, Git caches how you manually resolved a specific merge conflict. If the exact same conflict appears again, Git automatically applies your previous fix.

```bash
# Enable rerere globally
git config --global rerere.enabled true
```

> Most useful when **repeatedly rebasing** a long-lived feature branch where the same conflicts keep arising.

```powershell
# --- Simulate rerere auto-resolution ---
git config --global rerere.enabled true

git init rerere-lab; cd rerere-lab
"original" > shared.txt; git add .; git commit -m "Base"
git checkout -b feature
"feature version" > shared.txt; git add .; git commit -m "Feature edit"
git checkout main
"main version" > shared.txt; git add .; git commit -m "Main edit"

# First merge — resolve manually
git merge feature
# CONFLICT in shared.txt — edit it manually:
"resolved version" > shared.txt
git add shared.txt; git commit -m "Merge — manual resolution"
# rerere records the resolution in .git/rr-cache/
Get-ChildItem .git/rr-cache   # confirm cache entry exists

# Undo the merge, replay the exact same conflict
git reset --hard HEAD~1
git merge feature
# Git AUTOMATICALLY applies the saved resolution — no editor opens!
git status   # shared.txt already resolved by rerere
git add shared.txt; git commit -m "Merge — rerere auto-resolved"
```

### Q73: How does `git replace` work, and how does it differ from rewriting history?

**Answer:** `git replace` lets you tell Git to **virtually substitute** one object for another — without actually altering commit hashes in the real history. Unlike `git rebase` or `filter-repo` which rewrite every downstream hash, `git replace` grafts changes virtually and only applies locally.

| | `git replace` | `git rebase` / `filter-repo` |
| --- | --- | --- |
| Changes real hashes? | No | Yes — every downstream commit |
| Safe on pushed repos? | Yes | No — breaks collaborators |
| Shared automatically? | Only via `push refs/replace/*` | Normal push |

> **Common use:** Connect a shallow clone (small, fast for new devs) to the full old history — without rewriting anything.

```powershell
# --- Simulate shallow clone + git replace history grafting ---

# Full 4-commit history
git init replace-lab; cd replace-lab
"2020 code" > app.txt; git add .; git commit -m "2020: Initial"
"2021 code" > app.txt; git add .; git commit -m "2021: Refactor"
"2022 code" > app.txt; git add .; git commit -m "2022: Features"
"2023 code" > app.txt; git add .; git commit -m "2023: Current"

git log --oneline
# abc004 2023: Current  <- HEAD
# abc003 2022: Features
# abc002 2021: Refactor
# abc001 2020: Initial  <- original root

# Shallow clone: new dev only gets last 2 commits
cd ..
git clone --depth 2 replace-lab shallow-clone
cd shallow-clone
git log --oneline
# abc004 2023: Current
# abc003 2022: Features  <- appears as root, history cut off

# Fetch full history from original repo
git remote add full ../replace-lab
git fetch full

# Graft: make abc003 virtually point to abc002 as its parent
# (replace actual hashes from your git log output)
git replace --graft <abc003-hash> <abc002-hash>

git log --oneline
# All 4 commits now visible — real hashes unchanged underneath!

# Toggle replacement off to see raw truth
git --no-replace-objects log --oneline
# abc004, abc003 only — back to shallow view

# Share the graft with team
git push origin 'refs/replace/*'

# Remove when done
git replace -d <abc003-hash>
```

### Q74: What is `git filter-branch`, and what is its modern replacement?

**Answer:** `git filter-branch` was the "nuclear option" for rewriting history across a large number of commits — changing author emails, scrubbing passwords, or splitting subdirectories.
> ⚠️ **DEPRECATED since Git 2.24 (2019).** Use **`git-filter-repo`** instead — it is faster, safer, and the officially recommended replacement.

```bash
# Modern way: install git-filter-repo, then
git filter-repo --path src/ --to-subdirectory-filter lib/
git filter-repo --commit-callback 'commit.author_email = b"correct@email.com"'
```

```powershell
# Install git-filter-repo (Python-based, works on Windows)
pip install git-filter-repo

# --- Use case 1: Remove a file from ALL of history (leaked secret) ---
git init filter-lab; cd filter-lab
"normal code" > app.py
"API_KEY=secret123" > secrets.env
git add .; git commit -m "Initial (accidentally includes secret)"
"more code" >> app.py; git add .; git commit -m "More work"

# Scrub secrets.env from every commit in history
git filter-repo --path secrets.env --invert-paths
git log --oneline          # 2 commits still exist, different hashes
git show HEAD:secrets.env  # error: file no longer exists in any commit

# --- Use case 2: Fix wrong email across all commits ---
git filter-repo --email-callback 'return email.replace(b"old@wrong.com", b"correct@email.com")'

# --- Use case 3: Extract a subdirectory as its own repo ---
git filter-repo --subdirectory-filter src/
# Repo now contains ONLY what was under src/, with rewritten history
```
> **Key point:** After any `filter-repo` run, all downstream hashes change — force-push and notify the whole team.

### Q75: Why might it be better to create an additional commit rather than using `git commit --amend`?

**Answer:** Avoid `--amend` if the commit has **already been pushed** to a shared branch. Amending rewrites the commit and generates a new SHA hash. If others have based their work on the original commit, replacing it breaks their local history. Also, abusing `--amend` can make a single commit grow too large with unrelated changes.

```powershell
# Setup
git init amend-lab; cd amend-lab
"v1" > file.txt; git add .; git commit -m "Initial commit"

# Safe: amend BEFORE pushing (no one else has this commit yet)
"v1 fixed" > file.txt; git add .
git commit --amend -m "Initial commit (corrected)"  # Rewrites hash — safe locally
git log --oneline  # Still 1 commit, but hash changed

# Simulate the DANGER — after a push:
# Teammate already pulled the original hash
# Your amend creates a NEW hash that diverges from theirs
# -> their next pull will see a conflict or forced divergence

# CORRECT approach after pushing: add a new commit instead
"v2" > file.txt; git add .
git commit -m "Fix: correct initial content"  # Preserves history, safe for team
git log --oneline  # 2 commits, original hash intact
```

> **Rule:** `--amend` is fine locally. Once pushed, always add a new commit instead.

### Q76: What is the purpose of `git describe`?

**Answer:** `git describe` generates a **human-readable build identifier** based on the most recent tag. Output format: `<tag>-<commits-since-tag>-g<short-hash>`

```bash
git describe
# Output: v1.6.2-rc1-20-g8c5b85c
# Means: tag v1.6.2-rc1, 20 commits ahead, short hash 8c5b85c
```

> Widely used in **build pipelines** to generate unique, traceable release numbers.

```powershell
git init describe-lab; cd describe-lab
"code" > app.txt; git add .; git commit -m "Release 1.0"
git tag -a v1.0 -m "Version 1.0"  # Annotated tag
"patch1" >> app.txt; git add .; git commit -m "Patch A"
"patch2" >> app.txt; git add .; git commit -m "Patch B"

git describe          # v1.0-2-g<hash>  (2 commits after v1.0)
git describe --tags   # Also matches lightweight tags
git describe --always # Fallback to raw hash if no tag exists

# Practical CI/CD use — auto-generate build version
$version = git describe --tags --always
Write-Output "Docker image tag: myapp:$version"  # e.g. myapp:v1.0-2-gabcdef1
```

### Q77: What is `git blame` and how do you use it?

**Answer:** `git blame` annotates every line of a file with the **commit and author** that last modified it. Use it to track down when and why a specific bug was introduced.

```bash
git blame src/main.py

# Track code movement (even if copy-pasted from another file)
git blame -C src/main.py
```

> The `-C` flag detects code that was **copied/moved** from other files — invaluable for tracking refactored code.

```powershell
git init blame-lab; cd blame-lab
"def login(): pass" > auth.py; git add .; git commit -m "Add login"
"def login(): pass`ndef logout(): pass" > auth.py; git add .; git commit -m "Add logout"
Add-Content auth.py "def reset(): pass"; git add .; git commit -m "Add reset — bug here"

git blame auth.py
# Output: <hash> (Author  Date  LineNum) def login(): pass
#         <hash> (Author  Date  LineNum) def logout(): pass
#         <hash> (Author  Date  LineNum) def reset(): pass  <- this commit has the bug

# Jump to the full commit to understand context
git show <hash-of-reset-line>

# Blame only lines 1-2
git blame -L 1,2 auth.py

# -C: detect if a line was moved/copied from another file
git blame -C auth.py
```

### Q78: How does `git shortlog` differ from `git log`?

**Answer:** While `git log` lists every commit chronologically, `git shortlog` **groups commits by author** — perfect for generating release changelogs or contribution summaries.

```bash
git shortlog -sn          # Summary with commit count, sorted by number
git shortlog v1.0..HEAD   # All commits since v1.0
```

### Q79: What roles do `git gc`, `git prune`, and `git fsck` play?

**Answer:**

- **`git gc` (Garbage Collection):** Compresses loose objects into efficient **packfiles**, removes unreachable objects, and reduces disk usage. Runs automatically but can be triggered manually.
- **`git fsck` (File System Check):** Deep integrity check — identifies **corrupted or missing objects** in the database.
- **`git prune`:** Permanently deletes **orphaned objects** no longer reachable from any branch or tag.

```bash
git gc --aggressive    # Deep compression (slow but thorough)
git fsck --unreachable # Find all unreachable objects
git prune --dry-run    # Preview what would be deleted
```

```powershell
git init gc-lab; cd gc-lab
"v1" > f.txt; git add .; git commit -m "C1"
"v2" > f.txt; git add .; git commit -m "C2"
"v3" > f.txt; git add .; git commit -m "C3"

# Create an orphan object — hard reset loses C3 from any branch
git reset --hard HEAD~1  # C3 is now unreachable (dangling)

# fsck: find dangling (orphaned) objects
git fsck --unreachable
# Output: unreachable commit <hash>  <- that's C3

# count-objects: see how many loose objects exist before gc
git count-objects -v
# count: 9  size: ...  (loose objects)

# gc: compress into packfile, prune dangling objects older than 2 weeks
git gc
git count-objects -v
# count: 0  in-pack: 9  (all compressed)

# prune --dry-run: preview orphans that WOULD be deleted
git prune --dry-run --expire=now  # expire=now deletes immediately
```

### Q80: What is a Git Packfile and how does it save space?

**Answer:** By default, Git stores every version of every file as a separate **loose object**. Periodically, Git creates a **Packfile** — a single binary file that groups similar objects and stores only the **deltas (differences)** between versions, drastically compressing repository size.
> `git gc` triggers packfile creation. You can see packfiles in `.git/objects/pack/`.

```powershell
git init pack-lab; cd pack-lab

# Create several commits — each produces loose objects
"version 1 of a large file" > data.txt; git add .; git commit -m "V1"
"version 2 of a large file" > data.txt; git add .; git commit -m "V2"
"version 3 of a large file" > data.txt; git add .; git commit -m "V3"

# See loose objects BEFORE packing
git count-objects -v
# count: 9    <- 9 loose objects (blobs + trees + commits)
# size: 12    <- KB on disk

# See .git/objects — each is stored as a separate 2-char dir / 38-char file
Get-ChildItem .git/objects -Recurse -File | Where-Object { $_.DirectoryName -notlike "*pack*" }

# Trigger packing manually
git gc

# After gc — loose objects gone, packfile created
git count-objects -v
# count: 0       <- no loose objects
# in-pack: 9    <- all in one packfile

# The packfile lives here:
Get-ChildItem .git/objects/pack
# pack-<hash>.idx   <- index for fast lookup
# pack-<hash>.pack  <- the compressed binary data
```

### Q81: Deep dive — What is the technical difference between lightweight and annotated tags?

**Answer:**

- **Lightweight tag:** Just a simple pointer (reference file) to a specific commit. No extra object is created in the database. Like a branch that never moves.
- **Annotated tag:** A **full object** stored in the Git database — checksummed, contains tagger name, email, date, message, and can be **GPG-signed**. Git creates a separate tag object; the reference points to the tag object, not the commit directly.

```bash
# Lightweight
git tag v1.0-lw

# Annotated (preferred for releases)
git tag -a v1.0 -m "Release 1.0"
```

```powershell
git init tag-lab; cd tag-lab
"code" > app.txt; git add .; git commit -m "Release commit"

# Create both types
git tag v1.0-lw                          # lightweight
git tag -a v1.0 -m "Version 1.0 release" # annotated

# LIGHTWEIGHT: cat-file shows type = commit (points directly to commit)
git cat-file -t v1.0-lw   # Output: commit
git cat-file -p v1.0-lw   # Shows the commit object directly

# ANNOTATED: cat-file shows type = tag (its OWN object in the database)
git cat-file -t v1.0       # Output: tag
git cat-file -p v1.0
# object <commit-hash>  <- points TO the commit
# type commit
# tag v1.0
# tagger Your Name <you@email.com> ...
# Version 1.0 release

# Proof: lightweight has NO entry in objects, annotated does
Get-ChildItem .git/refs/tags  # Both tags listed here
git cat-file --batch-all-objects --batch-check | Where-Object { $_ -like "*tag*" }
# Only v1.0 (annotated) appears as a 'tag' type object
```

### Q82: How do you digitally sign commits and tags using GPG?

**Answer:** Git supports **cryptographic signing** using GPG to prove authenticity.

```bash
# Configure your GPG key
git config --global user.signingkey <gpg-key-id>

# Sign a tag
git tag -s v1.5 -m "Signed release"

# Verify the signature
git tag -v v1.5

# Sign a commit
git commit -S -m "Signed commit"
```

> GitHub displays a **"Verified" badge** on GPG-signed commits and tags.

```powershell
# Step 1: List your GPG keys
gpg --list-secret-keys --keyid-format=long
# Output: sec   rsa4096/ABCD1234EFGH5678  <- ABCD1234EFGH5678 is your key ID

# Step 2: Tell Git which key to use
git config --global user.signingkey ABCD1234EFGH5678

# Step 3: Sign a tag
git tag -s v1.5 -m "Signed release v1.5"

# Step 4: Verify the signature
git tag -v v1.5
# Output: gpg: Good signature from "Your Name <you@email.com>"

# Step 5: Sign a commit
git commit -S -m "[feat] signed feature commit"

# Step 6: Auto-sign ALL commits
git config --global commit.gpgsign true
# Now every git commit is signed automatically

# Step 7: Verify a commit signature
git verify-commit HEAD
# Output: gpg: Good signature from ...

# On GitHub: push a signed commit -> GitHub shows green "Verified" badge
```

> **Interview tip:** GPG signing proves the commit really came from you — essential for open-source projects and regulated environments.

### Q83: What is the `.gitattributes` file and what are "smudge" and "clean" filters?

**Answer:** `.gitattributes` assigns specific settings to file paths or types. **Smudge and Clean filters** run custom scripts on files as they move in/out of the repo.

- **Clean filter:** Runs when a file is **staged** (entering the repo) — e.g., strip whitespace or format code before committing.
- **Smudge filter:** Runs when a file is **checked out** (leaving the repo) — e.g., inject build timestamps or decrypt secrets.

> Git LFS uses exactly this mechanism internally — storing pointers in the repo and fetching the real binary via a smudge filter.

```powershell
git init attr-lab; cd attr-lab

# --- Line ending normalisation (most common .gitattributes use) ---
# Tell Git: always store LF in repo, checkout with CRLF on Windows
"* text=auto" > .gitattributes
"*.sh text eol=lf" >> .gitattributes   # Shell scripts always LF
"*.bat text eol=crlf" >> .gitattributes # Batch files always CRLF
git add .gitattributes; git commit -m "Add gitattributes"

# --- Binary files — tell Git not to diff or merge them ---
"*.png binary" >> .gitattributes
"*.zip binary" >> .gitattributes

# --- Smudge/Clean filter example: inject build date on checkout ---
# Register a filter called 'datestamp'
git config filter.datestamp.smudge 'sed "s/BUILD_DATE/$(date)/"'  # on checkout
git config filter.datestamp.clean  'sed "s/.*BUILD_DATE.*/BUILD_DATE/"'  # on stage

# Apply filter to a specific file
"Built on: BUILD_DATE" > version.txt
"version.txt filter=datestamp" >> .gitattributes

# Now: checkout -> smudge replaces BUILD_DATE with real date
# Stage  -> clean restores BUILD_DATE placeholder (keeps repo clean)
git add .gitattributes version.txt; git commit -m "Add datestamp filter"
```

### Q84: How do you exclude specific files when exporting with `git archive`?

**Answer:** Add the `export-ignore` attribute in `.gitattributes`:

```
# .gitattributes
test/ export-ignore
.github/ export-ignore
*.md export-ignore
```

When you run `git archive`, Git bundles the project but **completely skips** those paths.

```powershell
git init archive-lab; cd archive-lab

# Create project structure
"print('hello')" > app.py
"# README" > README.md
New-Item tests -ItemType Directory
"def test_app(): pass" > tests/test_app.py
New-Item .github -ItemType Directory
"name: CI" > .github/workflows.yml

# Set export-ignore in .gitattributes
@"
tests/ export-ignore
.github/ export-ignore
*.md export-ignore
"@ > .gitattributes

git add .; git commit -m "Full project"

# Export a clean release archive (no tests, no CI config, no docs)
git archive HEAD --format=zip -o ../release.zip

# Inspect the zip — excluded files are NOT in it
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::OpenRead("../release.zip").Entries.Name
# Output: app.py, .gitattributes  <- only production files
# README.md, tests/, .github/ are GONE
```

### Q85: How do you resolve a merge conflict by entirely favoring one side?

**Answer:** Pass a strategy option to the merge command:

```bash
# Keep YOUR branch's conflicting changes
git merge -Xours feature/branch

# Keep the INCOMING branch's conflicting changes
git merge -Xtheirs feature/branch
```

> Note: This only applies to the **conflicted lines** — non-conflicting changes from both sides are still merged normally.

### Q86: What is the difference between `-s ours` and `-Xours`?

**Answer:**

- **`-Xours`:** A **recursive strategy option** — attempts a real merge but resolves conflicts by picking your side.
- **`-s ours`:** A **drastic merge strategy** — creates a fake merge commit recording both parents but **completely ignores the incoming branch's files** (pulls in nothing). Used to trick Git into thinking an abandoned branch is merged so it won't conflict in future integrations.

```powershell
git init strategy-lab; cd strategy-lab
"original" > base.txt; git add .; git commit -m "Base"
git checkout -b feature
"feature change" > base.txt; git add .; git commit -m "Feature edit"
git checkout main
"main change" > base.txt; git add .; git commit -m "Main edit"

# -Xours: real merge, conflicts auto-resolved using OUR side
git merge -Xours feature
Get-Content base.txt   # "main change" — ours wins, but feature's unique files are merged in
git reset --hard HEAD~1

# -s ours: fake merge — NOTHING from feature comes in
git merge -s ours feature -m "Close feature (keep nothing)"
Get-Content base.txt   # "main change" — feature's changes completely ignored
git log --oneline
# Shows merge commit with two parents, but content = main's content only
```

> **When to use `-s ours`:** Mark a branch as "merged" in history without actually pulling any of its changes in — e.g., closing an abandoned experiment cleanly.

### Q87: How do you interactively stage only parts of a modified file?

**Answer:** Instead of `git add <file>` (stages everything), use:

```bash
git add -p   # patch mode — breaks file into hunks, stage selectively
git add -i   # full interactive mode
```

For each hunk Git shows, respond:

- `y` — stage this hunk
- `n` — skip this hunk
- `s` — split into smaller hunks
- `e` — manually edit the hunk

> This allows you to make one commit with a bug fix and another with a refactor, **even if they're in the same file**.

### Q88: What is the difference between client-side and server-side Git hooks?

**Answer:**

- **Client-side hooks:** Run on the developer's local machine. Examples: `pre-commit` (run linters), `commit-msg` (enforce message format), `pre-push` (run tests before push).
- **Server-side hooks:** Run on the remote server when code is received. Examples:
  - **`pre-receive`:** Evaluates the entire push — can reject it if checks fail (e.g., security scan).
  - **`update`:** Similar to `pre-receive` but runs **per-branch** — can reject pushes to specific branches.
  - **`post-receive`:** Runs after a successful push — used to trigger CI/CD pipelines or notifications.

### Q89: How do you use Git as a client for an SVN server?

**Answer:** Via the `git svn` bridge:

```bash
# Clone an SVN repository
git svn clone https://svn-server/repo

# Work normally with Git commits locally
git commit -m "My changes"

# Push back to SVN (instead of git push)
git svn dcommit

# Pull latest SVN changes
git svn rebase
```

> `git svn dcommit` translates your local Git commits into native SVN commits on the server.

```powershell
# Concept flow (requires SVN server access to run fully):

# 1. Clone an SVN repo into a local Git repo
git svn clone https://svn.example.com/repo/trunk svn-project
cd svn-project
git log --oneline   # SVN revisions imported as Git commits

# 2. Work locally with normal Git workflow
git checkout -b feature
"new feature" > feature.txt; git add .; git commit -m "[feat] new feature"

# 3. Rebase local commits onto latest SVN before pushing
git svn rebase       # Like git pull --rebase but for SVN

# 4. Push local commits back to SVN server
git svn dcommit      # Converts Git commits -> SVN commits
# SVN revision numbers now appear in your Git log
git log --oneline    # r1234 [feat] new feature

# 5. Check SVN metadata Git attached
git log -1
# git-svn-id: https://svn.example.com/repo/trunk@1234 ...
```

### Q90: What is the difference between "Dumb" and "Smart" HTTP protocols in Git?

**Answer:**

- **Dumb Protocol (plain HTTP):** No special Git service on the server — client downloads static object files directly (e.g., `info/refs`). Read-only and inefficient.
- **Smart Protocol (HTTPS/SSH):** Requires a Git process on the server. Client and server **negotiate exactly what data is needed**, allowing the server to generate compressed custom packfiles. Supports both upload and download. All modern Git hosting (GitHub, GitLab) uses the smart protocol.

### Q91: What is `git cat-file` and how is it used?

**Answer:** A low-level **"plumbing" command** — a Swiss army knife for inspecting raw Git objects directly from the database.

```bash
# Check the type of an object
git cat-file -t <hash>
# Output: blob / tree / commit / tag

# Pretty-print the contents
git cat-file -p <hash>
# For a commit: shows tree, parent, author, message
# For a blob: shows raw file content
```

> Essential for understanding Git internals. In interviews, knowing plumbing vs. porcelain commands signals deep expertise.

### Q92: How do you create Git command aliases?

**Answer:** Use `git config` to create shortcuts:

```bash
# Make 'git unstage' do 'git reset HEAD --'
git config --global alias.unstage 'reset HEAD --'

# Make 'git last' show the last commit
git config --global alias.last 'log -1 HEAD'

# Alias an external shell command with !
git config --global alias.tree '!git log --oneline --graph --all --decorate'
```

Aliases are stored in `~/.gitconfig` under `[alias]`.

### Q93: During a conflict, how do you extract the 3 versions of a conflicting file?

**Answer:** Git stores all three conflicting versions in the **staging area (index)** under different stage numbers:

- **Stage 1:** Common base (ancestor)
- **Stage 2:** Ours (current branch)
- **Stage 3:** Theirs (incoming branch)

```bash
git show :1:file.txt > file.common.txt   # Base version
git show :2:file.txt > file.ours.txt     # Your version
git show :3:file.txt > file.theirs.txt   # Incoming version
```

> This is the foundation of how tools like `vimdiff` and VS Code's merge editor display 3-way diffs.

---

## ⚙️ Configuration, Workflow & Advanced Operations

### Q94: How do you configure your username and email in Git, and why is this important?

**Answer:** Git attaches your identity to every commit so teams know who made each change. This is mandatory before making any commits.

```bash
# Set globally (applies to all repositories on your machine)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set per-repository (overrides global, useful for work vs. personal projects)
git config user.name "Work Name"
git config user.email "work@company.com"

# Set your default editor for commit messages
git config --global core.editor "code --wait"   # VS Code
git config --global core.editor "vim"           # Vim

# View all config
git config --list
```

### Q95: What is `git restore` and how does it differ from `git reset`?

**Answer:** `git restore` is a **newer, safer command** (introduced in Git 2.23) specifically designed for undoing file-level changes without touching commit history.

```bash
# Unstage a file (replaces: git reset HEAD <file>)
git restore --staged <file>

# Discard local changes in working directory (replaces: git checkout -- <file>)
git restore <file>

# Restore a file to a specific commit's state
git restore --source=HEAD~2 <file>
```

> **Key difference:** `git reset` moves the **branch pointer** (affects commit history). `git restore` only touches the **staging area or working directory** — it cannot alter history.

### Q96: What do the status flags in `git status -s` mean?

**Answer:** `git status -s` gives a compact two-column output. **Left column = Staging Area, Right column = Working Directory.**

| Flag | Meaning |
| --- | --- |
| `??` | Untracked (new) file |
| `A` | File added to staging area |
| `M` | Modified — left=staged, right=unstaged |
| `MM` | Modified, staged, then modified again |
| `D` | Deleted file |
| `R` | Renamed file |

### Q97: How do you perform advanced commit filtering with `git log`?

**Answer:** `git log` has powerful flags to search history precisely:

```bash
# Filter by author
git log --author="Abhishek"

# Filter by time range
git log --since="2024-01-01" --before="2024-06-01"

# Hide merge commits
git log --no-merges

# "Pickaxe" — find commits that added or removed a specific string
git log -S "DATABASE_URL"

# Combine filters
git log --author="Abhishek" --since="1 month ago" --no-merges --oneline
```

> The **`-S` "Pickaxe"** option is a favourite in senior interviews — it finds exactly when a function or variable was introduced or removed.

### Q98: What is the difference between `A..B` and `A...B` in `git log`?

**Answer:**

- **Double-dot `A..B`:** Shows commits reachable from `B` but **not** from `A`. (What's in B that A doesn't have.)
- **Triple-dot `A...B`:** Shows commits reachable from **either** A or B, but **not both** (excludes shared history).

```bash
git log master..experiment    # Commits in experiment not yet in master
git log master...experiment   # All diverged commits on both sides
```

### Q99: How does Git handle SHA-1 collision attacks?

**Answer:** SHA-1 is a 160-bit hash. While accidental collision probability is astronomically low (~1.2 × 10²⁴ attempts), Git has two defences against **intentional** collision attacks (like the "Shattered" attack):

1. **Object reuse:** If a crafted object hashes to the same SHA-1 as an existing one, Git finds the existing object and ignores the new one — the attack fails silently.
2. **SHA-256 migration:** Git has been transitioning to SHA-256 (since Git 2.29) for stronger collision resistance as a long-term fix.

> Mentioning the "Shattered" attack and SHA-256 transition in an interview signals you follow Git security developments.

### Q100: At the commit level, what is the core difference between `git checkout` and `git reset`?

**Answer:** Both manipulate Git's Three Trees (HEAD, Index, Working Directory) but in different ways:

- **`git checkout <branch>`:** Moves the **HEAD pointer** to a different branch. It is **working-directory safe** — it checks for unsaved edits and refuses to overwrite them.
- **`git reset <commit>`:** Moves the **branch reference itself** backward. With `--hard` it is **not safe** — it will aggressively overwrite uncommitted changes without warning.

```powershell
git init ckvr-lab; cd ckvr-lab
"v1" > f.txt; git add .; git commit -m "C1"
"v2" > f.txt; git add .; git commit -m "C2"
git checkout -b feature
"v3" > f.txt; git add .; git commit -m "C3 on feature"

# git checkout: moves HEAD pointer, branch ref stays
git checkout main
# HEAD now -> main (C2). feature branch still points to C3. f.txt = v2
Get-Content .git/HEAD              # ref: refs/heads/main
Get-Content .git/refs/heads/main   # C2 hash
Get-Content .git/refs/heads/feature # C3 hash (unchanged)

# git reset: moves the BRANCH ref itself
git checkout feature
git reset --hard main              # feature branch pointer moves back to C2
Get-Content .git/refs/heads/feature # now C2 hash — branch ref rewrote!
Get-Content f.txt                  # v2 — working dir also changed
# C3 is now dangling (find it via git reflog)

# SAFETY difference:
# checkout refuses to overwrite unsaved edits
"unsaved" > f.txt  # don't stage this
git checkout main  # safe — warns about modified files
git reset --hard main  # DANGEROUS — obliterates unsaved changes silently
```

### Q101: How do you force Git to always create a merge commit even on fast-forward merges?

**Answer:**

```bash
git merge --no-ff feature/login
```

By default, when a fast-forward is possible, Git just moves the pointer (no merge commit). `--no-ff` forces a real merge commit, preserving the visual record that a feature branch existed.
> Common in GitFlow — all feature merges into `develop` use `--no-ff` for traceability.

### Q102: What are the advanced stash flags `--keep-index`, `-u`, and `--patch`?

**Answer:** Default `git stash` only saves **tracked, modified** files.

```bash
# Stash but KEEP staged files in the index (test your staged commit first)
git stash --keep-index

# Also stash UNTRACKED files (brand new files not yet git add'd)
git stash -u
# or
git stash --include-untracked

# Interactively pick which hunks to stash
git stash --patch
```

```powershell
git init stash-adv; cd stash-adv
"base" > app.txt; git add .; git commit -m "Base"

# Scenario: staged a bugfix AND have untracked+unstaged experimental work
"bugfix" > app.txt;     git add app.txt    # staged
"experiment" > exp.txt                     # untracked, not staged
Add-Content app.txt " wip"                 # unstaged modification to staged file

git status -s
# MM app.txt   <- staged AND has unstaged changes
# ?? exp.txt   <- untracked

# --keep-index: stash only unstaged changes, leave staged bugfix alone
git stash --keep-index
git status -s
# M  app.txt   <- staged bugfix still here!
# stash holds only the unstaged WIP
git stash pop  # restore WIP

# -u: also stash untracked files (exp.txt)
git stash -u
git status     # clean! exp.txt is also stashed
git stash pop  # exp.txt returns

# --patch: interactively choose which hunks to stash
git stash --patch
# Shows each hunk: y=stash it, n=keep it, s=split hunk
```

### Q103: What is the difference between `git diff A..B` and `git diff A...B`?

**Answer:**

- **`git diff master..contrib`** (double-dot): Compares the tip of `master` directly with the tip of `contrib`. Can be misleading if `master` has moved forward — it looks like `contrib` is "removing" `master`'s new code.
- **`git diff master...contrib`** (triple-dot): Compares `contrib` against the **common ancestor** it shares with `master` — shows only the **new work** introduced on the topic branch. This is almost always what you want.

### Q104: How do you push a repository with Git Submodules safely?

**Answer:**

```bash
# Fail the push if any submodule commits haven't been published yet
git push --recurse-submodules=check

# Automatically push all submodules first, then push the main project
git push --recurse-submodules=on-demand
```

> Without this, you can push a main project referencing a submodule commit that doesn't exist on the remote — breaking everyone who clones the repo.

```powershell
# Setup: create a submodule repo and a parent repo
git init sub-lib; cd sub-lib
"lib code" > lib.txt; git add .; git commit -m "Lib v1"
cd ..

git init main-project; cd main-project
git submodule add ../sub-lib libs/sub-lib
git commit -m "Add submodule"

# Make a change IN the submodule (without pushing it)
cd libs/sub-lib
"lib v2" > lib.txt; git add .; git commit -m "Lib v2 (unpublished)"
cd ../..

# Update parent to reference the new submodule commit
git add libs/sub-lib
git commit -m "Update submodule ref to v2"

# Now try to push the parent:
# --check: FAILS if submodule commit not published (safety net)
git push --recurse-submodules=check
# Error: push declined, submodule 'libs/sub-lib' was not pushed

# --on-demand: auto-pushes submodule first, then parent
git push --recurse-submodules=on-demand
# Pushes sub-lib, then main-project — remote stays consistent
```

### Q105: What are essential Git environment variables?

**Answer:** Git uses environment variables for overriding internal paths and commit metadata — critical for CI/CD scripting:

```bash
GIT_DIR              # Override location of the .git folder
GIT_WORK_TREE        # Set root of the working directory (for non-bare repos)
GIT_AUTHOR_NAME      # Override author name for a specific commit
GIT_AUTHOR_EMAIL     # Override author email for a specific commit
GIT_COMMITTER_NAME   # Override committer name (can differ from author)
GIT_COMMITTER_DATE   # Override committer timestamp
GIT_SSH              # Override the SSH command Git uses
```

> These are heavily used in **CI/CD pipelines** to set bot/automation identities without modifying `~/.gitconfig`.

```powershell
git init envvar-lab; cd envvar-lab
"code" > app.txt; git add .

# Override author for a single commit (CI bot identity)
$env:GIT_AUTHOR_NAME    = "CI Bot"
$env:GIT_AUTHOR_EMAIL   = "ci@company.com"
$env:GIT_COMMITTER_NAME = "CI Bot"
git commit -m "[ci] automated release commit"

git log -1
# Author: CI Bot <ci@company.com>  <- overridden
# Committer: CI Bot <ci@company.com>

# Clean up
Remove-Item Env:\GIT_AUTHOR_NAME, Env:\GIT_AUTHOR_EMAIL, Env:\GIT_COMMITTER_NAME

# Override GIT_DIR: run git commands against a repo from a different directory
$env:GIT_DIR = "C:\path\to\other-repo\.git"
$env:GIT_WORK_TREE = "C:\path\to\other-repo"
git status   # operates on the OTHER repo without cd-ing there
Remove-Item Env:\GIT_DIR, Env:\GIT_WORK_TREE
```

### Q106: Can Git be used as a client for Mercurial repositories?

**Answer:** Yes, via **`git-remote-hg`** — a remote helper that maps Mercurial bookmarks and branches to Git refs, allowing standard Git commands to interact with Mercurial servers.

```bash
# Clone a Mercurial repo using Git
git clone hg::https://hg.example.com/repo

# Push back to Mercurial
git push
```

> For **SVN**, see Q89 (`git svn`). For Mercurial, `git-remote-hg` is the bridge.

### Q107: How do you fetch all GitHub Pull Requests locally for testing?

**Answer:** Edit `.git/config` under `[remote "origin"]` and add a custom refspec:

```ini
[remote "origin"]
    url = https://github.com/user/repo.git
    fetch = +refs/heads/*:refs/remotes/origin/*
    fetch = +refs/pull/*/head:refs/remotes/origin/pr/*
```

Then run:

```bash
git fetch origin
git checkout origin/pr/42   # Test PR #42 locally
```

> This downloads every active PR as a **read-only tracking branch** — essential for reviewing PRs without using the GitHub UI.

```powershell
# Step 1: Add the PR refspec to your repo config
# Open .git/config and add the second fetch line under [remote "origin"]
# OR do it via command:
git config --add remote.origin.fetch '+refs/pull/*/head:refs/remotes/origin/pr/*'

# Verify it was added
git config --get-all remote.origin.fetch
# +refs/heads/*:refs/remotes/origin/*
# +refs/pull/*/head:refs/remotes/origin/pr/*   <- new line

# Step 2: Fetch all PRs
git fetch origin
# Downloads every open PR as origin/pr/<number>

# Step 3: List available PR branches
git branch -r | Select-String "pr/"
# origin/pr/1
# origin/pr/42
# origin/pr/99

# Step 4: Check out a specific PR to test it
git checkout -b test-pr-42 origin/pr/42
# Now on a local branch with PR #42's code
git log --oneline   # See the PR's commits

# Step 5: Clean up
git checkout main
git branch -D test-pr-42
```

> **Use case:** Test a PR locally before approving it, run integration tests against the PR branch, or do code review at the command line.

---

## 🔬 Practical Simulations — Topics Not in SOP Guide

> These simulations cover interview questions that require hands-on practice but are **not** in `README_git_v2.md`. All commands are PowerShell-native with Unix equivalents noted.

---

### 🔬 SIM 1: Git Hooks — Enforce Rules Locally (Q41, Q79, Q88)

**SIM 1A — pre-commit: block commits containing TODO**

```powershell
git init hooks-lab
cd hooks-lab
"app code" > app.py
git add .
git commit -m "Initial"
```

Git hooks live in `.git/hooks/` and are shell scripts (Git uses its bash layer even on Windows):

```powershell
# Write the pre-commit hook
@'
#!/bin/sh
if git diff --cached | grep -q "TODO"; then
  echo "ERROR: Remove TODO comments before committing."
  exit 1
fi
exit 0
'@ | Set-Content .git/hooks/pre-commit -Encoding ASCII

# Test — commit with a TODO: BLOCKED
"my code # TODO: fix later" > app.py
git add app.py
git commit -m "Add app"
# Output: ERROR: Remove TODO comments before committing.
# Commit aborted.

# Test — commit without TODO: PASSES
"my code" > app.py
git add app.py
git commit -m "Add clean app"
```

**SIM 1B — commit-msg: enforce `[type]` prefix**

```powershell
@'
#!/bin/sh
MSG=$(cat "$1")
if ! echo "$MSG" | grep -qE "^\[(feat|fix|docs|chore)\]"; then
  echo "ERROR: Message must start with [feat], [fix], [docs], or [chore]"
  exit 1
fi
exit 0
'@ | Set-Content .git/hooks/commit-msg -Encoding ASCII

git commit --allow-empty -m "added some stuff"        # ERROR — rejected
git commit --allow-empty -m "[feat] add login"        # Succeeds
```

**SIM 1C — pre-push: block direct pushes to main**

```powershell
@'
#!/bin/sh
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" = "main" ]; then
  echo "ERROR: Direct push to main is not allowed. Use a PR."
  exit 1
fi
exit 0
'@ | Set-Content .git/hooks/pre-push -Encoding ASCII
```

> **Sharing hooks with team:** `.git/hooks/` is not committed. Store scripts in `scripts/hooks/` and configure with: `git config core.hooksPath scripts/hooks`

---

### 🔬 SIM 2: `git cherry-pick` — Apply One Commit Elsewhere (Q31)

```powershell
git init cherry-lab
cd cherry-lab
"base" > base.txt
git add .; git commit -m "Base"

git checkout -b branch-a
"bugfix" > bugfix.txt
git add .; git commit -m "[fix] critical auth bugfix"
"extra" > extra.txt
git add .; git commit -m "Extra work"

git log --oneline
# abc123 Extra work
# def456 [fix] critical auth bugfix   <- want ONLY this on main

git checkout main
git cherry-pick def456

git log --oneline
# ghi789 [fix] critical auth bugfix   <- NEW hash (parent changed)
# hij012 Base
```

```powershell
# Cherry-pick without auto-committing (inspect first)
git cherry-pick def456 --no-commit
git status   # changes staged, not committed yet
git commit -m "Verified cherry-pick of bugfix"

# Cherry-pick a range
git cherry-pick def456^..abc123
```

> Original commit on branch-a is untouched. cherry-pick always creates a **new commit with a new hash**.

---

### 🔬 SIM 3: `git worktree` — Two Branches Checked Out Simultaneously (Q64)

```powershell
git init worktree-lab
cd worktree-lab
"main code" > main.txt
git add .; git commit -m "Initial on main"

git checkout -b hotfix
"hotfix applied" > fix.txt
git add .; git commit -m "Hotfix"
git checkout main

# Check out hotfix into a PARALLEL directory without switching branches
git worktree add ../hotfix-view hotfix

# Two working directories now exist at the same time:
# ./worktree-lab  -> main branch
# ../hotfix-view  -> hotfix branch

cd ../hotfix-view
Get-Content fix.txt   # "hotfix applied" — main untouched

git worktree list
# /path/to/worktree-lab   abc123 [main]
# /path/to/hotfix-view    def456 [hotfix]

# When done
cd ../worktree-lab
git worktree remove ../hotfix-view
```

> **Use case:** Apply and test a hotfix on main while keeping your feature branch untouched — no stashing needed.

---

### 🔬 SIM 4: `git add -p` — Stage Specific Hunks Interactively (Q87)

```powershell
git init addp-lab
cd addp-lab
"line 1: stable" > app.py
"line 2: stable" >> app.py    # Unix: echo "line 2: stable" >> app.py
git add .; git commit -m "Initial"

# Two unrelated changes in the SAME file
"line 1: BUGFIX applied" > app.py
Add-Content app.py "line 2: stable"           # Unix: echo >> app.py
Add-Content app.py "line 3: new experiment"   # Unix: echo >> app.py
```

```powershell
# Stage ONLY the bugfix hunk, skip the experimental line
git add -p app.py
# Prompt: Stage this hunk [y,n,q,a,d,s,?]?
# s = split  |  y = stage this hunk  |  n = skip this hunk

git status
# Modified (staged):   app.py   <- bugfix hunk only
# Modified (unstaged): app.py   <- experimental line (same file!)

git commit -m "[fix] bugfix only"
# Experimental line remains in working directory, not committed
```

> Git tracks at the **hunk level**, not the file level. One file can be half-staged and half-unstaged simultaneously.

---

### 🔬 SIM 5: `git merge --no-ff` — Preserve Branch History (Q101)

```powershell
git init noff-lab
cd noff-lab
"base" > base.txt
git add .; git commit -m "Base"

git checkout -b feature
"feature work" > feature.txt
git add .; git commit -m "Feature done"
git checkout main

# Default fast-forward — no merge commit, branch history invisible
git merge feature
git log --oneline --graph
# * def456 Feature done
# * abc123 Base   <- linear, no sign a branch ever existed

git reset --hard abc123   # undo to try again

# --no-ff forces a merge commit even when fast-forward is possible
git merge --no-ff feature -m "Merge feature branch"
git log --oneline --graph
# *   ghi789 Merge feature branch
# |\
# | * def456 Feature done
# |/
# * abc123 Base   <- branch lifetime preserved in graph
```

> GitFlow uses `--no-ff` for all feature merges into `develop` so branch history is always visible.

---

### 🔬 SIM 6: `git merge -Xours` / `-Xtheirs` — Auto-Resolve Conflicts (Q85)

```powershell
git init xours-lab
cd xours-lab
"original" > config.txt
git add .; git commit -m "Base"

git checkout -b feature
"feature config version" > config.txt
git add .; git commit -m "Feature config"

git checkout main
"main config version" > config.txt
git add .; git commit -m "Main config"

# Normal merge produces CONFLICT
git merge feature
# CONFLICT (content): Merge conflict in config.txt
git merge --abort

# -Xours: auto-keep OUR (main) version on every conflict
git merge -Xours feature
Get-Content config.txt   # "main config version" — no manual editing needed

git reset --hard HEAD~1

# -Xtheirs: auto-keep THEIR (feature) version on every conflict
git merge -Xtheirs feature
Get-Content config.txt   # "feature config version"
```

> **`-Xours` vs `-s ours`:** `-Xours` does a real 3-way merge, auto-resolving in our favour. `-s ours` completely ignores the other branch and creates a fake merge commit.

---

### 🔬 SIM 7: `..` vs `...` in `git log` and `git diff` (Q98, Q103)

```powershell
git init dotdot-lab
cd dotdot-lab
"v1" > f.txt; git add .; git commit -m "Shared A"
"v2" > f.txt; git add .; git commit -m "Shared B"

git checkout -b feature
"fc" > feat.txt; git add .; git commit -m "C — feature only"

git checkout main
"mc" > fix.txt;  git add .; git commit -m "D — main only"

git log --oneline --graph --all
# * D main only        <- main tip
# | * C feature only  <- feature tip
# |/
# * B shared
# * A shared          <- common ancestor
```

```powershell
# git log DOUBLE-DOT: commits in feature NOT yet in main
git log main..feature --oneline
# C — feature only

# git log TRIPLE-DOT: all diverged commits (in either, not in both)
git log main...feature --oneline
# D — main only
# C — feature only

# git diff DOUBLE-DOT: compares tips directly (misleading — shows D as "deleted")
git diff main..feature

# git diff TRIPLE-DOT: compares feature vs COMMON ANCESTOR only
git diff main...feature   # Always use this for PR reviews
```

---

### 🔬 SIM 8: `git rerere` — Reuse Recorded Conflict Resolutions (Q72)

```powershell
git config --global rerere.enabled true

git init rerere-lab
cd rerere-lab
"original" > shared.txt
git add .; git commit -m "Base"

git checkout -b feature
"feature version" > shared.txt
git add .; git commit -m "Feature edit"

git checkout main
"main version" > shared.txt
git add .; git commit -m "Main edit"

# First merge — resolve the conflict manually
git merge feature
# CONFLICT in shared.txt
"final resolved version" > shared.txt
git add shared.txt
git commit -m "Merge — manual resolution"
# rerere records the resolution in .git/rr-cache/

Get-ChildItem .git/rr-cache   # confirm the cache entry exists

# Simulate the same conflict again (e.g. after a reset + re-merge)
git reset --hard HEAD~1
git merge feature
# Git AUTOMATICALLY applies the saved resolution — no editor opens
git add shared.txt
git commit -m "Merge — rerere auto-resolved"
```

> **Best use case:** Feature branches repeatedly rebased onto `main` — rerere eliminates resolving the same conflict every single time.

---

### 🔬 SIM 9: Extract Conflict Stage Versions (Q93)

```powershell
git init stage-lab
cd stage-lab
"common ancestor" > file.txt
git add .; git commit -m "Base"

git checkout -b branch-a
"branch-a version" > file.txt
git add .; git commit -m "A edit"

git checkout main
"main version" > file.txt
git add .; git commit -m "Main edit"

git merge branch-a   # CONFLICT — do NOT resolve yet

# Inspect the three versions stored in the index
git ls-files --stage file.txt
# 100644 <hash1> 1   file.txt   <- Stage 1: common ancestor
# 100644 <hash2> 2   file.txt   <- Stage 2: ours (main)
# 100644 <hash3> 3   file.txt   <- Stage 3: theirs (branch-a)

# Extract each version
git show :1:file.txt   # common ancestor
git show :2:file.txt   # our version (main)
git show :3:file.txt   # their version (branch-a)

# Save to disk for manual 3-way comparison
git show :1:file.txt > file.common.txt
git show :2:file.txt > file.ours.txt
git show :3:file.txt > file.theirs.txt
```

> This is exactly how VS Code and IntelliJ render their 3-way merge editor panels.

---

### 🔬 SIM 10: `git describe` — Human-Readable Build Version IDs (Q76)

```powershell
git init describe-lab
cd describe-lab
"release code" > app.txt
git add .; git commit -m "Version 1.0 release"
git tag -a v1.0 -m "Version 1.0"

"patch 1" >> app.txt; git add .; git commit -m "Patch 1"   # Unix: echo >> app.txt
"patch 2" >> app.txt; git add .; git commit -m "Patch 2"

git describe
# Output: v1.0-2-gabcdef1
#         |    |  |
#         tag  2  short SHA of HEAD (2 commits after tag)

git describe --tags --always   # fallback to raw hash if no tag exists

# In a CI/CD pipeline to auto-generate version strings:
$version = git describe --tags --always
Write-Output "Building version: $version"
# Output: Building version: v1.0-2-gabcdef1
```

---

### 🔬 SIM 11: `git bundle` — Offline Repo Transfer (Q71)

```powershell
git init bundle-source
cd bundle-source
"v1" > app.txt; git add .; git commit -m "Commit 1"
"v2" > app.txt; git add .; git commit -m "Commit 2"
"v3" > app.txt; git add .; git commit -m "Commit 3"

# Pack the entire repo into one portable binary file
git bundle create ../repo.bundle HEAD main
# Transfer repo.bundle via USB, email, shared drive — no network needed

# Verify the bundle is valid before sending
git bundle verify ../repo.bundle

# Recipient clones directly from the file
cd ..
git clone repo.bundle bundle-recipient
cd bundle-recipient
git log --oneline   # All 3 commits are present
```

---

### 🔬 SIM 12: `git restore --source` — Restore One File to a Past State (Q95)

```powershell
git init restore-lab
cd restore-lab
"version 1 content" > config.txt; git add .; git commit -m "v1"
"version 2 content" > config.txt; git add .; git commit -m "v2"
"version 3 broken"  > config.txt; git add .; git commit -m "v3 broken"

git log --oneline
# abc003 v3 broken   <- HEAD
# abc002 v2
# abc001 v1

# Restore ONLY config.txt to v1 — HEAD does not move
git restore --source=HEAD~2 config.txt
Get-Content config.txt   # "version 1 content"

git log --oneline
# abc003 v3 broken   <- HEAD still here, unchanged

git status
# modified: config.txt   <- file restored, ready to commit
```

> **vs `git reset --hard HEAD~2`:** reset moves HEAD and affects ALL files. `restore --source` touches only the specified file; HEAD and all other files are unchanged.

---

### 🔬 SIM 13: `git status -s` — Read the Compact Two-Column Output (Q96)

```powershell
git init status-lab
cd status-lab
"original" > tracked.txt
git add .; git commit -m "Initial"

# Create multiple file states at once
"modified version" > tracked.txt
git add tracked.txt                             # stage it
Add-Content tracked.txt "modified again"        # modify AFTER staging
"new staged file" > staged-new.txt
git add staged-new.txt
"untracked file" > untracked.txt               # never added to git

git status -s
# Output:
# MM tracked.txt       <- Left M=staged, Right M=modified after staging
# A  staged-new.txt    <- Added new file to staging area
# ?? untracked.txt     <- Untracked — Git sees it but ignores it

# Column key:
# Left  column = Staging Area (index) status
# Right column = Working Directory status
# M=Modified  A=Added  D=Deleted  R=Renamed  ??=Untracked
```

---

### 🔬 SIM 14: `git shortlog` — Contribution Summary per Author (Q78)

```powershell
git init shortlog-lab
cd shortlog-lab

# Simulate two authors using Git environment variable overrides
$env:GIT_AUTHOR_NAME    = "Alice"
$env:GIT_COMMITTER_NAME = "Alice"
"work" > a.txt;  git add .; git commit -m "Alice: feature A"
"fix"  >> a.txt; git add .; git commit -m "Alice: fix typo"   # Unix: echo >> a.txt

$env:GIT_AUTHOR_NAME    = "Bob"
$env:GIT_COMMITTER_NAME = "Bob"
"work" > b.txt;  git add .; git commit -m "Bob: feature B"

# Clean up env overrides
Remove-Item Env:\GIT_AUTHOR_NAME
Remove-Item Env:\GIT_COMMITTER_NAME

# Group commits by author
git shortlog
# Alice (2):
#     Alice: feature A
#     Alice: fix typo
#
# Bob (1):
#     Bob: feature B

# Summary only, sorted by commit count
git shortlog -sn
#  2  Alice
#  1  Bob

# Commits since a tag (for release changelog generation)
git shortlog v1.0..HEAD -sn
```

> **CI/CD use:** `git shortlog -sn` auto-generates contributor stats for release notes.

---

### 🔬 SIM 15: `git replace` — Virtual History Grafting (Q73)

#### 🧠 The Core Concept

`git replace` tells Git: **"whenever you encounter object A, transparently show object B instead"** — without touching any real commit hashes.

Think of it as a **transparent overlay** on the DAG. The real commits underneath are completely unchanged. No hashes are rewritten. No collaborators are broken.

---

#### 🤔 Why Does This Exist?

Git's object model is immutable. Every commit hash depends on its parent's hash. Rewriting one commit means **every downstream commit gets a new hash** — breaking everyone who cloned the repo.

`git replace` is the escape hatch: **graft alternate history virtually** without touching any real hashes.

---

#### 🏭 Real-World Use Cases

| Scenario | How `git replace` helps |
| --- | --- |
| **Huge old repo (10yr, 100k commits)** | Split into short history (new devs) + full history (data mining). Connect them virtually with `git replace`. |
| **Legacy team merge** | Company A acquires Company B. Unrelated histories. `git replace` connects the two DAGs virtually. |
| **Retroactive parent fix** | A commit was accidentally orphaned (wrong parent). Fix the parent pointer without rewriting 50k downstream commits. |
| **Preview before filter-repo** | Test what a rewritten commit looks like before committing to the full destructive rewrite. |

---

#### The Key Difference vs Rewriting History

---

#### The Key Difference vs Rewriting History

| | `git replace` | `git rebase` / `filter-repo` |
| --- | --- | --- |
| Changes real hashes? | ❌ No — zero hash changes | ✅ Yes — every downstream commit |
| Permanent? | Stored in `.git/refs/replace/` only | Rewrites the entire object database |
| Shared with others? | Only if you push `refs/replace/*` explicitly | Always shared via normal push |
| Safe on pushed repos? | ✅ Yes | ⚠️ No — breaks collaborators |

---

#### 🔬 Simulation — Full Step-by-Step (PowerShell)

**The Scenario:** You have a 4-year-old repo. New developers only need the last 2 commits (small, fast clone). But senior devs still need the full history connected. You use `git replace` to graft the old history onto the shallow clone — without rewriting anything.

**Step 1: Create the full history repo**

```powershell
git init full-history-repo
cd full-history-repo

"year 2020 code" > app.txt; git add .; git commit -m "2020: Initial project"
"year 2021 code" > app.txt; git add .; git commit -m "2021: Big refactor"
"year 2022 code" > app.txt; git add .; git commit -m "2022: New features"
"year 2023 code" > app.txt; git add .; git commit -m "2023: Current work"

git log --oneline
# abc004 (HEAD -> main) 2023: Current work
# abc003                2022: New features
# abc002                2021: Big refactor
# abc001                2020: Initial project  <- original root
```

**Step 2: Simulate a shallow clone (what a new dev gets)**

```powershell
cd ..
git clone --depth 2 full-history-repo shallow-clone
cd shallow-clone

git log --oneline
# abc004 2023: Current work
# abc003 2022: New features   <- appears as the ROOT, history ends here

# Confirm abc003 has no parent in this clone
git cat-file -p abc003
# tree   <hash>
# author ...
# 2022: New features
# NOTE: NO "parent" line — the shallow boundary cuts it off
```

**Step 3: Observe the problem — history is invisible**

```powershell
git log --oneline --all
# abc004 2023: Current work
# abc003 2022: New features   <- 2020 and 2021 are completely gone

git log --oneline abc003
# abc003 2022: New features   <- root, no ancestors visible
```

**Step 4: Fetch the old root from the full repo**

```powershell
# Add the full repo as a remote so we can pull objects from it
git remote add full ../full-history-repo
git fetch full

# Now we have all 4 commits available locally
git log --oneline full/main
# abc004 2023: Current work
# abc003 2022: New features
# abc002 2021: Big refactor
# abc001 2020: Initial project
```

**Step 5: Apply the `git replace` graft**

```powershell
# Tell Git: "Whenever you see abc003, virtually show its version
# from the full history — which DOES have a parent (abc002)"

# --graft creates a replacement commit with modified parent pointers
git replace --graft abc003 abc002
# This says: make abc003 virtually have abc002 as its parent

# OR to join the two complete histories seamlessly:
# git replace --graft abc003 abc001  <- makes abc003's parent = abc001
```

**Step 6: Observe the virtual graft working**

```powershell
# History now shows the FULL chain
git log --oneline
# abc004 2023: Current work
# abc003 2022: New features
# abc002 2021: Big refactor   <- appears even though not in original clone!
# abc001 2020: Initial project

# The real hashes are UNCHANGED — verify:
git cat-file -p abc003
# tree   <hash>
# author ...
# 2022: New features
# NOTE: still no parent here — the REAL object is untouched

# See the replacement that is active:
git replace -l
# abc003 -> <replacement-object-hash>
```

**Step 7: Bypass the replacement to see raw truth**

```powershell
# Disable all replacements for one command
git --no-replace-objects log --oneline
# abc004 2023: Current work
# abc003 2022: New features   <- back to root, graft disabled

# Normal log uses replacement transparently
git log --oneline
# All 4 commits visible again
```

**Step 8: Share the replacement with others (optional)**

```powershell
# Replacements live in refs/replace/ — NOT pushed by default
# To share with your team:
git push origin 'refs/replace/*'

# Others then fetch it:
git fetch origin 'refs/replace/*:refs/replace/*'
# Now their git log also shows the full grafted history
```

**Step 9: Clean up the replacement**

```powershell
# Delete a specific replacement
git replace -d abc003

# Verify it's gone
git replace -l   # empty output

# History returns to shallow view
git log --oneline
# abc004 2023: Current work
# abc003 2022: New features   <- root again
```

---

#### 🎯 Interview One-Liner

> *"`git replace` is a virtual history graft — it remaps object lookups in real time without touching any real SHA hashes, making it the only safe way to 'edit' an already-pushed commit's relationships."*
