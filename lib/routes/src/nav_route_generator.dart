import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'nav_routes.dart';
import 'nav_transition_type.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Internal helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Keys injected into the arguments map when a transition override is requested.
const String _kTransitionType = '_navkit_transitionType';
const String _kTransitionDuration = '_navkit_transitionDuration';
const String _kReverseTransitionDuration = '_navkit_reverseTransitionDuration';
const String _kOriginalArguments = '_navkit_originalArguments';

/// Wraps the caller's arguments together with transition metadata.
Map<String, dynamic> buildTransitionArgs({
  required Object? originalArguments,
  required NavTransitionType transitionType,
  Duration? transitionDuration,
  Duration? reverseTransitionDuration,
}) => <String, dynamic>{
  _kOriginalArguments: originalArguments,
  _kTransitionType: transitionType,
  _kTransitionDuration: transitionDuration,
  _kReverseTransitionDuration: reverseTransitionDuration,
};

// ─────────────────────────────────────────────────────────────────────────────
// TransitionParams
// ─────────────────────────────────────────────────────────────────────────────

/// Parsed transition configuration extracted from route arguments.
class NavTransitionParams {
  const NavTransitionParams({
    required this.transitionType,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.originalArguments,
  });

  final NavTransitionType transitionType;
  final Duration? transitionDuration;
  final Duration? reverseTransitionDuration;
  final Object? originalArguments;

  /// Extracts [NavTransitionParams] from raw route [arguments].
  static NavTransitionParams extract(Object? arguments) {
    if (arguments is Map<String, dynamic> &&
        arguments.containsKey(_kTransitionType)) {
      return NavTransitionParams(
        transitionType:
            arguments[_kTransitionType] as NavTransitionType? ??
            NavTransitionType.fade,
        transitionDuration: arguments[_kTransitionDuration] as Duration?,
        reverseTransitionDuration:
            arguments[_kReverseTransitionDuration] as Duration?,
        originalArguments: arguments[_kOriginalArguments],
      );
    }

    // Plain arguments – no transition override
    return NavTransitionParams(
      transitionType: NavTransitionType.fade,
      originalArguments: arguments,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NavRouteGenerator
// ─────────────────────────────────────────────────────────────────────────────

/// Generates [Route] objects from route settings.
///
/// Wire this into [MaterialApp.onGenerateRoute]:
///
/// ```dart
/// MaterialApp(
///   onGenerateRoute: NavRouteGenerator(
///     routes: Routes(),         // your NavRoutes subclass
///     noRouteScreen: const NotFoundScreen(),
///     firstRoute: Routes.home,
///     builders: {
///       Routes.home:   (_)     => const HomeScreen(),
///       Routes.detail: (args)  => DetailScreen(args: args as MyArgs),
///     },
///   ).generateRoute,
/// )
/// ```
///
/// ### Builder map
///
/// Each entry maps a route name to a builder that receives the **original**
/// arguments (with transition metadata already stripped out):
///
/// ```dart
/// Routes.profile: (args) {
///   final userId = args as String;
///   return ProfileScreen(userId: userId);
/// },
/// ```
class NavRouteGenerator {
  NavRouteGenerator({
    required this.routes,
    required this.noRouteScreen,
    required this.firstRoute,
    required this.builders,
  });

  /// Your [NavRoutes] subclass, used for optional validation logging.
  final NavRoutes routes;

  /// Shown when a route is not found in [builders].
  final Widget noRouteScreen;

  /// The initial route of your app (used as fallback when name is null).
  final String firstRoute;

  /// Maps route names → widget builders.
  ///
  /// The builder receives the caller's **original** arguments (transition
  /// metadata is stripped before the builder is called).
  final Map<String, Widget Function(Object? arguments)> builders;

  // ── Public entry point ────────────────────────────────────────────────────

  /// Pass this to [MaterialApp.onGenerateRoute].
  Route<dynamic> generateRoute(RouteSettings settings) {
    final String name = settings.name ?? firstRoute;
    final NavTransitionParams params = NavTransitionParams.extract(
      settings.arguments,
    );

    final Widget page = _buildPage(name, params.originalArguments);

    return _createRoute<dynamic>(
      page,
      settings,
      transitionType: params.transitionType,
      transitionDuration: params.transitionDuration,
      reverseTransitionDuration: params.reverseTransitionDuration,
    );
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  Widget _buildPage(String routeName, Object? arguments) {
    final Widget Function(Object?)? builder = builders[routeName];
    if (builder != null) {
      return builder(arguments);
    }
    assert(
      false,
      'flutter_nav_kit: No builder found for route "$routeName". '
      'Add it to the builders map passed to NavRouteGenerator.',
    );
    return noRouteScreen;
  }

  static Route<T> _createRoute<T>(
    Widget page,
    RouteSettings settings, {
    required NavTransitionType transitionType,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) => PageRouteBuilder<T>(
    settings: settings,
    transitionDuration:
        transitionDuration ?? NavTransitions.defaultDuration(transitionType),
    reverseTransitionDuration:
        reverseTransitionDuration ??
        NavTransitions.defaultReverseDuration(transitionType),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        NavTransitions.build(
          transitionType,
          context,
          animation,
          secondaryAnimation,
          child,
        ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// NavTransitions  (pure static helpers – no state)
// ─────────────────────────────────────────────────────────────────────────────

/// Builds animated page transitions and provides default durations.
///
/// You typically won't call this directly – it is used internally by
/// [NavRouteGenerator] and [NavKit].
class NavTransitions {
  const NavTransitions._();

  /// Default forward-transition duration for each [NavTransitionType].
  static Duration defaultDuration(NavTransitionType type) => switch (type) {
    NavTransitionType.bottomToUpWithFade => const Duration(milliseconds: 380),
    NavTransitionType.fade => const Duration(milliseconds: 300),
    NavTransitionType.slideWithFade => const Duration(milliseconds: 500),
    NavTransitionType.slideOnly => const Duration(milliseconds: 450),
    NavTransitionType.cupertino => const Duration(milliseconds: 300),
  };

  /// Default reverse-transition duration for each [NavTransitionType].
  static Duration defaultReverseDuration(NavTransitionType type) =>
      switch (type) {
        NavTransitionType.bottomToUpWithFade => const Duration(
          milliseconds: 250,
        ),
        NavTransitionType.fade => const Duration(milliseconds: 200),
        NavTransitionType.slideWithFade => const Duration(milliseconds: 300),
        NavTransitionType.slideOnly => const Duration(milliseconds: 300),
        NavTransitionType.cupertino => const Duration(milliseconds: 300),
      };

  /// Constructs the transition widget for the given [type].
  static Widget build(
    NavTransitionType type,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => switch (type) {
    NavTransitionType.bottomToUpWithFade => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
      child: FadeTransition(opacity: animation, child: child),
    ),

    NavTransitionType.fade => FadeTransition(opacity: animation, child: child),

    NavTransitionType.slideWithFade => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: const Interval(0.3, 1.0)),
        ),
        child: child,
      ),
    ),

    NavTransitionType.slideOnly => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
      child: child,
    ),

    NavTransitionType.cupertino => CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: true,
      child: child,
    ),
  };
}
