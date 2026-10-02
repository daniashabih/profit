import 'package:flutter/material.dart';

/// Centralized animation constants and utilities for the PROFIT app.
/// Ensures consistent timing, curves, and accessibility (reduced-motion) support across the entire app.
class AppAnimationConstants {
  // Durations
  static const Duration instant = Duration.zero;
  static const Duration micro = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration entrance = Duration(milliseconds: 450);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration splash = Duration(milliseconds: 1200);

  // Aliases for durations
  static const Duration fastDuration = fast;
  static const Duration standardDuration = standard;
  static const Duration mediumDuration = medium;
  static const Duration slowDuration = slow;

  // Stagger delays
  static const Duration staggerStep = Duration(milliseconds: 50);

  // Curves (Smooth, premium, athletic)
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve subtleSpring = Cubic(0.34, 1.25, 0.64, 1.0);
  static const Curve gentle = Curves.easeOutQuad;

  // Aliases for curves
  static const Curve curveAthletic = fastOutSlowIn;
  static const Curve curveEaseOut = easeOut;
  static const Curve curveEaseInOut = easeInOut;
  static const Curve curveSubtleSpring = subtleSpring;

  /// Returns true if the user has requested reduced motion / accessibility navigation.
  static bool shouldReduceMotion(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return false;
    return mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
  }
}

typedef AppAnimations = AppAnimationConstants;
