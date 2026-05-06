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

```bash
# Setup
git init merge-lab && cd merge-lab
echo "base" > base.txt && git add . && git commit -m "Base commit"

# Branch off
git checkout -b feature-a
echo "feature A work" > feature-a.txt
git add . && git commit -m "Feature A commit"

# Back to master, add a conflicting commit
git checkout master
echo "master work" > master.txt
git add . && git commit -m "Master commit"

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

```bash
git init conflict-lab && cd conflict-lab
echo "line 1: original" > story.txt
git add . && git commit -m "Initial story"

# Branch A edits line 1
git checkout -b branch-a
echo "line 1: Branch A version" > story.txt
git add . && git commit -m "Branch A edit"

# Master also edits line 1
git checkout master
echo "line 1: Master version" > story.txt
git add . && git commit -m "Master edit"

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
```bash
# Edit story.txt to the final desired version, remove ALL markers
echo "line 1: Final merged version" > story.txt

# Tell Git the conflict is resolved
git add story.txt

# Seal the merge
git commit
```

---

### 🔬 SOP 3.4 — Rebase (Linear History)

```bash
git init rebase-lab && cd rebase-lab
echo "base" > base.txt && git add . && git commit -m "Base"

git checkout -b feature
echo "feature work" > feature.txt
git add . && git commit -m "Feature commit"

# Add a new commit to master
git checkout master
echo "hotfix" > hotfix.txt
git add . && git commit -m "Hotfix on master"

# Before rebase — Y-shape
git log --oneline --graph --all

# Rebase feature onto master
git checkout feature
git rebase master

# After rebase — linear
git log --oneline --graph --all

# Proof: the hash of "Feature commit" CHANGED
```

> **The Golden Rule:** After rebase, the Feature commit has a **new hash** because its parent changed. This is why you NEVER rebase a branch that others have already pulled.

---

## ⏪ Part 4: Undoing Things — Reset, Revert, Restore

### The Reset Modes Compared

```bash
# Setup: make 3 commits
git init undo-lab && cd undo-lab
echo "v1" > file.txt && git add . && git commit -m "Commit 1"
echo "v2" > file.txt && git add . && git commit -m "Commit 2"
echo "v3" > file.txt && git add . && git commit -m "Commit 3"
git log --oneline
```

#### `--soft`: Undo commit, keep changes staged
```bash
git reset --soft HEAD~1
git status   # "Changes to be committed" — v3 is staged, commit gone
git log --oneline   # Only 2 commits
```

#### `--mixed` (default): Undo commit, unstage changes
```bash
git reset HEAD~1
git status   # "Changes not staged" — v2 is in working dir, unstaged
```

#### `--hard`: Obliterate everything
```bash
git reset --hard HEAD~1
git status   # Clean
cat file.txt   # Shows v1 — v2 and v3 are GONE from working dir
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

```bash
# Create messy history
git init squash-lab && cd squash-lab
echo "feature" > feature.txt && git add . && git commit -m "Add feature"
echo "fix1" >> feature.txt && git add . && git commit -m "typo fix 1"
echo "fix2" >> feature.txt && git add . && git commit -m "typo fix 2"
echo "fix3" >> feature.txt && git add . && git commit -m "typo fix 3"

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

### The Problem with `git pull`

```bash
# What git pull actually does:
git fetch origin    # Download new commits
git merge origin/master  # Creates a MERGE COMMIT

# After 10 syncs, your history looks like spaghetti
```

### The Professional Pattern: Fetch + Rebase

```bash
# Step 1: Download remote changes (SAFE — does NOT touch your code)
git fetch origin

# Step 2: See what the remote has that you don't
git log HEAD..origin/master --oneline

# Step 3: Replay your work on top of the remote
git rebase origin/master

# Or in one command:
git pull --rebase origin master
```

> This keeps your local commits looking like they were written AFTER the latest remote code — making PRs cleaner and easier to review.

---

### 🔬 SOP 6.1 — Simulate remote sync workflow

```bash
# Setup: two "clones" of the same repo
git init remote-origin && cd remote-origin
echo "v1" > shared.txt && git add . && git commit -m "Initial"
cd ..

git clone remote-origin dev1 && cd dev1

# Simulate teammate pushing to origin
cd ../remote-origin
echo "teammate work" >> shared.txt && git add . && git commit -m "Teammate commit"
cd ../dev1

# Your local work
git checkout -b my-feature
echo "my work" > myfile.txt && git add . && git commit -m "My commit"

# Sync properly
git fetch origin
git rebase origin/master

# Result: linear history with your commit on top
git log --oneline --graph --all
```

---

## 🔧 Part 7: Stashing — Save Work Without Committing

```bash
# Mid-task, urgent switch needed
git stash               # Save everything tracked+staged

# List stashes
git stash list          # stash@{0}: WIP on feature...

# Apply and remove
git stash pop           # Restore + delete stash

# Apply but keep stash
git stash apply stash@{0}

# Stash including untracked files
git stash -u

# Selective stash (interactive)
git stash --patch

# Delete a specific stash
git stash drop stash@{0}

# Clear all stashes
git stash clear
```

---

## 🔍 Part 8: Debugging & Archaeology

### `git bisect` — Binary Search for Bugs

```bash
git bisect start
git bisect bad          # Current state is broken
git bisect good v1.0    # This tag was known good

# Git checks out a middle commit. Test your app, then:
git bisect good         # or: git bisect bad

# Repeat until Git identifies the exact commit
git bisect reset        # Exit bisect mode
```

### `git blame` — Find Who Changed What

```bash
git blame src/api.py
# Shows: hash | author | date | line number | content

# Track code that was moved/copied from elsewhere
git blame -C src/api.py
```

### `git log` Archaeology

```bash
# Find when a specific string was introduced or removed ("Pickaxe")
git log -S "password_reset" --oneline

# Find all commits touching a specific file
git log --follow -- src/auth.py

# Show commits between two dates
git log --since="2024-01-01" --until="2024-06-01" --oneline

# Show full diff for each commit
git log -p --follow -- src/auth.py
```

---

## 🏷️ Part 9: Tags — Marking Releases

```bash
# Lightweight tag (just a pointer)
git tag v1.0

# Annotated tag (full object with metadata — use for releases)
git tag -a v1.0 -m "Version 1.0 release"

# Tag a specific past commit
git tag -a v0.9 <commit-hash> -m "Hotfix release"

# Push tags to remote
git push origin v1.0         # Single tag
git push origin --tags       # All tags

# List tags
git tag -l
git tag -l "v1.*"            # Wildcard

# Delete a tag
git tag -d v1.0              # Local
git push origin --delete v1.0  # Remote
```

---

## 🛡️ Part 10: Safety Net — Reflog & Recovery

```bash
# See every HEAD movement (local only, ~30 day retention)
git reflog

# Output format:
# abc123 HEAD@{0}: commit: My latest commit
# def456 HEAD@{1}: checkout: moving to main
# ghi789 HEAD@{2}: reset: moving to HEAD~1

# Recover a deleted branch
git branch recovered-branch <hash-from-reflog>

# Recover after a hard reset
git reset --hard <hash-from-reflog>
```

---

## 📋 Part 11: Essential Config & Aliases

```bash
# Identity (mandatory)
git config --global user.name "Your Name"
git config --global user.email "you@email.com"

# Default branch name
git config --global init.defaultBranch main

# Editor
git config --global core.editor "code --wait"

# Enable rerere (auto-reuse conflict resolutions)
git config --global rerere.enabled true

# Useful aliases
git config --global alias.lg "log --oneline --graph --all --decorate"
git config --global alias.st "status -s"
git config --global alias.undo "reset --soft HEAD~1"
git config --global alias.unstage "restore --staged"

# View all config
git config --list --show-origin
```

---

## 🎯 Quick Interview Cheatsheet

| Scenario | Command |
| --- | --- |
| Undo last commit, keep staged | `git reset --soft HEAD~1` |
| Undo last commit, keep in working dir | `git reset HEAD~1` |
| Discard ALL local changes | `git reset --hard HEAD` |
| Safe undo (shared branch) | `git revert HEAD` |
| Save work without committing | `git stash` |
| Recover deleted branch | `git reflog` → `git branch name <hash>` |
| Find bug-introducing commit | `git bisect start/good/bad` |
| Find who changed a line | `git blame <file>` |
| Find when string was added | `git log -S "string"` |
| Sync without merge commit | `git pull --rebase` |
| Combine last 3 commits | `git rebase -i HEAD~3` |
| Apply single commit from another branch | `git cherry-pick <hash>` |
| Show file at specific commit | `git show HEAD~2:path/to/file` |
| List all remote branches | `git branch -r` |
| Delete remote branch | `git push origin --delete branch-name` |
