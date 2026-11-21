import 'package:brms/data/database/app_database.dart';
import 'package:brms/models/brms_models.dart';
import 'package:brms/providers/brms_providers.dart';
import 'package:brms/screens/far_1a_report_screen.dart';
import 'package:brms/screens/obligation_registry_screen.dart';
import 'package:brms/screens/set_budget_screen.dart';
import 'package:brms/theme/brms_theme.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapScreen(AppDatabase db, Widget child) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: BrmsTheme.light(),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  testWidgets('SetBudgetScreen opens Manage UACS dialog and adds a UACS code', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => tester.runAsync(db.close));

    await tester.pumpWidget(_wrapScreen(db, const SetBudgetScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Manage UACS'), findsOneWidget);
    await tester.tap(find.text('Manage UACS'));
    await tester.pumpAndSettle();

    expect(find.text('Manage UACS Object Codes'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'UACS Code'),
      '50604900',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Object Title'),
      'Marine Research Boat Outlay',
    );
    await tester.tap(find.text('Add UACS'));
    await tester.pumpAndSettle();

    final uacsList = await tester.runAsync(() => db.watchUacsCodes().first);
    expect(
      uacsList!.any(
        (u) =>
            u.accountCode == '50604900' &&
            u.objectTitle == 'Marine Research Boat Outlay',
      ),
      isTrue,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('ObligationRegistryScreen deletes OBR after confirmation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => tester.runAsync(db.close));

    await db.insertObligation(
      const ObligationRegistriesCompanion(
        obrNo: Value('2026-01-0099'),
        fiscalYear: Value('2026-2027'),
        date: Value('2026-01-15'),
        fundCode: Value('101'),
        accountCode: Value('50604050'),
        allotmentClassification: Value('Capital Outlay'),
        payee: Value('Test Equipment Co.'),
        particular: Value('Microscopes for CFMS'),
        grossAmount: Value(150000.0),
      ),
    );

    await tester.pumpWidget(_wrapScreen(db, const ObligationRegistryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('OBR No. 2026-01-0099'), findsOneWidget);

    final deleteBtn = find.text('Delete').first;
    await tester.ensureVisible(deleteBtn);
    await tester.pumpAndSettle();
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    expect(find.text('Delete Obligation Record'), findsOneWidget);
    await tester.tap(find.text('Delete OBR'));
    await tester.pumpAndSettle();

    expect(find.text('OBR No. 2026-01-0099'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('ReportsScreen renders FAR 2 and FAR 2-A with live Drift data', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => tester.runAsync(db.close));

    await db.insertBudgetAllocation(
      fiscalYear: '2026-2027',
      fundCode: '101',
      mfoProgram: 'MFO 1: Higher Education',
      activityProject: 'Instruction',
      allotmentClass: 'Capital Outlay',
      accountCode: '50604050',
      amount: 400000.0,
      dateOfAllocation: '2026-01-20',
    );

    await tester.pumpWidget(
      _wrapScreen(db, const ReportsScreen(reportType: ReportType.far2a)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Financial Accountability Report (FAR 2 - A)'),
      findsOneWidget,
    );
    expect(find.textContaining('50604050'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
