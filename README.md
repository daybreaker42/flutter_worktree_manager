# Flutter Worktree Manager (ftree)

A powerful CLI tool to manage Git Worktrees in Flutter projects. It automatically handles non-git-tracked files (like `.env`, `google-services.json`, secrets) and initializes your environment in one command.

## Why ftree?

Standard `git worktree` is great, but for Flutter developers, it has a major drawback: **It doesn't copy ignored files.** Every time you create a new worktree, you have to manually copy your `.env` files, Firebase configs, and run `pub get`.

**ftree** automates this entire process:

1. Creates a git worktree.
2. Copies your specified secret/config files.
3. Runs `flutter pub get`.
4. Runs `build_runner build` (optional/automatic).

## How to Use

After installing `flutter_worktree_manager`, you should make a configuration file named `worktree_config.yaml` in the root of your Flutter project. This file specifies which files to copy and where to create the worktrees.

Here is an example `worktree_config.yaml`:

```yaml
# The parent directory where worktrees will be created
base_dir: "../my_worktrees"

# Files to copy from the current project to the new worktree
copy_files:
  - ".env"
  - "android/app/google-services.json"
  - "ios/Runner/GoogleService-Info.plist"
  - "lib/firebase_options.dart"
```

To create a new worktree, run:

```bash
ftree create <branch-name>
```

When you want to remove a worktree, use:

```bash
ftree --remove <branch-name>
```


## Installation

Add it to your `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_worktree_manager: ^0.1.0


## Credits

This package depends on the following excellent libraries:
- [path](https://pub.dev/packages/path) - BSD-3-Clause
- [yaml](https://pub.dev/packages/yaml) - MIT-Clause
