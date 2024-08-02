import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:logging/logging.dart';

import '../../app/auth/account_manager_provider.dart';
import '../../app/router.dart';
import '../../localization/localization.dart';
import '../../widgets/async_action.dart';
import '../../widgets/scrollable_expanded_box.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? redirectTo;

  const LoginPage({
    super.key,
    this.redirectTo,
  });

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('redirectTo', redirectTo));
  }
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _submitKey = GlobalKey<AsyncActionState>();
  final _logger = Logger('LoginPage');

  bool _isValid = false;
  String? _savedEmail;
  String? _savedPassword;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(context.strings.login_page_title),
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
                          context.strings.login_page_email_label,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                      onSaved: (newValue) => _savedEmail = newValue,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        label: Text(
                          context.strings.login_page_password_label,
                        ),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      autocorrect: false,
                      enableIMEPersonalizedLearning: false,
                      enableSuggestions: false,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofocus: true,
                      validator: FormBuilderValidators.required(),
                      onSaved: (newValue) => _savedPassword = newValue,
                      onFieldSubmitted: (_) =>
                          _submitKey.currentState?.triggerAction(),
                    ),
                    const SizedBox(height: 16),
                    AsyncAction(
                      key: _submitKey,
                      enabled: _isValid,
                      onAction: _submit,
                      onError: _onError,
                      builder: (onAction) => FilledButton.icon(
                        icon: const Icon(Icons.login),
                        label:
                            Text(context.strings.login_page_login_button_text),
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
    _savedEmail = null;
    _savedPassword = null;

    final state = _formKey.currentState;
    if (state == null || !state.validate()) {
      return;
    }

    state.save();

    await ref
        .read(accountManagerProvider.notifier)
        .signIn(_savedEmail!, _savedPassword!);
    ref
        .read(routerProvider)
        .go(widget.redirectTo ?? const RootRoute().location);
  }

  String _onError(Object e, StackTrace s) {
    _logger.severe('Failed to sign in with error', e, s);
    return context.strings.login_page_login_failed;
  }
}
