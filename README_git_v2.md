# 🧠 Git Mastery v2: Plumbing → SOP → Interview Prep

> **How to use this guide:** Follow each section top-to-bottom. Run every command yourself. The goal is to *understand* what Git is doing internally, not just memorize commands.

---

## 🔬 Part 1: Inside the Machine — Git Plumbing

Git has two command layers:
- **Porcelain:** High-level, user-friendly (`git commit`, `git add`, `git log`) — what you use every day.
- **Plumbing:** Raw, low-level inspection commands (`git cat-file`, `git ls-files`, `git ls-tree`) — used to *observe what Git created internally*.

> **Philosophy of this section:** We use **porcelain to do the work**, and **plumbing to see inside**. You never need to create objects manually — but you DO need to understand what Git creates automatically.

---

### 1.1 The Object Database — `.git/objects`

Every file, folder, and commit Git tracks is stored as a compressed, SHA-1 hashed **object** in `.git/objects`. There are exactly 4 types:

| Type | What it stores | Analogy |
| --- | --- | --- |
| `blob` | Raw file contents (no filename, no path) | The text inside a book |
| `tree` | Directory listing — maps filenames to blob/tree hashes | Table of contents |
| `commit` | Snapshot metadata — tree + parent + author + message | A library card |
| `tag` | A named, permanent pointer to a commit | A sticky bookmark |

---

### 🔬 SOP 1.1 — Create a commit and observe all 3 objects

```bash
# Start fresh
git init plumbing-lab
cd plumbing-lab

# Porcelain: create a file and commit it normally
echo "Hello, Git" > hello.txt
git add hello.txt
git commit -m "First commit"
```

Now let's **use plumbing to see what Git just created:**

```bash
# Step 1: Find the latest commit hash
git log --oneline
# Output: abc1234 First commit

# Step 2: Inspect the COMMIT object
git cat-file -t abc1234     # Output: commit
git cat-file -p abc1234
# Output:
# tree <tree-hash>
# author  Your Name <you@email.com> 1714000000 +0530
# committer Your Name <you@email.com> 1714000000 +0530
#
# First commit
```

> **What you just saw:** The commit stores the **tree hash** (directory snapshot), author metadata, and message. It does NOT store a diff — it stores a pointer to the full state.

```bash
# Step 3: Inspect the TREE object (the directory snapshot)
git cat-file -p <tree-hash>
# Output:
# 100644 blob <blob-hash>    hello.txt
```

> **What `100644` means:**
> - `100` = regular file
> - `644` = Unix permissions (rw-r--r--)
> - `040000` = directory (sub-tree)

```bash
# Step 4: Inspect the BLOB object (the actual file content)
git cat-file -t <blob-hash>    # Output: blob
git cat-file -p <blob-hash>    # Output: Hello, Git
```

> **Key Insight:** The blob has NO filename. The filename lives in the **tree**. This is why identical files across different folders share the same blob object — Git stores content, not paths.

---

### 🔬 SOP 1.2 — Observe the parent chain (commit history as linked list)

```bash
# Add a second commit
echo "World" >> hello.txt
git add hello.txt
git commit -m "Second commit"

# Inspect the new commit
git cat-file -p HEAD
# Output:
# tree <new-tree-hash>
# parent <first-commit-hash>     ← THIS IS THE LINKED LIST POINTER
# author ...
#
# Second commit
```

> **What you just saw:** Every commit except the first has a `parent` line. This chain of parent pointers IS the commit history — the DAG (Directed Acyclic Graph).

A **merge commit** has TWO parent lines — that's the only thing that makes it special:
```bash
# After a merge you'd see:
# parent <hash-of-master-tip>
# parent <hash-of-feature-tip>
```

---

### 🔬 SOP 1.3 — Prove snapshot reuse (Git's storage efficiency)

```bash
# Add a new file in the third commit (don't touch hello.txt)
echo "New file" > new.txt
git add new.txt
git commit -m "Add new.txt"

# Compare the trees of commit 2 and commit 3
git cat-file -p HEAD~1    # tree hash of commit 2 → inspect it
git cat-file -p HEAD      # tree hash of commit 3 → inspect it
```

**Look at the blob hash for `hello.txt` in both trees. It is IDENTICAL.**

Git did **not** copy `hello.txt`. It just referenced the same blob object in the new tree.

```
Commit 2 Tree:               Commit 3 Tree:
100644 blob abc123 hello.txt   100644 blob abc123 hello.txt  ← SAME HASH
                               100644 blob def456 new.txt    ← NEW blob only
```

> **Interview answer to "How is Git efficient?":** Git reuses blob objects across commits. Only changed files get new blobs. This is why `git checkout` is near-instant even on huge repos.

---

### 🔬 SOP 1.4 — Observe HEAD, branches, and refs as plain text files

Branches are not complex database entries. They are just **text files** containing one hash:

```powershell
# PowerShell: See what HEAD points to
Get-Content .git/HEAD
# Output: ref: refs/heads/master

# See what the master branch points to
Get-Content .git/refs/heads/master
# Output: abc1234...  (the latest commit hash)

# After creating a new branch:
git checkout -b feature-x
Get-Content .git/HEAD
# Output: ref: refs/heads/feature-x

# After detaching HEAD (git checkout <hash>):
Get-Content .git/HEAD
# Output: abc1234...  (points directly to a hash, not a ref)
```

> **Interview insight:** A branch costs ~41 bytes (one hash + newline). This is why Git branching is nearly free. SVN copies entire directories; Git just creates a new pointer file.

```bash
# List all objects Git has stored (observe how few objects exist)
git count-objects -v
# Output:
# count: 0        ← loose objects
# size: 0
# in-pack: 9      ← objects compressed in a packfile
```

---

### 🔬 SOP 1.5 — Observe the staging area (Index) directly

The **Index** (staging area) is Git's "proposed next commit". It is a binary file at `.git/index`.

```bash
# Make a change but don't commit yet
echo "Staged change" >> hello.txt
git add hello.txt

# Inspect what the Index currently holds (plumbing view of staging area)
git ls-files --stage
# Output:
# 100644 <new-blob-hash> 0    hello.txt
# 100644 <blob-hash>     0    new.txt

# The "0" is the stage number:
# 0 = normal (no conflict)
# 1 = common ancestor (during conflict)
# 2 = ours (during conflict)
# 3 = theirs (during conflict)
```

> This is why during a merge conflict, you can extract the 3 versions:
> `git show :1:hello.txt`, `git show :2:hello.txt`, `git show :3:hello.txt`

---

### 1.2 HEAD, Branches, and the DAG — The Full Picture

```
[Blob: "Hello, Git"]
        ↑
[Tree: hello.txt → blob]
        ↑
[Commit 1: tree → tree, parent → none]
        ↑
[Commit 2: tree → tree, parent → Commit1]
        ↑
[Commit 3: tree → tree, parent → Commit2]
        ↑
[master ref: → Commit3]
        ↑
[HEAD: → master]
```

Every `git commit` moves `master` (and `HEAD`) one step forward. Every `git checkout <branch>` moves `HEAD` to point at a different ref.

> **Interview insight:** Creating a branch in Git takes nanoseconds and costs ~41 bytes (one hash + newline). This is why Git branching is "cheap" compared to SVN.

---


## 🌿 Part 2: The Three Trees — The Mental Model for Everything

Every Git operation manipulates one or more of these three "trees":

```
Working Directory  →  Staging Area (Index)  →  Repository (HEAD)
    (your files)          (.git/index)           (.git/objects)
```

| Command | What it moves |
| --- | --- |
| `git add` | Working Dir → Index |
| `git commit` | Index → Repository |
| `git restore <file>` | Index/HEAD → Working Dir |
| `git reset HEAD~1` | HEAD back one commit (various modes) |
| `git checkout <branch>` | Repository → Index + Working Dir |

---

### 🔬 SOP 2.1 — Observe the Three Trees live

```bash
# Make a change
echo "change" >> hello.txt

# Tree 1: Working Directory shows modification
git status

# Move to Tree 2: Staging Area
git add hello.txt
git status   # "Changes to be committed"

# Inspect the Index directly (raw plumbing)
git ls-files --stage
# Output: 100644 <new-blob-hash> 0    hello.txt

# Move to Tree 3: Repository
git commit -m "Update hello.txt"

# All three trees are now in sync
git status   # "nothing to commit"
```

---

## 🔀 Part 3: Branching & Merging SOPs

### 🔬 SOP 3.1 — Simulate a Y-shape divergence

```powershell
# Setup  (Unix: git init merge-lab && cd merge-lab)
git init merge-lab
cd merge-lab
"base" > base.txt           # Unix: echo "base" > base.txt
git add .
git commit -m "Base commit"

# Branch off
git checkout -b feature-a
"feature A work" > feature-a.txt
git add .
git commit -m "Feature A commit"

# Back to master, add a commit there too
git checkout master
"master work" > master.txt
git add .
git commit -m "Master commit"

# Visualize the Y-shape
git log --oneline --graph --all
```

**Expected output:**
```
* abc1234 (HEAD -> master) Master commit
| * def5678 (feature-a) Feature A commit
|/
* ghi9012 Base commit
```

---

### 🔬 SOP 3.2 — Three-Way Merge

```bash
# Merge feature-a into master
git merge feature-a -m "Merge feature-a into master"

# Inspect the merge commit — it has TWO parents
git cat-file -p HEAD
# Look for TWO "parent" lines — this is what makes it a merge commit

# Visualize merged history
git log --oneline --graph --all
```

> **Interview insight:** Git finds the **Common Ancestor** (the base commit), computes diffs from both sides, and combines them. If they touch different lines → automatic merge. Same line → CONFLICT.

---

### 🔬 SOP 3.3 — Force a Conflict and Resolve it

```powershell
# Unix: git init conflict-lab && cd conflict-lab
git init conflict-lab
cd conflict-lab
"line 1: original" > story.txt
git add .
git commit -m "Initial story"

# Branch A edits line 1
git checkout -b branch-a
"line 1: Branch A version" > story.txt
git add .
git commit -m "Branch A edit"

# Master also edits line 1
git checkout master
"line 1: Master version" > story.txt
git add .
git commit -m "Master edit"

# Trigger the conflict
git merge branch-a
```

**Git output:** `CONFLICT (content): Merge conflict in story.txt`

**Open `story.txt` — you will see:**
```
<<<<<<< HEAD
line 1: Master version
=======
line 1: Branch A version
>>>>>>> branch-a
```

**Resolution:**
```powershell
# Edit story.txt manually to the final version, remove ALL markers
# Then run:
git add story.txt
git commit
```

---

### 🔬 SOP 3.4 — Rebase (Linear History)

```powershell
# Unix: git init rebase-lab && cd rebase-lab
git init rebase-lab
cd rebase-lab
"base" > base.txt
git add .
git commit -m "Base"

git checkout -b feature
"feature work" > feature.txt
git add .
git commit -m "Feature commit"

# Add a new commit to master
git checkout master
"hotfix" > hotfix.txt
git add .
git commit -m "Hotfix on master"

# Before rebase — Y-shape
git log --oneline --graph --all

# Rebase feature onto master
git checkout feature
git rebase master

# After rebase — linear
git log --oneline --graph --all

# Proof: the hash of "Feature commit" CHANGED (note the different hash vs before)
```

> **The Golden Rule:** After rebase, the Feature commit has a **new hash** because its parent changed. This is why you NEVER rebase a branch that others have already pulled.

---

## ⏪ Part 4: Undoing Things — Reset, Revert, Restore

### The Reset Modes Compared

```powershell
# Setup: make 3 commits  (Unix: git init undo-lab && cd undo-lab)
git init undo-lab
cd undo-lab
"v1" > file.txt; git add .; git commit -m "Commit 1"
"v2" > file.txt; git add .; git commit -m "Commit 2"
"v3" > file.txt; git add .; git commit -m "Commit 3"
git log --oneline
```

#### `--soft`: Undo commit, keep changes staged
```powershell
git reset --soft HEAD~1
git status           # "Changes to be committed" — v3 is staged, commit gone
git log --oneline    # Only 2 commits remain
```

#### `--mixed` (default): Undo commit, unstage changes
```powershell
git reset HEAD~1
git status           # "Changes not staged" — v2 is in working dir, unstaged
```

#### `--hard`: Obliterate everything
```powershell
git reset --hard HEAD~1
git status                       # Clean working directory
Get-Content file.txt             # Shows v1 — v2 and v3 are GONE
                                 # Unix: cat file.txt
```

> **Recovery:** Even after `--hard`, commits still exist in `git reflog` for ~30 days.

```bash
git reflog   # Find the lost commit hash
git checkout -b recovered <lost-hash>   # Bring it back
```

---

### `git revert` — Safe Undo for Shared Branches

```bash
# This creates a NEW commit that undoes Commit 2, preserving history
git revert HEAD~1 --no-edit
git log --oneline   # 3 original commits + 1 revert commit
```

> **Rule:** `reset` for local/private cleanup. `revert` for anything already pushed.

---

## 🏗️ Part 5: Interactive Rebase — History Surgery

### 🔬 SOP 5.1 — Squash messy commits

```powershell
# Create messy history  (Unix: git init squash-lab && cd squash-lab)
git init squash-lab
cd squash-lab
"feature" > feature.txt; git add .; git commit -m "Add feature"
Add-Content feature.txt "fix1"; git add .; git commit -m "typo fix 1"
Add-Content feature.txt "fix2"; git add .; git commit -m "typo fix 2"
Add-Content feature.txt "fix3"; git add .; git commit -m "typo fix 3"
# Unix equivalent for append: echo "fix1" >> feature.txt

git log --oneline
# abc123 typo fix 3
# def456 typo fix 2
# ghi789 typo fix 1
# jkl012 Add feature

# Squash last 3 into 1
git rebase -i HEAD~3
```

**In the editor that opens:**
```
pick def456 typo fix 1    ← keep this as the "base"
s   ghi789 typo fix 2     ← squash into above
s   abc123 typo fix 3     ← squash into above
```

Save and close. Git opens a second editor for the combined message. Write a clean message and save.

```bash
git log --oneline
# One clean commit remains
```

---

### 🔬 SOP 5.2 — Reword a commit message
```bash
git rebase -i HEAD~2
# Change "pick" to "reword" (or "r") on the target commit
# Save. Git opens message editor for that commit only.
```

---

## 🌐 Part 6: Remote Workflows — The Professional Sync Pattern

### Why `git pull` is Messy

```powershell
# What git pull actually does under the hood:
git fetch origin             # Step 1: download commits from remote
git merge origin/main        # Step 2: MERGE into your branch → creates a merge commit

# If you do this 10 times while teammates push, your history becomes spaghetti.
# Every sync adds a useless merge commit.
```

### The Professional Pattern: Fetch → Inspect → Rebase

```powershell
# Step 1: Download remote changes SAFELY (does NOT touch your working files)
git fetch origin

# Step 2: See what the remote has that you don't
git log HEAD..origin/main --oneline

# Step 3: Replay your local commits ON TOP of the remote changes (no merge commit)
git rebase origin/main

# OR do both in one command:
git pull --rebase origin main
```

> Rebasing keeps your feature commits looking like they were written *after* the latest remote code — making PRs much cleaner.

---

### 🔬 SOP 6.1 — Real GitHub Remote Sync Simulation

**The Scenario:** You have a local repo connected to a real GitHub repository. Someone (or you via the GitHub GUI) commits directly to GitHub. Your local branch is now behind. You need to sync cleanly.

**Step 1: Create a local repo and connect it to GitHub**

```powershell
# Create local repo
git init github-sync-lab
cd github-sync-lab

# Create an initial file and commit
"# GitHub Sync Lab" > README.md
git add .
git commit -m "Initial local commit"

# Add your GitHub remote (replace URL with your real repo URL)
git remote add origin https://github.com/your-username/github-sync-lab.git

# Verify the remote is set
git remote -v
# Output:
# origin  https://github.com/your-username/github-sync-lab.git (fetch)
# origin  https://github.com/your-username/github-sync-lab.git (push)

# Push local main to GitHub
git push -u origin main
# -u sets the upstream tracking — from now on git push/pull work without args
```

**Step 2: Simulate a commit made via the GitHub GUI**

Go to your GitHub repo in the browser → click any file → click the pencil (Edit) icon → make a small change → click "Commit changes".

> This creates a commit on the remote (`origin/main`) that your LOCAL repo does NOT have yet.

**Step 3: Do local work at the same time (your feature)**

```powershell
# You're working locally while that GitHub commit was made
git checkout -b my-feature
"my local feature work" > feature.txt
git add .
git commit -m "Add feature locally"

# Visualize — your branch is AHEAD of local main, but local main is BEHIND GitHub
git log --oneline --graph --all
```

**Step 4: Fetch to see what GitHub has (SAFE — no files change)**

```powershell
git fetch origin

# Now inspect what GitHub has that you don't
git log HEAD..origin/main --oneline
# Output: shows the commit made via GitHub GUI

# See the full diff of what the remote added
git diff HEAD origin/main
```

**Step 5: Rebase your local work on top of the remote commits**

```powershell
# Make sure you're on your feature branch
git checkout my-feature

# Replay your commits on top of the GitHub remote changes
git rebase origin/main

# After rebase — your feature commit sits neatly on top of the GUI commit
git log --oneline --graph --all
```

**Step 6: Observe the result**

```powershell
# Check origin/main now matches your expectation
git cat-file -p origin/main
# Shows the commit made via GitHub GUI

# Confirm your feature commit's parent is the GitHub commit
git cat-file -p HEAD
# parent line should point to the GitHub GUI commit hash
```

**Step 7: Push your feature and open a PR**

```powershell
git push origin my-feature
# Then go to GitHub → you'll see a banner: "Compare & pull request"
```

---

## 🔧 Part 7: Stashing — Save Work Without Committing

**The Scenario:** You're mid-task on a feature when an urgent bug report comes in. You can't commit half-finished work. You need to put your changes "in a drawer" and come back later.

### 🔬 SOP 7.1 — Basic stash and restore

```powershell
# Setup: create a repo with some committed history
git init stash-lab
cd stash-lab
"v1 of app" > app.txt
git add .
git commit -m "Initial commit"

# Start working on a new feature (don't commit it)
"new feature in progress" > feature.txt
Add-Content app.txt "wip changes"    # Unix: echo "wip changes" >> app.txt
git add feature.txt                  # Stage one file
# Leave app.txt unstaged intentionally

git status
# Output:
# Changes to be committed: feature.txt   (staged)
# Changes not staged:      app.txt       (modified but not staged)
```

```powershell
# Urgent! Stash ALL current work (staged + unstaged tracked files)
git stash

# Verify your working directory is now CLEAN
git status
# Output: nothing to commit, working tree clean

# Your stash is saved:
git stash list
# Output: stash@{0}: WIP on main: abc1234 Initial commit

# Now switch to fix the bug
git checkout -b hotfix
"bugfix applied" > bugfix.txt
git add .
git commit -m "Critical bugfix"
git checkout main
git merge hotfix
```

```powershell
# Come back to your feature — restore the stash
git stash pop
# Restores your changes AND removes the stash entry

git status
# Your modified files are back exactly as you left them

git stash list
# Output: (empty) — stash was consumed by pop
```

### 🔬 SOP 7.2 — Advanced stash flags

```powershell
# stash apply — restore but KEEP the stash in the list
git stash apply stash@{0}
git stash list   # stash still exists

# stash -u — also stash UNTRACKED files (new files not yet git add'd)
"brand new file" > newfile.txt    # not added to git yet
git stash -u                      # now newfile.txt is also stashed

# stash --keep-index — stash unstaged changes but LEAVE staged ones
Add-Content app.txt "unstaged work"
"staged work" > staged.txt
git add staged.txt
git stash --keep-index
# Result: staged.txt stays in staging area, app.txt changes are stashed

# stash drop — delete a specific stash WITHOUT applying it
git stash drop stash@{0}

# stash clear — delete ALL stashes
git stash clear
```

> **Interview tip:** The key difference — `pop` = apply + delete stash. `apply` = restore but keep stash. `drop` = delete without applying.

---

## 🔍 Part 8: Debugging & Archaeology

### 🔬 SOP 8.1 — `git bisect` (Binary Search for Bugs)

**The Scenario:** Your app is broken. It worked 3 weeks ago. There are 50 commits between then and now. `git bisect` finds the exact commit in ~6 steps instead of checking all 50.

```powershell
# Setup: create a repo simulating a bug being introduced mid-history
git init bisect-lab
cd bisect-lab

"app v1 - works fine" > app.txt; git add .; git commit -m "v1 good"
"app v2 - works fine" > app.txt; git add .; git commit -m "v2 good"
"app v3 - BUG INTRODUCED HERE" > app.txt; git add .; git commit -m "v3 introduced bug"
"app v4 - bug still present" > app.txt; git add .; git commit -m "v4 still broken"
"app v5 - bug still present" > app.txt; git add .; git commit -m "v5 still broken"

git log --oneline
# abc001 v5 still broken       ← HEAD (current, broken)
# abc002 v4 still broken
# abc003 v3 introduced bug
# abc004 v2 good
# abc005 v1 good               ← known good
```

```powershell
# Start bisect
git bisect start

# Tell Git: current state is BAD
git bisect bad

# Tell Git: the oldest known-good commit (use its hash from git log)
git bisect good <hash-of-v1-good-commit>

# Git automatically checks out a commit halfway between good and bad
# Test your app. Does the bug exist?

# If the checked-out commit is BROKEN:
git bisect bad

# If the checked-out commit is FINE:
git bisect good

# Git halves the range again — repeat until Git prints:
# "<hash> is the first bad commit"
# commit abc003 ...
# Author: ...
# v3 introduced bug

# Exit bisect mode and return to HEAD
git bisect reset
```

> **Internal logic:** With 50 commits, bisect finds the bad one in just ⌈log₂(50)⌉ = **6 steps** instead of checking all 50.

---

### 🔬 SOP 8.2 — `git blame` (Find Who Changed What)

```powershell
# Setup: multi-author file history
git init blame-lab
cd blame-lab
"line 1: original" > auth.py; git add .; git commit -m "Initial auth.py"
"line 1: original`nline 2: added by dev" > auth.py; git add .; git commit -m "Add line 2"
Add-Content auth.py "line 3: possible bug here"; git add .; git commit -m "Add line 3"

# See who last modified each line
git blame auth.py
# Output format:
# <hash> (<Author> <date> <line#>) line content
# abc123 (Your Name 2024-01-15  1) line 1: original
# def456 (Your Name 2024-01-16  2) line 2: added by dev
# ghi789 (Your Name 2024-01-17  3) line 3: possible bug here

# Jump to that commit to understand the full context
git show ghi789
```

```powershell
# Track code that was MOVED or COPIED from another file
git blame -C auth.py
# The -C flag detects if the line was originally written in a different file

# Blame only specific line range (e.g., lines 10-20)
git blame -L 10,20 auth.py
```

---

### 🔬 SOP 8.3 — `git log` Archaeology

```powershell
# Setup: create a repo with a "secret" being committed and removed
git init log-lab
cd log-lab
"normal content" > config.py; git add .; git commit -m "Initial"
Add-Content config.py "API_KEY=secret123"; git add .; git commit -m "Add API key (oops)"
"normal content" > config.py; git add .; git commit -m "Remove API key"
"more features" > feature.py; git add .; git commit -m "Add feature"

# --- PICKAXE: Find when a string was added or removed ---
git log -S "API_KEY" --oneline
# Output: shows ONLY the 2 commits that added or removed "API_KEY"
# This is the most powerful debugging tool for finding when things changed

# --- Filter by author ---
git log --author="Your Name" --oneline

# --- Filter by date ---
git log --since="2024-01-01" --until="2024-12-31" --oneline

# --- Hide merge commits ---
git log --no-merges --oneline

# --- Full diff of every commit touching a file ---
git log -p -- config.py

# --- Trace file renames (follow) ---
git log --follow -- config.py
```

---

## 🏷️ Part 9: Tags — Marking Releases

### 🔬 SOP 9.1 — Create and inspect tags

```powershell
# Setup
git init tag-lab
cd tag-lab
"v1 code" > app.txt; git add .; git commit -m "Version 1.0 release"
"v2 code" > app.txt; git add .; git commit -m "Version 2.0 release"

# --- LIGHTWEIGHT TAG: just a pointer (no metadata stored) ---
git tag v1.0 HEAD~1      # tag the previous commit (v1.0)

# Inspect: lightweight tag points DIRECTLY to the commit
git cat-file -t v1.0     # Output: commit  ← points straight to commit
git cat-file -p v1.0     # Shows the commit object directly

# --- ANNOTATED TAG: full object with metadata ---
git tag -a v2.0 -m "Version 2.0 - major release"

# Inspect: annotated tag is its OWN object (type: tag)
git cat-file -t v2.0     # Output: tag  ← its own object!
git cat-file -p v2.0
# Output:
# object <commit-hash>   ← points to the commit
# type commit
# tag v2.0
# tagger Your Name <you@email.com> ...
#
# Version 2.0 - major release
```

> **Interview insight:** This is the key difference. A lightweight tag is just a ref file (like a branch). An annotated tag is a real object in the database with its own hash, metadata, and can be GPG-signed.

```powershell
# Tag a specific PAST commit (useful for retroactively tagging a release)
git tag -a v0.9 <commit-hash> -m "Retroactive pre-release tag"

# List all tags
git tag -l
git tag -l "v1.*"          # Wildcard filter

# Delete a tag
git tag -d v1.0            # Local only
git push origin --delete v1.0  # Remote

# Push tags to remote
git push origin v2.0       # Single tag
git push origin --tags     # All local tags
```

---

## 🛡️ Part 10: Safety Net — Reflog & Recovery

**The Scenario:** You ran `git reset --hard`, deleted a branch, or rebased badly. Your work seems lost. `git reflog` is your rescue parachute.

### 🔬 SOP 10.1 — Recover from a hard reset

```powershell
# Setup: create some commits, then "accidentally" hard reset
git init reflog-lab
cd reflog-lab
"v1" > file.txt; git add .; git commit -m "Commit 1"
"v2" > file.txt; git add .; git commit -m "Commit 2"
"v3" > file.txt; git add .; git commit -m "Commit 3"

git log --oneline
# abc003 Commit 3  ← HEAD
# abc002 Commit 2
# abc001 Commit 1

# Simulate an "accidental" hard reset
git reset --hard HEAD~2
git log --oneline
# abc001 Commit 1  ← Commits 2 and 3 appear GONE!
Get-Content file.txt
# v1  ← working directory reset to v1
```

```powershell
# RECOVERY: reflog records every HEAD movement
git reflog
# Output:
# abc001 HEAD@{0}: reset: moving to HEAD~2
# abc003 HEAD@{1}: commit: Commit 3         ← the "lost" commit
# abc002 HEAD@{2}: commit: Commit 2
# abc001 HEAD@{3}: commit: Commit 1

# Restore to the "lost" Commit 3
git reset --hard abc003   # use the actual hash from your reflog

git log --oneline
# abc003 Commit 3  ← fully restored
Get-Content file.txt
# v3  ← file content restored
```

### 🔬 SOP 10.2 — Recover a deleted branch

```powershell
# Create a branch, commit to it, then delete it
git checkout -b feature-lost
"important work" > important.txt; git add .; git commit -m "Important feature"
git checkout main
git branch -D feature-lost    # Force delete — branch gone!

# Recovery via reflog
git reflog
# Output includes:
# <hash> HEAD@{1}: commit: Important feature  ← this is our lost commit

# Restore the branch
git checkout -b feature-restored <hash>

git log --oneline
# <hash> Important feature  ← branch restored with all commits
```

> **Key insight:** Deleting a branch only removes the pointer file in `.git/refs/heads/`. The actual commit objects remain in `.git/objects` until `git gc` runs (~30 days by default).

---

## 📋 Part 11: Essential Config & Aliases

### 🔬 SOP 11.1 — Setup and verify config

```powershell
# --- Identity (MANDATORY before first commit) ---
git config --global user.name "Your Name"
git config --global user.email "you@email.com"

# --- Set VS Code as default editor for commit messages ---
git config --global core.editor "code --wait"
# Unix equivalent: same command

# --- Default branch name for new repos ---
git config --global init.defaultBranch main

# --- Auto-reuse conflict resolutions (rerere) ---
git config --global rerere.enabled true

# --- View all config and WHERE each setting comes from ---
git config --list --show-origin
# Output shows: system / global / local config levels

# --- Per-repo override (e.g., work email for one repo) ---
# Inside the repo folder:
git config user.email "work@company.com"
git config --list --local   # Shows only this repo's overrides
```

### 🔬 SOP 11.2 — Useful aliases

```powershell
# Pretty graph log
git config --global alias.lg "log --oneline --graph --all --decorate"
git lg    # Test it

# Short status
git config --global alias.st "status -s"
git st

# Undo last commit but keep changes staged
git config --global alias.undo "reset --soft HEAD~1"
git undo

# Unstage a file (safer than reset)
git config --global alias.unstage "restore --staged"
git unstage <file>

# Show last commit
git config --global alias.last "log -1 HEAD --stat"
git last
```

> Aliases are stored in `C:\Users\<you>\.gitconfig` under the `[alias]` section.

---

## 🎯 Quick Interview Cheatsheet

| Scenario | PowerShell Command |
| --- | --- |
| Undo last commit, keep staged | `git reset --soft HEAD~1` |
| Undo last commit, keep in working dir | `git reset HEAD~1` |
| Discard ALL local changes | `git reset --hard HEAD` |
| Safe undo (shared branch) | `git revert HEAD` |
| Save work without committing | `git stash` |
| Save including untracked files | `git stash -u` |
| Restore stash and delete it | `git stash pop` |
| Recover deleted branch / hard reset | `git reflog` → `git checkout -b name <hash>` |
| Find bug-introducing commit | `git bisect start` → `bad` / `good` |
| Find who changed a line | `git blame <file>` |
| Find when string was added/removed | `git log -S "string"` |
| Sync without merge commit | `git pull --rebase` |
| Combine last 3 commits | `git rebase -i HEAD~3` |
| Apply single commit from another branch | `git cherry-pick <hash>` |
| Show file at specific commit | `git show HEAD~2:path/to/file` |
| List all remote branches | `git branch -r` |
| Delete remote branch | `git push origin --delete branch-name` |
| See all HEAD movements | `git reflog` |
| Inspect any Git object | `git cat-file -p <hash>` |
| See what type an object is | `git cat-file -t <hash>` |
| Inspect staging area raw | `git ls-files --stage` |


