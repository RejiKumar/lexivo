import 'package:flutter/painting.dart';

/// Named elevation presets as [BoxShadow] lists. Never invent inline shadows.
abstract final class LexivoElevation {
  /// Flat — no elevation.
  static const List<BoxShadow> level0 = <BoxShadow>[];

  /// Card resting.
  static const List<BoxShadow> level1 = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A0F172A),
      offset: Offset(0, 1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// Card hover/pressed, dropdown.
  static const List<BoxShadow> level2 = <BoxShadow>[
    BoxShadow(
      color: Color(0x240F172A),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Modal, bottom sheet.
  static const List<BoxShadow> level3 = <BoxShadow>[
    BoxShadow(
      color: Color(0x330F172A),
      offset: Offset(0, 12),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
}
