/// Compile-time / env flags for design-system tooling.
///
/// Enable the catalog with:
/// `flutter run --dart-define=LEXIVO_SHOWCASE=true`
abstract final class LexivoDesignSystemFlags {
  static const bool showcaseEnabled = bool.fromEnvironment(
    'LEXIVO_SHOWCASE',
    defaultValue: false,
  );
}
