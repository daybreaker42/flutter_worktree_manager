import 'dart:io';
import 'package:yaml/yaml.dart';

class WorktreeConfig {
  final String baseDir;
  final List<String> configFiles;

  WorktreeConfig({required this.baseDir, required this.configFiles});

  static Future<WorktreeConfig> load() async {
    final configFile = File('worktree_config.yaml');
    
    if (!await configFile.exists()) {
      print('ℹ️  worktree_config.yaml 파일이 없어 기본 설정을 사용합니다.');
      return WorktreeConfig(
        baseDir: '../worktrees',
        configFiles: ['.env'],
      );
    }

    final content = await configFile.readAsString();
    final doc = loadYaml(content);

    return WorktreeConfig(
      baseDir: doc['base_dir'] ?? '../worktrees',
      configFiles: List<String>.from(doc['copy_files'] ?? []),
    );
  }
}