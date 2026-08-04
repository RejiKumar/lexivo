import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/design_system/components/error_banner.dart';
import 'package:lexivo/core/design_system/components/skeleton_loader.dart';
import 'package:lexivo/core/theming/app_theme.dart';
import 'package:lexivo/core/widgets/async_value_view.dart';

void main() {
  Widget host(AsyncValue<String> value, {VoidCallback? onRetry}) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: AsyncValueView<String>(
          value: value,
          onRetry: onRetry,
          builder: (context, data) => Text('DATA:$data'),
        ),
      ),
    );
  }

  testWidgets('loading shows LexivoSkeleton', (tester) async {
    await tester.pumpWidget(host(const AsyncValue.loading()));
    expect(find.byType(LexivoSkeleton), findsWidgets);
  });

  testWidgets('error shows LexivoErrorBanner with retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      host(
        AsyncValue.error('boom', StackTrace.empty),
        onRetry: () => retried = true,
      ),
    );
    expect(find.byType(LexivoErrorBanner), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('data builds child', (tester) async {
    await tester.pumpWidget(host(const AsyncValue.data('ok')));
    expect(find.text('DATA:ok'), findsOneWidget);
  });
}
