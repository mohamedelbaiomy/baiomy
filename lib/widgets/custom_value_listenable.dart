import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BaiomyValueListenableBuilder2<A, B> extends StatelessWidget {
  const BaiomyValueListenableBuilder2({
    required this.first,
    required this.second,
    super.key,
    required this.builder,
    this.child,
  });

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<A>(
    valueListenable: first,
    builder: (_, A a, _) => ValueListenableBuilder<B>(
      valueListenable: second,
      builder: (BuildContext context, B b, _) => builder(context, a, b, child),
    ),
  );
}

class ValueListenableBuilder2PreferredSizeWidget<A, B> extends StatelessWidget
    implements PreferredSizeWidget {
  const ValueListenableBuilder2PreferredSizeWidget({
    required this.first,
    required this.second,
    super.key,
    required this.builder,
    this.child,
  });

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<A>(
    valueListenable: first,
    builder: (_, A a, _) => ValueListenableBuilder<B>(
      valueListenable: second,
      builder: (BuildContext context, B b, _) => builder(context, a, b, child),
    ),
  );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
