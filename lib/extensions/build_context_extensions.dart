import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  void pop() {
    Navigator.of(this).pop();
  }

  Future<bool> mayBePop() => Navigator.maybePop(this);

  void popWithValue(dynamic value) {
    Navigator.of(this).pop(value);
  }

  // bool isCurrentLanguageAr () {
  //   return Localizations.localeOf(this).languageCode == 'ar';
  // }

  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);

/// Returns the current text scale factor from the device's settings.
// double get textScale => MediaQuery.textScaleFactorOf(this);

/// For more advanced use cases, you could return the TextScaler object itself.
// TextScaler get textScaler => MediaQuery.textScalerOf(this);
//
// EdgeInsets get padding => MediaQuery.paddingOf(this);
//
// double get safeHeight => height - padding.top - padding.bottom;
//
// static const double _designWidth = 375;
// static const double _designHeight = 812;
//
// double scaleWidth(double size) => (width / _designWidth) * size;
//
// double scaleHeight(double size) => (height / _designHeight) * size;
//
// double scaleFont(double size) {
//   final double scaledSize = (width / _designWidth) * size;
//   return scaledSize * textScaler.scale(scaledSize);
// }
//
// double scaleRadius(double size) => (width / _designWidth) * size;
//
// double scaleSmart(double size) {
//   final double widthRatio = width / _designWidth;
//   final double heightRatio = height / _designHeight;
//   return size * (widthRatio < heightRatio ? widthRatio : heightRatio);
// }
}
