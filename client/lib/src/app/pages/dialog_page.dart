import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DialogPage extends Page<void> {
  final bool barrierDismissible;
  final bool useSafeArea;
  final WidgetBuilder builder;

  DialogPage({
    required GoRouterState state,
    required this.builder,
    this.barrierDismissible = true,
    this.useSafeArea = true,
  }) : super(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          name: state.name ?? state.path,
          arguments: {
            ...state.pathParameters,
            ...state.uri.queryParameters,
          },
        );

  @override
  Route<void> createRoute(BuildContext context) => DialogRoute<void>(
        context: context,
        settings: this,
        barrierDismissible: barrierDismissible,
        useSafeArea: useSafeArea,
        builder: builder,
      );
}
