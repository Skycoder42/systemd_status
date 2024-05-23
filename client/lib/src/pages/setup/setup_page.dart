import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:logging/logging.dart';

import '../../localization/localization.dart';
import '../../widgets/async_action.dart';
import '../../widgets/error_listener.dart';
import '../../widgets/error_snack_bar.dart';
import '../../widgets/scrollable_expanded_box.dart';
import 'setup_controller.dart';

class SetupPage extends ConsumerStatefulWidget {
  final String? redirectTo;
  final bool hasError;

  const SetupPage({
    super.key,
    this.redirectTo,
    this.hasError = false,
  });

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('redirectTo', redirectTo))
      ..add(DiagnosticsProperty<bool>('hasError', hasError));
  }
}

class _SetupPageState extends ConsumerState<SetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _logger = Logger('SetupPage');

  bool _isValid = false;
  Uri? _savedUrl;

  @override
  void initState() {
    super.initState();

    if (widget.hasError) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ScaffoldMessenger.of(context).showSnackBar(
          ErrorSnackBar(
            context: context,
            content: Text(context.strings.setup_page_config_invalid),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listenForErrors(
      context,
      setupControllerProvider,
      onError: (_) => context.strings.setup_page_config_not_loaded,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.setup_page_title),
      ),
      body: switch (ref.watch(setupControllerProvider)) {
        AsyncData(value: final state) => _buildForm(state),
        AsyncError() => _buildForm(const SetupState(serverUrl: null)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildForm(SetupState state) => Form(
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
                    initialValue: state.urlInput,
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
                    enabled: _isValid,
                    onAction: _submit,
                    onError: _onError,
                    builder: (onAction) => FilledButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(context.strings.setup_page_save_button_text),
                      onPressed: onAction,
                    ),
                  ),
                ],
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
    _savedUrl = null;

    final state = _formKey.currentState;
    if (state == null || !state.validate()) {
      return;
    }

    state.save();

    await ref.read(setupControllerProvider.notifier).submit(
          serverUrl: _savedUrl!,
          redirectTo: widget.redirectTo,
        );
  }

  String _onError(Object e, StackTrace s) {
    _logger.severe('Failed to submit setup data', e, s);
    return context.strings.setup_page_configure_failed;
  }
}
