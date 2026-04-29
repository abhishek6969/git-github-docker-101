# 🎯 Interview Questions & Scenarios

## 🧠 Git Conceptual Level

### Q1: Is Git a "Diff" or "Snapshot" system?
**Answer:** Snapshot. Git captures the state of all files at each commit. Unchanged files are referenced via their existing hashes, ensuring no data duplication.

### Q2: Explain the "Three Trees" of Git.
**Answer:** 
1. **Working Directory:** The files you see and edit.
2. **Index (Staging Area):** A "draft" snapshot for the next commit.
3. **HEAD:** The snapshot of your last commit.
*Interview Value:* Demonstrates you understand why `git add` is a separate step.

### Q3: What is the difference between `git reset` and `git revert`?
**Answer:** 
- `reset` moves the branch pointer backward (deleting/hiding history). 
- `revert` creates a new commit that applies the inverse of a previous commit (preserving history).
*Rule of Thumb:* Reset for private/local work, Revert for public/shared branches.

### Q4: Why is a branch "cheap" in Git?
**Answer:** A branch is just a 41-byte text file containing a commit hash. Creating a branch is just creating a pointer; it doesn't copy any project files.

### Q5: How does Git handle storage if I change 1 character in a 1GB file?
**Answer:** Initially, it creates a new 1GB Blob (compressed). Eventually, `git gc` packs these into a **Packfile** using **Delta Compression** to store only the difference.

---

## 🏗️ Practical Scenarios

**Scenario:** You "deleted" a commit using `git reset --hard` but realized you need it back. How do you find it?
- **Concept:** `git reflog`.
- **Logic:** Find the hash of the "lost" commit in the reflog and `git reset` or `git branch` back to it.
