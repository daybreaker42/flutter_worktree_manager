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

  /// Checks if the 'worktree_config.yaml' file exists.
  static Future<bool> exists() async {
    return await File('worktree_config.yaml').exists();
  }

  /// Creates a default 'worktree_config.yaml' file.
  static Future<void> createDefault() async {
    final configFile = File('worktree_config.yaml');
    const defaultConfig = '''
# Base directory where worktrees will be created.
base_dir: ../worktrees

# List of files to be copied from the current project to each new worktree.
# Examples: .env, keys.jks, local.properties
copy_files:
  - .env
  - android/local.properties
  - android/key.properties
  - android/app/google-services.json
  - ios/GoogleService-Info.plist
  - ios/Runner/GoogleService-Info.plist
  - lib/firebase_options.dart
''';
    await configFile.writeAsString(defaultConfig);
    print('✅ worktree_config.yaml has been created with default settings.');
  }
}
