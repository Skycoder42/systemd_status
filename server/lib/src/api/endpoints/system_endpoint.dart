import 'package:shelf_api/shelf_api.dart';

import '../../middlewares/firebase_auth.dart';
import '../../services/systemctl_service.dart';
import '../models/user_permissions.dart';

@ApiEndpoint('/system', middleware: firebaseAuth)
class SystemEndpoint extends ShelfEndpoint {
  SystemEndpoint(super.request);

  @Get('/permissions')
  UserPermissions getPermissions() {
    final userInfo = ref.read(userInfoProvider);
    return UserPermissions(canReboot: userInfo.canReboot);
  }

  @Post('/reboot')
  Future<TResponse<void>> reboot() async {
    final userInfo = ref.read(userInfoProvider);
    if (!userInfo.canReboot) {
      return TResponse.forbidden('User is not allowed to reboot');
    }

    final systemctlService = ref.read(systemctlServiceProvider);
    await systemctlService.reboot();
    return TResponse.ok(null);
  }
}
