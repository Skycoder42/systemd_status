import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/app_settings.dart';
import '../../localization/localization.dart';

class ServerUnreachablePage extends ConsumerWidget {
  const ServerUnreachablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (statusCode, error) = ref.watch(
      settingsLoaderProvider.select(
        (s) => switch (s) {
          AsyncError(error: final DioException error) => (
              error.response?.statusCode,
              error
            ),
          AsyncError(error: final error) => (null, error),
          _ => (null, null),
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
            error?.toString() ?? '',
            statusCode ?? -1,
          ),
        ),
      ),
    );
  }
}
