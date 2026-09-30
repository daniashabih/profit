import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit/core/responsive/breakpoints.dart';
import 'package:profit/core/responsive/responsive_scaffold.dart';
import 'package:profit/core/responsive/adaptive_card.dart';
import 'package:profit/core/responsive/responsive_padding.dart';

void main() {
  group('Responsive Breakpoints & System Tests', () {
    testWidgets('Breakpoints classify small phone, standard phone, and tablet correctly', (WidgetTester tester) async {
      // 1. Small Phone (< 360 width)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(320, 600)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveBreakpoints.isSmallPhone(context), isTrue);
                expect(ResponsiveBreakpoints.isTablet(context), isFalse);
                expect(ResponsiveBreakpoints.deviceType(context), equals(ScreenDeviceType.smallPhone));
                expect(ResponsiveBreakpoints.horizontalPadding(context), equals(16.0));
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // 2. Standard Phone (360 - 599 width)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(390, 844)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveBreakpoints.isSmallPhone(context), isFalse);
                expect(ResponsiveBreakpoints.isTablet(context), isFalse);
                expect(ResponsiveBreakpoints.deviceType(context), equals(ScreenDeviceType.standardPhone));
                expect(ResponsiveBreakpoints.horizontalPadding(context), equals(24.0));
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // 3. Tablet (>= 600 width)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveBreakpoints.isSmallPhone(context), isFalse);
                expect(ResponsiveBreakpoints.isTablet(context), isTrue);
                expect(ResponsiveBreakpoints.deviceType(context), equals(ScreenDeviceType.tablet));
                expect(ResponsiveBreakpoints.horizontalPadding(context), equals(32.0));
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('ResponsiveScaffold renders content and applies constraints', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(800, 1000)),
            child: ResponsiveScaffold(
              scrollable: true,
              body: Text('Responsive Content'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Responsive Content'), findsOneWidget);

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
      expect(
        constrainedBoxes.any((box) => box.constraints.maxWidth == ResponsiveBreakpoints.maxContentWidth),
        isTrue,
      );
    });

    testWidgets('AdaptiveCard responds to tap and selection state', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveCard(
              isSelected: true,
              onTap: () => tapped = true,
              child: const Text('Adaptive Card Child'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Adaptive Card Child'), findsOneWidget);
      await tester.tap(find.text('Adaptive Card Child'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('ResponsivePadding applies proper adaptive padding on small phone', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(320, 600)),
            child: Scaffold(
              body: ResponsivePadding(
                child: Text('Padded'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final paddingWidget = tester.widget<Padding>(
        find.ancestor(of: find.text('Padded'), matching: find.byType(Padding)).first,
      );
      expect(paddingWidget.padding, equals(const EdgeInsets.all(16.0)));
    });
  });
}
