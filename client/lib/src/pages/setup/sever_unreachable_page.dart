import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/localization.dart';
import '../../settings/setup_loader.dart';

class ServerUnreachablePage extends ConsumerWidget {
  const ServerUnreachablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorState = ref.watch(
      setupStateProvider.select(
        (s) => switch (s) {
          final SetupServerUnreachableState state => state,
          _ => null,
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.setup_page_title),
      ),
      body: Center(
        child: Text(
          context.strings.server_unreachable_page_message(
            errorState?.errorMessage ?? '',
            errorState?.statusCode ?? -1,
          ),
        ),
      ),
    );
  }
}
