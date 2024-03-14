import 'dart:io';

Future<void> main() async {
  final preCommitHook = File('.git/hooks/pre-commit');
  await preCommitHook.parent.create();
  await preCommitHook.writeAsString(
    '''
#!/bin/bash
set -exo pipefail

pushd systemd_status_server
dart run dart_pre_commit
popd

pushd systemd_status_flutter
flutter pub run dart_pre_commit
popd
''',
  );

  if (!Platform.isWindows) {
    final result = await Process.run('chmod', ['a+x', preCommitHook.path]);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    exitCode = result.exitCode;
  }
}
