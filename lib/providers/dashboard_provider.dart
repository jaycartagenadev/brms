import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../models/brms_models.dart';
import '../utils/brms_formatters.dart';
import 'brms_providers.dart';

class DashboardFundClusterData {
  const DashboardFundClusterData({
    required this.code,
    required this.name,
    required this.tag,
    required this.subtitle,
    required this.allotment,
    required this.obligated,
    required this.unobligated,
    required this.percent,
  });

  final String code;
  final String name;
  final String tag;
  final String subtitle;
  final double allotment;
  final double obligated;
  final double unobligated;
  final double percent;
}

class DashboardExpenseClassData {
  const DashboardExpenseClassData({
    required this.code,
    required this.title,
    required this.allotment,
    required this.obligated,
    required this.unobligated,
    required this.ratio,
    required this.sharePercent,
  });

  final String code;
  final String title;
  final double allotment;
  final double obligated;
  final double unobligated;
  final double ratio;
  final int sharePercent;
}

class DashboardQuarterData {
  const DashboardQuarterData({
    required this.label,
    required this.obligatedMillions,
    required this.disbursedMillions,
  });

  final String label;
  final double obligatedMillions;
  final double disbursedMillions;
}

class DashboardPayeeAbsorptionData {
  const DashboardPayeeAbsorptionData({
    required this.name,
    required this.spent,
    required this.ratio,
  });

  final String name;
  final double spent;
  final double ratio;
}

class DashboardObrItem {
  const DashboardObrItem({
    required this.id,
    required this.obrNo,
    required this.dateRecorded,
    required this.fundCode,
    required this.accountCode,
    required this.uacsDescription,
    required this.payee,
    required this.particulars,
    required this.grossAmount,
    required this.status,
  });

  final int id;
  final String obrNo;
  final String dateRecorded;
  final String fundCode;
  final String accountCode;
  final String uacsDescription;
  final String payee;
  final String particulars;
  final double grossAmount;
  final String status;
}

class DashboardSummaryData {
  const DashboardSummaryData({
    required this.totalAllotment,
    required this.totalObligated,
    required this.totalDisbursed,
    required this.activeAllocationsCount,
    required this.hiddenAllocationsCount,
    required this.totalObrCount,
    required this.fundClusters,
    required this.expenseClasses,
    required this.quarterlyBurn,
    required this.payeeUnits,
    required this.allObrItems,
  });

  final double totalAllotment;
  final double totalObligated;
  final double totalDisbursed;
  final int activeAllocationsCount;
  final int hiddenAllocationsCount;
  final int totalObrCount;
  final List<DashboardFundClusterData> fundClusters;
  final List<DashboardExpenseClassData> expenseClasses;
  final List<QuarterlyBurnPoint> quarterlyBurn;
  final List<DashboardPayeeAbsorptionData> payeeUnits;
  final List<DashboardObrItem> allObrItems;

  double get totalUnobligated => totalAllotment - totalObligated;
  double get utilizationRatio =>
      totalAllotment > 0 ? (totalObligated / totalAllotment).clamp(0.0, 1.0) : 0.0;
  double get remainingRatio =>
      totalAllotment > 0 ? (totalUnobligated / totalAllotment).clamp(0.0, 1.0) : 0.0;
}

/// Derives all Executive Dashboard metrics reactively from Drift SQLite streams,
/// optionally filtered by fiscal year (`'ALL'` or e.g. `'2024-2025'`).
final dashboardSummaryProvider =
    Provider.family<AsyncValue<DashboardSummaryData>, String>((ref, fiscalYear) {
  final fundsAsync = ref.watch(fundSourcesProvider);
  final uacsAsync = ref.watch(uacsCodesProvider);
  final allocationsAsync = ref.watch(budgetAllocationsProvider);
  final modificationsAsync = ref.watch(budgetModificationsProvider);
  final obligationsAsync = ref.watch(obligationRegistriesProvider);

  if (fundsAsync.isLoading ||
      uacsAsync.isLoading ||
      allocationsAsync.isLoading ||
      modificationsAsync.isLoading ||
      obligationsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (fundsAsync.hasError) {
    return AsyncValue.error(
      fundsAsync.error!,
      fundsAsync.stackTrace ?? StackTrace.current,
    );
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

  final funds = fundsAsync.value ?? const <FundSource>[];
  final uacsList = uacsAsync.value ?? const <UacsCode>[];
  final allAllocations = allocationsAsync.value ?? const <BudgetAllocation>[];
  final allModifications =
      modificationsAsync.value ?? const <BudgetModification>[];
  final obligations = obligationsAsync.value ?? const <ObligationRegistry>[];

  final uacsByCode = {for (final u in uacsList) u.accountCode: u};

  final fyAllocations = fiscalYear == 'ALL'
      ? allAllocations
      : allAllocations.where((a) => a.fiscalYear == fiscalYear).toList();
  final fyModifications = fiscalYear == 'ALL'
      ? allModifications
      : allModifications.where((m) => m.fiscalYear == fiscalYear).toList();

  final activeAllocations =
      fyAllocations.where((a) => a.isHidden == 0).toList();
  final hiddenCount = fyAllocations.where((a) => a.isHidden != 0).length;

  final totalAllotment = activeAllocations.fold<double>(
        0.0,
        (sum, a) =>
            sum +
            a.beginningBalance +
            a.authorizedAppropriations +
            a.adjustmentsAllotment,
      ) +
      fyModifications.fold<double>(0.0, (sum, m) => sum + m.modificationAmount);
  final totalObligated = obligations.fold<double>(
    0.0,
    (sum, o) => sum + o.grossAmount,
  );
  final totalDisbursed = obligations.fold<double>(
    0.0,
    (sum, o) => sum + o.disbursementAmount,
  );

  // Fund Clusters
  final fundClusters = funds.map((f) {
    final fundAllocs =
        activeAllocations.where((a) => a.fundCode == f.fundCode).toList();
    final fundMods =
        fyModifications.where((m) => m.fundCode == f.fundCode).toList();
    final fundObrs =
        obligations.where((o) => o.fundCode == f.fundCode).toList();

    final allotment = fundAllocs.fold<double>(
          0.0,
          (sum, a) =>
              sum +
              a.beginningBalance +
              a.authorizedAppropriations +
              a.adjustmentsAllotment,
        ) +
        fundMods.fold<double>(0.0, (sum, m) => sum + m.modificationAmount);
    final obligated = fundObrs.fold<double>(
      0.0,
      (sum, o) => sum + o.grossAmount,
    );
    final unobligated = allotment - obligated;
    final pct = allotment > 0 ? (obligated / allotment).clamp(0.0, 1.0) : 0.0;

    return DashboardFundClusterData(
      code: f.fundCode,
      name: f.fundName,
      tag: f.fundingSourceHeader,
      subtitle:
          '${fundAllocs.length} active allocation(s) • ${fundObrs.length} OBR(s)',
      allotment: allotment,
      obligated: obligated,
      unobligated: unobligated,
      percent: pct,
    );
  }).toList();

  // Expense Classes (PS, MOOE, CO)
  final expenseClasses = BrmsFormatters.allotmentClasses.map((cls) {
    final allotment = activeAllocations
            .where((a) => a.allotmentClass == cls)
            .fold<double>(
              0.0,
              (sum, a) =>
                  sum +
                  a.beginningBalance +
                  a.authorizedAppropriations +
                  a.adjustmentsAllotment,
            ) +
        fyModifications
            .where((m) => m.allotmentClass == cls)
            .fold<double>(0.0, (sum, m) => sum + m.modificationAmount);
    final obligated = obligations
        .where((o) => o.allotmentClassification == cls)
        .fold<double>(0.0, (sum, o) => sum + o.grossAmount);
    final unobligated = allotment - obligated;
    final ratio =
        allotment > 0 ? (obligated / allotment).clamp(0.0, 1.0) : 0.0;
    final sharePct = totalAllotment > 0
        ? ((allotment / totalAllotment) * 100).round()
        : 0;

    return DashboardExpenseClassData(
      code: BrmsFormatters.shortAllotmentLabel(cls),
      title: cls,
      allotment: allotment,
      obligated: obligated,
      unobligated: unobligated,
      ratio: ratio,
      sharePercent: sharePct,
    );
  }).toList();

  // Quarterly Burn (Q1–Q4)
  const quarterLabels = ['Q1 (Jan-Mar)', 'Q2 (Apr-Jun)', 'Q3 (Jul-Sep)', 'Q4 (Oct-Dec)'];
  final quarterlyBurn = List.generate(4, (idx) {
    final q = idx + 1;
    final qObrs = obligations
        .where((o) => BrmsFormatters.quarterOfIso(o.date) == q)
        .toList();
    final obTotal = qObrs.fold<double>(0.0, (sum, o) => sum + o.grossAmount);
    final disbTotal =
        qObrs.fold<double>(0.0, (sum, o) => sum + o.disbursementAmount);
    return QuarterlyBurnPoint(
      quarter: quarterLabels[idx],
      obligatedMillions: obTotal / 1000000.0,
      disbursedMillions: disbTotal / 1000000.0,
      obrCount: qObrs.length,
    );
  });

  // Top Payee Absorption (up to 6 payees)
  final payeeTotals = <String, double>{};
  for (final o in obligations) {
    payeeTotals.update(
      o.payee,
      (prev) => prev + o.grossAmount,
      ifAbsent: () => o.grossAmount,
    );
  }
  final sortedPayees = payeeTotals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final payeeUnits = sortedPayees.take(6).map((e) {
    final ratio = totalObligated > 0
        ? (e.value / totalObligated).clamp(0.0, 1.0)
        : 0.0;
    return DashboardPayeeAbsorptionData(
      name: e.key,
      spent: e.value,
      ratio: ratio,
    );
  }).toList();

  // Recent OBR Items
  final allObrItems = obligations.map((o) {
    final uacs = uacsByCode[o.accountCode];
    final uacsDesc = uacs != null
        ? '${o.accountCode} • ${uacs.objectTitle}'
        : o.accountCode;

    final String status;
    if (o.disbursementAmount >= o.grossAmount && o.grossAmount > 0) {
      status = 'Liquidated / Paid';
    } else if (o.disbursementAmount > 0) {
      status = 'Processing DV';
    } else {
      status = 'Obligated';
    }

    return DashboardObrItem(
      id: o.id,
      obrNo: o.obrNo,
      dateRecorded: BrmsFormatters.isoToDisplay(o.date),
      fundCode: o.fundCode,
      accountCode: o.accountCode,
      uacsDescription: uacsDesc,
      payee: o.payee,
      particulars: o.particular,
      grossAmount: o.grossAmount,
      status: status,
    );
  }).toList();

  return AsyncValue.data(
    DashboardSummaryData(
      totalAllotment: totalAllotment,
      totalObligated: totalObligated,
      totalDisbursed: totalDisbursed,
      activeAllocationsCount: activeAllocations.length,
      hiddenAllocationsCount: hiddenCount,
      totalObrCount: obligations.length,
      fundClusters: fundClusters,
      expenseClasses: expenseClasses,
      quarterlyBurn: quarterlyBurn,
      payeeUnits: payeeUnits,
      allObrItems: allObrItems,
    ),
  );
});
