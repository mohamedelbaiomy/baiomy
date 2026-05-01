/// flutter_nav_kit – a type-safe, animated navigation package for Flutter.
///
/// ## Quick-start
///
/// ```dart
/// // 1. Declare your routes
/// class Routes extends NavRoutes {
///   static const home   = '/home';
///   static const detail = '/detail';
///
///   @override
///   List<String> get all => [home, detail];
/// }
///
/// // 2. Wire up the generator
/// MaterialApp(
///   onGenerateRoute: NavRouteGenerator(
///     routes: Routes(),
///     noRouteScreen: const NotFoundScreen(),
///     firstRoute: Routes.home,
///     builders: {
///       Routes.home:   (_) => const HomeScreen(),
///       Routes.detail: (args) => DetailScreen(args: args),
///     },
///   ).generateRoute,
/// )
///
/// // 3. Navigate
/// NavKit.push(context, Routes.home);
/// NavKit.pushWithSlideUp(context, Routes.detail, arguments: item);
/// ```
library;

export 'src/nav_routes.dart';
export 'src/nav_transition_type.dart';
export 'src/nav_route_generator.dart';
export 'src/nav_kit.dart';
export 'src/nav_extensions.dart';
