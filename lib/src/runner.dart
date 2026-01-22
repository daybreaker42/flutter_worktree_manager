import 'dart:io';
import 'package:path/path.dart' as p;
import 'config_loader.dart';

class WorktreeRunner {
  final WorktreeConfig config;

  WorktreeRunner(this.config);

  /// 새로운 워크트리를 생성하고 환경을 설정합니다.
  Future<void> create(String branchName) async {
    final safeFolderName = branchName.replaceAll('/', '_');
    final targetPath = p.join(config.baseDir, safeFolderName);

    print('🚀 Worktree 생성 시작: $branchName');

    try {
      // 1. Git Worktree 추가
      if (await Directory(targetPath).exists()) {
        print('⚠️  이미 폴더가 존재합니다: $targetPath');
      } else {
        print('📂 [1/4] Git 워크트리 생성 중...');
        await _runCommand(
            'git', ['worktree', 'add', '-b', branchName, targetPath]);
      }

      // 2. 설정 파일 복사 (시크릿 파일 등)
      print('📄 [2/4] 설정 파일 복사 중...');
      for (var filePath in config.configFiles) {
        final sourceFile = File(filePath);
        final destFile = File(p.join(targetPath, filePath));

        if (await sourceFile.exists()) {
          await Directory(destFile.parent.path).create(recursive: true);
          await sourceFile.copy(destFile.path);
          print('   ✅ 복사 완료: $filePath');
        } else {
          print('   ❓ 원본 없음 (건너뜀): $filePath');
        }
      }

      // 3. Flutter 패키지 설치
      print('📦 [3/4] Flutter 패키지 설치 중...');
      await _runCommand('flutter', ['pub', 'get'],
          workingDirectory: targetPath);

      // 4. Build Runner 실행
      print('🔧 [4/4] 빌드 러너 실행 중...');
      await _runCommand(
          'dart',
          [
            'run',
            'build_runner',
            'build',
            '--delete-conflicting-outputs',
          ],
          workingDirectory: targetPath);

      print('\n✨ 모든 설정이 완료되었습니다!');
      print('📍 작업 경로: ${Directory(targetPath).absolute.path}');
    } catch (e) {
      print('\n❌ 생성 중 오류 발생: $e');
    }
  }

  /// 워크트리를 삭제하고 연결을 해제합니다.
  Future<void> remove(String branchName) async {
    final safeFolderName = branchName.replaceAll('/', '_');
    final targetPath = p.join(config.baseDir, safeFolderName);

    print('🧹 워크트리 삭제 시작: $branchName');

    try {
      print('🗑️ [1/2] Git 워크트리 연결 해제 중...');
      await _runCommand('git', ['worktree', 'remove', targetPath]);
      await _runCommand('git', ['worktree', 'prune']);

      final dir = Directory(targetPath);
      if (await dir.exists()) {
        print('📂 [2/2] 잔여 폴더 삭제 중...');
        await dir.delete(recursive: true);
      }
      print('\n✅ 워크트리가 성공적으로 제거되었습니다.');
    } catch (e) {
      print('\n❌ 삭제 중 오류 발생: $e');
      print('💡 수동 삭제: git worktree remove $targetPath --force');
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
