/// Auth feature public surface — the ONLY import allowed outside this feature.
library;

export 'domain/entities/auth_entities.dart';
export 'presentation/providers/auth_providers.dart'
    show
        AuthState,
        AuthNotifier,
        authStateProvider,
        authAccessTokenProvider,
        authGuardBridgeProvider,
        authScreenBuildersBridgeProvider,
        authCoreOverrides,
        accountProfileProvider,
        authRepositoryProvider;
export 'presentation/screens/account_settings_screen.dart';
export 'presentation/screens/auth_home_shell.dart';
export 'presentation/screens/sign_in_screen.dart';
export 'presentation/screens/sign_up_screen.dart';
