import 'package:flutter/foundation.dart';

extension TargetPlatformX on TargetPlatform {
  bool get isDesktop => switch (this) {
        TargetPlatform.linux => true,
        TargetPlatform.macOS => true,
        TargetPlatform.windows => true,
        _ => false,
      };

  bool get isMobile => switch (this) {
        TargetPlatform.android => true,
        TargetPlatform.iOS => true,
        _ => false,
      };
}
