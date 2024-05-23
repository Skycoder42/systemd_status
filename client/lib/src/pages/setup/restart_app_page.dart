import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/localization.dart';

class RestartAppPage extends ConsumerWidget {
  const RestartAppPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: Text(context.strings.setup_page_title),
        ),
        body: Center(
          child: Text(context.strings.restart_app_page_message),
        ),
      );
}
