import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../localization/localization.dart';
import '../../widgets/async_action.dart';
import '../../widgets/scrollable_expanded_box.dart';
import 'setup_controller.dart';

class SetupPage extends ConsumerStatefulWidget {
  final String? redirectTo;

  const SetupPage({
    super.key,
    this.redirectTo,
  });

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('redirectTo', redirectTo));
  }
}

class _SetupPageState extends ConsumerState<SetupPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isValid = false;
  Uri? _savedUrl;
  String? _savedFirebaseApiKey;
  String? _savedSentryDsn;

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
                      initialValue: ref.watch(setupControllerProvider).urlInput,
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
                    TextFormField(
                      decoration: InputDecoration(
                        label: Text(
                          context.strings.setup_page_firebase_api_key_label,
                        ),
                      ),
                      initialValue:
                          ref.watch(setupControllerProvider).firebaseApiKey,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.match('[0-9a-zA-Z]+'),
                      ]),
                      onSaved: (newValue) => _savedFirebaseApiKey = newValue,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        label: Text(
                          context.strings.setup_page_sentry_dsn_label,
                        ),
                      ),
                      initialValue:
                          ref.watch(setupControllerProvider).sentryDsn,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                      validator: FormBuilderValidators.url(
                        protocols: const ['https'],
                        requireProtocol: true,
                      ),
                      onSaved: (newValue) => _savedSentryDsn = newValue,
                    ),
                    const SizedBox(height: 16),
                    AsyncAction(
                      enabled: _isValid,
                      onAction: _submit,
                      onError: (_) =>
                          context.strings.setup_page_configure_failed,
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
    _reset();

    final state = _formKey.currentState;
    if (state == null || !state.validate()) {
      return;
    }

    state.save();

    await ref.read(setupControllerProvider.notifier).submit(
          serverUrl: _savedUrl!,
          firebaseApiKey: _savedFirebaseApiKey!,
          sentryDsn: _savedSentryDsn,
          redirectTo: widget.redirectTo,
        );
  }

  void _reset() {
    _savedUrl = null;
    _savedFirebaseApiKey = null;
    _savedSentryDsn = null;
  }
}
