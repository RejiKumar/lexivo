import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/document_card.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/routing/app_router.dart';
import 'package:lexivo/core/routing/route_guards.dart';
import 'package:lexivo/core/utils/job_poller.dart';
import 'package:lexivo/features/auth/auth.dart';
import 'package:lexivo/features/document_scan/document_scan.dart';
import 'package:lexivo/features/ocr/ocr.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_document_input_source.dart';
import '../../helpers/fake_document_repository.dart';
import '../../helpers/fake_ocr_repository.dart';

void main() {
  testWidgets('library card tap (processing) → OCR polls → shows text',
      (tester) async {
    final docRepo = FakeDocumentRepository(
      initial: [
        sampleDocument(
          id: 'doc-p',
          status: DocumentStatus.processing,
          title: 'Lease',
        ),
      ],
    );
    final ocrRepo = FakeOcrRepository(
      initial: [
        sampleOcrDocument(
          id: 'doc-p',
          status: DocumentStatus.processing,
          extractedText: null,
        ),
      ],
    );
    ocrRepo.statusSequence.addAll([
      DocumentStatus.processing,
      DocumentStatus.ready,
    ]);
    ocrRepo.documents[0] = sampleOcrDocument(
      id: 'doc-p',
      status: DocumentStatus.ready,
      extractedText: 'Flow extracted text',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(initialSession: sampleSession()),
          ),
          ...authCoreOverrides(),
          documentRepositoryProvider.overrideWithValue(docRepo),
          documentInputSourceProvider.overrideWithValue(
            FakeDocumentInputSource(),
          ),
          ...documentScanCoreOverrides(),
          ocrRepositoryProvider.overrideWithValue(ocrRepo),
          ocrJobPollerProvider.overrideWithValue(
            const JobPoller(
              interval: Duration(milliseconds: 1),
              timeout: Duration(seconds: 2),
            ),
          ),
          ...ocrCoreOverrides(),
          showcaseEnabledProvider.overrideWith((ref) => false),
        ],
        child: const LexivoRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp).first),
    );
    container.read(goRouterProvider).go(RouteGuards.documents);
    await tester.pumpAndSettle();

    expect(find.byType(LexivoDocumentCard), findsOneWidget);
    await tester.tap(find.byType(LexivoDocumentCard));
    await tester.pumpAndSettle();

    expect(find.textContaining('Flow extracted text'), findsOneWidget);
  });

  testWidgets('already-ready document → shows text without long poll',
      (tester) async {
    final ocrRepo = FakeOcrRepository(
      initial: [
        sampleOcrDocument(
          id: 'doc-ready',
          extractedText: 'Ready immediately',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(initialSession: sampleSession()),
          ),
          ...authCoreOverrides(),
          documentRepositoryProvider.overrideWithValue(
            FakeDocumentRepository(
              initial: [
                sampleDocument(id: 'doc-ready', title: 'Ready'),
              ],
            ),
          ),
          documentInputSourceProvider.overrideWithValue(
            FakeDocumentInputSource(),
          ),
          ...documentScanCoreOverrides(),
          ocrRepositoryProvider.overrideWithValue(ocrRepo),
          ...ocrCoreOverrides(),
          showcaseEnabledProvider.overrideWith((ref) => false),
        ],
        child: const LexivoRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp).first),
    );
    container.read(goRouterProvider).go(RouteGuards.documentOcr('doc-ready'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Ready immediately'), findsOneWidget);
    // Single status check then get — no multi-tick poll.
    expect(ocrRepo.statusCalls, 1);
    expect(ocrRepo.getCalls, 1);
  });

  testWidgets('poll → failed → error banner + retry reloads', (tester) async {
    final ocrRepo = FakeOcrRepository(
      initial: [
        sampleOcrDocument(
          id: 'doc-fail',
          status: DocumentStatus.processing,
          extractedText: null,
        ),
      ],
    );
    ocrRepo.statusSequence.addAll([
      DocumentStatus.processing,
      DocumentStatus.failed,
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(initialSession: sampleSession()),
          ),
          ...authCoreOverrides(),
          documentRepositoryProvider.overrideWithValue(
            FakeDocumentRepository(),
          ),
          documentInputSourceProvider.overrideWithValue(
            FakeDocumentInputSource(),
          ),
          ...documentScanCoreOverrides(),
          ocrRepositoryProvider.overrideWithValue(ocrRepo),
          ocrJobPollerProvider.overrideWithValue(
            const JobPoller(
              interval: Duration(milliseconds: 1),
              timeout: Duration(seconds: 2),
            ),
          ),
          ...ocrCoreOverrides(),
          showcaseEnabledProvider.overrideWith((ref) => false),
        ],
        child: const LexivoRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp).first),
    );
    container.read(goRouterProvider).go(RouteGuards.documentOcr('doc-fail'));
    await tester.pumpAndSettle();

    expect(find.byType(LexivoErrorBanner), findsOneWidget);

    // Fix repo for retry.
    ocrRepo.statusSequence
      ..clear()
      ..add(DocumentStatus.ready);
    ocrRepo.documents[0] = sampleOcrDocument(
      id: 'doc-fail',
      status: DocumentStatus.ready,
      extractedText: 'Recovered text',
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Recovered text'), findsOneWidget);
  });
}
