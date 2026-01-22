import 'package:flutter_worktree_manager/src/config_loader.dart';
import 'package:flutter_worktree_manager/src/runner.dart';

void main(List<String> arguments) async {
  final config = await WorktreeConfig.load();
  final runner = WorktreeRunner(config);

  if (arguments.isEmpty || arguments[0] == '--help' || arguments[0] == '-h') {
    print('🚀 Usage:');
    print('  Create: ftree <branch_name>');
    print('  Remove: ftree --remove <branch_name>');
    print('\nOptions:');
    print('  -h, --help    Show this help message');
    print('  -r, --remove  Remove a worktree');
    return;
  }

  if (arguments[0] == '--remove' || arguments[0] == '-r') {
    if (arguments.length < 2) {
      print('❌ Error: Please provide a branch name to remove.');
      print('Usage: ftree --remove <branch_name>');
      return;
    }
    await runner.remove(arguments[1]);
  } else {
    await runner.create(arguments[0]);
  }
}
