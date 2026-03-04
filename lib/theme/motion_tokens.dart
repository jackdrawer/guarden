import 'package:flutter/material.dart';

class MotionDurations {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 320);

  static const Duration navIndicator = Duration(milliseconds: 280);
  static const Duration navItem = Duration(milliseconds: 220);
  static const Duration fabVisibility = Duration(milliseconds: 260);
  static const Duration fabSwitch = Duration(milliseconds: 240);
  static const Duration fabPressDown = Duration(milliseconds: 110);
  static const Duration fabPressUp = Duration(milliseconds: 140);
}

class MotionCurves {
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasis = Curves.easeOutBack;
}
