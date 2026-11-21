import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'models/brms_models.dart';
import 'screens/account_management_screen.dart';
import 'screens/auth_gate_screen.dart';
import 'screens/executive_dashboard_screen.dart';
import 'screens/far_1a_report_screen.dart';
import 'screens/obligation_registry_screen.dart';
import 'screens/set_budget_screen.dart';
import 'theme/brms_theme.dart';
import 'widgets/brms_shell.dart';

void main() {
  runApp(const ProviderScope(child: BrmsApp()));
}

class _BrmsScrollBehavior extends MaterialScrollBehavior {
  const _BrmsScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };
}

/// CSU-Aparri Budget Resource Monitoring System (BRMS) Desktop & Web App.
class BrmsApp extends StatefulWidget {
  const BrmsApp({super.key});

  @override
  State<BrmsApp> createState() => _BrmsAppState();
}

class _BrmsAppState extends State<BrmsApp> {
  final ValueNotifier<bool> _authNotifier = ValueNotifier<bool>(false);
  late final GoRouter _router;

  static const double minAppWidth = 768;
  static const double minAppHeight = 600;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/auth',
      refreshListenable: _authNotifier,
      redirect: (context, state) {
        final loggedIn = _authNotifier.value;
        final isAuthRoute = state.matchedLocation == '/auth';
        if (!loggedIn && !isAuthRoute) return '/auth';
        if (loggedIn && isAuthRoute) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(
          path: '/auth',
          pageBuilder: (context, state) => NoTransitionPage(
            child: AuthGateScreen(
              onAuthenticated: () => _authNotifier.value = true,
            ),
          ),
        ),
        ShellRoute(
          builder: (context, state, child) {
            final loc = state.uri.path;
            final activeModule = _moduleForPath(loc);
            final reportType = loc.startsWith('/reports/')
                ? ReportType.fromSlug(loc.split('/').last)
                : ReportType.far2;
            return BrmsShell(
              activeModule: activeModule,
              selectedReportType: reportType,
              onSignOut: () => _authNotifier.value = false,
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) => NoTransitionPage(
                child: ExecutiveDashboardScreen(
                  onNavigate: (module) => context.go(module.routePath),
                ),
              ),
            ),
            GoRoute(
              path: '/budget',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SetBudgetScreen()),
            ),
            GoRoute(
              path: '/obligations',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ObligationRegistryScreen()),
            ),
            GoRoute(
              path: '/reports/:type',
              pageBuilder: (context, state) {
                final type = ReportType.fromSlug(state.pathParameters['type']);
                return NoTransitionPage(
                  child: ReportsScreen(reportType: type),
                );
              },
            ),
            GoRoute(
              path: '/accounts',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AccountManagementScreen()),
            ),
          ],
        ),
      ],
    );
  }

  BrmsModule _moduleForPath(String path) {
    if (path.startsWith('/budget')) return BrmsModule.setBudget;
    if (path.startsWith('/obligations')) return BrmsModule.obligations;
    if (path.startsWith('/reports')) return BrmsModule.reports;
    if (path.startsWith('/accounts')) return BrmsModule.accounts;
    return BrmsModule.dashboard;
  }

  @override
  void dispose() {
    _router.dispose();
    _authNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CSU-Aparri BRMS',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _BrmsScrollBehavior(),
      theme: BrmsTheme.light(),
      routerConfig: _router,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final needsHorizontalScroll = constraints.maxWidth < minAppWidth;
            final needsVerticalScroll = constraints.maxHeight < minAppHeight;
            if (!needsHorizontalScroll && !needsVerticalScroll) {
              return child ?? const SizedBox.shrink();
            }
            final targetWidth = needsHorizontalScroll
                ? minAppWidth
                : constraints.maxWidth;
            final targetHeight = needsVerticalScroll
                ? minAppHeight
                : constraints.maxHeight;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: targetWidth,
                  height: targetHeight,
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
