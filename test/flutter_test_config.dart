import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global test config for Lexivo golden tests via Alchemist.
/// Component goldens will live under `test/goldens/` once §3 components land.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Keep typography unit/theme tests offline and deterministic.
  GoogleFonts.config.allowRuntimeFetching = false;

  await AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: true),
      ciGoldensConfig: CiGoldensConfig(enabled: true),
    ),
    run: testMain,
  );
}
