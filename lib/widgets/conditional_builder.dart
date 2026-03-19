import 'package:flutter/material.dart';
import 'custom_sized_box.dart';

class BaiomyConditionalBuilder extends StatelessWidget {
  final bool condition;

  final WidgetBuilder builder;

  final WidgetBuilder? fallback;

  const BaiomyConditionalBuilder({
    super.key,
    required this.condition,
    required this.builder,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return builder(context);
    }
    return fallback?.call(context) ?? Spacing.shrink;
  }
}
