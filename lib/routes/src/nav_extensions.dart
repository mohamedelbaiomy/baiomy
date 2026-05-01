import 'package:flutter/material.dart';

import 'nav_kit.dart';
import 'nav_transition_type.dart';

/// Convenience extensions on [BuildContext] for common navigation actions.
///
/// These mirror the [NavKit] static methods but can be called directly on
/// the context — useful inside widget `build` methods where you already
/// have `context` in scope:
///
/// ```dart
/// // Instead of:
/// NavKit.push(context, Routes.detail, arguments: item);
///
/// // You can write:
/// context.navPush(Routes.detail, arguments: item);
/// context.navPop();
/// ```
extension NavKitContext on BuildContext {
  // ── Push ──────────────────────────────────────────────────────────────────

  /// Push a named route with the default platform transition.
  Future<T?> navPush<T>(String routeName, {Object? arguments}) =>
      BaiomyNavKit.push<T>(this, routeName, arguments: arguments);

  /// Push with a bottom-to-up slide + fade animation.
  Future<T?> navPushWithSlideUp<T>(
    String routeName, {
    Object? arguments,
    Duration transitionDuration = const Duration(milliseconds: 380),
    Duration reverseTransitionDuration = const Duration(milliseconds: 470),
  }) => BaiomyNavKit.pushWithSlideUp<T>(
    this,
    routeName,
    arguments: arguments,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  /// Push with a fade animation.
  Future<T?> navPushWithFade<T>(
    String routeName, {
    Object? arguments,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => BaiomyNavKit.pushWithFade<T>(
    this,
    routeName,
    arguments: arguments,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  /// Push with a slide + fade animation.
  Future<T?> navPushWithSlideAndFade<T>(
    String routeName, {
    Object? arguments,
    Duration transitionDuration = const Duration(milliseconds: 380),
    Duration reverseTransitionDuration = const Duration(milliseconds: 470),
  }) => BaiomyNavKit.pushWithSlideAndFade<T>(
    this,
    routeName,
    arguments: arguments,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  /// Push with a slide-only animation.
  Future<T?> navPushWithSlide<T>(
    String routeName, {
    Object? arguments,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => BaiomyNavKit.pushWithSlide<T>(
    this,
    routeName,
    arguments: arguments,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  /// Push with a fully custom [NavTransitionType].
  Future<T?> navPushNamed<T>(
    String routeName, {
    Object? arguments,
    NavTransitionType? transitionType,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => BaiomyNavKit.pushNamed<T>(
    this,
    routeName,
    arguments: arguments,
    transitionType: transitionType,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  // ── Push replacement ──────────────────────────────────────────────────────

  /// Push replacement with the default platform transition.
  Future<T?> navPushReplacement<T, TO>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) => BaiomyNavKit.pushReplacement<T, TO>(
    this,
    routeName,
    arguments: arguments,
    result: result,
  );

  /// Push replacement with fade.
  Future<T?> navPushReplacementWithFade<T, TO>(
    String routeName, {
    Object? arguments,
    TO? result,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => BaiomyNavKit.pushReplacementWithFade<T, TO>(
    this,
    routeName,
    arguments: arguments,
    result: result,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  /// Push replacement with bottom-to-up slide + fade.
  Future<T?> navPushReplacementWithSlideUp<T, TO>(
    String routeName, {
    Object? arguments,
    TO? result,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => BaiomyNavKit.pushReplacementWithSlideUp<T, TO>(
    this,
    routeName,
    arguments: arguments,
    result: result,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  // ── Push and remove all ───────────────────────────────────────────────────

  /// Push and remove all with the default platform transition.
  Future<T?> navPushAndRemoveAll<T>(String routeName, {Object? arguments}) =>
      BaiomyNavKit.pushAndRemoveAll<T>(this, routeName, arguments: arguments);

  /// Push and remove all with fade.
  Future<T?> navPushAndRemoveAllWithFade<T>(
    String routeName, {
    Object? arguments,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => BaiomyNavKit.pushAndRemoveAllWithFade<T>(
    this,
    routeName,
    arguments: arguments,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  /// Push and remove all with bottom-to-up slide + fade.
  Future<T?> navPushAndRemoveAllWithSlideUp<T>(
    String routeName, {
    Object? arguments,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => BaiomyNavKit.pushAndRemoveAllWithSlideUp<T>(
    this,
    routeName,
    arguments: arguments,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  // ── Stack control ─────────────────────────────────────────────────────────

  /// Pop the current route.
  void navPop<T>([T? result]) => BaiomyNavKit.pop<T>(this, result);

  /// Pop until [routeName] is at the top.
  void navPopUntil(String routeName) => BaiomyNavKit.popUntil(this, routeName);

  /// Returns `true` if there is a route that can be popped.
  bool get navCanPop => BaiomyNavKit.canPop(this);

  // ── Widget push ───────────────────────────────────────────────────────────

  /// Push a widget directly with bottom-to-up slide + fade.
  Future<T?> navPushWidgetWithSlideUp<T>(
    Widget page, {
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => BaiomyNavKit.pushWidgetWithSlideUp<T>(
    this,
    page,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  /// Push a widget directly with fade.
  Future<T?> navPushWidgetWithFade<T>(
    Widget page, {
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => BaiomyNavKit.pushWidgetWithFade<T>(
    this,
    page,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );
}
