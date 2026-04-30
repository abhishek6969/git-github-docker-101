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

---

## 🌿 4. Branching & Merging (The DAG in Action)

### The "Y-Shape" (Divergence)
When two branches move forward independently, they create a "Y-shape" in the history graph.

### The Three-Way Merge
To join them, Git uses the **`ort`** strategy. It compares the two branch tips and their **Common Ancestor**.

### The Merge Commit (Multi-Parent)
Unlike regular commits, a Merge Commit has **two or more parent pointers**.

---

## 🛠️ 5. Standard Operating Procedures (SOPs)

### SOP #1: Simulating & Merging Diverged History
| Step | Action | Command | Internal Outcome |
| :--- | :--- | :--- | :--- |
| **1** | Create Feature Branch | `git checkout -b feature-a` | New pointer created at current HEAD. |
| **2** | Work on Feature | Edit `feature-a.txt`, then `git add .` & `git commit` | New Blob and Commit created on `feature-a`. |
| **3** | Return to Master | `git checkout master` | HEAD pointer moves back to `master`. |
| **4** | Work on Master | Edit `master.txt`, then `git add .` & `git commit` | New Blob and Commit created on `master`. |
| **5** | Visualize Divergence | `git log --oneline --graph --all` | Confirms the "Y-shape" graph. |
| **6** | Perform Merge | `git merge feature-a` | Git identifies **Common Ancestor** and combines work. |
| **7** | Verify Internal Structure | `git cat-file -p <merge_hash>` | Confirms commit has **two parents**. |

### SOP #2: Resolving Merge Conflicts
**Goal:** Manually resolve a situation where Git cannot automatically combine changes.

| Step | Action | Command | Internal Outcome |
| :--- | :--- | :--- | :--- |
| **1** | Trigger Conflict | `git merge branch-b` | Git identifies overlapping changes and pauses. |
| **2** | Identify Conflict | `git status` | Files are marked as "both modified". |
| **3** | Edit File | Open file and resolve markers | Conflict markers (`<<<<`, `====`, `>>>>`) are removed. |
| **4** | Mark as Resolved | `git add <filename>` | Git removes the "unmerged" flag from the Index. |
| **5** | Seal the Merge | `git commit` | Final Merge Commit is created, ending the merge state. |

---

## 🧪 Proof of Concept: Snapshot Efficiency
*From our Day 1 Session:* We compared two Trees from two real commits to prove the "Re-use" logic.

**Tree from 4th Commit (`81c01cf`):**
```text
100644 blob b5af13c1f9b234314011ce2589dd5c707d905496    README_docker.md
100644 blob ce2972ffd21e7a4dfd487e1135f17f9c0e46f8b2    README_git.md
```

**Tree from 3rd Commit (`0fb2e77`):**
```text
100644 blob b5af13c1f9b234314011ce2589dd5c707d905496    README_docker.md
100644 blob fd243b0742b54cb0b03bac0bd69011217b044061    README_git.md
```

### 🎯 The Discovery:
Notice that `README_docker.md` has the **EXACT SAME HASH** (`b5af13...`) in both commits. Git only created **one new blob** for the edit to the git readme and reused the rest.

---

## 🧪 Lab Log: Inspecting the Internal Tree
1. **Step 1:** `git cat-file -p <commit_hash>` ➔ See the **Tree** hash.
2. **Step 2:** `git cat-file -p <tree_hash>` ➔ See the **Blob** hashes & filenames.
3. **Step 3:** `git cat-file -p <blob_hash>` ➔ See the **Raw Content**.

---

## 🔧 6. Plumbing vs. Porcelain
- **Porcelain:** High-level commands (`git commit`, `git add`).
- **Plumbing:** Low-level commands (`git cat-file`, `git hash-object`).

---

## 🪟 7. Windows / PowerShell Survival Guide
- `Get-ChildItem -Path .git/objects -File -Recurse` (List Objects)
- `git cat-file -t <hash>` (Type)
- `git cat-file -p <hash>` (Content)

---

## 🛡️ 8. The Safety Net
- **Reflog:** Log of every HEAD movement.
- **Reset vs. Revert:** Reset for private cleanup; Revert for shared history.
