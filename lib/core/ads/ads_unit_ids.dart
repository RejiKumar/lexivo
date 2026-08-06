import 'package:lexivo/core/config/app_config.dart';

/// Google sample / production ad unit IDs.
///
/// Outside production ([AppConfig.adsUseProductionIds] false), always use
/// [Google test units](https://developers.google.com/admob/android/test-ads).
abstract final class AdsUnitIds {
  /// Google sample App ID (Android / iOS manifests).
  static const String testAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String testAppIdIos = 'ca-app-pub-3940256099942544~1458002511';

  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testMediumRectangle =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testNative = 'ca-app-pub-3940256099942544/2247696110';
  static const String _testAppOpen = 'ca-app-pub-3940256099942544/3419835294';

  // Production placeholders — replace before enabling ADS_USE_PRODUCTION_IDS.
  static const String _prodBanner = _testBanner;
  static const String _prodMediumRectangle = _testMediumRectangle;
  static const String _prodInterstitial = _testInterstitial;
  static const String _prodRewarded = _testRewarded;
  static const String _prodNative = _testNative;
  static const String _prodAppOpen = _testAppOpen;

  static bool get _useProd => AppConfig.adsUseProductionIds;

  static String get banner => _useProd ? _prodBanner : _testBanner;
  static String get mediumRectangle =>
      _useProd ? _prodMediumRectangle : _testMediumRectangle;
  static String get interstitial =>
      _useProd ? _prodInterstitial : _testInterstitial;
  static String get rewarded => _useProd ? _prodRewarded : _testRewarded;
  static String get native => _useProd ? _prodNative : _testNative;
  static String get appOpen => _useProd ? _prodAppOpen : _testAppOpen;
}
