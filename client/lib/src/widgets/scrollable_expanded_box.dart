import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class const ScrollableExpandedBox({
  super.key,
  final ScrollPhysics? physics,
  required final Widget child,
}) extends StatelessWidget {
  static const _maxWidth = 1000.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: physics,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: min(constraints.maxWidth, _maxWidth),
            maxWidth: _maxWidth,
            minHeight: constraints.maxHeight,
          ),
          child: child,
        ),
      ),
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ScrollPhysics?>('physics', physics));
  }
}
