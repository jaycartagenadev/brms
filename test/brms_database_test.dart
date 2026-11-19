import 'package:brms/data/database/app_database.dart';
import 'package:brms/providers/brms_providers.dart';
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

  test('seeds initial fund_sources and uacs_codes on first launch', () async {
    final funds = await db.watchFundSources().first;
    final uacs = await db.watchUacsCodes().first;

    expect(funds.map((f) => f.fundCode), ['101', '161', '164', '184']);
    expect(uacs.map((u) => u.accountCode), ['50101010', '50211990', '50216010']);
  });

  test('budget_allocations CRUD and hide/unhide affect remaining balance', () async {
    final id = await db.insertBudgetAllocation(
      fiscalYear: '2024-2025',
      fundCode: '101',
      allotmentClass: 'Personal Service',
      accountCode: '50101010',
      amount: 1000000.0,
      dateOfAllocation: '2024-01-03',
    );

    expect(
      await db.computeRemainingBalance(
        fundCode: '101',
        allotmentClass: 'Personal Service',
      ),
      1000000.0,
    );

    await db.updateBudgetAllocation(
      id: id,
      fiscalYear: '2024-2025',
      fundCode: '101',
      allotmentClass: 'Personal Service',
      accountCode: '50101010',
      amount: 1500000.0,
      dateOfAllocation: '2024-01-05',
    );

    expect(
      await db.computeRemainingBalance(
        fundCode: '101',
        allotmentClass: 'Personal Service',
      ),
      1500000.0,
    );

    await db.setBudgetAllocationHidden(id: id, hidden: true);
    expect(
      await db.computeRemainingBalance(
        fundCode: '101',
        allotmentClass: 'Personal Service',
      ),
      0.0,
    );

    await db.setBudgetAllocationHidden(id: id, hidden: false);
    expect(
      await db.computeRemainingBalance(
        fundCode: '101',
        allotmentClass: 'Personal Service',
      ),
      1500000.0,
    );
  });

  test('obligation_registries uniqueness and remaining balance calculation', () async {
    await db.insertBudgetAllocation(
      fiscalYear: '2024-2025',
      fundCode: '101',
      allotmentClass: 'Maintenance & Other Operating Expenses',
      accountCode: '50216010',
      amount: 500000.0,
      dateOfAllocation: '2024-01-10',
    );

    final obrId = await db.insertObligation(
      const ObligationRegistriesCompanion(
        obrNo: Value('2024-01-0001'),
        date: Value('2024-02-15'),
        fundCode: Value('101'),
        accountCode: Value('50216010'),
        allotmentClassification: Value('Maintenance & Other Operating Expenses'),
        payee: Value('Juan Dela Cruz'),
        particular: Value('Labor wages for campus grounds'),
        grossAmount: Value(120000.0),
      ),
    );

    expect(await db.isObrNoUnique('2024-01-0001'), isFalse);
    expect(await db.isObrNoUnique('2024-01-0001', excludeId: obrId), isTrue);
    expect(await db.isObrNoUnique('2024-01-0002'), isTrue);

    expect(
      await db.computeRemainingBalance(
        fundCode: '101',
        allotmentClass: 'Maintenance & Other Operating Expenses',
      ),
      380000.0,
    );

    // Excluding the edited obligation restores its amount to available balance
    expect(
      await db.computeRemainingBalance(
        fundCode: '101',
        allotmentClass: 'Maintenance & Other Operating Expenses',
        excludeObligationId: obrId,
      ),
      500000.0,
    );
  });

  test('Riverpod remainingBalanceProvider reacts to DB changes', () async {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);

    const key = BalanceQueryKey(
      fundCode: '164',
      allotmentClass: 'Personal Service',
    );
    final sub = container.listen(
      remainingBalanceProvider(key),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    await db.insertBudgetAllocation(
      fiscalYear: '2024-2025',
      fundCode: '164',
      allotmentClass: 'Personal Service',
      accountCode: '50101010',
      amount: 250000.0,
      dateOfAllocation: '2024-03-01',
    );

    // Allow stream events to propagate
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final balance = sub.read();
    expect(balance.value, 250000.0);
  });

  test('BrmsFormatters formats and parses currency and dates', () {
    expect(BrmsFormatters.formatPhp(15500000), 'Php 15,500,000.00');
    expect(BrmsFormatters.parseAmount('Php 15,500,000.00'), 15500000.0);
    expect(BrmsFormatters.isoToDisplay('2024-01-03'), '01-03-2024');
    expect(BrmsFormatters.quarterOfIso('2024-04-15'), 2);
  });
}
