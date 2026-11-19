import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Statutory and campus fund sources (101, 161, 164, 184).
class FundSources extends Table {
  TextColumn get fundCode => text()();
  TextColumn get fundName => text()();
  TextColumn get fundingSourceHeader => text()();

  @override
  Set<Column<Object>> get primaryKey => {fundCode};
}

/// Unified Accounts Code Structure (UACS) object codes.
class UacsCodes extends Table {
  TextColumn get accountCode => text()();
  TextColumn get objectTitle => text()();
  TextColumn get allotmentClass => text()();

  @override
  Set<Column<Object>> get primaryKey => {accountCode};
}

/// Budget allocations per fiscal year, fund source, and allotment class.
class BudgetAllocations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fiscalYear => text()();
  TextColumn get fundCode => text().references(FundSources, #fundCode)();
  TextColumn get allotmentClass => text()();
  TextColumn get accountCode =>
      text().nullable().references(UacsCodes, #accountCode)();
  RealColumn get authorizedAppropriations =>
      real().withDefault(const Constant(0.0))();
  RealColumn get adjustmentsAppropriations =>
      real().withDefault(const Constant(0.0))();
  RealColumn get allotmentReceived =>
      real().withDefault(const Constant(0.0))();
  RealColumn get adjustmentsAllotment =>
      real().withDefault(const Constant(0.0))();
  TextColumn get dateOfAllocation => text()();
  IntColumn get isHidden => integer().withDefault(const Constant(0))();
}

/// Obligation Request (OBR) ledger records.
class ObligationRegistries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get obrNo => text().unique()();
  TextColumn get date => text()();
  TextColumn get fundCode => text().references(FundSources, #fundCode)();
  TextColumn get accountCode => text().references(UacsCodes, #accountCode)();
  TextColumn get allotmentClassification => text()();
  TextColumn get payee => text()();
  TextColumn get particular => text()();
  TextColumn get description => text().nullable()();
  RealColumn get grossAmount => real()();
  RealColumn get disbursementAmount =>
      real().withDefault(const Constant(0.0))();
  TextColumn get attachmentFilename => text().nullable()();
  TextColumn get attachmentLocalPath => text().nullable()();
}

@DriftDatabase(
  tables: [FundSources, UacsCodes, BudgetAllocations, ObligationRegistries],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the local SQLite database inside the user's application documents
  /// directory (`brms_database.sqlite`).
  factory AppDatabase.open() => AppDatabase(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedInitialData();
        },
        onUpgrade: (m, from, to) async {
          await m.createAll();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _seedInitialData() async {
    await batch((b) {
      b.insertAll(
        fundSources,
        const [
          FundSourcesCompanion(
            fundCode: Value('101'),
            fundName: Value('Regular Agency Fund'),
            fundingSourceHeader: Value('NEW GENERAL APPROPRIATIONS'),
          ),
          FundSourcesCompanion(
            fundCode: Value('161'),
            fundName: Value('Income-Generating Projects'),
            fundingSourceHeader: Value('INCOME GENERATING PROJECTS'),
          ),
          FundSourcesCompanion(
            fundCode: Value('164'),
            fundName: Value('Internally Generated Fund'),
            fundingSourceHeader: Value('INTERNALLY GENERATED FUND'),
          ),
          FundSourcesCompanion(
            fundCode: Value('184'),
            fundName: Value('Research and Mangrove Projects'),
            fundingSourceHeader: Value('RESEARCH AND MANGROVE PROJECTS'),
          ),
        ],
        mode: InsertMode.insertOrIgnore,
      );

      b.insertAll(
        uacsCodes,
        const [
          UacsCodesCompanion(
            accountCode: Value('50101010'),
            objectTitle: Value('Basic Salary - Civilian'),
            allotmentClass: Value('Personal Service'),
          ),
          UacsCodesCompanion(
            accountCode: Value('50216010'),
            objectTitle: Value('Labor and wages'),
            allotmentClass: Value('Maintenance & Other Operating Expenses'),
          ),
          UacsCodesCompanion(
            accountCode: Value('50211990'),
            objectTitle: Value('Other Professional Services'),
            allotmentClass: Value('Maintenance & Other Operating Expenses'),
          ),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Reference Lookups
  // ---------------------------------------------------------------------------

  Stream<List<FundSource>> watchFundSources() {
    return (select(fundSources)
          ..orderBy([(t) => OrderingTerm.asc(t.fundCode)]))
        .watch();
  }

  Stream<List<UacsCode>> watchUacsCodes() {
    return (select(uacsCodes)
          ..orderBy([(t) => OrderingTerm.asc(t.accountCode)]))
        .watch();
  }

  // ---------------------------------------------------------------------------
  // Budget Allocations (Set Budget)
  // ---------------------------------------------------------------------------

  Stream<List<BudgetAllocation>> watchBudgetAllocations() {
    return (select(budgetAllocations)
          ..orderBy([
            (t) => OrderingTerm.desc(t.dateOfAllocation),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch();
  }

  Future<int> insertBudgetAllocation({
    required String fiscalYear,
    required String fundCode,
    required String allotmentClass,
    String? accountCode,
    required double amount,
    required String dateOfAllocation,
  }) {
    return into(budgetAllocations).insert(
      BudgetAllocationsCompanion.insert(
        fiscalYear: fiscalYear,
        fundCode: fundCode,
        allotmentClass: allotmentClass,
        accountCode: Value(accountCode),
        authorizedAppropriations: Value(amount),
        allotmentReceived: Value(amount),
        dateOfAllocation: dateOfAllocation,
      ),
    );
  }

  Future<bool> updateBudgetAllocation({
    required int id,
    required String fiscalYear,
    required String fundCode,
    required String allotmentClass,
    String? accountCode,
    required double amount,
    required String dateOfAllocation,
  }) async {
    final rows = await (update(budgetAllocations)
          ..where((t) => t.id.equals(id)))
        .write(
      BudgetAllocationsCompanion(
        fiscalYear: Value(fiscalYear),
        fundCode: Value(fundCode),
        allotmentClass: Value(allotmentClass),
        accountCode: Value(accountCode),
        authorizedAppropriations: Value(amount),
        allotmentReceived: Value(amount),
        dateOfAllocation: Value(dateOfAllocation),
      ),
    );
    return rows > 0;
  }

  Future<void> setBudgetAllocationHidden({
    required int id,
    required bool hidden,
  }) async {
    await (update(budgetAllocations)..where((t) => t.id.equals(id))).write(
      BudgetAllocationsCompanion(isHidden: Value(hidden ? 1 : 0)),
    );
  }

  // ---------------------------------------------------------------------------
  // Obligation Registries
  // ---------------------------------------------------------------------------

  Stream<List<ObligationRegistry>> watchObligationRegistries() {
    return (select(obligationRegistries)
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.obrNo),
          ]))
        .watch();
  }

  Stream<ObligationRegistry?> watchObligationById(int id) {
    return (select(obligationRegistries)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<bool> isObrNoUnique(String obrNo, {int? excludeId}) async {
    final query = select(obligationRegistries)
      ..where((t) => t.obrNo.equals(obrNo));
    if (excludeId != null) {
      query.where((t) => t.id.equals(excludeId).not());
    }
    final existing = await query.getSingleOrNull();
    return existing == null;
  }

  Future<int> insertObligation(ObligationRegistriesCompanion entry) {
    return into(obligationRegistries).insert(entry);
  }

  Future<bool> updateObligation(
    int id,
    ObligationRegistriesCompanion entry,
  ) async {
    final rows = await (update(obligationRegistries)
          ..where((t) => t.id.equals(id)))
        .write(entry);
    return rows > 0;
  }

  Stream<List<String>> watchDistinctPayees() {
    final query = selectOnly(obligationRegistries, distinct: true)
      ..addColumns([obligationRegistries.payee])
      ..orderBy([OrderingTerm.asc(obligationRegistries.payee)]);
    return query.watch().map(
          (rows) => rows
              .map((r) => r.read(obligationRegistries.payee))
              .whereType<String>()
              .where((s) => s.trim().isNotEmpty)
              .toList(),
        );
  }

  Stream<List<String>> watchDistinctParticulars() {
    final query = selectOnly(obligationRegistries, distinct: true)
      ..addColumns([obligationRegistries.particular])
      ..orderBy([OrderingTerm.asc(obligationRegistries.particular)]);
    return query.watch().map(
          (rows) => rows
              .map((r) => r.read(obligationRegistries.particular))
              .whereType<String>()
              .where((s) => s.trim().isNotEmpty)
              .toList(),
        );
  }

  /// Computes remaining available balance for a [fundCode] and [allotmentClass]:
  /// `sum(allotment_received + adjustments_allotment)` (where `is_hidden = 0`)
  /// minus `sum(gross_amount)` (excluding [excludeObligationId] if editing).
  Future<double> computeRemainingBalance({
    required String fundCode,
    required String allotmentClass,
    int? excludeObligationId,
  }) async {
    final allocations = await (select(budgetAllocations)
          ..where(
            (t) =>
                t.fundCode.equals(fundCode) &
                t.allotmentClass.equals(allotmentClass) &
                t.isHidden.equals(0),
          ))
        .get();

    final totalAllotment = allocations.fold<double>(
      0.0,
      (sum, row) => sum + row.allotmentReceived + row.adjustmentsAllotment,
    );

    final obligationsQuery = select(obligationRegistries)
      ..where(
        (t) =>
            t.fundCode.equals(fundCode) &
            t.allotmentClassification.equals(allotmentClass),
      );
    if (excludeObligationId != null) {
      obligationsQuery.where((t) => t.id.equals(excludeObligationId).not());
    }
    final obligations = await obligationsQuery.get();

    final totalObligated = obligations.fold<double>(
      0.0,
      (sum, row) => sum + row.grossAmount,
    );

    return totalAllotment - totalObligated;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(docsDir.path, 'brms_database.sqlite'));
    return NativeDatabase.createInBackground(dbFile);
  });
}
