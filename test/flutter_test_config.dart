import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// Global test config for Lexivo golden tests via Alchemist.
/// Component goldens will live under `test/goldens/` once §3 components land.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: true),
      ciGoldensConfig: CiGoldensConfig(enabled: true),
    ),
    run: testMain,
  );
}
