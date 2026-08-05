# Localization (`core/l10n`)

Flutter gen-l10n / ARB is the only localization path. Default locale: **en**.

## Add a key

1. Add the message to `arb/app_en.arb` (template). Include `@key` metadata when useful.
2. Run `flutter gen-l10n` (or any `flutter pub get` / build — `generate: true` in `pubspec.yaml`).
3. Use `AppLocalizations.of(context).yourKey` in features. Pass strings into design-system components as props — do not hardcode copy inside DS atoms.

Generated code lands in `generated/` — do not edit it by hand.

## Wire-up

`LexivoRouterApp` and `LexivoApp` set `localizationsDelegates` and `supportedLocales` from `AppLocalizations`.
