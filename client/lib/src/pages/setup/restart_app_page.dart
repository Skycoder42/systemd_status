import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/localization.dart';
import '../../providers/restart_app_provider.dart';
import '../../widgets/error_listener.dart';

class RestartAppPage extends ConsumerWidget {
  const RestartAppPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listenForErrors(context, restartProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.setup_page_title),
      ),
      body: Center(
        child: switch (ref.watch(restartProvider)) {
          AsyncLoading() => const CircularProgressIndicator(),
          _ => Text(context.strings.restart_app_page_message),
        },
      ),
    );
  }
}
