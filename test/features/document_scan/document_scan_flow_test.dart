import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/document_card.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/features/auth/auth.dart';
import 'package:lexivo/features/document_scan/presentation/providers/document_providers.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_document_input_source.dart';
import '../../helpers/fake_document_repository.dart';

void main() {
  testWidgets('camera path → upload → processing → poll ready', (tester) async {
    final repo = FakeDocumentRepository(initial: []);
    repo.createdStatus = DocumentStatus.processing;
    repo.statusSequence.addAll([
      DocumentStatus.processing,
      DocumentStatus.ready,
    ]);
    final input = FakeDocumentInputSource(cameraAvailable: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(initialSession: sampleSession()),
          ),
          ...authCoreOverrides(),
          documentRepositoryProvider.overrideWithValue(repo),
          documentInputSourceProvider.overrideWithValue(input),
          documentJobPollerProvider.overrideWithValue(
            const JobPoller(
              interval: Duration(milliseconds: 1),
              timeout: Duration(seconds: 2),
            ),
          ),
          ...documentScanCoreOverrides(),
          showcaseEnabledProvider.overrideWith((ref) => false),
        ],
        child: const LexivoRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp).first),
    );
    container.read(goRouterProvider).go(RouteGuards.documentScan);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Scan or upload'));
    await tester.pumpAndSettle();
    expect(input.forceCropInvoked, isTrue);

    await tester.pump(const Duration(milliseconds: 50));
    container.read(goRouterProvider).go(RouteGuards.documents);
    await tester.pumpAndSettle();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(find.byType(LexivoDocumentCard), findsWidgets);
    container.read(documentScanControllerProvider.notifier).cancelPolling();
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('camera unavailable → file pick → library entry', (tester) async {
    final repo = FakeDocumentRepository(initial: []);
    final input = FakeDocumentInputSource(cameraAvailable: false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(initialSession: sampleSession()),
          ),
          ...authCoreOverrides(),
          documentRepositoryProvider.overrideWithValue(repo),
          documentInputSourceProvider.overrideWithValue(input),
          ...documentScanCoreOverrides(),
          showcaseEnabledProvider.overrideWith((ref) => false),
        ],
        child: const LexivoRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp).first),
    );
    container.read(goRouterProvider).go(RouteGuards.documentScan);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan or upload'));
    await tester.pumpAndSettle();

    expect(input.captureCalls, 1);
    expect(repo.documents, isNotEmpty);
    expect(repo.documents.first.status, DocumentStatus.ready);
  });
}
