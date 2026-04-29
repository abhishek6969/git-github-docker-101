# 📜 Git Mastery: Conceptual Deep Dive

> "Git is a content-addressable filesystem with a VCS user interface."

---

## 🧩 1. The Soul of Git: Snapshots vs. Diffs
- **The Concept:** Unlike SVN (which stores a base file + incremental diffs), Git stores **Snapshots**.
- **Why it matters:** Every commit is a complete "picture" of the project. This makes switching branches instantaneous because Git doesn't have to "calculate" the state—it just grabs the snapshot.
- **Optimization:** If a file hasn't changed, Git doesn't duplicate it. It just points to the previous version's hash ID.

---

## 🏗️ 2. The Directed Acyclic Graph (DAG)
- **Directed:** Commits point back to their parents.
- **Acyclic:** History moves forward; you cannot have a loop where a commit is its own ancestor.
- **Pointers:** 
    - **Branch:** A lightweight, movable pointer to a commit node.
    - **HEAD:** A pointer to the branch you are currently "sitting" on.
    - **Tag:** An immutable pointer (a "bookmark") to a specific commit.

---

## 📦 3. The Object Trinity
Git stores everything in `.git/objects` as one of these:

| Object | Role | Analogy |
| :--- | :--- | :--- |
| **Blob** | Content only (no filename) | The text in a book. |
| **Tree** | Maps Filenames → Hashes | The Table of Contents / Folder structure. |
| **Commit** | Metadata + Pointers | The library card (Author, Date, Parent, Root Tree). |

### 🛠️ Content-Addressable Storage
Git identifies data by its **SHA-1 Hash** (a 40-character fingerprint).
- **Deterministic:** The same content ALWAYS produces the same hash.
- **Empty File Hash:** `e69de29bb2d1d6434b8b29ae775ad8c2e48c5391`

---

## 🔧 4. Plumbing vs. Porcelain
- **Porcelain:** High-level, user-friendly commands (`git commit`, `git add`).
- **Plumbing:** Low-level commands that touch the "pipes" (`git cat-file`, `git hash-object`).

---

## 🪟 5. Windows / PowerShell Survival Guide
Because you are on Windows, use these instead of Linux commands:

| Task | PowerShell Command |
| :--- | :--- |
| **List Objects** | `Get-ChildItem -Path .git/objects -File -Recurse` |
| **View Object Type** | `git cat-file -t <hash>` |
| **View Content** | `git cat-file -p <hash>` |
| **View History** | `git log --oneline --graph --all` |

---

## ⚡ 6. Storage Optimization
- **Loose Objects:** Individual compressed files in `.git/objects`.
- **Packfiles:** Highly optimized files where Git uses **Delta Compression** (storing diffs) to save space.
- **Garbage Collection (`git gc`):** The process that turns loose objects into packfiles and deletes orphaned nodes.

---

## 🛡️ 7. The Safety Net
- **Reflog:** A log of every time your HEAD pointer moved. Even if you "delete" a branch, the commits are in the reflog for ~30 days.
- **Reset vs. Revert:**
    - **Reset:** Moves the pointer (rewrites history). Good for local cleanup.
    - **Revert:** Adds a *new* commit that undoes a previous one. Safe for shared branches.

---

## 📚 8. The Library Analogy (Sharing vs. Taking)
When a new commit is made, it doesn't "copy" the unchanged files from the parent. Instead, both the Parent Tree and the New Tree point to the **same unique Blob** in the database. They share the reference.

---

## 🧪 Lab Log: Inspecting the Internal Tree
This is the process we followed to unmask Git's data structure in our session.

### Step 1: Find your current Commit
When you commit, Git gives you a short hash. You can inspect it to see the "Root Tree".
```powershell
# Command
git cat-file -p 418a34a

# Mock Output
tree 04df07b08ca746b3167d0f1d1514e2f39a52c16c
author abhishek <email@domain.com> 1234567890 +0530
committer abhishek <email@domain.com> 1234567890 +0530

First commit
```

### Step 2: Open the "Tree" (The Folder)
The Tree tells you which filenames belong to which hashes.
```powershell
# Command (using the tree hash from above)
git cat-file -p 04df07b

# Mock Output
100644 blob b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0    hello.txt
```

### Step 3: Read the "Blob" (The Content)
The Blob is purely the content, stripped of its name.
```powershell
# Command (using the blob hash from the tree)
git cat-file -p b6fc4c6

# Mock Output
hello git world
```

### Summary of the "Jump"
**Commit** (Metadata) ➔ **Tree** (Directory Map) ➔ **Blob** (File Content)
