import 'package:flutter_worktree_manager/src/config_loader.dart';
import 'package:flutter_worktree_manager/src/runner.dart';

void main(List<String> arguments) async {
  final config = await WorktreeConfig.load();
  final runner = WorktreeRunner(config);

  if (arguments.isEmpty) {
    print('🚀 사용법:');
    print('  생성: dart run ftree <branch_name>');
    print('  삭제: dart run ftree --remove <branch_name>');
    return;
  }

  if (arguments[0] == '--remove' || arguments[0] == '-r') {
    await runner.remove(arguments[1]);
  } else {
    await runner.create(arguments[0]);
  }
}