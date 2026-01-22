# Flutter Worktree Manager (ftree)

A powerful CLI tool to manage Git Worktrees in Flutter projects. It automatically handles non-git-tracked files (like `.env`, `google-services.json`, secrets) and initializes your environment in one command.

## Why ftree?

Standard `git worktree` is great, but for Flutter developers, it has a major drawback: **It doesn't copy ignored files.** Every time you create a new worktree, you have to manually copy your `.env` files, Firebase configs, and run `pub get`. 

**ftree** automates this entire process:
1. Creates a git worktree.
2. Copies your specified secret/config files.
3. Runs `flutter pub get`.
4. Runs `build_runner build` (optional/automatic).

---

## Installation

Add it to your `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_worktree_manager: ^1.0.0