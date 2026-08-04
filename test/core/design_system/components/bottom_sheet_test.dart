import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/bottom_sheet.dart';
import 'package:lexivo/core/design_system/tokens/color.dart';

import 'harness.dart';

void main() {
  group('LexivoBottomSheet', () {
    testWidgets('generic shows custom content', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoBottomSheet(
            variant: LexivoBottomSheetVariant.generic,
            child: const Text('Generic sheet body'),
          ),
        ),
      );
      expect(find.text('Generic sheet body'), findsOneWidget);
    });

    testWidgets('actionList renders tappable actions with icons', (tester) async {
      var share = 0;
      var delete = 0;
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: LexivoBottomSheet(
            variant: LexivoBottomSheetVariant.actionList,
            actions: [
              LexivoBottomSheetAction(
                label: 'Share',
                icon: Icons.share_outlined,
                onTap: () => share++,
              ),
              LexivoBottomSheetAction(
                label: 'Delete',
                icon: Icons.delete_outline,
                onTap: () => delete++,
                isDestructive: true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);

      await tester.tap(find.text('Share'));
      expect(share, 1);
      await tester.tap(find.text('Delete'));
      expect(delete, 1);
    });

    testWidgets('scrollable wraps long content', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: Builder(
            builder: (context) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: const Size(400, 200),
                ),
                child: LexivoBottomSheet(
                  variant: LexivoBottomSheetVariant.scrollable,
                  child: Column(
                    children: [
                      for (var i = 0; i < 20; i++) Text('Line $i'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Line 0'), findsOneWidget);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      expect(find.text('Line 19'), findsOneWidget);
    });

    testWidgets('show presents modal bottom sheet', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LexivoBottomSheet.show(
                    context,
                    variant: LexivoBottomSheetVariant.generic,
                    child: const Text('Sheet shown'),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Sheet shown'), findsOneWidget);
    });

    testWidgets('show uses tokenized overlayScrim barrier', (tester) async {
      await tester.pumpWidget(
        wrapWithLexivoTheme(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LexivoBottomSheet.show(
                    context,
                    child: const Text('Scrim sheet'),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final modal = tester.widget<ModalBarrier>(
        find.byType(ModalBarrier).last,
      );
      expect(modal.color, LexivoColors.light().overlayScrim);
    });
  });
}
