import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brms/main.dart';

void main() {
  testWidgets('BRMS auth gate and desktop shell navigation smoke test', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BrmsApp());

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

    // Navigate to FAR 1-A Reports.
    await tester.tap(find.text('FAR 1-A Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Financial Accountability Report (FAR No. 1-A)'), findsOneWidget);

    // Navigate to Accounts.
    await tester.tap(find.text('Accounts'));
    await tester.pumpAndSettle();
    expect(find.text('Account & Access Management'), findsOneWidget);

    // Sign out returns to Auth Gate.
    await tester.tap(find.byTooltip('Sign Out'));
    await tester.pumpAndSettle();
    expect(find.text('CAGAYAN STATE UNIVERSITY'), findsOneWidget);
  });

  testWidgets('BRMS renders without overflow at minimum tablet size (768x600)', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(768, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BrmsApp());
    expect(find.text('Sign In'), findsOneWidget);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    for (final label in [
      'Dashboard',
      'Set Budget',
      'Obligation Registry',
      'FAR 1-A Reports',
      'Accounts',
    ]) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
  });
}
