import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

// ignore: prefer_const_constructors_in_immutables not const-able
class DialogPage({
  required GoRouterState state,
  required final WidgetBuilder builder,
  final bool barrierDismissible = true,
  final bool useSafeArea = true,
}) extends Page<void> {
  this
    : super(
        key: state.pageKey,
        restorationId: state.pageKey.value,
        name: state.name ?? state.path,
        arguments: {...state.pathParameters, ...state.uri.queryParameters},
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
