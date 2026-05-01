/// The animation style used when pushing a new route.
///
/// | Value              | Description                                   |
/// |--------------------|-----------------------------------------------|
/// | bottomToUpWithFade | Slides from bottom + fades in (Material feel) |
/// | fade               | Simple opacity transition                     |
/// | slideWithFade      | Slight vertical slide + delayed fade-in       |
/// | slideOnly          | Subtle vertical slide, no fade                |
/// | cupertino          | iOS-style horizontal swipe (uses CupertinoPageTransition) |
enum NavTransitionType {
  bottomToUpWithFade,
  fade,
  slideWithFade,
  slideOnly,
  cupertino,
}
