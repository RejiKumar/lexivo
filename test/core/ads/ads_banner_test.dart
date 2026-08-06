import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/ads/ads.dart';
import 'package:lexivo/core/ads/admob_ads_provider.dart';
import 'package:lexivo/core/ads/ump_ads_consent.dart';
import 'package:lexivo/core/config/app_config.dart';
import 'package:lexivo/core/l10n/l10n.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/features/document_scan/presentation/providers/document_providers.dart';
import 'package:lexivo/features/document_scan/presentation/screens/document_library_screen.dart';

import '../../helpers/document_test_harness.dart';
import '../../helpers/fake_document_repository.dart';
import 'recording_ads_provider.dart';

void main() {
  group('AppConfig ads defaults', () {
    test('ENABLE_ADS defaults false', () {
      expect(AppConfig.enableAds, isFalse);
      expect(AppConfig.childDirected, isFalse);
      expect(AppConfig.adsUseProductionIds, isFalse);
    });
  });

  group('LexivoAdBanner gates', () {
    testWidgets('ENABLE_ADS false → no ads rendered', (tester) async {
      final recording = RecordingAdsProvider();
      await recording.initialize(consent: AdsConsentStatus.obtained);

      await tester.pumpWidget(
        _host(
          overrides: [
            enableAdsFlagProvider.overrideWithValue(false),
            adsSuppressedProvider.overrideWithValue(false),
            adsConsentStatusProvider
                .overrideWith((ref) => AdsConsentStatus.obtained),
            adsProviderProvider.overrideWithValue(recording),
          ],
          child: const LexivoAdBanner(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(LexivoAdBanner.visibleSlotKey), findsNothing);
      expect(find.byKey(RecordingAdsProvider.bannerKey), findsNothing);
      expect(recording.bannerBuilds, 0);
    });

    testWidgets('premium suppress → no ads', (tester) async {
      final recording = RecordingAdsProvider();
      await recording.initialize(consent: AdsConsentStatus.obtained);

      await tester.pumpWidget(
        _host(
          overrides: [
            enableAdsFlagProvider.overrideWithValue(true),
            adsSuppressedProvider.overrideWithValue(true),
            adsConsentStatusProvider
                .overrideWith((ref) => AdsConsentStatus.obtained),
            adsProviderProvider.overrideWithValue(recording),
          ],
          child: const LexivoAdBanner(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(LexivoAdBanner.visibleSlotKey), findsNothing);
      expect(recording.bannerBuilds, 0);
    });

    testWidgets('consent blocked → no personalized/load', (tester) async {
      final recording = RecordingAdsProvider();
      await recording.initialize(consent: AdsConsentStatus.required);

      await tester.pumpWidget(
        _host(
          overrides: [
            enableAdsFlagProvider.overrideWithValue(true),
            adsSuppressedProvider.overrideWithValue(false),
            adsConsentStatusProvider
                .overrideWith((ref) => AdsConsentStatus.required),
            adsProviderProvider.overrideWithValue(recording),
          ],
          child: const LexivoAdBanner(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(LexivoAdBanner.visibleSlotKey), findsNothing);
      expect(recording.bannerBuilds, 0);
    });

    testWidgets('ads enabled + consent + free → banner slot', (tester) async {
      final recording = RecordingAdsProvider();
      await recording.initialize(consent: AdsConsentStatus.obtained);

      await tester.pumpWidget(
        _host(
          overrides: [
            enableAdsFlagProvider.overrideWithValue(true),
            adsSuppressedProvider.overrideWithValue(false),
            adsConsentStatusProvider
                .overrideWith((ref) => AdsConsentStatus.obtained),
            adsProviderProvider.overrideWithValue(recording),
          ],
          child: const LexivoAdBanner(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(LexivoAdBanner.visibleSlotKey), findsOneWidget);
      expect(find.byKey(RecordingAdsProvider.bannerKey), findsOneWidget);
      expect(recording.bannerBuilds, 1);
    });
  });

  group('AdsBootstrap', () {
    testWidgets('slot appears once the adapter finishes initializing',
        (tester) async {
      final gate = Completer<void>();
      final recording = _SlowInitAdsProvider(gate.future);

      await tester.pumpWidget(
        _host(
          overrides: [
            enableAdsFlagProvider.overrideWithValue(true),
            adsSuppressedProvider.overrideWithValue(false),
            adsConsentGatewayProvider.overrideWithValue(
              StubAdsConsentGateway(status: AdsConsentStatus.obtained),
            ),
            adsProviderProvider.overrideWithValue(recording),
          ],
          child: const AdsBootstrap(child: LexivoAdBanner()),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byKey(RecordingAdsProvider.bannerKey), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();

      expect(recording.initializeCalls, 1);
      expect(find.byKey(RecordingAdsProvider.bannerKey), findsOneWidget);
    });
  });

  group('unreachable UMP consent', () {
    test('debug build on test ad units renders inventory', () {
      expect(
        resolveUnreachableConsent(debugBuild: true, productionAdUnits: false),
        AdsConsentStatus.notRequired,
      );
    });

    test('production ad units stay blank', () {
      expect(
        resolveUnreachableConsent(debugBuild: true, productionAdUnits: true),
        AdsConsentStatus.unknown,
      );
      expect(
        resolveUnreachableConsent(debugBuild: false, productionAdUnits: false),
        AdsConsentStatus.unknown,
      );
    });
  });

  group('AdMobAdsProvider consent', () {
    test('does not init SDK when consent still required', () async {
      final sdk = RecordingAdMobSdk();
      final ads = AdMobAdsProvider(sdk: sdk);
      await ads.initialize(consent: AdsConsentStatus.required);
      expect(sdk.initializeCalls, 0);
      final banner = ads.banner(placementId: 'x');
      expect(banner, isA<SizedBox>());
    });

    test('blocks personalized inventory when consent denied', () async {
      final sdk = RecordingAdMobSdk();
      final ads = AdMobAdsProvider(sdk: sdk);
      await ads.initialize(consent: AdsConsentStatus.denied);
      expect(sdk.initializeCalls, 1);
      expect(sdk.lastRequestPersonalized, isFalse);
      expect(ads.canRequestPersonalizedAds, isFalse);
      expect(ads.tryRequestPersonalizedInventory(), isFalse);
      expect(ads.blockedPersonalizedLoads, 1);
    });

    test('setAdsSuppressed hides banner', () async {
      final sdk = RecordingAdMobSdk();
      final ads = AdMobAdsProvider(sdk: sdk);
      await ads.initialize(consent: AdsConsentStatus.obtained);
      ads.setAdsSuppressed(true);
      expect(ads.banner(placementId: 'x'), isA<SizedBox>());
    });
  });

  group('document library placement', () {
    testWidgets('flag off keeps library free of ad slot', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final recording = RecordingAdsProvider();
      await recording.initialize(consent: AdsConsentStatus.obtained);
      final repo = FakeDocumentRepository();

      await tester.pumpWidget(
        wrapDocumentScreen(
          const DocumentLibraryScreen(),
          overrides: [
            documentRepositoryProvider.overrideWithValue(repo),
            enableAdsFlagProvider.overrideWithValue(false),
            adsSuppressedProvider.overrideWithValue(false),
            adsConsentStatusProvider
                .overrideWith((ref) => AdsConsentStatus.obtained),
            adsProviderProvider.overrideWithValue(recording),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(LexivoAdBanner.visibleSlotKey), findsNothing);
      expect(recording.bannerBuilds, 0);
    });
  });
}

/// Mimics the real SDK: initialization completes well after consent resolves.
class _SlowInitAdsProvider extends RecordingAdsProvider {
  _SlowInitAdsProvider(this._gate);

  final Future<void> _gate;

  @override
  Future<void> initialize({required AdsConsentStatus consent}) async {
    await _gate;
    await super.initialize(consent: consent);
  }
}

Widget _host({
  required List<Override> overrides,
  required Widget child,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}
