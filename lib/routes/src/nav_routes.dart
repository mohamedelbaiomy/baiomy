/// Base class for declaring application route names.
///
/// Extend this class in your app to get compile-time safety for route strings:
///
/// ```dart
/// class Routes extends NavRoutes {
///   static const home   = '/home';
///   static const login  = '/login';
///   static const detail = '/detail';
///
///   @override
///   List<String> get all => [home, login, detail];
/// }
/// ```
///
/// The `all` getter is used by [NavKit] to validate route names at
/// debug time via `assert`, so typos are caught before they reach production.
abstract class NavRoutes {
  const NavRoutes();

  /// Every valid route name in your application.
  ///
  /// Override this and include every constant you declare so that
  /// [NavKit] can validate navigation calls during development.
  List<String> get all;

  /// Returns `true` when [route] is a declared route name.
  bool isValid(String route) => all.contains(route);
}
