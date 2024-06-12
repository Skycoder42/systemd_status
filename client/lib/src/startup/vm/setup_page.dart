import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:logging/logging.dart';
import 'package:systemd_status_server/api.dart';

import '../../localization/localization.dart';
import '../../widgets/async_action.dart';
import '../../widgets/scrollable_expanded_box.dart';

class SetupPage extends ConsumerStatefulWidget {
  final Completer<Uri> serverUrlCompleter;

  const SetupPage({
    super.key,
    required this.serverUrlCompleter,
  });

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Completer<Uri>>(
        'serverUrlCompleter',
        serverUrlCompleter,
      ),
    );
  }
}

class _SetupPageState extends ConsumerState<SetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _logger = Logger('SetupPage');

  bool _isValid = false;
  Uri? _savedUrl;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(context.strings.setup_page_title),
        ),
        body: Form(
          key: _formKey,
          onChanged: _updateValidState,
          child: ScrollableExpandedBox(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        label: Text(
                          context.strings.setup_page_server_url_label,
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.url(
                          protocols: const ['http', 'https'],
                          requireProtocol: true,
                        ),
                      ]),
                      onSaved: (newValue) => _savedUrl =
                          newValue != null ? Uri.parse(newValue) : null,
                    ),
                    const SizedBox(height: 16),
                    AsyncAction(
                      enabled:
                          _isValid && !widget.serverUrlCompleter.isCompleted,
                      onAction: _submit,
                      onError: _onError,
                      errorToastDuration: const Duration(seconds: 10),
                      builder: (onAction) => FilledButton.icon(
                        icon: const Icon(Icons.save),
                        label:
                            Text(context.strings.setup_page_save_button_text),
                        onPressed: onAction,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  void _updateValidState() {
    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _isValid = isValid;
    });
  }

  Future<void> _submit() async {
    // submit form
    _savedUrl = null;
    final state = _formKey.currentState;
    if (state == null || !state.validate()) {
      return;
    }
    state.save();

    // validate URL works
    final client = SystemdStatusApiClient(_savedUrl!);
    try {
      await client.configGet();
    } finally {
      client.close(force: true);
    }

    // complete with URL
    if (!widget.serverUrlCompleter.isCompleted) {
      widget.serverUrlCompleter.complete(_savedUrl!);
      // rebuild to ensure button stays disabled
      setState(() {});
    } else {
      _logger.warning('Already completed!');
    }
  }

  String _onError(Object e, StackTrace s) {
    _logger.severe('Failed to submit setup data', e, s);
    if (e is DioException) {
      return context.strings.setup_page_configure_failed(
        e.response?.statusCode ?? -1,
        e.message ?? e.toString(),
      );
    } else {
      return context.strings.setup_page_configure_failed(-1, e.toString());
    }
  }
}
