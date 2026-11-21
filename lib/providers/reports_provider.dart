import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../utils/brms_formatters.dart';
import 'brms_providers.dart';

/// Filter parameters shared across Central, Registries, FAR 2, and FAR 2-A.
class ReportFilterParams {
  const ReportFilterParams({
    this.fiscalYear = 'ALL',
    this.fundCode = 'ALL',
    this.maxQuarter = 0, // 0 = Full Year (Q1–Q4), 1..4 = As of Q1..Q4
  });

  final String fiscalYear;
  final String fundCode;
  final int maxQuarter;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportFilterParams &&
          runtimeType == other.runtimeType &&
          fiscalYear == other.fiscalYear &&
          fundCode == other.fundCode &&
          maxQuarter == other.maxQuarter;

  @override
  int get hashCode => Object.hash(fiscalYear, fundCode, maxQuarter);
}

/// Shared 9-column financial metric summary used by FAR 2, FAR 2-A, and totals.
class ReportMetrics {
  const ReportMetrics({
    this.approvedBudget = 0.0,
    this.totalModification = 0.0,
    this.adjustedBudget = 0.0,
    this.totalUtilizations = 0.0,
    this.totalDisbursement = 0.0,
    this.unutilizedBudget = 0.0,
    this.dueAndDemandable = 0.0,
    this.nyddo = 0.0,
    this.totalUnpaidUtilization = 0.0,
  });

  final double approvedBudget;
  final double totalModification;
  final double adjustedBudget;
  final double totalUtilizations;
  final double totalDisbursement;
  final double unutilizedBudget;
  final double dueAndDemandable;
  final double nyddo;
  final double totalUnpaidUtilization;

  ReportMetrics operator +(ReportMetrics other) => ReportMetrics(
        approvedBudget: approvedBudget + other.approvedBudget,
        totalModification: totalModification + other.totalModification,
        adjustedBudget: adjustedBudget + other.adjustedBudget,
        totalUtilizations: totalUtilizations + other.totalUtilizations,
        totalDisbursement: totalDisbursement + other.totalDisbursement,
        unutilizedBudget: unutilizedBudget + other.unutilizedBudget,
        dueAndDemandable: dueAndDemandable + other.dueAndDemandable,
        nyddo: nyddo + other.nyddo,
        totalUnpaidUtilization:
            totalUnpaidUtilization + other.totalUnpaidUtilization,
      );
}

/// Granular 30-column Central report row grouped by
/// `(mfoProgram, activityProject, allotmentClass, accountCode)`.
class CentralReportRow {
  const CentralReportRow({
    required this.mfoProgram,
    required this.activityProject,
    required this.allotmentClass,
    required this.accountCode,
    required this.objectTitle,
    required this.beginningBalance,
    required this.budgetQ1,
    required this.budgetQ2,
    required this.budgetQ3,
    required this.budgetQ4,
    required this.modQ1,
    required this.modQ2,
    required this.modQ3,
    required this.modQ4,
    required this.utilQ1,
    required this.utilQ2,
    required this.utilQ3,
    required this.utilQ4,
    required this.disbQ1,
    required this.disbQ2,
    required this.disbQ3,
    required this.disbQ4,
    required this.dueAndDemandable,
  });

  final String mfoProgram;
  final String activityProject;
  final String allotmentClass;
  final String? accountCode;
  final String objectTitle;

  final double beginningBalance;
  final double budgetQ1;
  final double budgetQ2;
  final double budgetQ3;
  final double budgetQ4;

  final double modQ1;
  final double modQ2;
  final double modQ3;
  final double modQ4;

  final double utilQ1;
  final double utilQ2;
  final double utilQ3;
  final double utilQ4;

  final double disbQ1;
  final double disbQ2;
  final double disbQ3;
  final double disbQ4;

  final double dueAndDemandable;

  String get objectOfExpenditures =>
      accountCode != null && accountCode!.isNotEmpty
          ? '$accountCode - $objectTitle'
          : objectTitle;

  double get currentYearBudget => budgetQ1 + budgetQ2 + budgetQ3 + budgetQ4;
  double get approvedBudget => beginningBalance + currentYearBudget;
  double get totalModification => modQ1 + modQ2 + modQ3 + modQ4;
  double get adjustedBudget => approvedBudget + totalModification;
  double get totalUtilization => utilQ1 + utilQ2 + utilQ3 + utilQ4;
  double get totalDisbursement => disbQ1 + disbQ2 + disbQ3 + disbQ4;
  double get unutilizedBudget => adjustedBudget - totalUtilization;
  double get nyddo => (totalUtilization - totalDisbursement) - dueAndDemandable;
  double get totalUnpaidUtilization => dueAndDemandable + nyddo;

  ReportMetrics toMetrics() => ReportMetrics(
        approvedBudget: approvedBudget,
        totalModification: totalModification,
        adjustedBudget: adjustedBudget,
        totalUtilizations: totalUtilization,
        totalDisbursement: totalDisbursement,
        unutilizedBudget: unutilizedBudget,
        dueAndDemandable: dueAndDemandable,
        nyddo: nyddo,
        totalUnpaidUtilization: totalUnpaidUtilization,
      );
}

class Far2ChildRow {
  const Far2ChildRow({
    required this.label,
    required this.allotmentClass,
    required this.metrics,
  });

  final String label;
  final String allotmentClass;
  final ReportMetrics metrics;
}

class Far2ProgramGroup {
  const Far2ProgramGroup({
    required this.mfoProgram,
    required this.children,
    required this.total,
  });

  final String mfoProgram;
  final List<Far2ChildRow> children;
  final ReportMetrics total;
}

class Far2ARow {
  const Far2ARow({
    required this.particulars,
    required this.accountCode,
    required this.allotmentClass,
    required this.metrics,
  });

  final String particulars;
  final String accountCode;
  final String allotmentClass;
  final ReportMetrics metrics;
}

class Far2AClassGroup {
  const Far2AClassGroup({
    required this.sectionTitle,
    required this.allotmentClass,
    required this.rows,
    required this.subtotal,
  });

  final String sectionTitle;
  final String allotmentClass;
  final List<Far2ARow> rows;
  final ReportMetrics subtotal;
}

/// Complete unified report dataset calculated from one source of truth.
class UnifiedReportBundle {
  const UnifiedReportBundle({
    required this.centralRows,
    required this.centralTotal,
    required this.far2Groups,
    required this.far2GrandTotal,
    required this.far2AGroups,
    required this.far2AGrandTotal,
    required this.totalObrCount,
  });

  final List<CentralReportRow> centralRows;
  final CentralReportRow centralTotal;
  final List<Far2ProgramGroup> far2Groups;
  final ReportMetrics far2GrandTotal;
  final List<Far2AClassGroup> far2AGroups;
  final ReportMetrics far2AGrandTotal;
  final int totalObrCount;
}

class _GroupKey {
  const _GroupKey({
    required this.mfoProgram,
    required this.activityProject,
    required this.allotmentClass,
    required this.accountCode,
  });

  final String mfoProgram;
  final String activityProject;
  final String allotmentClass;
  final String? accountCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GroupKey &&
          runtimeType == other.runtimeType &&
          mfoProgram == other.mfoProgram &&
          activityProject == other.activityProject &&
          allotmentClass == other.allotmentClass &&
          accountCode == other.accountCode;

  @override
  int get hashCode =>
      Object.hash(mfoProgram, activityProject, allotmentClass, accountCode);
}

class _MutableCentralAccumulator {
  _MutableCentralAccumulator({
    required this.key,
    required this.objectTitle,
  });

  final _GroupKey key;
  final String objectTitle;

  double beginningBalance = 0.0;
  double budgetQ1 = 0.0;
  double budgetQ2 = 0.0;
  double budgetQ3 = 0.0;
  double budgetQ4 = 0.0;

  double modQ1 = 0.0;
  double modQ2 = 0.0;
  double modQ3 = 0.0;
  double modQ4 = 0.0;

  double utilQ1 = 0.0;
  double utilQ2 = 0.0;
  double utilQ3 = 0.0;
  double utilQ4 = 0.0;

  double disbQ1 = 0.0;
  double disbQ2 = 0.0;
  double disbQ3 = 0.0;
  double disbQ4 = 0.0;

  double dueAndDemandable = 0.0;

  void addBudget(int quarter, double amount) {
    switch (quarter) {
      case 1:
        budgetQ1 += amount;
      case 2:
        budgetQ2 += amount;
      case 3:
        budgetQ3 += amount;
      case 4:
        budgetQ4 += amount;
    }
  }

  void addMod(int quarter, double amount) {
    switch (quarter) {
      case 1:
        modQ1 += amount;
      case 2:
        modQ2 += amount;
      case 3:
        modQ3 += amount;
      case 4:
        modQ4 += amount;
    }
  }

  void addUtil(int quarter, double amount) {
    switch (quarter) {
      case 1:
        utilQ1 += amount;
      case 2:
        utilQ2 += amount;
      case 3:
        utilQ3 += amount;
      case 4:
        utilQ4 += amount;
    }
  }

  void addDisb(int quarter, double amount) {
    switch (quarter) {
      case 1:
        disbQ1 += amount;
      case 2:
        disbQ2 += amount;
      case 3:
        disbQ3 += amount;
      case 4:
        disbQ4 += amount;
    }
  }

  CentralReportRow build() => CentralReportRow(
        mfoProgram: key.mfoProgram,
        activityProject: key.activityProject,
        allotmentClass: key.allotmentClass,
        accountCode: key.accountCode,
        objectTitle: objectTitle,
        beginningBalance: beginningBalance,
        budgetQ1: budgetQ1,
        budgetQ2: budgetQ2,
        budgetQ3: budgetQ3,
        budgetQ4: budgetQ4,
        modQ1: modQ1,
        modQ2: modQ2,
        modQ3: modQ3,
        modQ4: modQ4,
        utilQ1: utilQ1,
        utilQ2: utilQ2,
        utilQ3: utilQ3,
        utilQ4: utilQ4,
        disbQ1: disbQ1,
        disbQ2: disbQ2,
        disbQ3: disbQ3,
        disbQ4: disbQ4,
        dueAndDemandable: dueAndDemandable,
      );
}

/// Single-source-of-truth Riverpod aggregation engine producing Central (30-col),
/// Registries, FAR 2, and FAR 2-A from live Drift SQLite streams.
final centralReportProvider =
    Provider.family<AsyncValue<UnifiedReportBundle>, ReportFilterParams>(
  (ref, params) {
    final uacsAsync = ref.watch(uacsCodesProvider);
    final allocationsAsync = ref.watch(budgetAllocationsProvider);
    final modificationsAsync = ref.watch(budgetModificationsProvider);
    final obligationsAsync = ref.watch(obligationRegistriesProvider);

    if (uacsAsync.isLoading ||
        allocationsAsync.isLoading ||
        modificationsAsync.isLoading ||
        obligationsAsync.isLoading) {
      return const AsyncValue.loading();
    }
    if (uacsAsync.hasError) {
      return AsyncValue.error(
        uacsAsync.error!,
        uacsAsync.stackTrace ?? StackTrace.current,
      );
    }
    if (allocationsAsync.hasError) {
      return AsyncValue.error(
        allocationsAsync.error!,
        allocationsAsync.stackTrace ?? StackTrace.current,
      );
    }
    if (modificationsAsync.hasError) {
      return AsyncValue.error(
        modificationsAsync.error!,
        modificationsAsync.stackTrace ?? StackTrace.current,
      );
    }
    if (obligationsAsync.hasError) {
      return AsyncValue.error(
        obligationsAsync.error!,
        obligationsAsync.stackTrace ?? StackTrace.current,
      );
    }

    final uacsList = uacsAsync.value ?? const <UacsCode>[];
    final allocations = allocationsAsync.value ?? const <BudgetAllocation>[];
    final modifications =
        modificationsAsync.value ?? const <BudgetModification>[];
    final obligations = obligationsAsync.value ?? const <ObligationRegistry>[];

    final uacsByCode = {for (final u in uacsList) u.accountCode: u};
    final accumulators = <_GroupKey, _MutableCentralAccumulator>{};

    _MutableCentralAccumulator getOrCreate(_GroupKey key) {
      return accumulators.putIfAbsent(key, () {
        final title = key.accountCode != null
            ? (uacsByCode[key.accountCode]?.objectTitle ?? 'Unknown Object')
            : 'Unassigned UACS (${BrmsFormatters.shortAllotmentLabel(key.allotmentClass)})';
        return _MutableCentralAccumulator(key: key, objectTitle: title);
      });
    }

    bool withinQuarter(int q) => params.maxQuarter == 0 || q <= params.maxQuarter;

    final hiddenAllocIds = allocations
        .where((a) => a.isHidden != 0)
        .map((a) => a.id)
        .toSet();

    // 1. Fold active budget_allocations
    for (final a in allocations) {
      if (a.isHidden != 0) continue;
      if (params.fiscalYear != 'ALL' && a.fiscalYear != params.fiscalYear) {
        continue;
      }
      if (params.fundCode != 'ALL' && a.fundCode != params.fundCode) {
        continue;
      }

      final q = BrmsFormatters.quarterOfIso(a.dateOfAllocation) ?? 1;
      final key = _GroupKey(
        mfoProgram: a.mfoProgram,
        activityProject: a.activityProject,
        allotmentClass: a.allotmentClass,
        accountCode: a.accountCode,
      );
      final acc = getOrCreate(key);
      acc.beginningBalance += a.beginningBalance;
      if (withinQuarter(q)) {
        acc.addBudget(q, a.authorizedAppropriations);
        if (a.adjustmentsAllotment != 0) {
          acc.addMod(q, a.adjustmentsAllotment);
        }
      }
    }

    // 2. Fold budget_modifications (excluding modifications tied to hidden allocations)
    for (final m in modifications) {
      if (m.allocationId != null && hiddenAllocIds.contains(m.allocationId)) {
        continue;
      }
      if (params.fiscalYear != 'ALL' && m.fiscalYear != params.fiscalYear) {
        continue;
      }
      if (params.fundCode != 'ALL' && m.fundCode != params.fundCode) {
        continue;
      }
      final q = BrmsFormatters.quarterOfIso(m.modificationDate) ?? 1;
      if (!withinQuarter(q)) continue;

      final key = _GroupKey(
        mfoProgram: m.mfoProgram,
        activityProject: m.activityProject,
        allotmentClass: m.allotmentClass,
        accountCode: m.accountCode,
      );
      final acc = getOrCreate(key);
      acc.addMod(q, m.modificationAmount);
    }

    // 3. Fold obligation_registries
    int matchingObrCount = 0;
    for (final o in obligations) {
      if (params.fiscalYear != 'ALL' && o.fiscalYear != params.fiscalYear) {
        continue;
      }
      if (params.fundCode != 'ALL' && o.fundCode != params.fundCode) {
        continue;
      }
      final q = BrmsFormatters.quarterOfIso(o.date) ?? 1;
      if (!withinQuarter(q)) continue;

      matchingObrCount++;
      final key = _GroupKey(
        mfoProgram: o.mfoProgram,
        activityProject: o.activityProject,
        allotmentClass: o.allotmentClassification,
        accountCode: o.accountCode,
      );
      final acc = getOrCreate(key);
      acc.addUtil(q, o.grossAmount);
      acc.addDisb(q, o.disbursementAmount);
      acc.dueAndDemandable += o.dueAndDemandable;
    }

    // 4. Sort Central rows by MFO reporting order -> activity -> class -> account
    final mfoRank = {
      for (int i = 0; i < BrmsFormatters.mfoPrograms.length; i++)
        BrmsFormatters.mfoPrograms[i]: i,
    };
    final classRank = {
      for (int i = 0; i < BrmsFormatters.allotmentClasses.length; i++)
        BrmsFormatters.allotmentClasses[i]: i,
    };

    final centralRows = accumulators.values.map((e) => e.build()).toList()
      ..sort((a, b) {
        final mfoCmp =
            (mfoRank[a.mfoProgram] ?? 99).compareTo(mfoRank[b.mfoProgram] ?? 99);
        if (mfoCmp != 0) return mfoCmp;
        final actCmp = a.activityProject.compareTo(b.activityProject);
        if (actCmp != 0) return actCmp;
        final clsCmp = (classRank[a.allotmentClass] ?? 99)
            .compareTo(classRank[b.allotmentClass] ?? 99);
        if (clsCmp != 0) return clsCmp;
        return (a.accountCode ?? '').compareTo(b.accountCode ?? '');
      });

    final centralTotal = sumCentralRows(centralRows);

    // 5. Derive FAR 2 (Hierarchical 6 MFOs)
    final far2Groups = BrmsFormatters.mfoPrograms.map((mfo) {
      final mfoRows = centralRows.where((r) => r.mfoProgram == mfo).toList();

      ReportMetrics sumForClass(String cls) {
        return mfoRows
            .where((r) => r.allotmentClass == cls)
            .fold<ReportMetrics>(
              const ReportMetrics(),
              (sum, r) => sum + r.toMetrics(),
            );
      }

      final psMetrics = sumForClass('Personal Service');
      final mooeMetrics = sumForClass('Maintenance & Other Operating Expenses');
      final coMetrics = sumForClass('Capital Outlay');

      final hasPs = mfoRows.any((r) => r.allotmentClass == 'Personal Service');
      final children = <Far2ChildRow>[
        if (hasPs)
          Far2ChildRow(
            label: '50100000-00 Personal Services',
            allotmentClass: 'Personal Service',
            metrics: psMetrics,
          ),
        Far2ChildRow(
          label: '50200000-00 Maintenance and Other Operating Expenses',
          allotmentClass: 'Maintenance & Other Operating Expenses',
          metrics: mooeMetrics,
        ),
        Far2ChildRow(
          label: '50600000-00 Capital Outlay',
          allotmentClass: 'Capital Outlay',
          metrics: coMetrics,
        ),
      ];

      final mfoTotal = children.fold<ReportMetrics>(
        const ReportMetrics(),
        (sum, c) => sum + c.metrics,
      );

      return Far2ProgramGroup(
        mfoProgram: mfo,
        children: children,
        total: mfoTotal,
      );
    }).toList();

    final far2GrandTotal = far2Groups.fold<ReportMetrics>(
      const ReportMetrics(),
      (sum, g) => sum + g.total,
    );

    // 6. Derive FAR 2-A (By Object of Expenditures)
    const sectionSpecs = [
      (
        sectionTitle: 'I. Personal Services',
        allotmentClass: 'Personal Service',
      ),
      (
        sectionTitle: 'II. Maintenance and Other Operating Expenses',
        allotmentClass: 'Maintenance & Other Operating Expenses',
      ),
      (
        sectionTitle: 'III. Capital Outlay',
        allotmentClass: 'Capital Outlay',
      ),
    ];

    final far2AGroups = sectionSpecs.map((spec) {
      final clsRows = centralRows
          .where((r) => r.allotmentClass == spec.allotmentClass)
          .toList();

      final groupedByObject = <String, ({String title, ReportMetrics metrics})>{};
      for (final r in clsRows) {
        final code = r.accountCode ?? 'UNASSIGNED';
        final existing = groupedByObject[code];
        if (existing == null) {
          groupedByObject[code] = (
            title: r.objectOfExpenditures,
            metrics: r.toMetrics(),
          );
        } else {
          groupedByObject[code] = (
            title: existing.title,
            metrics: existing.metrics + r.toMetrics(),
          );
        }
      }

      final sortedCodes = groupedByObject.keys.toList()..sort();
      final rows = sortedCodes.map((code) {
        final entry = groupedByObject[code]!;
        return Far2ARow(
          particulars: entry.title,
          accountCode: code,
          allotmentClass: spec.allotmentClass,
          metrics: entry.metrics,
        );
      }).toList();

      final subtotal = rows.fold<ReportMetrics>(
        const ReportMetrics(),
        (sum, r) => sum + r.metrics,
      );

      return Far2AClassGroup(
        sectionTitle: spec.sectionTitle,
        allotmentClass: spec.allotmentClass,
        rows: rows,
        subtotal: subtotal,
      );
    }).toList();

    final far2AGrandTotal = far2AGroups.fold<ReportMetrics>(
      const ReportMetrics(),
      (sum, g) => sum + g.subtotal,
    );

    return AsyncValue.data(
      UnifiedReportBundle(
        centralRows: centralRows,
        centralTotal: centralTotal,
        far2Groups: far2Groups,
        far2GrandTotal: far2GrandTotal,
        far2AGroups: far2AGroups,
        far2AGrandTotal: far2AGrandTotal,
        totalObrCount: matchingObrCount,
      ),
    );
  },
);

/// Sums a list of [CentralReportRow]s into a Grand Total row.
CentralReportRow sumCentralRows(List<CentralReportRow> rows) {
  double beginningBalance = 0;
  double budgetQ1 = 0, budgetQ2 = 0, budgetQ3 = 0, budgetQ4 = 0;
  double modQ1 = 0, modQ2 = 0, modQ3 = 0, modQ4 = 0;
  double utilQ1 = 0, utilQ2 = 0, utilQ3 = 0, utilQ4 = 0;
  double disbQ1 = 0, disbQ2 = 0, disbQ3 = 0, disbQ4 = 0;
  double dueAndDemandable = 0;

  for (final r in rows) {
    beginningBalance += r.beginningBalance;
    budgetQ1 += r.budgetQ1;
    budgetQ2 += r.budgetQ2;
    budgetQ3 += r.budgetQ3;
    budgetQ4 += r.budgetQ4;
    modQ1 += r.modQ1;
    modQ2 += r.modQ2;
    modQ3 += r.modQ3;
    modQ4 += r.modQ4;
    utilQ1 += r.utilQ1;
    utilQ2 += r.utilQ2;
    utilQ3 += r.utilQ3;
    utilQ4 += r.utilQ4;
    disbQ1 += r.disbQ1;
    disbQ2 += r.disbQ2;
    disbQ3 += r.disbQ3;
    disbQ4 += r.disbQ4;
    dueAndDemandable += r.dueAndDemandable;
  }

  return CentralReportRow(
    mfoProgram: 'GRAND TOTAL',
    activityProject: '',
    allotmentClass: '',
    accountCode: null,
    objectTitle: '',
    beginningBalance: beginningBalance,
    budgetQ1: budgetQ1,
    budgetQ2: budgetQ2,
    budgetQ3: budgetQ3,
    budgetQ4: budgetQ4,
    modQ1: modQ1,
    modQ2: modQ2,
    modQ3: modQ3,
    modQ4: modQ4,
    utilQ1: utilQ1,
    utilQ2: utilQ2,
    utilQ3: utilQ3,
    utilQ4: utilQ4,
    disbQ1: disbQ1,
    disbQ2: disbQ2,
    disbQ3: disbQ3,
    disbQ4: disbQ4,
    dueAndDemandable: dueAndDemandable,
  );
}

/// Persists the expanded/collapsed MFO state for FAR 2 across page
/// navigations, defaulting to all collapsed on initial app launch.
class Far2ExpandedMfosNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  void toggle(String mfoProgram) {
    final next = Set<String>.from(state);
    if (next.contains(mfoProgram)) {
      next.remove(mfoProgram);
    } else {
      next.add(mfoProgram);
    }
    state = next;
  }

  void expandAll() {
    state = Set<String>.from(BrmsFormatters.mfoPrograms);
  }

  void collapseAll() {
    state = const <String>{};
  }
}

final far2ExpandedMfosProvider =
    NotifierProvider<Far2ExpandedMfosNotifier, Set<String>>(
  Far2ExpandedMfosNotifier.new,
);
