import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/brms_models.dart';
import '../providers/brms_providers.dart';
import '../providers/dashboard_provider.dart';
import '../theme/brms_theme.dart';
import '../utils/brms_formatters.dart';
import '../widgets/brms_common.dart';

/// Screen 2: BRMS CSU Aparri - Executive Dashboard (Monochrome).
class ExecutiveDashboardScreen extends ConsumerStatefulWidget {
  const ExecutiveDashboardScreen({super.key, required this.onNavigate});

  final ValueChanged<BrmsModule> onNavigate;

  @override
  ConsumerState<ExecutiveDashboardScreen> createState() =>
      _ExecutiveDashboardScreenState();
}

class _ExecutiveDashboardScreenState
    extends ConsumerState<ExecutiveDashboardScreen> {
  String _selectedFundFilter = 'ALL';
  String _selectedStatusFilter = 'All Statuses';
  String _selectedFy = 'ALL';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int? _hoveredQuarterIndex;
  int? _hoveredUnitIndex;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardSummaryProvider(_selectedFy));

    return summaryAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: BrmsErrorState(
            title: 'Failed to load dashboard summary',
            error: err,
            onRetry: () {
              ref.invalidate(databaseProvider);
              ref.invalidate(dashboardSummaryProvider(_selectedFy));
            },
          ),
        ),
      ),
      data: (data) => Column(
        children: [
          _buildCommandStrip(context, data),
          const SizedBox(height: 20),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildKpiRow(context, data),
                    const SizedBox(height: 20),
                    _buildAnalyticsSection(context, data),
                    const SizedBox(height: 20),
                    _buildSplitCanvas(context, data),
                    const SizedBox(height: 20),
                    _buildRecentObrCard(context, data),
                    const SizedBox(height: 20),
                    _buildLedgerFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandStrip(BuildContext context, DashboardSummaryData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: BrmsColors.surface,
        border: Border(
          top: BorderSide(color: BrmsColors.outlineVariant),
          bottom: BorderSide(color: BrmsColors.outlineVariant),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 340,
                    height: 36,
                    child: TextField(
                      controller: _searchController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                          BrmsInputLimits.maxSearchLength,
                        ),
                      ],
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: BrmsColors.secondary,
                        ),
                        hintText:
                            'Search OBR No., Payee, DV, UACS Code, or Pap Code...',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: BrmsColors.secondary,
                        ),
                        filled: true,
                        fillColor: BrmsColors.surfaceContainerLow,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: BrmsColors.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: BrmsColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: BrmsColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: BrmsColors.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'FY:',
                          style: TextStyle(
                            fontSize: 11,
                            color: BrmsColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFy,
                            isDense: true,
                            style: BrmsTheme.mono(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: 'ALL',
                                child: Text('All Years'),
                              ),
                              ...BrmsFormatters.fiscalYears.map(
                                (fy) => DropdownMenuItem(
                                  value: fy,
                                  child: Text(fy),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedFy = val);
                              }
                            },
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 14,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: BrmsColors.outlineVariant,
                        ),
                        const Text(
                          'OBR:',
                          style: TextStyle(
                            fontSize: 11,
                            color: BrmsColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        BrmsBadge(
                          label: '${data.totalObrCount}',
                          filled: true,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: BrmsColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: BrmsColors.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: BrmsColors.onSurface,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ACTIVE OBRS:',
                          style: TextStyle(
                            fontSize: 11,
                            color: BrmsColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${data.totalObrCount}',
                          style: BrmsTheme.mono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiRow(BuildContext context, DashboardSummaryData data) {
    final utilizedPct = (data.utilizationRatio * 100).toStringAsFixed(1);
    final remainingPct = (data.remainingRatio * 100).toStringAsFixed(1);
    final disbursedPct = data.totalObligated > 0
        ? ((data.totalDisbursed / data.totalObligated) * 100).toStringAsFixed(1)
        : '0.0';
    final unpaidAmount = data.totalObligated - data.totalDisbursed;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isStacked = constraints.maxWidth < 860;
        final cards = [
          _KpiSummaryCard(
            title: 'TOTAL BUDGET ALLOCATION',
            value: '₱ ${BrmsFormatters.formatNumber(data.totalAllotment)}',
            badge: '100% AUTHORIZED',
            middle: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 15,
                        color: BrmsColors.onSurface,
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Adjusted Total Allotment Received',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: BrmsColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'LOCAL SQLITE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: BrmsColors.onSurface,
                  ),
                ),
              ],
            ),
            footerLeft: 'Active Entries: ${data.activeAllocationsCount}',
            footerRight: 'Hidden: ${data.hiddenAllocationsCount}',
          ),
          _KpiSummaryCard(
            title: 'TOTAL BUDGET UTILIZATION',
            value: '₱ ${BrmsFormatters.formatNumber(data.totalObligated)}',
            badge: '$utilizedPct% UTILIZED',
            middle: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BrmsProgressBar(value: data.utilizationRatio),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Cumulative Obligations Incurred',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: BrmsColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${data.totalObrCount} OBR(s)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: BrmsColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            footerLeft:
                'Disbursed: ₱${BrmsFormatters.formatNumber(data.totalDisbursed)} ($disbursedPct%)',
            footerRight:
                'Unpaid OBRs: ₱${BrmsFormatters.formatNumber(unpaidAmount)}',
          ),
          _KpiSummaryCard(
            title: 'TOTAL UNOBLIGATED BALANCE',
            value: '₱ ${BrmsFormatters.formatNumber(data.totalUnobligated)}',
            badge: '$remainingPct% REMAINING',
            middle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.savings_outlined,
                        size: 15,
                        color: BrmsColors.onSurface,
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Unallotted Balance Available',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: BrmsColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  data.totalUnobligated >= 0 ? 'OPTIMAL SOLVENCY' : 'OVERDRAWN',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: BrmsColors.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            footerLeft: 'Fund Clusters: ${data.fundClusters.length}',
            footerRight: 'FY: ${_selectedFy == 'ALL' ? 'All Years' : _selectedFy}',
          ),
        ];

        if (isStacked) {
          return Column(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 16),
            Expanded(child: cards[1]),
            const SizedBox(width: 16),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  Widget _buildSplitCanvas(BuildContext context, DashboardSummaryData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1020;
        final leftPanel = _buildFundSourcePanel(data);
        final rightPanel = _buildAllotmentClassPanel(data);

        if (!isWide) {
          return Column(
            children: [leftPanel, const SizedBox(height: 16), rightPanel],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: leftPanel),
            const SizedBox(width: 20),
            Expanded(flex: 5, child: rightPanel),
          ],
        );
      },
    );
  }

  Widget _buildFundSourcePanel(DashboardSummaryData data) {
    return BrmsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fund Source Allocation vs. Utilization',
                      style: BrmsTheme.heading(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Detailed segregation per DBM Fund Clusters and statutory earmarks',
                      style: TextStyle(
                        fontSize: 12,
                        color: BrmsColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              BrmsBadge(label: '${data.fundClusters.length} Active Clusters'),
            ],
          ),
          const Divider(height: 24, color: BrmsColors.outlineVariant),
          ...data.fundClusters.map(
            (fund) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: BrmsColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: BrmsColors.outlineVariant.withValues(alpha: 0.8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: BrmsColors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: BrmsColors.outlineVariant,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              fund.code,
                              style: BrmsTheme.mono(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    fund.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: BrmsColors.onSurface,
                                    ),
                                  ),
                                  BrmsBadge(label: fund.tag),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                fund.subtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: BrmsColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'ALLOTMENT:',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: BrmsColors.secondary,
                              ),
                            ),
                            Text(
                              BrmsFormatters.formatPhp(fund.allotment),
                              style: BrmsTheme.mono(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Obligated: ${BrmsFormatters.formatPhp(fund.obligated)} (${(fund.percent * 100).toStringAsFixed(1)}%)',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: BrmsColors.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Unobligated Balance: ${BrmsFormatters.formatPhp(fund.unobligated)}',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 11,
                              color: BrmsColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    BrmsProgressBar(value: fund.percent),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllotmentClassPanel(DashboardSummaryData data) {
    final psClass = data.expenseClasses[0];
    final mooeClass = data.expenseClasses[1];
    final coClass = data.expenseClasses[2];
    final hasAnyPool =
        psClass.sharePercent + mooeClass.sharePercent + coClass.sharePercent >
            0;
    final psFlex = hasAnyPool ? psClass.sharePercent.clamp(1, 100) : 1;
    final mooeFlex = hasAnyPool ? mooeClass.sharePercent.clamp(1, 100) : 1;
    final coFlex = hasAnyPool ? coClass.sharePercent.clamp(1, 100) : 1;

    return BrmsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Allotment Classification (GAM)',
                      style: BrmsTheme.heading(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Expense class ceilings and statutory utilization caps',
                      style: TextStyle(
                        fontSize: 12,
                        color: BrmsColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.pie_chart_outline,
                size: 20,
                color: BrmsColors.secondary,
              ),
            ],
          ),
          const Divider(height: 24, color: BrmsColors.outlineVariant),
          // Macro Ratio Bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BrmsColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: BrmsColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'EXPENDITURE DISTRIBUTION',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: BrmsColors.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₱${BrmsFormatters.formatNumber(data.totalAllotment)} Total Pool',
                      style: BrmsTheme.mono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        Expanded(
                          flex: psFlex,
                          child: const ColoredBox(color: BrmsColors.primary),
                        ),
                        Expanded(
                          flex: mooeFlex,
                          child: const ColoredBox(color: BrmsColors.barMedium),
                        ),
                        Expanded(
                          flex: coFlex,
                          child: const ColoredBox(color: BrmsColors.barLight),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    _LegendItem(
                      color: BrmsColors.primary,
                      label: 'Personnel (${psClass.sharePercent}%)',
                    ),
                    _LegendItem(
                      color: BrmsColors.barMedium,
                      label: 'MOOE (${mooeClass.sharePercent}%)',
                    ),
                    _LegendItem(
                      color: BrmsColors.barLight,
                      label: 'Capital Outlays (${coClass.sharePercent}%)',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...data.expenseClasses.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BrmsColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: BrmsColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              BrmsBadge(label: item.code),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: BrmsColors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          BrmsFormatters.formatPhp(item.allotment),
                          style: BrmsTheme.mono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Obligated: ${BrmsFormatters.formatPhp(item.obligated)} (${(item.ratio * 100).toStringAsFixed(1)}%)',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: BrmsColors.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Remaining: ${BrmsFormatters.formatPhp(item.unobligated)}',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 11,
                              color: BrmsColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    BrmsProgressBar(value: item.ratio, height: 4),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BrmsColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: BrmsColors.outlineVariant),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 18,
                  color: BrmsColors.secondary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COA Section 4(8) Compliance Confirmed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: BrmsColors.onSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'No unliquidated cash advances exceed 30 statutory days. PS ceiling remains compliant within 55% cap under DBM Local Budget Circular No. 145.',
                        style: TextStyle(
                          fontSize: 11,
                          color: BrmsColors.secondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(
    BuildContext context,
    DashboardSummaryData data,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1020;
        final burnCard = _buildQuarterlyBurnCard(data);
        final unitCard = _buildCampusUnitsCard(data);

        if (!isWide) {
          return Column(
            children: [burnCard, const SizedBox(height: 16), unitCard],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: burnCard),
            const SizedBox(width: 20),
            Expanded(flex: 5, child: unitCard),
          ],
        );
      },
    );
  }

  Widget _buildQuarterlyBurnCard(DashboardSummaryData data) {
    const targetPaceMillions = 10.5;
    const chartHeight = 148.0;
    final points = data.quarterlyBurn;
    final maxObserved = points.fold<double>(
      15.0,
      (m, p) => p.obligatedMillions > m ? p.obligatedMillions : m,
    );
    final maxScaleMillions = maxObserved;
    final hoveredPoint = _hoveredQuarterIndex != null &&
            _hoveredQuarterIndex! < points.length
        ? points[_hoveredQuarterIndex!]
        : null;

    String qoqDeltaLabel(int idx) {
      if (idx == 0) return 'Baseline Q1';
      final prev = points[idx - 1].obligatedMillions;
      final curr = points[idx].obligatedMillions;
      if (prev <= 0) return curr > 0 ? '+100.0% vs Q$idx' : '0.0% vs Q$idx';
      final pct = ((curr - prev) / prev) * 100;
      final sign = pct >= 0 ? '+' : '';
      return '$sign${pct.toStringAsFixed(1)}% vs Q$idx';
    }

    return BrmsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quarterly Burn Rate & Obligation Trajectory',
                      style: BrmsTheme.heading(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Cumulative obligations, disbursements & trajectory vs. ₱10.5M/qtr target pace',
                      style: TextStyle(
                        fontSize: 12,
                        color: BrmsColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const BrmsBadge(label: 'Q1–Q4 TRACKING'),
            ],
          ),
          const Divider(height: 24, color: BrmsColors.outlineVariant),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _LegendItem(
                    color: BrmsColors.primary,
                    label: 'Obligated (₱M)',
                  ),
                  _LegendItem(
                    color: BrmsColors.barMuted,
                    label: 'Disbursed (₱M)',
                  ),
                  _LegendItem(
                    color: BrmsColors.barMedium,
                    label: 'Trajectory',
                    isLine: true,
                  ),
                ],
              ),
              Text(
                'Target Pace: ₱10.5M / Qtr',
                style: BrmsTheme.mono(
                  fontSize: 11,
                  color: BrmsColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Interactive Hover Telemetry Strip
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: hoveredPoint != null
                  ? BrmsColors.primary
                  : BrmsColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hoveredPoint != null
                    ? BrmsColors.primary
                    : BrmsColors.outlineVariant,
              ),
            ),
            child: hoveredPoint == null
                ? Row(
                    children: [
                      const Icon(
                        Icons.touch_app_outlined,
                        size: 15,
                        color: BrmsColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hover over any quarter column to inspect obligation velocity, liquidation rate & QoQ trajectory.',
                          style: TextStyle(
                            fontSize: 11,
                            color: BrmsColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  )
                : Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        hoveredPoint.quarter,
                        style: BrmsTheme.mono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Obligated: ₱${hoveredPoint.obligatedMillions.toStringAsFixed(2)}M',
                        style: BrmsTheme.mono(
                          fontSize: 11,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      Text(
                        'Disbursed: ₱${hoveredPoint.disbursedMillions.toStringAsFixed(2)}M (${hoveredPoint.obligatedMillions > 0 ? ((hoveredPoint.disbursedMillions / hoveredPoint.obligatedMillions) * 100).toStringAsFixed(1) : '0.0'}%)',
                        style: BrmsTheme.mono(
                          fontSize: 11,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      Text(
                        '${hoveredPoint.obrCount} OBRs · ${qoqDeltaLabel(_hoveredQuarterIndex!)}',
                        style: BrmsTheme.mono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          // Grouped Bar Chart + Trajectory Overlay
          Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            decoration: BoxDecoration(
              color: BrmsColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: BrmsColors.outlineVariant),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Y-Axis Labels
                    SizedBox(
                      width: 38,
                      height: chartHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₱15M',
                            style: BrmsTheme.mono(
                              fontSize: 9.5,
                              color: BrmsColors.secondary,
                            ),
                          ),
                          Text(
                            '₱10M',
                            style: BrmsTheme.mono(
                              fontSize: 9.5,
                              color: BrmsColors.secondary,
                            ),
                          ),
                          Text(
                            '₱5M',
                            style: BrmsTheme.mono(
                              fontSize: 9.5,
                              color: BrmsColors.secondary,
                            ),
                          ),
                          Text(
                            '₱0M',
                            style: BrmsTheme.mono(
                              fontSize: 9.5,
                              color: BrmsColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bars + CustomPaint Trajectory
                    Expanded(
                      child: SizedBox(
                        height: chartHeight,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _TrajectoryChartPainter(
                                  points: points,
                                  maxScale: maxScaleMillions,
                                  targetPace: targetPaceMillions,
                                  hoveredIndex: _hoveredQuarterIndex,
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(points.length, (index) {
                                final point = points[index];
                                final isTarget = point.quarter.contains(
                                  'Target',
                                );
                                final isHovered = _hoveredQuarterIndex == index;
                                final obFraction =
                                    (point.obligatedMillions / maxScaleMillions)
                                        .clamp(0.0, 1.0);
                                final disbFraction =
                                    (point.disbursedMillions / maxScaleMillions)
                                        .clamp(0.0, 1.0);
                                final liqPct = point.obligatedMillions > 0
                                    ? (point.disbursedMillions /
                                            point.obligatedMillions) *
                                        100
                                    : 0.0;

                                return Expanded(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    onEnter: (_) => setState(
                                      () => _hoveredQuarterIndex = index,
                                    ),
                                    onExit: (_) => setState(
                                      () => _hoveredQuarterIndex = null,
                                    ),
                                    child: Tooltip(
                                      message:
                                          '${point.quarter}\nObligated: ₱${point.obligatedMillions.toStringAsFixed(2)}M\nDisbursed: ₱${point.disbursedMillions.toStringAsFixed(2)}M (${liqPct.toStringAsFixed(1)}%)\n${point.obrCount} OBRs · ${qoqDeltaLabel(index)}',
                                      waitDuration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 140,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isHovered
                                              ? BrmsColors.surfaceContainer
                                                    .withValues(alpha: 0.75)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: isHovered
                                              ? Border.all(
                                                  color:
                                                      BrmsColors.outlineVariant,
                                                )
                                              : null,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 140,
                                                  ),
                                                  width: isHovered ? 20 : 18,
                                                  height:
                                                      chartHeight * obFraction,
                                                  decoration: BoxDecoration(
                                                    color: isTarget
                                                        ? BrmsColors.primary
                                                              .withValues(
                                                                alpha: 0.42,
                                                              )
                                                        : (isHovered
                                                              ? BrmsColors
                                                                    .primaryContainer
                                                              : BrmsColors
                                                                    .primary),
                                                    borderRadius:
                                                        const BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            4,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 140,
                                                  ),
                                                  width: isHovered ? 20 : 18,
                                                  height:
                                                      chartHeight *
                                                      disbFraction,
                                                  decoration: BoxDecoration(
                                                    color: isTarget
                                                        ? BrmsColors.barMuted
                                                              .withValues(
                                                                alpha: 0.38,
                                                              )
                                                        : BrmsColors.barMuted,
                                                    borderRadius:
                                                        const BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            4,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: BrmsColors.outlineVariant),
                const SizedBox(height: 8),
                // X-Axis Labels aligned with bar columns
                Row(
                  children: [
                    const SizedBox(width: 46),
                    ...List.generate(points.length, (index) {
                      final point = points[index];
                      final isHovered = _hoveredQuarterIndex == index;
                      return Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) =>
                              setState(() => _hoveredQuarterIndex = index),
                          onExit: (_) =>
                              setState(() => _hoveredQuarterIndex = null),
                          child: Column(
                            children: [
                              Text(
                                point.quarter,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isHovered
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: BrmsColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₱${point.obligatedMillions.toStringAsFixed(1)}M · ${point.obrCount} OBRs',
                                textAlign: TextAlign.center,
                                style: BrmsTheme.mono(
                                  fontSize: 9.5,
                                  color: isHovered
                                      ? BrmsColors.onSurface
                                      : BrmsColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Bottom Analytical Highlights
          Builder(
            builder: (context) {
              final avgQtr = data.totalObligated / 4.0 / 1000000.0;
              final unpaid = data.totalObligated - data.totalDisbursed;
              final unpaidPct = data.totalObligated > 0
                  ? ((unpaid / data.totalObligated) * 100).toStringAsFixed(1)
                  : '0.0';
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _AnalyticsStatPill(
                    label: 'AVG. QUARTERLY BURN',
                    value: '₱ ${avgQtr.toStringAsFixed(2)}M',
                  ),
                  _AnalyticsStatPill(
                    label: 'Q3 VELOCITY VARIANCE',
                    value: qoqDeltaLabel(2),
                  ),
                  _AnalyticsStatPill(
                    label: 'UNPAID OBLIGATION LAG',
                    value: '$unpaidPct% (₱ ${(unpaid / 1000000.0).toStringAsFixed(2)}M)',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCampusUnitsCard(DashboardSummaryData data) {
    final units = data.payeeUnits;
    return BrmsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campus Unit & Payee Absorption',
                      style: BrmsTheme.heading(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Top obligation share by payee / unit (hover for details)',
                      style: TextStyle(
                        fontSize: 12,
                        color: BrmsColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.bar_chart_outlined,
                size: 20,
                color: BrmsColors.secondary,
              ),
            ],
          ),
          const Divider(height: 24, color: BrmsColors.outlineVariant),
          if (units.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No obligations recorded yet.',
                  style: TextStyle(fontSize: 12, color: BrmsColors.secondary),
                ),
              ),
            )
          else
            ...List.generate(units.length, (index) {
              final unit = units[index];
              final isHovered = _hoveredUnitIndex == index;
              final remainingPct = ((1.0 - unit.ratio) * 100).toStringAsFixed(1);
              final spentLabel = BrmsFormatters.formatPhp(unit.spent);
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _hoveredUnitIndex = index),
                onExit: (_) => setState(() => _hoveredUnitIndex = null),
                child: Tooltip(
                  message:
                      '${unit.name}\nObligated: $spentLabel (${(unit.ratio * 100).toStringAsFixed(1)}%)\nOther Share: $remainingPct%',
                  waitDuration: const Duration(milliseconds: 180),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isHovered
                          ? BrmsColors.surfaceContainerLow
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isHovered
                            ? BrmsColors.outlineVariant
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                unit.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: BrmsColors.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(unit.ratio * 100).toStringAsFixed(1)}%',
                              style: BrmsTheme.mono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        BrmsProgressBar(
                          value: unit.ratio,
                          height: isHovered ? 7 : 6,
                          barColor: unit.ratio >= 0.70 || isHovered
                              ? BrmsColors.primary
                              : BrmsColors.barMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                spentLabel,
                                overflow: TextOverflow.ellipsis,
                                style: BrmsTheme.mono(
                                  fontSize: 10,
                                  color: BrmsColors.secondary,
                                ),
                              ),
                            ),
                            if (isHovered)
                              Text(
                                '$remainingPct% remaining share',
                                style: BrmsTheme.mono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: BrmsColors.onSurface,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BrmsColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: BrmsColors.outlineVariant),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.insights_outlined,
                  size: 17,
                  color: BrmsColors.onSurface,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '142 OBRs processed · 89.5% disbursement liquidation rate · CFMS leads campus absorption at 78.4%.',
                    style: TextStyle(
                      fontSize: 11,
                      color: BrmsColors.secondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentObrCard(
    BuildContext context,
    DashboardSummaryData data,
  ) {
    final q = _searchQuery.trim().toLowerCase();
    final filteredRows = data.allObrItems.where((row) {
      if (_selectedFundFilter != 'ALL' && row.fundCode != _selectedFundFilter) {
        return false;
      }
      if (_selectedStatusFilter != 'All Statuses' &&
          row.status != _selectedStatusFilter) {
        return false;
      }
      if (q.isNotEmpty) {
        final match = row.obrNo.toLowerCase().contains(q) ||
            row.payee.toLowerCase().contains(q) ||
            row.particulars.toLowerCase().contains(q) ||
            row.accountCode.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();
    final visibleRows = filteredRows.take(10).toList();

    final fundFilterItems = <String>[
      'ALL',
      ...data.fundClusters.map((f) => f.code),
    ];
    final activeFundFilter = fundFilterItems.contains(_selectedFundFilter)
        ? _selectedFundFilter
        : 'ALL';

    return BrmsCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: BrmsColors.surfaceContainerLow,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(color: BrmsColors.outlineVariant),
              ),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: BrmsColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: BrmsColors.outlineVariant),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                        color: BrmsColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Obligation Requests (OBR) Registry',
                            style: BrmsTheme.heading(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'GAM FAR No. 1-A Individual Allotment & Obligation Slips',
                            style: TextStyle(
                              fontSize: 12,
                              color: BrmsColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _FilterDropdownPill(
                      label: 'FILTER FUND:',
                      value: activeFundFilter == 'ALL'
                          ? 'All Funds (101, 161, 164, 184)'
                          : 'Fund $activeFundFilter',
                      items: [
                        'All Funds (101, 161, 164, 184)',
                        ...data.fundClusters.map((f) => 'Fund ${f.code}'),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          if (v.startsWith('All Funds')) {
                            _selectedFundFilter = 'ALL';
                          } else {
                            _selectedFundFilter =
                                v.replaceFirst('Fund ', '').trim();
                          }
                        });
                      },
                    ),
                    _FilterDropdownPill(
                      label: 'STATUS:',
                      value: _selectedStatusFilter,
                      items: const [
                        'All Statuses',
                        'Liquidated / Paid',
                        'Obligated',
                        'Processing DV',
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedStatusFilter = v);
                        }
                      },
                    ),
                    BrmsButton(
                      label: 'Export CSV',
                      icon: Icons.file_download_outlined,
                      primary: false,
                      height: 32,
                      onPressed: () => showBrmsNotice(
                        context,
                        'Showing ${filteredRows.length} OBR rows.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          BrmsHorizontalTableScroll(
            ensureMinWidth: true,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                BrmsColors.surfaceContainerLow,
              ),
              headingTextStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BrmsColors.secondary,
                letterSpacing: 0.4,
              ),
              dataRowMinHeight: 46,
              dataRowMaxHeight: 54,
              columns: const [
                DataColumn(label: Text('OBR TRACKING NO.')),
                DataColumn(label: Text('DATE RECORDED')),
                DataColumn(label: Text('FUND & UACS CODE')),
                DataColumn(label: Text('PAYEE / CLAIMANT')),
                DataColumn(label: Text('PARTICULARS & PURPOSE')),
                DataColumn(label: Text('AMOUNT (₱)'), numeric: true),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTION')),
              ],
              rows: visibleRows.map((row) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        row.obrNo,
                        style: BrmsTheme.mono(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        row.dateRecorded,
                        style: BrmsTheme.mono(
                          fontSize: 12,
                          color: BrmsColors.secondary,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BrmsBadge(label: row.fundCode),
                          const SizedBox(width: 6),
                          Text(
                            row.uacsDescription,
                            style: BrmsTheme.mono(
                              fontSize: 11,
                              color: BrmsColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        row.payee,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: BrmsColors.onSurface,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 240,
                        child: Text(
                          row.particulars,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: BrmsColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        BrmsFormatters.formatPhp(row.grossAmount),
                        style: BrmsTheme.mono(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(BrmsBadge(label: row.status)),
                    DataCell(
                      OutlinedButton.icon(
                        onPressed: () =>
                            widget.onNavigate(BrmsModule.obligations),
                        icon: const Icon(Icons.visibility_outlined, size: 13),
                        label: const Text(
                          'Inspect',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: BrmsColors.secondary,
                          side: const BorderSide(
                            color: BrmsColors.outlineVariant,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: BrmsColors.surfaceContainerLow,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border(top: BorderSide(color: BrmsColors.outlineVariant)),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Showing ${visibleRows.length} of ${filteredRows.length} Active OBR entries',
                  style: BrmsTheme.mono(
                    fontSize: 11,
                    color: BrmsColors.secondary,
                  ),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BrmsBadge(label: 'Prev'),
                    SizedBox(width: 4),
                    BrmsBadge(label: '1', filled: true),
                    SizedBox(width: 4),
                    BrmsBadge(label: '2'),
                    SizedBox(width: 4),
                    BrmsBadge(label: '3'),
                    SizedBox(width: 4),
                    BrmsBadge(label: 'Next'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerFooter() {
    return BrmsCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: BrmsColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: BrmsColors.outlineVariant),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 18,
              color: BrmsColors.onSurface,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CSU Aparri Campus Budget Management Ledger',
                  style: BrmsTheme.heading(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Internal campus allocation tracking, fund utilization monitoring, and obligation records for CSU Aparri.',
                  style: TextStyle(fontSize: 12, color: BrmsColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiSummaryCard extends StatelessWidget {
  const _KpiSummaryCard({
    required this.title,
    required this.value,
    required this.badge,
    required this.middle,
    required this.footerLeft,
    required this.footerRight,
  });

  final String title;
  final String value;
  final String badge;
  final Widget middle;
  final String footerLeft;
  final String footerRight;

  @override
  Widget build(BuildContext context) {
    return BrmsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: BrmsColors.secondary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: BrmsTheme.mono(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              BrmsBadge(label: badge),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: BrmsColors.outlineVariant),
          const SizedBox(height: 10),
          middle,
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  footerLeft,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: BrmsColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  footerRight,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    color: BrmsColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.isLine = false,
  });

  final Color color;
  final String label;
  final bool isLine;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLine)
          Container(width: 14, height: 2, color: color)
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: BrmsTheme.mono(fontSize: 11, color: BrmsColors.secondary),
        ),
      ],
    );
  }
}

class _FilterDropdownPill extends StatelessWidget {
  const _FilterDropdownPill({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: BrmsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BrmsColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: BrmsColors.secondary,
            ),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              style: const TextStyle(fontSize: 12, color: BrmsColors.onSurface),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsStatPill extends StatelessWidget {
  const _AnalyticsStatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: BrmsColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BrmsColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: BrmsColors.secondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: BrmsTheme.mono(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TrajectoryChartPainter extends CustomPainter {
  const _TrajectoryChartPainter({
    required this.points,
    required this.maxScale,
    required this.targetPace,
    required this.hoveredIndex,
  });

  final List<QuarterlyBurnPoint> points;
  final double maxScale;
  final double targetPace;
  final int? hoveredIndex;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Horizontal scale gridlines (0, 5, 10, 15)
    final gridPaint = Paint()
      ..color = BrmsColors.outlineVariant.withValues(alpha: 0.7)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = size.height - (size.height * (i / 3));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Dashed horizontal Target Pace reference line
    final targetY =
        size.height - (size.height * (targetPace / maxScale).clamp(0.0, 1.0));
    final targetPaint = Paint()
      ..color = BrmsColors.outline
      ..strokeWidth = 1.2;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, targetY),
        Offset((startX + dashWidth).clamp(0.0, size.width), targetY),
        targetPaint,
      );
      startX += dashWidth + dashSpace;
    }

    if (points.isEmpty) return;

    // 3. Trajectory line connecting each quarter's Obligated value
    final colWidth = size.width / points.length;
    final coords = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final x = colWidth * (i + 0.5);
      final fraction = (points[i].obligatedMillions / maxScale).clamp(0.0, 1.0);
      final y = size.height - (size.height * fraction);
      coords.add(Offset(x, y));
    }

    final solidLinePaint = Paint()
      ..color = BrmsColors.barMedium
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < coords.length - 1; i++) {
      final isProjected = points[i + 1].quarter.contains('Target');
      if (!isProjected) {
        canvas.drawLine(coords[i], coords[i + 1], solidLinePaint);
      } else {
        // Dashed projection segment to Q4 Target
        final p1 = coords[i];
        final p2 = coords[i + 1];
        final dx = p2.dx - p1.dx;
        final dy = p2.dy - p1.dy;
        final dist = (p2 - p1).distance;
        const step = 6.0;
        for (double d = 0; d < dist; d += step * 2) {
          final t1 = d / dist;
          final t2 = ((d + step) / dist).clamp(0.0, 1.0);
          canvas.drawLine(
            Offset(p1.dx + dx * t1, p1.dy + dy * t1),
            Offset(p1.dx + dx * t2, p1.dy + dy * t2),
            solidLinePaint,
          );
        }
      }
    }

    // 4. Trajectory nodes
    for (int i = 0; i < coords.length; i++) {
      final isHovered = hoveredIndex == i;
      final isTarget = points[i].quarter.contains('Target');
      final outerRadius = isHovered ? 5.5 : 4.0;
      canvas.drawCircle(
        coords[i],
        outerRadius,
        Paint()..color = BrmsColors.surface,
      );
      canvas.drawCircle(
        coords[i],
        outerRadius,
        Paint()
          ..color = isTarget ? BrmsColors.secondary : BrmsColors.primary
          ..strokeWidth = isHovered ? 2.5 : 2.0
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrajectoryChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.points != points;
  }
}
