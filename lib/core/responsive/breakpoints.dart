import 'package:flutter/material.dart';

/// Screen size classification for PROFIT responsive layout.
enum ScreenDeviceType {
  smallPhone,
  standardPhone,
  tablet,
}

/// Centralized responsive breakpoints and dimension helpers for the PROFIT application.
/// Ensures consistent adaptive behavior across small, standard, and tablet Android devices.
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Small phones (e.g. 320dp - 359dp screen width)
  static const double smallPhoneBreakpoint = 360.0;

  /// Standard phones (360dp - 599dp) to tablet transition
  static const double tabletBreakpoint = 600.0;

  /// Maximum content width on tablets and large screens to prevent unnatural stretching
  static const double maxContentWidth = 640.0;

  /// Returns the current device screen width
  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  /// Returns the current device screen height
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;

  /// Returns whether the device width is less than [smallPhoneBreakpoint] (360dp)
  static bool isSmallPhone(BuildContext context) => width(context) < smallPhoneBreakpoint;

  /// Returns whether the device is a tablet or large fold device (>= 600dp)
  static bool isTablet(BuildContext context) => width(context) >= tabletBreakpoint;

  /// Returns whether the device is in landscape orientation
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Returns the current device classification
  static ScreenDeviceType deviceType(BuildContext context) {
    final w = width(context);
    if (w < smallPhoneBreakpoint) {
      return ScreenDeviceType.smallPhone;
    } else if (w >= tabletBreakpoint) {
      return ScreenDeviceType.tablet;
    }
    return ScreenDeviceType.standardPhone;
  }

  /// Selects a value based on the current screen size tier.
  static T value<T>(
    BuildContext context, {
    required T standard,
    T? small,
    T? tablet,
  }) {
    final type = deviceType(context);
    switch (type) {
      case ScreenDeviceType.smallPhone:
        return small ?? standard;
      case ScreenDeviceType.tablet:
        return tablet ?? standard;
      case ScreenDeviceType.standardPhone:
        return standard;
    }
  }

  /// Returns adaptive horizontal screen padding:
  /// - Small phones: 16.0
  /// - Standard phones: 24.0
  /// - Tablets: 32.0
  static double horizontalPadding(BuildContext context) {
    return value<double>(
      context,
      small: 16.0,
      standard: 24.0,
      tablet: 32.0,
    );
  }

  /// Returns adaptive screen padding as an [EdgeInsets] instance
  static EdgeInsets screenPadding(BuildContext context) {
    final hp = horizontalPadding(context);
    final vp = value<double>(context, small: 12.0, standard: 16.0, tablet: 24.0);
    return EdgeInsets.symmetric(horizontal: hp, vertical: vp);
  }
}
