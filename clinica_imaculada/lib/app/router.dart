import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/session.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/setup_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/shell/placeholder_page.dart';
import 'providers.dart';
import 'sections.dart';

/// Primeira secção a que um perfil tem acesso (destino após iniciar sessão).
String firstAllowedPath(AppSession session) {
  for (final r in kSectionRoutes) {
    if (session.can(r.section)) return r.path;
  }
  return '/pacientes';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final hasUsers = ref.read(hasUsersProvider);
      final session = ref.read(sessionProvider);
      final loc = state.matchedLocation;

      if (!hasUsers) {
        return loc == '/setup' ? null : '/setup';
      }
      if (session == null) {
        return loc == '/login' ? null : '/login';
      }
      // Sessão iniciada: sair dos ecrãs de entrada.
      if (loc == '/login' || loc == '/setup' || loc == '/') {
        return firstAllowedPath(session);
      }
      // Impede aceder a secções fora do perfil.
      final sectionRoute = sectionRouteForPath(loc);
      if (sectionRoute != null && !session.can(sectionRoute.section)) {
        return firstAllowedPath(session);
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, _) => null),
      GoRoute(path: '/setup', builder: (_, _) => const SetupScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          for (final r in kSectionRoutes)
            GoRoute(
              path: r.path,
              builder: (_, _) => PlaceholderPage(title: r.label, icon: r.icon),
            ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

/// Faz o `GoRouter` reavaliar o `redirect` quando a sessão ou a existência de
/// utilizadores muda.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(sessionProvider, (_, _) => notifyListeners());
    ref.listen(hasUsersProvider, (_, _) => notifyListeners());
  }
}
