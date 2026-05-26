// Boot smoke test for the AURA app.
//
// Validates that:
//   - the app builds and renders without throwing
//   - the theme preview screen mounts under the dark theme
//   - design-token text exists in the widget tree
//
// This is intentionally a *smoke* test, not a snapshot or interaction test —
// the goal is to lock down "the app boots cleanly with the design system
// applied" so future refactors that break it surface immediately.

import 'package:aura/app/app.dart';
import 'package:aura/core/theme/aura_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AURA app boots and renders theme preview', (tester) async {
    await tester.pumpWidget(const AuraApp());
    await tester.pumpAndSettle();

    // Brand mark is on screen.
    expect(find.text('AURA'), findsOneWidget);

    // Theme preview screen header.
    expect(find.text('Design tokens'), findsOneWidget);

    // App is using the dark theme with our scaffold background token.
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AuraColors.bgBase);
    expect(scaffold.backgroundColor, isNull); // inherits from theme
  });

  testWidgets('CTA buttons respect 56dp minimum tap target via theme', (tester) async {
    await tester.pumpWidget(const AuraApp());
    await tester.pumpAndSettle();

    final theme = Theme.of(tester.element(find.byType(ElevatedButton).first));
    final minHeight = theme.elevatedButtonTheme.style?.minimumSize
        ?.resolve(<WidgetState>{})
        ?.height;
    expect(minHeight, isNotNull);
    expect(minHeight, greaterThanOrEqualTo(56));

    final outlinedMin = theme.outlinedButtonTheme.style?.minimumSize
        ?.resolve(<WidgetState>{})
        ?.height;
    expect(outlinedMin, greaterThanOrEqualTo(56));
  });
}
