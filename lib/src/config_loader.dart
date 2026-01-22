import 'dart:io';
import 'package:yaml/yaml.dart';

/// Configuration for the worktree manager.
class WorktreeConfig {
  /// The base directory where worktrees will be created.
  final String baseDir;

  /// The list of configuration files to be copied to the new worktree.
  final List<String> configFiles;

  WorktreeConfig({required this.baseDir, required this.configFiles});

  /// Loads the configuration from 'worktree_config.yaml'.
  ///
  /// If the file does not exist, it returns a default configuration.
  static Future<WorktreeConfig> load() async {
    final configFile = File('worktree_config.yaml');

    if (!await configFile.exists()) {
      print('ℹ️  worktree_config.yaml not found, using default settings.');
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
