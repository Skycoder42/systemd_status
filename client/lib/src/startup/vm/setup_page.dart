import 'dart:async';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:logging/logging.dart';
import 'package:systemd_status_server/api.dart';

import '../../localization/localization.dart';
import '../../providers/file_picker_provider.dart';
import '../../widgets/async_action.dart';
import '../../widgets/scrollable_expanded_box.dart';
import 'http_client_adapter_factory.dart';
import 'setup_result.dart';

class SetupPage extends ConsumerStatefulWidget {
  final Completer<SetupResult> setupCompleter;

  const SetupPage({
    super.key,
    required this.setupCompleter,
  });

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Completer<SetupResult>>(
        'setupCompleter',
        setupCompleter,
      ),
    );
  }
}

class _SetupPageState extends ConsumerState<SetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _logger = Logger('SetupPage');

  late final TextEditingController _serverCertController;

  bool _isValid = false;
  Uri? _savedUrl;
  Uint8List? _savedCertBytes;

  @override
  void initState() {
    super.initState();
    _serverCertController = TextEditingController();
  }

  @override
  void dispose() {
    _serverCertController.dispose();
    super.dispose();
  }

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
                      decoration: InputDecoration(
                        label: Text(
                          context.strings.setup_page_server_url_label,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serverCertController,
                      readOnly: true,
                      decoration: InputDecoration(
                        label: Text(
                          context.strings.setup_page_server_cert_label,
                        ),
                        suffix: IconButton(
                          icon: const Icon(Icons.file_open),
                          onPressed: _pickFile,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AsyncAction(
                      enabled: _isValid && !widget.setupCompleter.isCompleted,
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

  Future<void> _pickFile() async {
    final filePicker = ref.read(filePickerProvider);
    final result = await filePicker.pickFiles(
      dialogTitle: context.strings.setup_page_server_cert_pick_title,
      type: FileType.custom,
      allowedExtensions: const ['crt', 'pem', 'pfx'],
      withData: true,
      lockParentWindow: true,
    );

    final selectedFile = result?.files.singleOrNull;
    if (selectedFile == null) {
      return;
    }

    _serverCertController.text = selectedFile.name;
    _savedCertBytes = selectedFile.bytes;
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
    final dio = Dio(BaseOptions(baseUrl: _savedUrl!.toString()));
    try {
      if (_savedCertBytes case final Uint8List certBytes) {
        dio.httpClientAdapter =
            const HttpClientAdapterFactory().create(certBytes);
      }
      final client = SystemdStatusApiClient.dio(dio);
      await client.configGet();
    } finally {
      dio.close(force: true);
    }

    // complete with URL
    if (!widget.setupCompleter.isCompleted) {
      widget.setupCompleter.complete(
        SetupResult(
          serverUrl: _savedUrl!,
          serverCertBytes: _savedCertBytes,
        ),
      );
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
