import 'dart:io';
import 'package:path/path.dart' as p;
import 'config_loader.dart';

class WorktreeRunner {
  final WorktreeConfig config;

  WorktreeRunner(this.config);

  /// Creates a new worktree and sets up the environment.
  Future<void> create(String branchName) async {
    final safeFolderName = branchName.replaceAll('/', '_');
    final targetPath = p.join(config.baseDir, safeFolderName);

    print('🚀 Starting worktree creation: $branchName');

    try {
      // 1. Git Worktree 추가
      if (await Directory(targetPath).exists()) {
        print('⚠️  Folder already exists: $targetPath');
      } else {
        print('📂 [1/4] Creating git worktree...');
        await _runCommand(
            'git', ['worktree', 'add', '-b', branchName, targetPath]);
      }

      // 2. 설정 파일 복사 (시크릿 파일 등)
      print('📄 [2/4] Copying configuration files...');
      for (var filePath in config.configFiles) {
        final sourceFile = File(filePath);
        final destFile = File(p.join(targetPath, filePath));

        if (await sourceFile.exists()) {
          await Directory(destFile.parent.path).create(recursive: true);
          await sourceFile.copy(destFile.path);
          print('   ✅ Copy completed: $filePath');
        } else {
          print('   ❓ Source not found (skipping): $filePath');
        }
      }

      // 3. Flutter 패키지 설치
      print('📦 [3/4] Installing Flutter packages...');
      await _runCommand('flutter', ['pub', 'get'],
          workingDirectory: targetPath);

      // 4. Build Runner 실행
      print('🔧 [4/4] Running build_runner...');
      await _runCommand(
          'dart',
          [
            'run',
            'build_runner',
            'build',
            '--delete-conflicting-outputs',
          ],
          workingDirectory: targetPath);

      print('\n✨ All setup completed!');
      print('📍 Work path: ${Directory(targetPath).absolute.path}');
    } catch (e) {
      print('\n❌ Error occurred during creation: $e');
    }
  }

  /// Removes the worktree and disconnects it.
  Future<void> remove(String branchName) async {
    final safeFolderName = branchName.replaceAll('/', '_');
    final targetPath = p.join(config.baseDir, safeFolderName);

    print('🧹 Starting worktree removal: $branchName');

    try {
      print('🗑️ [1/2] Removing git worktree...');
      await _runCommand('git', ['worktree', 'remove', targetPath]);
      await _runCommand('git', ['worktree', 'prune']);

      final dir = Directory(targetPath);
      if (await dir.exists()) {
        print('📂 [2/2] Deleting remaining folder...');
        await dir.delete(recursive: true);
      }
      print('\n✅ Worktree removed successfully.');
    } catch (e) {
      print('\n❌ Error occurred during removal: $e');
      print('💡 Manual removal: git worktree remove $targetPath --force');
    }
  }

  Future<void> _runCommand(String command, List<String> args,
      {String? workingDirectory}) async {
    final result = await Process.run(
      command,
      args,
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw Exception(result.stderr);
    }
  }
}
