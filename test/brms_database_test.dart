import 'package:brms/data/database/app_database.dart';
import 'package:brms/providers/brms_providers.dart';
import 'package:brms/providers/dashboard_provider.dart';
import 'package:brms/providers/reports_provider.dart';
import 'package:brms/utils/brms_formatters.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('seeds initial fund_sources and PS/MOOE/CO uacs_codes on first launch', () async {
    final funds = await db.watchFundSources().first;
    final uacs = await db.watchUacsCodes().first;

    expect(funds.map((f) => f.fundCode), ['101', '161', '164', '184']);
    final codes = uacs.map((u) => u.accountCode).toSet();
    expect(codes, containsAll(['50101010', '50211990', '50216010']));
    expect(
      uacs.any((u) => u.allotmentClass == 'Capital Outlay'),
      isTrue,
      reason: 'Capital Outlay UACS codes must be seeded for CO obligations',
    );
  });

  test('UACS upsert and safe delete respect foreign key usage', () async {
    await db.upsertUacsCode(
      accountCode: '50604999',
      objectTitle: 'Test Lab Outlay',
      allotmentClass: 'Capital Outlay',
    );
    var uacs = await db.watchUacsCodes().first;
    expect(uacs.any((u) => u.accountCode == '50604999'), isTrue);

    await db.insertObligation(
      const ObligationRegistriesCompanion(
        obrNo: Value('2025-CO-0001'),
        fiscalYear: Value('2025-2026'),
        date: Value('2025-02-10'),
        fundCode: Value('101'),
        accountCode: Value('50604999'),
        allotmentClassification: Value('Capital Outlay'),
        payee: Value('Test Vendor'),
        particular: Value('Lab equipment'),
        grossAmount: Value(50000.0),
      ),
    );

    // Cannot delete while referenced by an OBR.
    expect(await db.deleteUacsCode('50604999'), isFalse);

    // Can delete an unreferenced custom code.
    await db.upsertUacsCode(
      accountCode: '50604998',
      objectTitle: 'Unused Outlay',
      allotmentClass: 'Capital Outlay',
    );
    expect(await db.deleteUacsCode('50604998'), isTrue);
  });

  test(
    'budget_allocations CRUD, modifications, and hide/unhide exclude linked modifications',
    () async {
      final id = await db.insertBudgetAllocation(
        fiscalYear: '2024-2025',
        fundCode: '101',
        mfoProgram: 'MFO 1: Higher Education',
        activityProject: 'BSIT Operations',
        allotmentClass: 'Personal Service',
        accountCode: '50101010',
        beginningBalance: 200000.0,
        amount: 1000000.0,
        dateOfAllocation: '2024-01-03',
      );

      expect(
        await db.computeRemainingBalance(
          fundCode: '101',
          allotmentClass: 'Personal Service',
          fiscalYear: '2024-2025',
        ),
        1200000.0,
      );

      await db.insertBudgetModification(
        allocationId: id,
        fiscalYear: '2024-2025',
        fundCode: '101',
        mfoProgram: 'MFO 1: Higher Education',
        activityProject: 'BSIT Operations',
        allotmentClass: 'Personal Service',
        accountCode: '50101010',
        modificationAmount: -100000.0,
        modificationDate: '2024-04-15',
      );

      expect(
        await db.computeRemainingBalance(
          fundCode: '101',
          allotmentClass: 'Personal Service',
          fiscalYear: '2024-2025',
        ),
        1100000.0,
      );

      // Hiding the allocation also excludes its linked modification.
      await db.setBudgetAllocationHidden(id: id, hidden: true);
      expect(
        await db.computeRemainingBalance(
          fundCode: '101',
          allotmentClass: 'Personal Service',
          fiscalYear: '2024-2025',
        ),
        0.0,
      );

      await db.setBudgetAllocationHidden(id: id, hidden: false);
      expect(
        await db.computeRemainingBalance(
          fundCode: '101',
          allotmentClass: 'Personal Service',
          fiscalYear: '2024-2025',
        ),
        1100000.0,
      );
    },
  );

  test(
    'obligation_registries uniqueness, fiscal year isolation, and delete restore balance',
    () async {
      await db.insertBudgetAllocation(
        fiscalYear: '2024-2025',
        fundCode: '101',
        allotmentClass: 'Maintenance & Other Operating Expenses',
        accountCode: '50216010',
        amount: 500000.0,
        dateOfAllocation: '2024-01-10',
      );
      await db.insertBudgetAllocation(
        fiscalYear: '2025-2026',
        fundCode: '101',
        allotmentClass: 'Maintenance & Other Operating Expenses',
        accountCode: '50216010',
        amount: 300000.0,
        dateOfAllocation: '2025-01-10',
      );

      final obrId = await db.insertObligation(
        const ObligationRegistriesCompanion(
          obrNo: Value('2024-01-0001'),
          fiscalYear: Value('2024-2025'),
          date: Value('2024-02-15'),
          fundCode: Value('101'),
          accountCode: Value('50216010'),
          allotmentClassification: Value(
            'Maintenance & Other Operating Expenses',
          ),
          payee: Value('Juan Dela Cruz'),
          particular: Value('Labor wages for campus grounds'),
          grossAmount: Value(120000.0),
        ),
      );

      expect(await db.isObrNoUnique('2024-01-0001'), isFalse);
      expect(await db.isObrNoUnique('2024-01-0001', excludeId: obrId), isTrue);
      expect(await db.isObrNoUnique('2024-01-0002'), isTrue);

      // 2024-2025 balance is reduced; 2025-2026 balance is untouched.
      expect(
        await db.computeRemainingBalance(
          fundCode: '101',
          allotmentClass: 'Maintenance & Other Operating Expenses',
          fiscalYear: '2024-2025',
        ),
        380000.0,
      );
      expect(
        await db.computeRemainingBalance(
          fundCode: '101',
          allotmentClass: 'Maintenance & Other Operating Expenses',
          fiscalYear: '2025-2026',
        ),
        300000.0,
      );

      expect(
        await db.computeRemainingBalance(
          fundCode: '101',
          allotmentClass: 'Maintenance & Other Operating Expenses',
          fiscalYear: '2024-2025',
          excludeObligationId: obrId,
        ),
        500000.0,
      );

      // Deleting the OBR restores the 2024-2025 balance.
      expect(await db.deleteObligation(obrId), isTrue);
      expect(
        await db.computeRemainingBalance(
          fundCode: '101',
          allotmentClass: 'Maintenance & Other Operating Expenses',
          fiscalYear: '2024-2025',
        ),
        500000.0,
      );
    },
  );

  test(
    'Riverpod centralReportProvider and dashboardSummaryProvider isolate fiscal years accurately',
    () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final reportSub = container.listen(
        centralReportProvider(
          const ReportFilterParams(fiscalYear: '2024-2025'),
        ),
        (_, _) {},
        fireImmediately: true,
      );
      final dashSub = container.listen(
        dashboardSummaryProvider('2024-2025'),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(reportSub.close);
      addTearDown(dashSub.close);

      final allocId = await db.insertBudgetAllocation(
        fiscalYear: '2024-2025',
        fundCode: '101',
        mfoProgram: 'MFO 1: Higher Education',
        activityProject: 'Instruction',
        allotmentClass: 'Maintenance & Other Operating Expenses',
        accountCode: '50216010',
        beginningBalance: 50000.0,
        amount: 200000.0,
        dateOfAllocation: '2024-02-01', // Q1
      );

      await db.insertBudgetModification(
        allocationId: allocId,
        fiscalYear: '2024-2025',
        fundCode: '101',
        mfoProgram: 'MFO 1: Higher Education',
        activityProject: 'Instruction',
        allotmentClass: 'Maintenance & Other Operating Expenses',
        accountCode: '50216010',
        modificationAmount: 50000.0,
        modificationDate: '2024-05-10', // Q2
      );

      await db.insertObligation(
        const ObligationRegistriesCompanion(
          obrNo: Value('2024-07-0001'),
          fiscalYear: Value('2024-2025'),
          date: Value('2024-07-15'), // Q3
          fundCode: Value('101'),
          mfoProgram: Value('MFO 1: Higher Education'),
          activityProject: Value('Instruction'),
          accountCode: Value('50216010'),
          allotmentClassification: Value(
            'Maintenance & Other Operating Expenses',
          ),
          payee: Value('Campus Contractor'),
          particular: Value('Lab maintenance'),
          grossAmount: Value(120000.0),
          disbursementAmount: Value(70000.0),
          dueAndDemandable: Value(30000.0),
        ),
      );

      // Obligation in a different FY must NOT appear in 2024-2025 metrics.
      await db.insertObligation(
        const ObligationRegistriesCompanion(
          obrNo: Value('2025-02-0001'),
          fiscalYear: Value('2025-2026'),
          date: Value('2025-02-15'),
          fundCode: Value('101'),
          mfoProgram: Value('MFO 1: Higher Education'),
          activityProject: Value('Instruction'),
          accountCode: Value('50216010'),
          allotmentClassification: Value(
            'Maintenance & Other Operating Expenses',
          ),
          payee: Value('Next Year Vendor'),
          particular: Value('Next year expense'),
          grossAmount: Value(99999.0),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final bundle = reportSub.read().value!;
      expect(bundle.centralRows.length, 1);
      expect(bundle.totalObrCount, 1);

      final row = bundle.centralRows.first;
      expect(row.beginningBalance, 50000.0);
      expect(row.budgetQ1, 200000.0);
      expect(row.approvedBudget, 250000.0);
      expect(row.modQ2, 50000.0);
      expect(row.totalModification, 50000.0);
      expect(row.adjustedBudget, 300000.0);
      expect(row.utilQ3, 120000.0);
      expect(row.totalUtilization, 120000.0);
      expect(row.disbQ3, 70000.0);
      expect(row.totalDisbursement, 70000.0);
      expect(row.unutilizedBudget, 180000.0);
      expect(row.dueAndDemandable, 30000.0);
      expect(row.nyddo, 20000.0);
      expect(row.totalUnpaidUtilization, 50000.0);

      // Dashboard 2024-2025 should also exclude the 2025-2026 OBR.
      final dash = dashSub.read().value!;
      expect(dash.totalAllotment, 300000.0);
      expect(dash.totalObligated, 120000.0);
      expect(dash.totalObrCount, 1);

      // FAR 2 checks: 6 MFO groups in exact order
      expect(
        bundle.far2Groups.map((g) => g.mfoProgram).toList(),
        BrmsFormatters.mfoPrograms,
      );
      expect(bundle.far2GrandTotal.adjustedBudget, 300000.0);
      expect(bundle.far2GrandTotal.totalUnpaidUtilization, 50000.0);

      // FAR 2-A checks: 3 classes, MOOE has 50216010
      expect(bundle.far2AGroups.length, 3);
      final mooeGroup = bundle.far2AGroups[1];
      expect(mooeGroup.rows.length, 1);
      expect(mooeGroup.rows.first.accountCode, '50216010');
      expect(bundle.far2AGrandTotal.adjustedBudget, 300000.0);
    },
  );

  test('BrmsFormatters formats and parses currency, dates, and dynamic FYs', () {
    expect(BrmsFormatters.formatPhp(15500000), 'Php 15,500,000.00');
    expect(BrmsFormatters.formatNumber(15500000), '15,500,000.00');
    expect(BrmsFormatters.parseAmount('Php 15,500,000.00'), 15500000.0);
    expect(BrmsFormatters.isoToDisplay('2024-01-03'), '01-03-2024');
    expect(BrmsFormatters.quarterOfIso('2024-04-15'), 2);
    expect(BrmsFormatters.mfoPrograms.length, 6);
    expect(
      BrmsFormatters.fiscalYears,
      contains(BrmsFormatters.currentFiscalYear),
    );
    expect(BrmsFormatters.fiscalYearForIsoDate('2026-03-10'), '2026-2027');
  });
}
