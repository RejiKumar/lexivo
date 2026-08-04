import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/features/auth/auth.dart';

/// Smoke: barrel exposes intended public symbols.
void main() {
  test('barrel exports session provider and screens', () {
    expect(authStateProvider, isNotNull);
    expect(SignInScreen, isNotNull);
    expect(SignUpScreen, isNotNull);
    expect(AccountSettingsScreen, isNotNull);
    expect(AuthHomeShell, isNotNull);
    expect(authCoreOverrides(), isNotEmpty);
  });
}
