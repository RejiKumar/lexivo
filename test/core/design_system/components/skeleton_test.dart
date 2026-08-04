import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/skeleton_loader.dart';

import 'harness.dart';

void main() {
  group('LexivoSkeleton', () {
    testWidgets('line / card / avatar render sized boxes', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const Column(
            children: [
              LexivoSkeleton(variant: LexivoSkeletonVariant.line, animate: false),
              LexivoSkeleton(variant: LexivoSkeletonVariant.card, animate: false),
              LexivoSkeleton(
                variant: LexivoSkeletonVariant.avatar,
                animate: false,
              ),
            ],
          ),
        ),
      );
      expect(find.byType(LexivoSkeleton), findsNWidgets(3));
      final line = tester.getSize(
        find.byWidgetPredicate(
          (w) =>
              w is LexivoSkeleton && w.variant == LexivoSkeletonVariant.line,
        ),
      );
      expect(line.height, 12);
      final avatar = tester.getSize(
        find.byWidgetPredicate(
          (w) =>
              w is LexivoSkeleton && w.variant == LexivoSkeletonVariant.avatar,
        ),
      );
      expect(avatar.width, avatar.height);
    });

    testWidgets('animate true starts shimmer controller', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: const LexivoSkeleton(animate: true),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(LexivoSkeleton), findsOneWidget);
    });
  });
}
