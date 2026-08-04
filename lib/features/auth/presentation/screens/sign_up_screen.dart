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

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();
  String? _emailError;
  String? _passwordError;
  var _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _displayName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = _email.text.trim().isEmpty ? 'Email is required' : null;
      _passwordError = _password.text.length < 6
          ? 'Password must be at least 6 characters'
          : null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _submitting = true);
    await ref.read(authStateProvider.notifier).signUp(
          email: _email.text.trim(),
          password: _password.text,
          displayName: _displayName.text.trim().isEmpty
              ? null
              : _displayName.text.trim(),
        );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final failure = auth.failure;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LexivoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Lexivo', style: LexivoTypography.display),
              const SizedBox(height: LexivoSpacing.sm),
              Text('Create account', style: LexivoTypography.title),
              const SizedBox(height: LexivoSpacing.lg),
              if (failure != null) ...[
                LexivoErrorBanner(message: failure.message),
                const SizedBox(height: LexivoSpacing.md),
              ],
              LexivoTextField(
                controller: _displayName,
                label: 'Display name',
                hintText: 'Optional',
              ),
              const SizedBox(height: LexivoSpacing.md),
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
                hintText: 'At least 6 characters',
                errorText: _passwordError,
              ),
              const SizedBox(height: LexivoSpacing.lg),
              LexivoButton(
                label: 'Sign up',
                loading: _submitting || auth.isLoading,
                onPressed: _submit,
                fullWidth: true,
              ),
              const SizedBox(height: LexivoSpacing.md),
              LexivoButton(
                label: 'Already have an account',
                variant: LexivoButtonVariant.ghost,
                onPressed: () => context.go(RouteGuards.signIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
