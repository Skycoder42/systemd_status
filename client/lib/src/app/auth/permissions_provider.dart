import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:systemd_status_server/api.dart';

import '../../providers/api_provider.dart';
import 'account_manager_provider.dart';

part 'permissions_provider.g.dart';

@riverpod
Future<UserPermissions> userPermissions(Ref ref) async {
  // ensure this is rebuilt when the account changes
  ref.watch(accountManagerProvider);

  final permissions = await ref
      .watch(systemdStatusApiClientProvider)
      .systemGetPermissions();
  ref.keepAlive();
  return permissions;
}
