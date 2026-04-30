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

## 🏗️ Practical Scenarios

**Scenario:** You have a diverged history and run `git merge`. Git says "Fast-Forward". What does that mean?
- **Concept:** It means the target branch hasn't moved since you branched off. Git doesn't need to create a merge commit; it just slides the pointer forward.
