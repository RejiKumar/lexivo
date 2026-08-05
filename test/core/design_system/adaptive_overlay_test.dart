import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/tokens/breakpoints.dart';
import 'package:lexivo/core/design_system/utils/adaptive_overlay.dart';

void main() {
  testWidgets('mobile width uses sheet path', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var sheet = 0;
    var dialog = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                showLexivoAdaptiveOverlay<void>(
                  context: context,
                  showSheet: () async {
                    sheet++;
                  },
                  showDialog: () async {
                    dialog++;
                  },
                );
              },
              child: const Text('go'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(LexivoBreakpoints.resolve(390), LexivoBreakpoint.mobile);
    expect(sheet, 1);
    expect(dialog, 0);
  });

  testWidgets('desktop width uses dialog path', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var sheet = 0;
    var dialog = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                showLexivoAdaptiveOverlay<void>(
                  context: context,
                  showSheet: () async {
                    sheet++;
                  },
                  showDialog: () async {
                    dialog++;
                  },
                );
              },
              child: const Text('go'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(sheet, 0);
    expect(dialog, 1);
  });
}
