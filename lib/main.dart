import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth_gate_screen.dart';
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
  bool _authenticated = false;

  static const double minAppWidth = 768;
  static const double minAppHeight = 600;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSU-Aparri BRMS',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _BrmsScrollBehavior(),
      theme: BrmsTheme.light(),
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
      home: _authenticated
          ? BrmsShell(
              onSignOut: () => setState(() => _authenticated = false),
            )
          : AuthGateScreen(
              onAuthenticated: () => setState(() => _authenticated = true),
            ),
    );
  }
}
