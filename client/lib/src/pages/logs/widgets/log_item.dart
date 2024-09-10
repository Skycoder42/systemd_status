import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:systemd_status_server/api.dart';

import '../../../extensions/flutter_x.dart';
import '../../../localization/localization.dart';
import 'log_priority_extensions.dart';
import 'timestamp_text.dart';

class LogItem extends StatelessWidget {
  final JournalEntry item;

  const LogItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(
          item.message,
          style: item.priority.style,
        ),
        subtitle: MediaQuery.orientationOf(context) == Orientation.portrait
            ? Align(
                alignment: Alignment.centerRight,
                child: TimestampText(item.timeStamp),
              )
            : null,
        trailing: MediaQuery.orientationOf(context) == Orientation.landscape
            ? TimestampText(item.timeStamp)
            : null,
        onTap: () async => _onTap(context, item),
        dense: true,
      );

  Future<void> _onTap(BuildContext context, JournalEntry entry) async {
    final contentText = context.strings.logs_page_copied_to_clipboard;
    final messenger = ScaffoldMessenger.of(context);

    await Clipboard.setData(ClipboardData(text: entry.message));

    if (messenger.mounted && defaultTargetPlatform.isDesktop) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 1),
            content: Text(contentText),
          ),
        );
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<JournalEntry>('item', item));
  }
}
