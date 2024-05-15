import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ScrollableExpandedBox extends StatelessWidget {
  static const _maxWidth = 1000.0;

  final ScrollPhysics? physics;
  final Widget child;

  const ScrollableExpandedBox({
    super.key,
    this.physics,
    required this.child,
  });

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
