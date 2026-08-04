import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/components/error_banner.dart';
import '../design_system/components/skeleton_loader.dart';
import '../design_system/tokens/spacing.dart';

/// Generic AsyncValue loading/error/data wrapper composing Lexivo* only.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.loading,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) => builder(context, data),
      loading: () =>
          loading ??
          const Padding(
            padding: EdgeInsets.all(LexivoSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LexivoSkeleton(variant: LexivoSkeletonVariant.line, width: 240),
                SizedBox(height: LexivoSpacing.sm),
                LexivoSkeleton(variant: LexivoSkeletonVariant.line, width: 180),
              ],
            ),
          ),
      error: (error, _) => LexivoErrorBanner(
        message: error.toString(),
        onRetry: onRetry,
      ),
    );
  }
}
