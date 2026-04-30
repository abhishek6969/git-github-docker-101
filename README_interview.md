# 🎯 Interview Questions & Scenarios

## 🧠 Git Conceptual Level

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

## 🏗️ Practical Scenarios

**Scenario:** You have a diverged history and run `git merge`. Git says "Fast-Forward". What does that mean?
- **Concept:** It means the target branch hasn't moved since you branched off. Git doesn't need to create a merge commit; it just slides the pointer forward.
