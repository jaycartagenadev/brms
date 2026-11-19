import 'package:brms/data/database/app_database.dart';
import 'package:brms/main.dart';
import 'package:brms/providers/brms_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildSmokeApp(AppDatabase db) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
    ],
    child: const BrmsApp(),
  );
}

void main() {
  testWidgets('BRMS auth gate and desktop shell navigation smoke test', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => tester.runAsync(db.close));

    await tester.pumpWidget(_buildSmokeApp(db));

    // Starts on Offline Authentication Gate.
    expect(find.text('CAGAYAN STATE UNIVERSITY'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Sign in to enter main desktop shell.
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Dashboard is shown initially.
    expect(find.text('Total Budget Allocation'.toUpperCase()), findsOneWidget);
    expect(find.text('Fund Source Allocation vs. Utilization'), findsOneWidget);

    // Navigate to Set Budget.
    await tester.tap(find.text('Set Budget'));
    await tester.pumpAndSettle();
    expect(find.text('Summary of Allocated Budgets'), findsOneWidget);

    // Navigate to Obligation Registry.
    await tester.tap(find.text('Obligation Registry'));
    await tester.pumpAndSettle();
    expect(find.text('OBLIGATION REGISTRIES'), findsOneWidget);

    // Navigate to Reports dropdown and verify options.
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('FAR 2'), findsOneWidget);
    expect(find.text('FAR 2 - A'), findsOneWidget);
    expect(find.text('Registries'), findsOneWidget);
    expect(find.text('Central'), findsOneWidget);

    await tester.tap(find.text('FAR 2 - A'));
    await tester.pumpAndSettle();
    expect(
      find.text('Financial Accountability Report (FAR 2 - A)'),
      findsOneWidget,
    );

    // Navigate to Accounts.
    await tester.tap(find.text('Accounts'));
    await tester.pumpAndSettle();
    expect(find.text('Account & Access Management'), findsOneWidget);

    // Sign out returns to Auth Gate.
    await tester.tap(find.byTooltip('Sign Out'));
    await tester.pumpAndSettle();
    expect(find.text('CAGAYAN STATE UNIVERSITY'), findsOneWidget);

    // Unmount and flush Drift's zero-duration StreamQueryStore cleanup timer.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('BRMS renders without overflow at minimum tablet size (768x600)', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(768, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => tester.runAsync(db.close));

    await tester.pumpWidget(_buildSmokeApp(db));
    expect(find.text('Sign In'), findsOneWidget);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    for (final label in [
      'Dashboard',
      'Set Budget',
      'Obligation Registry',
      'Accounts',
    ]) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('FAR 2'));
    await tester.pumpAndSettle();

    // Unmount and flush Drift's zero-duration StreamQueryStore cleanup timer.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
