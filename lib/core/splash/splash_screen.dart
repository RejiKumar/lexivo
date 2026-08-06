import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/tokens/color.dart';
import '../design_system/tokens/spacing.dart';
import '../design_system/tokens/typography.dart';
import '../routing/route_guards.dart';

/// Override in widget tests to skip the branded hold.
final splashMinDurationProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 1800),
);

/// Branded animated splash shown once at cold start before auth routing.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, this.minDuration});

  final Duration? minDuration;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _markSlide;
  var _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _markSlide = Tween<double>(begin: 12, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Duration hold =
          widget.minDuration ?? ref.read(splashMinDurationProvider);
      Future<void>.delayed(hold, _tryNavigate);
    });
  }

  void _tryNavigate() {
    if (!mounted || _navigated) return;
    final auth = ref.read(authGuardStateProvider);
    if (auth.isLoading) {
      // Auth session still resolving — wait for the next rebuild.
      return;
    }
    _navigated = true;
    final next =
        auth.isAuthenticated ? RouteGuards.documents : RouteGuards.signIn;
    context.go(next);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthGuardState>(authGuardStateProvider, (_, next) {
      if (!next.isLoading) {
        _tryNavigate();
      }
    });

    final colors = Theme.of(context).extension<LexivoColors>() ??
        LexivoColors.light();

    return Scaffold(
      backgroundColor: colors.brandPrimary,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Opacity(
              opacity: _fade.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, _markSlide.value),
                child: Transform.scale(
                  scale: _scale.value,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: colors.backgroundSurface,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Image.asset(
                            'assets/branding/lexivo_icon.png',
                            fit: BoxFit.contain,
                            // ignore: unnecessary_underscores
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.description_outlined,
                              size: 56,
                              color: colors.brandPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: LexivoSpacing.lg),
                        Text(
                          'Lexivo',
                          style: LexivoTypography.display.copyWith(
                            color: colors.contentOnInverse,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: LexivoSpacing.xs),
                        Text(
                          'Documents into answers',
                          style: LexivoTypography.body.copyWith(
                            color: colors.contentOnInverse.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
