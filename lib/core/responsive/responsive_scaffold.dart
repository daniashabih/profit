import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// A production-grade responsive scaffold that automatically constrains content width
/// on tablets/large screens, wraps in SafeArea, and avoids keyboard overflow issues.
class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;
  final double maxContentWidth;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.scrollable = false,
    this.padding,
    this.maxContentWidth = ResponsiveBreakpoints.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (scrollable) {
      content = LayoutBuilder(
        builder: (context, constraints) {
          final effectivePadding =
              padding ?? ResponsiveBreakpoints.screenPadding(context);
          final double minHeight = constraints.hasBoundedHeight
              ? (constraints.maxHeight - effectivePadding.vertical)
                  .clamp(0.0, double.infinity)
              : 0.0;

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: effectivePadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: body,
            ),
          );
        },
      );
    } else {
      content = padding != null
          ? Padding(
              padding: padding!,
              child: body,
            )
          : body;
    }

    // Center and constrain max width on wide screens / tablets
    content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: content,
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: SafeArea(child: content),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
