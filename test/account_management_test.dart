import 'package:brms/screens/account_management_screen.dart';
import 'package:brms/theme/brms_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestApp() {
  return ProviderScope(
    child: MaterialApp(
      theme: BrmsTheme.light(),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: AccountManagementScreen(),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('AccountManagementScreen pagination, search, and filters work', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Showing 1–5 of 6 accounts'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DataTable),
        matching: find.text('Johnyrey Tumanu'),
      ),
      findsOneWidget,
    );
    expect(find.text('COA Resident Auditor'), findsNothing);

    // Navigate to page 2
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Showing 6–6 of 6 accounts'), findsOneWidget);
    expect(find.text('COA Resident Auditor'), findsOneWidget);

    // Search for a user
    await tester.enterText(find.byType(TextField).first, 'Amanda');
    await tester.pumpAndSettle();

    expect(find.text('Showing 1–1 of 1 accounts'), findsOneWidget);
    expect(find.text('Amanda Perez'), findsOneWidget);

    // Search with no match -> empty state + Clear Filters
    await tester.enterText(find.byType(TextField).first, 'NonExistentUser');
    await tester.pumpAndSettle();

    expect(
      find.text('No accounts match your current search or filter criteria.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Clear Filters'));
    await tester.pumpAndSettle();

    expect(find.text('Showing 1–5 of 6 accounts'), findsOneWidget);
  });

  testWidgets('Add User Account, Edit Permissions, Reset PIN, and Audit Logs work', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(2000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    // 1. Add User Account
    await tester.tap(find.text('Add User Account'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'e.g., Prof. Juan Dela Cruz'),
      'Juan Dela Cruz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'ID-2026-0101'),
      'ID-2026-0777',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '@jdelacruz'),
      'jdelacruz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Accounting & Disbursement Unit'),
      'Budget & Finance Unit',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Accounting Clerk'),
      'Budget Specialist',
    );

    await tester.tap(find.text('Provision Account'));
    await tester.pumpAndSettle();

    expect(find.text('Juan Dela Cruz'), findsOneWidget);
    expect(find.text('Showing 1–5 of 7 accounts'), findsOneWidget);

    // 2. Edit Permissions for first row (Juan Dela Cruz)
    final editPermsFinder = find.byTooltip('Edit Permissions').first;
    await tester.ensureVisible(editPermsFinder);
    await tester.pumpAndSettle();
    await tester.tap(editPermsFinder);
    await tester.pumpAndSettle();

    expect(find.text('Edit Permissions — Juan Dela Cruz'), findsOneWidget);
    await tester.tap(find.text('Save Permissions'));
    await tester.pumpAndSettle();

    expect(find.text('Permissions Updated (ACTIVE)'), findsOneWidget);

    // 3. Reset PIN for first row
    final resetPinFinder = find.byTooltip('Reset PIN').first;
    await tester.ensureVisible(resetPinFinder);
    await tester.pumpAndSettle();
    await tester.tap(resetPinFinder);
    await tester.pumpAndSettle();

    expect(find.text('Reset PIN — Juan Dela Cruz'), findsOneWidget);
    await tester.tap(find.text('Confirm PIN Reset'));
    await tester.pumpAndSettle();

    expect(find.text('PIN Reset Issued'), findsOneWidget);

    // 4. Open Audit Access Logs and verify actions were recorded
    await tester.tap(find.text('Audit Access Logs'));
    await tester.pumpAndSettle();

    expect(find.text('PIN RESET'), findsOneWidget);
    expect(find.text('PERMISSIONS UPDATED'), findsOneWidget);
    expect(find.text('PROVISION ACCOUNT'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // 5. Change Terminal PIN
    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, '••••••'),
      '123456',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter 6 digits'),
      '654321',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Re-enter 6 digits'),
      '654321',
    );
    await tester.tap(find.text('Update PIN'));
    await tester.pumpAndSettle();

    expect(find.text('Terminal PIN updated successfully.'), findsOneWidget);
  });
}
