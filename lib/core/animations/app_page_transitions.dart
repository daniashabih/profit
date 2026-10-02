import 'package:flutter/material.dart';
import 'app_animation_constants.dart';

/// Clean, commercial-grade page transitions combining a smooth fade
/// with a subtle horizontal or vertical slide (16-24px).
/// Designed to run within 250-320ms at a rock-solid 60 FPS.
class AppSlideFadeTransitionBuilder extends PageTransitionsBuilder {
  final bool slideFromBottom;

  const AppSlideFadeTransitionBuilder({this.slideFromBottom = false});

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppAnimationConstants.shouldReduceMotion(context)) {
      return FadeTransition(opacity: animation, child: child);
    }

    final curve = CurvedAnimation(
      parent: animation,
      curve: AppAnimationConstants.easeOut,
      reverseCurve: Curves.easeInCubic,
    );

    final offsetBegin = slideFromBottom
        ? const Offset(0.0, 0.08)
        : const Offset(0.06, 0.0);

    final slideAnimation = Tween<Offset>(
      begin: offsetBegin,
      end: Offset.zero,
    ).animate(curve);

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: curve,
        child: child,
      ),
    );
  }
}

/// Helper method to create a smooth, standardized route with custom duration and fade-slide transition.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required WidgetBuilder builder,
    Duration duration = AppAnimationConstants.standard,
    bool slideFromBottom = false,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (AppAnimationConstants.shouldReduceMotion(context)) {
              return FadeTransition(opacity: animation, child: child);
            }

            final curve = CurvedAnimation(
              parent: animation,
              curve: AppAnimationConstants.easeOut,
              reverseCurve: Curves.easeInCubic,
            );

            final offsetBegin = slideFromBottom
                ? const Offset(0.0, 0.08)
                : const Offset(0.06, 0.0);

            return SlideTransition(
              position: Tween<Offset>(
                begin: offsetBegin,
                end: Offset.zero,
              ).animate(curve),
              child: FadeTransition(
                opacity: curve,
                child: child,
              ),
            );
          },
        );
}
