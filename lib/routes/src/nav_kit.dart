import 'dart:io';

import 'package:flutter/material.dart';

import 'nav_route_generator.dart';
import 'nav_routes.dart';
import 'nav_transition_type.dart';

/// Primary navigation facade for **flutter_nav_kit**.
///
/// All methods are static. Before calling any named-route method, initialise
/// the kit once (usually in `main.dart` or your app widget):
///
/// ```dart
/// void main() {
///   NavKit.init(routes: Routes());
///   runApp(const MyApp());
/// }
/// ```
///
/// ### Named-route navigation
///
/// ```dart
/// // Simple push
/// NavKit.push(context, Routes.home);
///
/// // With arguments
/// NavKit.push(context, Routes.detail, arguments: myItem);
///
/// // Animated variants
/// NavKit.pushWithSlideUp(context, Routes.detail);
/// NavKit.pushWithFade(context, Routes.settings);
///
/// // Replace / clear stack
/// NavKit.pushReplacement(context, Routes.home);
/// NavKit.pushAndRemoveAll(context, Routes.login);
/// ```
///
/// ### Direct widget navigation (no route name needed)
///
/// ```dart
/// NavKit.pushWidget(context, () => const MyPage());
/// NavKit.pushWidgetWithSlideUp(context, const MyPage());
/// ```
///
/// ### Stack control
///
/// ```dart
/// NavKit.pop(context);
/// NavKit.popUntil(context, Routes.home);
/// NavKit.canPop(context);   // → bool
/// ```
class BaiomyNavKit {
  BaiomyNavKit._();

  // ── Initialisation ─────────────────────────────────────────────────────────

  static NavRoutes? _routes;

  /// Call once at app startup with your [NavRoutes] subclass.
  ///
  /// Enables route-name validation in debug mode.
  static void init({required NavRoutes routes}) {
    _routes = routes;
  }

  // ── Platform detection ────────────────────────────────────────────────────

  static bool get _isIOS {
    try {
      return Platform.isIOS;
    } catch (_) {
      // Platform.isIOS throws on web
      return false;
    }
  }

  static NavTransitionType get _defaultTransition =>
      _isIOS ? NavTransitionType.cupertino : NavTransitionType.fade;

  // ── Route validation ──────────────────────────────────────────────────────

  static void _assertValid(String routeName) {
    assert(
      _routes == null || _routes!.isValid(routeName),
      'flutter_nav_kit: "$routeName" is not a declared route. '
      'Add it to your NavRoutes.all list, or call NavKit.init() with your '
      'routes object.',
    );
  }

  // ── Core: push ────────────────────────────────────────────────────────────

  /// Push a named route with an optional animated transition.
  ///
  /// Omit [transitionType] to use the default platform transition.
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    NavTransitionType? transitionType,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) {
    _assertValid(routeName);

    final Object? effectiveArgs = transitionType != null
        ? buildTransitionArgs(
            originalArguments: arguments,
            transitionType: transitionType,
            transitionDuration: transitionDuration,
            reverseTransitionDuration: reverseTransitionDuration,
          )
        : arguments;

    return Navigator.pushNamed<T>(context, routeName, arguments: effectiveArgs);
  }

  // ── Core: pushReplacement ─────────────────────────────────────────────────

  /// Push a named route, replacing the current one.
  static Future<T?> pushReplacementNamed<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
    NavTransitionType? transitionType,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) {
    _assertValid(routeName);

    final Object? effectiveArgs = transitionType != null
        ? buildTransitionArgs(
            originalArguments: arguments,
            transitionType: transitionType,
            transitionDuration: transitionDuration,
            reverseTransitionDuration: reverseTransitionDuration,
          )
        : arguments;

    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: effectiveArgs,
      result: result,
    );
  }

  // ── Core: pushAndRemoveAll ────────────────────────────────────────────────

  /// Push a named route and clear the entire back-stack.
  static Future<T?> pushNamedAndRemoveAll<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    NavTransitionType? transitionType,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) {
    _assertValid(routeName);

    final Object? effectiveArgs = transitionType != null
        ? buildTransitionArgs(
            originalArguments: arguments,
            transitionType: transitionType,
            transitionDuration: transitionDuration,
            reverseTransitionDuration: reverseTransitionDuration,
          )
        : arguments;

    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (Route<dynamic> route) => false,
      arguments: effectiveArgs,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Semantic push helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Push with the default platform-aware transition (fade / cupertino).
  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) => pushNamed<T>(
    context,
    routeName,
    arguments: arguments,
    transitionType: _defaultTransition,
  );

  /// Push with a bottom-to-up slide + fade animation.
  static Future<T?> pushWithSlideUp<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    Duration transitionDuration = const Duration(milliseconds: 380),
    Duration reverseTransitionDuration = const Duration(milliseconds: 470),
  }) => pushNamed<T>(
    context,
    routeName,
    arguments: arguments,
    transitionType: _isIOS
        ? NavTransitionType.cupertino
        : NavTransitionType.bottomToUpWithFade,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  /// Push with a simple fade animation.
  static Future<T?> pushWithFade<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => pushNamed<T>(
    context,
    routeName,
    arguments: arguments,
    transitionType: _isIOS
        ? NavTransitionType.cupertino
        : NavTransitionType.fade,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  /// Push with a slide + fade animation.
  static Future<T?> pushWithSlideAndFade<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    Duration transitionDuration = const Duration(milliseconds: 380),
    Duration reverseTransitionDuration = const Duration(milliseconds: 470),
  }) => pushNamed<T>(
    context,
    routeName,
    arguments: arguments,
    transitionType: _isIOS
        ? NavTransitionType.cupertino
        : NavTransitionType.slideWithFade,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  /// Push with a slide-only animation (no fade).
  static Future<T?> pushWithSlide<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => pushNamed<T>(
    context,
    routeName,
    arguments: arguments,
    transitionType: _isIOS
        ? NavTransitionType.cupertino
        : NavTransitionType.slideOnly,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Semantic pushReplacement helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Push replacement with the default platform-aware transition.
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) => pushReplacementNamed<T, TO>(
    context,
    routeName,
    arguments: arguments,
    result: result,
    transitionType: _defaultTransition,
  );

  /// Push replacement with bottom-to-up slide + fade.
  static Future<T?> pushReplacementWithSlideUp<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => pushReplacementNamed<T, TO>(
    context,
    routeName,
    arguments: arguments,
    result: result,
    transitionType: _isIOS
        ? NavTransitionType.cupertino
        : NavTransitionType.bottomToUpWithFade,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  /// Push replacement with fade.
  static Future<T?> pushReplacementWithFade<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => pushReplacementNamed<T, TO>(
    context,
    routeName,
    arguments: arguments,
    result: result,
    transitionType: _isIOS
        ? NavTransitionType.cupertino
        : NavTransitionType.fade,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Semantic pushAndRemoveAll helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Push and remove all with the default platform-aware transition.
  static Future<T?> pushAndRemoveAll<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) => pushNamedAndRemoveAll<T>(
    context,
    routeName,
    arguments: arguments,
    transitionType: _defaultTransition,
  );

  /// Push and remove all with bottom-to-up slide + fade.
  static Future<T?> pushAndRemoveAllWithSlideUp<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => pushNamedAndRemoveAll<T>(
    context,
    routeName,
    arguments: arguments,
    transitionType: _isIOS
        ? NavTransitionType.cupertino
        : NavTransitionType.bottomToUpWithFade,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  /// Push and remove all with fade.
  static Future<T?> pushAndRemoveAllWithFade<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => pushNamedAndRemoveAll<T>(
    context,
    routeName,
    arguments: arguments,
    transitionType: _isIOS
        ? NavTransitionType.cupertino
        : NavTransitionType.fade,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Smart / utility navigation
  // ═══════════════════════════════════════════════════════════════════════════

  /// Push only if [routeName] is not already the current route.
  ///
  /// Prevents duplicate entries in the back-stack.
  static Future<T?> pushIfNotCurrent<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    NavTransitionType? transitionType,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) {
    final String? current = ModalRoute.of(context)?.settings.name;
    if (current == routeName) return Future<T?>.value();

    return pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
      transitionType: transitionType,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
    );
  }

  /// Replace the entire navigation stack with an ordered list of routes.
  ///
  /// The first route replaces everything; subsequent routes are pushed on top.
  /// Useful for deep-link handling or logout-then-login flows.
  static Future<void> replaceStack(
    BuildContext context,
    List<String> routes, {
    NavTransitionType? transitionType,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) async {
    if (routes.isEmpty) return;

    final NavTransitionType type = transitionType ?? _defaultTransition;

    await pushNamedAndRemoveAll<void>(
      context,
      routes.first,
      transitionType: type,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
    );

    for (int i = 1; i < routes.length; i++) {
      if (!context.mounted) return;
      await pushNamed<void>(
        context,
        routes[i],
        transitionType: type,
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Direct widget navigation (no route name required)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Push a widget directly using a lazy builder (avoids building the widget
  /// before the transition starts).
  static Future<T?> pushWidget<T>(
    BuildContext context,
    Widget Function() pageBuilder, {
    NavTransitionType transitionType = NavTransitionType.fade,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) => Navigator.push<T>(
    context,
    PageRouteBuilder<T>(
      transitionDuration:
          transitionDuration ?? NavTransitions.defaultDuration(transitionType),
      reverseTransitionDuration:
          reverseTransitionDuration ??
          NavTransitions.defaultReverseDuration(transitionType),
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      pageBuilder: (_, _, _) => pageBuilder(),
      transitionsBuilder: (ctx, animation, secondary, child) =>
          NavTransitions.build(
            transitionType,
            ctx,
            animation,
            secondary,
            child,
          ),
    ),
  );

  /// Push a widget directly with a custom transition.
  static Future<T?> pushWidgetWithTransition<T>(
    BuildContext context,
    Widget page, {
    NavTransitionType transitionType = NavTransitionType.fade,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => Navigator.push<T>(
    context,
    PageRouteBuilder<T>(
      transitionDuration:
          transitionDuration ?? NavTransitions.defaultDuration(transitionType),
      reverseTransitionDuration:
          reverseTransitionDuration ??
          NavTransitions.defaultReverseDuration(transitionType),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (ctx, animation, secondary, child) =>
          NavTransitions.build(
            transitionType,
            ctx,
            animation,
            secondary,
            child,
          ),
    ),
  );

  /// Push a widget with bottom-to-up slide + fade.
  static Future<T?> pushWidgetWithSlideUp<T>(
    BuildContext context,
    Widget page, {
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => pushWidgetWithTransition<T>(
    context,
    page,
    transitionType: NavTransitionType.bottomToUpWithFade,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  /// Push a widget with fade.
  static Future<T?> pushWidgetWithFade<T>(
    BuildContext context,
    Widget page, {
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => pushWidgetWithTransition<T>(
    context,
    page,
    transitionType: _isIOS
        ? NavTransitionType.cupertino
        : NavTransitionType.fade,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Stack control
  // ═══════════════════════════════════════════════════════════════════════════

  /// Pop the current route, optionally passing a [result] back.
  static void pop<T>(BuildContext context, [T? result]) =>
      Navigator.pop<T>(context, result);

  /// Pop routes until [routeName] is at the top of the stack.
  static void popUntil(BuildContext context, String routeName) =>
      Navigator.popUntil(context, ModalRoute.withName(routeName));

  /// Returns `true` if there is a route that can be popped.
  static bool canPop(BuildContext context) => Navigator.canPop(context);
}
