import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../services/attachment_service.dart';

/// Singleton Drift database provider.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

/// Local PDF attachment service provider.
final attachmentServiceProvider = Provider<AttachmentService>((ref) {
  return const AttachmentService();
});

/// Reactive stream of all statutory and campus fund sources.
final fundSourcesProvider = StreamProvider<List<FundSource>>((ref) {
  return ref.watch(databaseProvider).watchFundSources();
});

/// Reactive stream of all UACS object codes.
final uacsCodesProvider = StreamProvider<List<UacsCode>>((ref) {
  return ref.watch(databaseProvider).watchUacsCodes();
});

/// Reactive stream of budget allocations ordered by `date_of_allocation DESC`.
final budgetAllocationsProvider = StreamProvider<List<BudgetAllocation>>((ref) {
  return ref.watch(databaseProvider).watchBudgetAllocations();
});

/// Reactive stream of obligation registries ordered by `date DESC, obr_no DESC`.
final obligationRegistriesProvider =
    StreamProvider<List<ObligationRegistry>>((ref) {
  return ref.watch(databaseProvider).watchObligationRegistries();
});

/// Reactive stream of a single obligation registry record by [id].
final obligationByIdProvider =
    StreamProvider.family<ObligationRegistry?, int>((ref, id) {
  return ref.watch(databaseProvider).watchObligationById(id);
});

/// Reactive stream of distinct historical payees for autocomplete.
final distinctPayeesProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(databaseProvider).watchDistinctPayees();
});

/// Reactive stream of distinct historical particulars for autocomplete.
final distinctParticularsProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(databaseProvider).watchDistinctParticulars();
});

/// Query key for calculating remaining available balance.
class BalanceQueryKey {
  const BalanceQueryKey({
    required this.fundCode,
    required this.allotmentClass,
    this.excludeObligationId,
  });

  final String fundCode;
  final String allotmentClass;
  final int? excludeObligationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BalanceQueryKey &&
          runtimeType == other.runtimeType &&
          fundCode == other.fundCode &&
          allotmentClass == other.allotmentClass &&
          excludeObligationId == other.excludeObligationId;

  @override
  int get hashCode =>
      Object.hash(fundCode, allotmentClass, excludeObligationId);
}

/// Real-time remaining available balance for a given `fundCode` and `allotmentClass`:
/// `sum(Active Adjusted Allotments) - sum(Existing Obligations)`.
/// Recomputes automatically whenever allocations or obligations change.
final remainingBalanceProvider =
    Provider.family<AsyncValue<double>, BalanceQueryKey>((ref, key) {
  final allocationsAsync = ref.watch(budgetAllocationsProvider);
  final obligationsAsync = ref.watch(obligationRegistriesProvider);

  if (allocationsAsync.isLoading || obligationsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (allocationsAsync.hasError) {
    return AsyncValue.error(
      allocationsAsync.error!,
      allocationsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (obligationsAsync.hasError) {
    return AsyncValue.error(
      obligationsAsync.error!,
      obligationsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final allocations = allocationsAsync.value ?? const <BudgetAllocation>[];
  final obligations = obligationsAsync.value ?? const <ObligationRegistry>[];

  final totalAllotment = allocations
      .where(
        (a) =>
            a.isHidden == 0 &&
            a.fundCode == key.fundCode &&
            a.allotmentClass == key.allotmentClass,
      )
      .fold<double>(
        0.0,
        (sum, a) => sum + a.allotmentReceived + a.adjustmentsAllotment,
      );

  final totalObligated = obligations
      .where(
        (o) =>
            o.fundCode == key.fundCode &&
            o.allotmentClassification == key.allotmentClass &&
            o.id != key.excludeObligationId,
      )
      .fold<double>(0.0, (sum, o) => sum + o.grossAmount);

  return AsyncValue.data(totalAllotment - totalObligated);
});

/// Aggregated totals per fund source for Dashboard and FAR 1-A consumers.
class FundBalanceSummary {
  const FundBalanceSummary({
    required this.fundCode,
    required this.totalAllotment,
    required this.totalObligated,
    required this.totalDisbursed,
  });

  final String fundCode;
  final double totalAllotment;
  final double totalObligated;
  final double totalDisbursed;

  double get unobligated => totalAllotment - totalObligated;
}

/// Reactive summary map keyed by `fund_code` for Dashboard / FAR 1-A totals.
final fundBalanceSummaryProvider =
    Provider<AsyncValue<Map<String, FundBalanceSummary>>>((ref) {
  final fundsAsync = ref.watch(fundSourcesProvider);
  final allocationsAsync = ref.watch(budgetAllocationsProvider);
  final obligationsAsync = ref.watch(obligationRegistriesProvider);

  if (fundsAsync.isLoading ||
      allocationsAsync.isLoading ||
      obligationsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (fundsAsync.hasError) {
    return AsyncValue.error(
      fundsAsync.error!,
      fundsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (allocationsAsync.hasError) {
    return AsyncValue.error(
      allocationsAsync.error!,
      allocationsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (obligationsAsync.hasError) {
    return AsyncValue.error(
      obligationsAsync.error!,
      obligationsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final funds = fundsAsync.value ?? const <FundSource>[];
  final allocations = allocationsAsync.value ?? const <BudgetAllocation>[];
  final obligations = obligationsAsync.value ?? const <ObligationRegistry>[];

  final result = <String, FundBalanceSummary>{};
  for (final fund in funds) {
    final allotment = allocations
        .where((a) => a.isHidden == 0 && a.fundCode == fund.fundCode)
        .fold<double>(
          0.0,
          (sum, a) => sum + a.allotmentReceived + a.adjustmentsAllotment,
        );
    final obligated = obligations
        .where((o) => o.fundCode == fund.fundCode)
        .fold<double>(0.0, (sum, o) => sum + o.grossAmount);
    final disbursed = obligations
        .where((o) => o.fundCode == fund.fundCode)
        .fold<double>(0.0, (sum, o) => sum + o.disbursementAmount);

    result[fund.fundCode] = FundBalanceSummary(
      fundCode: fund.fundCode,
      totalAllotment: allotment,
      totalObligated: obligated,
      totalDisbursed: disbursed,
    );
  }

  return AsyncValue.data(result);
});
