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

## 🛠️ 5. Standard Operating Procedures (Walkthroughs)

### 📂 Phase 1: Handling Diverged History
**The Simulation:**
We wanted to simulate a real-world scenario where two developers work on different features at the same time.
1. We branched off with `git checkout -b feature-a`.
2. We added a file `feature-a.txt` and committed it.
3. We switched back to `master` (`git checkout master`).
4. We added a *different* file `master.txt` and committed it.
**The Result:** A "Y-shape" divergence seen via `git log --graph --oneline --all`.

**The Resolution:**
1. We ran `git merge feature-a` while on the `master` branch.
2. **Internal Logic:** Git identified the "Common Ancestor", combined the two files into a new "Merge Commit".
3. **The Proof:** We ran `git cat-file -p <merge_hash>` and saw **two parent lines**, confirming the history was successfully joined.

---

### 📂 Phase 2: Resolving Merge Conflicts
**The Simulation:**
We forced Git into a "Textual Conflict" by making conflicting changes to the *same line* of the *same file*.
1. On `master`, we edited line 1 of `hello.txt` and committed.
2. On `feature-b`, we edited the *exact same* line 1 of `hello.txt` and committed.
3. We tried to merge: `git merge feature-b`.
**The Result:** Git screamed `CONFLICT (content)` and paused the merge.

**The Resolution:**
1. We opened `hello.txt` and saw the markers (`<<<<`, `====`, `>>>>`).
2. We manually edited the file to the final version and **removed the markers**.
3. We ran `git add hello.txt` to tell Git the "weld" was complete.
4. We ran `git commit` to seal the merge.

---

### 📂 Phase 3: Rebasing & History Cleanup
**The Simulation:**
We wanted to avoid the "messy" Y-shape and make history look like a straight line.
1. We created a branch `rebase-test` and added a commit.
2. We added a separate commit on `master`.
**The Result:** A Y-shape where `rebase-test` is "behind" the latest master.

**The Resolution (Part 1 - The Rebase):**
1. On `rebase-test`, we ran `git rebase master`.
2. **Internal Logic:** Git "popped" our feature commit, moved our branch to the tip of master, and "replayed" our commit on top.
3. **The Proof:** The Y-shape disappeared, and our history became linear.

**The Resolution (Part 2 - The Squash):**
1. We made multiple messy "typo" commits.
2. We ran `git rebase -i HEAD~3` (Interactive mode).
3. In the editor, we changed `pick` to `squash` for the messy commits.
4. **The Result:** Three messy commits were condensed into one professional commit.

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
