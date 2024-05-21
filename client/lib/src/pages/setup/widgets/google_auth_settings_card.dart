import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../localization/localization.dart';
import '../../../settings/settings.dart';
import '../setup_controller.dart';

class GoogleAuthSettingsCard extends ConsumerStatefulWidget {
  final FormFieldSetter<GoogleAuthSettings> onSaved;

  const GoogleAuthSettingsCard({
    super.key,
    required this.onSaved,
  });

  @override
  ConsumerState<GoogleAuthSettingsCard> createState() =>
      _GoogleAuthSettingsCardState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<ValueChanged<GoogleAuthSettings>>.has(
        'onSaved',
        onSaved,
      ),
    );
  }
}

class _GoogleAuthSettingsCardState
    extends ConsumerState<GoogleAuthSettingsCard> {
  late final TextEditingController _clientIdController;
  late final TextEditingController _serverClientIdController;
  late final TextEditingController _redirectUriController;

  String? _savedClientId;
  String? _savedServerClientId;
  String? _savedRedirectUri;

  @override
  void initState() {
    super.initState();

    final googleAuthSettings =
        ref.read(setupControllerProvider).googleAuthSettings;
    _clientIdController =
        TextEditingController(text: googleAuthSettings?.clientId);
    _serverClientIdController =
        TextEditingController(text: googleAuthSettings?.serverClientId);
    _redirectUriController =
        TextEditingController(text: googleAuthSettings?.redirectUri.toString());
  }

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(context.strings.setup_page_google_auth_title),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientIdController,
                decoration: InputDecoration(
                  label: Text(
                    context.strings.setup_page_google_auth_client_id_label,
                  ),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: _validateAuthComplete,
                onSaved: (newValue) {
                  _savedClientId = newValue;
                  _triggerOnSaved();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serverClientIdController,
                decoration: InputDecoration(
                  label: Text(
                    context
                        .strings.setup_page_google_auth_server_client_id_label,
                  ),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: _validateAuthComplete,
                onSaved: (newValue) {
                  _savedServerClientId = newValue;
                  _triggerOnSaved();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _redirectUriController,
                decoration: InputDecoration(
                  label: Text(
                    context.strings.setup_page_google_auth_redirect_uri_label,
                  ),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                validator: FormBuilderValidators.compose([
                  _validateAuthComplete,
                  FormBuilderValidators.url(
                    protocols: const ['http', 'https'],
                    requireProtocol: true,
                    errorText: context.strings.setup_page_url_validator_text,
                  ),
                ]),
                onSaved: (newValue) {
                  _savedRedirectUri = newValue;
                  _triggerOnSaved();
                },
              ),
            ],
          ),
        ),
      );

  void _triggerOnSaved() {
    if (_savedClientId == null ||
        _savedServerClientId == null ||
        _savedRedirectUri == null) {
      return;
    }

    widget.onSaved(
      GoogleAuthSettings(
        clientId: _savedClientId!,
        serverClientId: _savedServerClientId!,
        redirectUri: Uri.parse(_savedRedirectUri!),
      ),
    );
  }

  String? _validateAuthComplete(String? _) {
    final currentClientId = _clientIdController.text;
    final currentServerClientId = _serverClientIdController.text;
    final currentRedirectUri = _redirectUriController.text;

    if (currentClientId == '' &&
        currentServerClientId == '' &&
        currentRedirectUri == '') {
      return null;
    }

    if (currentClientId != '' &&
        currentServerClientId != '' &&
        currentRedirectUri != '') {
      return null;
    }

    return context.strings.setup_page_google_auth_validator_text;
  }
}
