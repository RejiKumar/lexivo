import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/nav_bar.dart';
import 'package:lexivo/core/routing/adaptive_authenticated_shell.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/routing/route_guards.dart';

void main() {
  test('isDocumentDetailLocation detects deep document routes', () {
    expect(isDocumentDetailLocation('/documents'), isFalse);
    expect(isDocumentDetailLocation('/documents/scan'), isFalse);
    expect(isDocumentDetailLocation('/documents/doc-1/ocr'), isTrue);
    expect(isDocumentDetailLocation('/documents/doc-1/chat'), isTrue);
  });

  testWidgets('shell shows BottomNav at mobile width', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          showcaseEnabledProvider.overrideWith((ref) => false),
          authGuardStateProvider.overrideWith(
            (ref) => const AuthGuardState(isAuthenticated: true),
          ),
        ],
        child: const LexivoRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LexivoBottomNav), findsOneWidget);
    expect(find.byType(LexivoNavRail), findsNothing);
    expect(find.text('Documents'), findsWidgets);
  });

  testWidgets('shell shows NavRail at desktop width', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          showcaseEnabledProvider.overrideWith((ref) => false),
          authGuardStateProvider.overrideWith(
            (ref) => const AuthGuardState(isAuthenticated: true),
          ),
        ],
        child: const LexivoRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LexivoNavRail), findsOneWidget);
    expect(find.byType(LexivoBottomNav), findsNothing);
    expect(find.text('Documents'), findsWidgets);
  });
}
