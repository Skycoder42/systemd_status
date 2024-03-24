import 'package:json_rpc_codegen/json_rpc_codegen.dart';

import 'models/unit_info.dart';

part 'systemctl.g.dart';

@jsonRpc
// ignore: unused_element
abstract class _Systemctl {
  List<UnitInfo> listUnits({
    bool all = false,
  });
}
