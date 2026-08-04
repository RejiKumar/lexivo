import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/components/button.dart';
import '../../../../core/design_system/components/error_banner.dart';
import '../../../../core/design_system/components/input.dart';
import '../../../../core/design_system/tokens/spacing.dart';
import '../../../../core/design_system/tokens/typography.dart';
import '../../../../core/routing/route_guards.dart';
import '../providers/auth_providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;
  var _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = _email.text.trim().isEmpty ? 'Email is required' : null;
      _passwordError =
          _password.text.isEmpty ? 'Password is required' : null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _submitting = true);
    await ref.read(authStateProvider.notifier).signIn(
          email: _email.text.trim(),
          password: _password.text,
        );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final failure = auth.failure;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LexivoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Lexivo', style: LexivoTypography.display),
              const SizedBox(height: LexivoSpacing.sm),
              Text('Sign in', style: LexivoTypography.title),
              const SizedBox(height: LexivoSpacing.lg),
              if (failure != null) ...[
                LexivoErrorBanner(message: failure.message),
                const SizedBox(height: LexivoSpacing.md),
              ],
              LexivoTextField(
                controller: _email,
                label: 'Email',
                hintText: 'you@lexivo.app',
                errorText: _emailError,
              ),
              const SizedBox(height: LexivoSpacing.md),
              LexivoTextField(
                controller: _password,
                variant: LexivoTextFieldVariant.password,
                label: 'Password',
                hintText: 'Your password',
                errorText: _passwordError,
              ),
              const SizedBox(height: LexivoSpacing.lg),
              LexivoButton(
                label: 'Sign in',
                loading: _submitting || auth.isLoading,
                onPressed: _submit,
                fullWidth: true,
              ),
              const SizedBox(height: LexivoSpacing.md),
              LexivoButton(
                label: 'Create an account',
                variant: LexivoButtonVariant.ghost,
                onPressed: () => context.go(RouteGuards.signUp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
