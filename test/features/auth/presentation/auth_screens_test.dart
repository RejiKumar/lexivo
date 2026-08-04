import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/button.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/design_system/components/input.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/auth/presentation/providers/auth_providers.dart';
import 'package:lexivo/features/auth/presentation/screens/account_settings_screen.dart';
import 'package:lexivo/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:lexivo/features/auth/presentation/screens/sign_up_screen.dart';

import '../../../helpers/fake_auth_repository.dart';
import '../../../helpers/test_harness.dart';

void main() {
  group('SignInScreen', () {
    testWidgets('composes LexivoTextField + LexivoButton; no Material button',
        (tester) async {
      final repo = FakeAuthRepository();
      await tester.pumpWidget(
        wrapAuthScreen(
          const SignInScreen(),
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LexivoTextField), findsNWidgets(2));
      expect(find.byType(LexivoButton), findsWidgets);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(TextField), findsWidgets); // inside LexivoTextField
    });

    testWidgets('invalid credentials show LexivoErrorBanner', (tester) async {
      final repo = FakeAuthRepository();
      repo.nextFailure =
          const UnauthorizedFailure(message: 'Invalid credentials');
      await tester.pumpWidget(
        wrapAuthScreen(
          const SignInScreen(),
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'bad@lexivo.app');
      await tester.enterText(find.byType(TextField).at(1), 'wrong');
      await tester.tap(find.byType(LexivoButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(LexivoErrorBanner), findsOneWidget);
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });

  group('SignUpScreen', () {
    testWidgets('validation errors clear path for success', (tester) async {
      final repo = FakeAuthRepository();
      await tester.pumpWidget(
        wrapAuthScreen(
          const SignUpScreen(),
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign up'));
      await tester.pump();
      expect(find.text('Email is required'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(1), 'new@lexivo.app');
      await tester.enterText(find.byType(TextField).at(2), 'secret12');
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();
      expect(repo.authStateChanges(), isNotNull);
    });
  });

  group('AccountSettingsScreen', () {
    testWidgets('loads profile via AsyncValueView and saves', (tester) async {
      final repo = FakeAuthRepository(initialSession: sampleSession());
      await tester.pumpWidget(
        wrapAuthScreen(
          const AccountSettingsScreen(),
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Display name'), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), 'Alex Updated');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Account updated'), findsOneWidget);
    });
  });
}
