import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../models/brms_models.dart';
import '../providers/brms_providers.dart';
import '../providers/reports_provider.dart';
import '../services/report_export_service.dart';
import '../theme/brms_theme.dart';
import '../utils/brms_formatters.dart';
import '../widgets/brms_common.dart';

class _MatrixColSpec {
  const _MatrixColSpec({
    required this.key,
    required this.label,
    required this.superGroup,
    required this.width,
    required this.numeric,
    required this.textValue,
    this.numericValue,
  });

  final String key;
  final String label;
  final String superGroup;
  final double width;
  final bool numeric;
  final String Function(CentralReportRow row) textValue;
  final double Function(CentralReportRow row)? numericValue;
}

class _SuperHeaderSpan {
  const _SuperHeaderSpan({required this.title, required this.width});
  final String title;
  final double width;
}

/// Screen 5: BRMS CSU Aparri - Reports (FAR 2, FAR 2 - A, Registries, Central).
typedef ReportsScreen = Far1AReportScreen;

class Far1AReportScreen extends ConsumerStatefulWidget {
  const Far1AReportScreen({super.key, this.reportType = ReportType.far2});

  final ReportType reportType;

  @override
  ConsumerState<Far1AReportScreen> createState() => _Far1AReportScreenState();
}

class _Far1AReportScreenState extends ConsumerState<Far1AReportScreen> {
  String _selectedCat = 'ALL';
  String _far2MfoFilter = 'ALL';
  String _far2ClassFilter = 'ALL';
  String _metricActivityFilter = 'ALL';
  String _fy = 'ALL';
  int _maxQuarter = 0; // 0 = Full Year, 1..4 = As of Q1..Q4
  String _fundCode = 'ALL';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  /// Per-column filter selections for Central and Registries headers.
  final Map<String, String> _columnFilters = <String, String>{};

  final ScrollController _rightHeaderScroll = ScrollController();
  final ScrollController _rightBodyScroll = ScrollController();
  bool _syncingScroll = false;
  bool _isExporting = false;

  static const _periodOptions = <int, String>{
    0: 'Full Year (Q1 - Q4)',
    1: 'As of 1st Quarter (Jan - Mar)',
    2: 'As of 2nd Quarter (Apr - Jun)',
    3: 'As of 3rd Quarter (Jul - Sep)',
    4: 'As of 4th Quarter (Oct - Dec)',
  };

  @override
  void initState() {
    super.initState();
    _rightHeaderScroll.addListener(() {
      if (_syncingScroll || !_rightBodyScroll.hasClients) return;
      _syncingScroll = true;
      _rightBodyScroll.jumpTo(_rightHeaderScroll.offset);
      _syncingScroll = false;
    });
    _rightBodyScroll.addListener(() {
      if (_syncingScroll || !_rightHeaderScroll.hasClients) return;
      _syncingScroll = true;
      _rightHeaderScroll.jumpTo(_rightBodyScroll.offset);
      _syncingScroll = false;
    });
  }

  @override
  void didUpdateWidget(covariant Far1AReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reportType != widget.reportType) {
      _columnFilters.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _rightHeaderScroll.dispose();
    _rightBodyScroll.dispose();
    super.dispose();
  }

  ReportFilterParams get _filterParams => ReportFilterParams(
    fiscalYear: _fy,
    fundCode: _fundCode,
    maxQuarter: _maxQuarter,
  );

  void _resetAllFilters() {
    setState(() {
      _selectedCat = 'ALL';
      _far2MfoFilter = 'ALL';
      _far2ClassFilter = 'ALL';
      _metricActivityFilter = 'ALL';
      _fy = 'ALL';
      _maxQuarter = 0;
      _fundCode = 'ALL';
      _searchQuery = '';
      _searchController.clear();
      _columnFilters.clear();
    });
  }

  bool _matchesMetricActivity(ReportMetrics m) {
    switch (_metricActivityFilter) {
      case 'BUDGET':
        return m.adjustedBudget != 0.0 || m.approvedBudget != 0.0;
      case 'UTILIZED':
        return m.totalUtilizations != 0.0;
      case 'UNPAID':
        return m.totalUnpaidUtilization != 0.0;
      default:
        return true;
    }
  }

  List<CentralReportRow> _filterCentralRows(
    List<CentralReportRow> rows,
    List<_MatrixColSpec> allCols,
  ) {
    final q = _searchQuery.trim().toLowerCase();
    return rows.where((row) {
      if (q.isNotEmpty) {
        final match =
            row.mfoProgram.toLowerCase().contains(q) ||
            row.activityProject.toLowerCase().contains(q) ||
            row.allotmentClass.toLowerCase().contains(q) ||
            row.objectOfExpenditures.toLowerCase().contains(q);
        if (!match) return false;
      }

      for (final entry in _columnFilters.entries) {
        final filterVal = entry.value;
        if (filterVal == '__ALL__') continue;
        final col = allCols.where((c) => c.key == entry.key).firstOrNull;
        if (col == null) continue;

        if (!col.numeric) {
          if (col.textValue(row) != filterVal) return false;
        } else {
          final numVal = col.numericValue?.call(row) ?? 0.0;
          if (filterVal == '__NONZERO__') {
            if (numVal == 0.0) return false;
          } else if (filterVal == '__POSITIVE__') {
            if (numVal <= 0.0) return false;
          } else if (filterVal == '__NEGATIVE__') {
            if (numVal >= 0.0) return false;
          } else if (filterVal == '__ZERO__') {
            if (numVal != 0.0) return false;
          }
        }
      }
      return true;
    }).toList();
  }

  ReportExportFilters get _activeExportFilters => ReportExportFilters(
    searchQuery: _searchQuery,
    far2MfoFilter: _far2MfoFilter,
    far2ClassFilter: _far2ClassFilter,
    far2aClassFilter: _selectedCat,
    metricActivityFilter: _metricActivityFilter,
  );

  Future<void> _exportCsv(
    UnifiedReportBundle bundle,
    List<FundSource> funds,
    List<_MatrixColSpec> activeCols,
  ) async {
    final filteredCentral = _filterCentralRows(bundle.centralRows, activeCols);
    final meta = _buildExportMeta(funds);
    final filters = _activeExportFilters;
    final preview = ref
        .read(reportExportServiceProvider)
        .buildPreviewData(
          meta: meta,
          bundle: bundle,
          filteredCentralRows: filteredCentral,
          filters: filters,
        );

    await showBrmsExportPreviewDialog(
      context,
      title: '${meta.reportType.label} — ${meta.reportType.subtitle}',
      formatLabel: 'CSV / EXCEL',
      headers: preview.headers,
      rows: preview.rows,
      totalRow: preview.totalRow,
      metadata: [
        MapEntry('Fiscal Year', meta.fiscalYearLabel),
        MapEntry('Period', meta.periodLabel),
        MapEntry('Fund Cluster', meta.fundLabel),
        if (meta.classFilterLabel != null)
          MapEntry('Class', meta.classFilterLabel!),
      ],
      onConfirmExport: (exportHeaders, exportRows, exportTotalRow) async {
        setState(() => _isExporting = true);
        try {
          final isUnmodifiedColumns =
              exportHeaders.length == preview.headers.length;
          final filteredTable = isUnmodifiedColumns
              ? null
              : TabularReportData(
                  labelColumnCount: preview.labelColumnCount.clamp(
                    1,
                    exportHeaders.length,
                  ),
                  headers: exportHeaders,
                  rows: exportRows,
                  totalRow:
                      exportTotalRow ?? List.filled(exportHeaders.length, ''),
                );
          final msg = await ref
              .read(reportExportServiceProvider)
              .exportCsv(
                meta: meta,
                bundle: bundle,
                filteredCentralRows: filteredCentral,
                filters: filters,
                overrideTable: filteredTable,
              );
          if (msg != null && mounted) {
            showBrmsNotice(context, msg);
          }
        } catch (e) {
          if (mounted) {
            showBrmsNotice(context, 'CSV export failed: $e');
          }
        } finally {
          if (mounted) setState(() => _isExporting = false);
        }
      },
    );
  }

  Future<void> _exportPdf(
    UnifiedReportBundle bundle,
    List<FundSource> funds,
    List<_MatrixColSpec> activeCols,
  ) async {
    final filteredCentral = _filterCentralRows(bundle.centralRows, activeCols);
    final meta = _buildExportMeta(funds);
    final filters = _activeExportFilters;
    final preview = ref
        .read(reportExportServiceProvider)
        .buildPreviewData(
          meta: meta,
          bundle: bundle,
          filteredCentralRows: filteredCentral,
          filters: filters,
        );

    await showBrmsExportPreviewDialog(
      context,
      title: '${meta.reportType.label} — ${meta.reportType.subtitle}',
      formatLabel: 'LANDSCAPE PDF',
      headers: preview.headers,
      rows: preview.rows,
      totalRow: preview.totalRow,
      metadata: [
        MapEntry('Fiscal Year', meta.fiscalYearLabel),
        MapEntry('Period', meta.periodLabel),
        MapEntry('Fund Cluster', meta.fundLabel),
        const MapEntry('Page Format', 'Legal Landscape'),
      ],
      onConfirmExport: (exportHeaders, exportRows, exportTotalRow) async {
        setState(() => _isExporting = true);
        try {
          final isUnmodifiedColumns =
              exportHeaders.length == preview.headers.length;
          final filteredTable = isUnmodifiedColumns
              ? null
              : TabularReportData(
                  labelColumnCount: preview.labelColumnCount.clamp(
                    1,
                    exportHeaders.length,
                  ),
                  headers: exportHeaders,
                  rows: exportRows,
                  totalRow:
                      exportTotalRow ?? List.filled(exportHeaders.length, ''),
                );
          final msg = await ref
              .read(reportExportServiceProvider)
              .exportLandscapePdf(
                meta: meta,
                bundle: bundle,
                filteredCentralRows: filteredCentral,
                filters: filters,
                overrideTable: filteredTable,
              );
          if (msg != null && mounted) {
            showBrmsNotice(context, msg);
          }
        } catch (e) {
          if (mounted) {
            showBrmsNotice(context, 'PDF export failed: $e');
          }
        } finally {
          if (mounted) setState(() => _isExporting = false);
        }
      },
    );
  }

  ReportExportMeta _buildExportMeta(List<FundSource> funds) {
    final fundObj = funds.where((f) => f.fundCode == _fundCode).firstOrNull;
    final fundLabel = _fundCode == 'ALL'
        ? 'All Fund Clusters (101, 161, 164, 184)'
        : '${fundObj?.fundCode ?? _fundCode} - ${fundObj?.fundName ?? ''}';
    return ReportExportMeta(
      reportType: widget.reportType,
      fiscalYearLabel: _fy == 'ALL' ? 'All Fiscal Years' : 'FY $_fy',
      periodLabel: _periodOptions[_maxQuarter] ?? 'Full Year',
      fundLabel: fundLabel,
      classFilterLabel: widget.reportType == ReportType.far2a
          ? (_selectedCat == 'ALL' ? 'All Classes' : _selectedCat)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final funds = ref.watch(fundSourcesProvider).value ?? const <FundSource>[];
    final bundleAsync = ref.watch(centralReportProvider(_filterParams));
    final activeMatrixCols = widget.reportType == ReportType.central
        ? _centralColumns
        : _registriesColumns;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: bundleAsync.when(
            loading: () => const BrmsCard(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (err, _) => BrmsCard(
              padding: const EdgeInsets.all(24),
              child: BrmsErrorState(
                title: 'Failed to aggregate ${widget.reportType.label} report',
                error: err,
                onRetry: () {
                  ref.invalidate(databaseProvider);
                  ref.invalidate(centralReportProvider(_filterParams));
                },
              ),
            ),
            data: (bundle) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatutoryHeaderCard(
                  context,
                  bundle: bundle,
                  funds: funds,
                  activeCols: activeMatrixCols,
                ),
                const SizedBox(height: 14),
                _buildParameterFilterRibbon(context, funds),
                const SizedBox(height: 14),
                _buildKpiCardsRow(bundle),
                const SizedBox(height: 14),
                _buildCategoryTabsStrip(bundle, activeMatrixCols),
                const SizedBox(height: 12),
                _buildActiveReportTable(bundle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatutoryHeaderCard(
    BuildContext context, {
    required UnifiedReportBundle bundle,
    required List<FundSource> funds,
    required List<_MatrixColSpec> activeCols,
  }) {
    final selectedFund = funds
        .where((f) => f.fundCode == _fundCode)
        .firstOrNull;
    final fundClusterDisplay = _fundCode == 'ALL'
        ? 'All Funds (101, 161, 164, 184)'
        : '${selectedFund?.fundCode ?? _fundCode} - ${selectedFund?.fundName ?? ''}';
    final fundingSourceDisplay = _fundCode == 'ALL'
        ? 'CONSOLIDATED APPROPRIATIONS & FUNDS'
        : (selectedFund?.fundingSourceHeader ?? _fundCode);

    return BrmsCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      BrmsBadge(
                        label: 'GAM ${widget.reportType.label.toUpperCase()}',
                        filled: true,
                      ),
                      Text(
                        widget.reportType.subtitle,
                        style: BrmsTheme.mono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: BrmsColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Financial Accountability Report (${widget.reportType.label})',
                    style: BrmsTheme.heading(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrmsButton(
                    label: 'Export Excel',
                    icon: Icons.table_view_outlined,
                    primary: false,
                    onPressed: _isExporting
                        ? null
                        : () => _exportCsv(bundle, funds, activeCols),
                  ),
                  const SizedBox(width: 8),
                  BrmsButton(
                    label: 'Export PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    onPressed: _isExporting
                        ? null
                        : () => _exportPdf(bundle, funds, activeCols),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 22, color: BrmsColors.outlineVariant),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              const _StatutoryMeta(
                label: 'DEPARTMENT',
                value: 'SUCs (State Universities)',
              ),
              const _StatutoryMeta(
                label: 'AGENCY / OPERATING UNIT',
                value: 'CAGAYAN STATE UNIVERSITY - APARRI CAMPUS',
              ),
              const _StatutoryMeta(
                label: 'ORGANIZATION CODE (UACS)',
                value: '08 022 0000000',
                mono: true,
              ),
              _StatutoryMeta(
                label: 'FUND CLUSTER CODE',
                value: fundClusterDisplay,
              ),
              _StatutoryMeta(
                label: 'FUNDING SOURCE HEADER',
                value: fundingSourceDisplay,
                mono: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParameterFilterRibbon(
    BuildContext context,
    List<FundSource> funds,
  ) {
    final fundOptions = <DropdownMenuItem<String>>[
      const DropdownMenuItem(
        value: 'ALL',
        child: Text('All Funds (101, 161, 164, 184)'),
      ),
      ...funds.map(
        (f) => DropdownMenuItem(
          value: f.fundCode,
          child: Text('Fund ${f.fundCode} - ${f.fundName}'),
        ),
      ),
    ];

    return BrmsCard(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _LabeledSelect<String>(
                label: 'FISCAL YEAR',
                value: _fy,
                items: [
                  const DropdownMenuItem(
                    value: 'ALL',
                    child: Text('All Fiscal Years'),
                  ),
                  ...BrmsFormatters.fiscalYears.map(
                    (fy) => DropdownMenuItem(value: fy, child: Text('FY $fy')),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _fy = v);
                },
              ),
              _LabeledSelect<int>(
                label: 'REPORTING PERIOD',
                value: _maxQuarter,
                items: _periodOptions.entries
                    .map(
                      (e) => DropdownMenuItem<int>(
                        value: e.key,
                        child: Text(e.value),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _maxQuarter = v);
                },
              ),
              _LabeledSelect<String>(
                label: 'FUND CLUSTER',
                value: fundOptions.any((i) => i.value == _fundCode)
                    ? _fundCode
                    : 'ALL',
                items: fundOptions,
                onChanged: (v) {
                  if (v != null) setState(() => _fundCode = v);
                },
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrmsButton(
                label: 'Reset',
                primary: false,
                height: 32,
                onPressed: _resetAllFilters,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCardsRow(UnifiedReportBundle bundle) {
    final m = bundle.centralTotal.toMetrics();
    final utilRatio = m.adjustedBudget > 0
        ? (m.totalUtilizations / m.adjustedBudget).clamp(0.0, 1.0)
        : 0.0;
    final disbRatio = m.totalUtilizations > 0
        ? (m.totalDisbursement / m.totalUtilizations).clamp(0.0, 1.0)
        : 0.0;
    final remRatio = m.adjustedBudget > 0
        ? (m.unutilizedBudget / m.adjustedBudget).clamp(0.0, 1.0)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _FarMetricCard(
            label: 'ADJUSTED BUDGET',
            icon: Icons.account_balance_wallet_outlined,
            value: '₱${BrmsFormatters.formatNumber(m.adjustedBudget)}',
            subLeft: 'Approved Budget',
            subRight: '₱${BrmsFormatters.formatNumber(m.approvedBudget)}',
            progress: 1.0,
          ),
          _FarMetricCard(
            label: 'TOTAL UTILIZATIONS',
            icon: Icons.receipt_long_outlined,
            value: '₱${BrmsFormatters.formatNumber(m.totalUtilizations)}',
            subLeft: '${bundle.totalObrCount} OBR(s)',
            subRight: '${(utilRatio * 100).toStringAsFixed(2)}% Utilized',
            progress: utilRatio,
          ),
          _FarMetricCard(
            label: 'TOTAL DISBURSEMENT',
            icon: Icons.payments_outlined,
            value: '₱${BrmsFormatters.formatNumber(m.totalDisbursement)}',
            subLeft: 'Disbursement Rate',
            subRight: '${(disbRatio * 100).toStringAsFixed(2)}% of Util.',
            progress: disbRatio,
          ),
          _FarMetricCard(
            label: 'UNUTILIZED BUDGET',
            icon: Icons.savings_outlined,
            value: '₱${BrmsFormatters.formatNumber(m.unutilizedBudget)}',
            subLeft: 'Total Unpaid Util.',
            subRight:
                '₱${BrmsFormatters.formatNumber(m.totalUnpaidUtilization)}',
            progress: remRatio,
          ),
        ];

        if (constraints.maxWidth < 920) {
          return Column(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
            const SizedBox(width: 12),
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
        );
      },
    );
  }

  Widget _buildCategoryTabsStrip(
    UnifiedReportBundle bundle,
    List<_MatrixColSpec> activeMatrixCols,
  ) {
    final isMatrix =
        widget.reportType == ReportType.central ||
        widget.reportType == ReportType.registries;
    final filteredCount = isMatrix
        ? _filterCentralRows(bundle.centralRows, activeMatrixCols).length
        : (widget.reportType == ReportType.far2
              ? bundle.far2Groups.length
              : bundle.far2AGroups.fold<int>(
                  0,
                  (sum, g) => sum + g.rows.length,
                ));

    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (widget.reportType == ReportType.far2a)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: BrmsColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: BrmsColors.outlineVariant),
                ),
                child: Wrap(
                  spacing: 4,
                  children: [
                    _CatTab(
                      label: 'All Classes',
                      count:
                          '${bundle.far2AGroups.fold<int>(0, (s, g) => s + g.rows.length)}',
                      selected: _selectedCat == 'ALL',
                      onTap: () => setState(() => _selectedCat = 'ALL'),
                    ),
                    ...bundle.far2AGroups.map(
                      (g) => _CatTab(
                        label: BrmsFormatters.shortAllotmentLabel(
                          g.allotmentClass,
                        ),
                        count: '${g.rows.length}',
                        selected: _selectedCat == g.allotmentClass,
                        onTap: () =>
                            setState(() => _selectedCat = g.allotmentClass),
                      ),
                    ),
                  ],
                ),
              ),
              BrmsTableFilterSelect<String>(
                label: 'SHOW:',
                value: _metricActivityFilter,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All Objects')),
                  DropdownMenuItem(
                    value: 'BUDGET',
                    child: Text('With Budget (> 0)'),
                  ),
                  DropdownMenuItem(
                    value: 'UTILIZED',
                    child: Text('With Utilizations (> 0)'),
                  ),
                  DropdownMenuItem(
                    value: 'UNPAID',
                    child: Text('With Unpaid (> 0)'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _metricActivityFilter = v);
                },
              ),
            ],
          )
        else if (widget.reportType == ReportType.far2)
          Builder(
            builder: (context) {
              final expandedMfos = ref.watch(far2ExpandedMfosProvider);
              final hasExpanded = expandedMfos.isNotEmpty;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  BrmsButton(
                    label: hasExpanded ? 'Collapse All MFOs' : 'Expand All MFOs',
                    icon: hasExpanded ? Icons.unfold_less : Icons.unfold_more,
                    primary: false,
                    height: 32,
                    onPressed: () {
                      final notifier = ref.read(
                        far2ExpandedMfosProvider.notifier,
                      );
                      if (hasExpanded) {
                        notifier.collapseAll();
                      } else {
                        notifier.expandAll();
                      }
                    },
                  ),
                  BrmsTableFilterSelect<String>(
                label: 'PROGRAM:',
                value: _far2MfoFilter,
                items: [
                  const DropdownMenuItem(
                    value: 'ALL',
                    child: Text('All Programs'),
                  ),
                  ...BrmsFormatters.mfoPrograms.map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(m, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _far2MfoFilter = v);
                },
              ),
              BrmsTableFilterSelect<String>(
                label: 'CLASS:',
                value: _far2ClassFilter,
                items: [
                  const DropdownMenuItem(
                    value: 'ALL',
                    child: Text('All Classes'),
                  ),
                  ...BrmsFormatters.allotmentClasses.map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(BrmsFormatters.shortAllotmentLabel(c)),
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _far2ClassFilter = v);
                },
              ),
              BrmsTableFilterSelect<String>(
                label: 'SHOW:',
                value: _metricActivityFilter,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All Rows')),
                  DropdownMenuItem(
                    value: 'BUDGET',
                    child: Text('With Budget (> 0)'),
                  ),
                  DropdownMenuItem(
                    value: 'UTILIZED',
                    child: Text('With Utilizations (> 0)'),
                  ),
                  DropdownMenuItem(
                    value: 'UNPAID',
                    child: Text('With Unpaid (> 0)'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _metricActivityFilter = v);
                },
              ),
            ],
          );
            },
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrmsBadge(
                label: widget.reportType == ReportType.central
                    ? '30 COLUMNS • 5 SUPER-HEADERS'
                    : '22 COLUMNS • 5 SUPER-HEADERS',
                filled: true,
              ),
              if (_columnFilters.values.any((v) => v != '__ALL__')) ...[
                const SizedBox(width: 8),
                BrmsButton(
                  label: 'Clear Column Filters',
                  icon: Icons.filter_alt_off_outlined,
                  primary: false,
                  height: 30,
                  onPressed: () => setState(() => _columnFilters.clear()),
                ),
              ],
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 260,
              height: 32,
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
                    size: 16,
                    color: BrmsColors.outline,
                  ),
                  hintText: 'Search Program, Activity, UACS...',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: BrmsColors.outline,
                  ),
                  filled: true,
                  fillColor: BrmsColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: BrmsColors.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: BrmsColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Showing $filteredCount Lines',
              style: BrmsTheme.mono(fontSize: 11, color: BrmsColors.secondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveReportTable(UnifiedReportBundle bundle) {
    switch (widget.reportType) {
      case ReportType.central:
        return _buildPinnedMatrixTable(
          rows: bundle.centralRows,
          cols: _centralColumns,
        );
      case ReportType.registries:
        return _buildPinnedMatrixTable(
          rows: bundle.centralRows,
          cols: _registriesColumns,
        );
      case ReportType.far2:
        return _buildFar2Table(bundle);
      case ReportType.far2a:
        return _buildFar2ATable(bundle);
    }
  }

  // ---------------------------------------------------------------------------
  // Central (30 cols) & Registries (22 cols) Pinned Matrix Table
  // ---------------------------------------------------------------------------

  List<_MatrixColSpec> get _centralColumns => [
    _MatrixColSpec(
      key: 'programs',
      label: 'PROGRAMS',
      superGroup: 'CLASSIFICATION',
      width: 210,
      numeric: false,
      textValue: (r) => r.mfoProgram,
    ),
    _MatrixColSpec(
      key: 'activities',
      label: 'ACTIVITIES/PROJECTS',
      superGroup: 'CLASSIFICATION',
      width: 165,
      numeric: false,
      textValue: (r) => r.activityProject,
    ),
    _MatrixColSpec(
      key: 'allotment_class',
      label: 'ALLOTMENT CLASS',
      superGroup: 'CLASSIFICATION',
      width: 150,
      numeric: false,
      textValue: (r) => r.allotmentClass,
    ),
    _MatrixColSpec(
      key: 'object',
      label: 'OBJECT OF EXPENDITURES',
      superGroup: 'CLASSIFICATION',
      width: 215,
      numeric: false,
      textValue: (r) => r.objectOfExpenditures,
    ),
    // BUDGET (6 cols)
    _numCol(
      'beg_bal',
      'BEGINNING BALANCE',
      'BUDGET',
      (r) => r.beginningBalance,
    ),
    _numCol('b_q1', '1ST QUARTER', 'BUDGET', (r) => r.budgetQ1),
    _numCol('b_q2', '2ND QUARTER', 'BUDGET', (r) => r.budgetQ2),
    _numCol('b_q3', '3RD QUARTER', 'BUDGET', (r) => r.budgetQ3),
    _numCol('b_q4', '4TH QUARTER', 'BUDGET', (r) => r.budgetQ4),
    _numCol('b_app', 'APPROVED BUDGET', 'BUDGET', (r) => r.approvedBudget),
    // ADJUSTED BUDGET (6 cols)
    _numCol('m_q1', '1ST QUARTER', 'ADJUSTED BUDGET', (r) => r.modQ1),
    _numCol('m_q2', '2ND QUARTER', 'ADJUSTED BUDGET', (r) => r.modQ2),
    _numCol('m_q3', '3RD QUARTER', 'ADJUSTED BUDGET', (r) => r.modQ3),
    _numCol('m_q4', '4TH QUARTER', 'ADJUSTED BUDGET', (r) => r.modQ4),
    _numCol(
      'm_tot',
      'TOTAL MODIFICATION',
      'ADJUSTED BUDGET',
      (r) => r.totalModification,
    ),
    _numCol(
      'adj_b',
      'ADJUSTED BUDGET',
      'ADJUSTED BUDGET',
      (r) => r.adjustedBudget,
    ),
    // UTILIZATIONS (5 cols)
    _numCol('u_q1', '1ST QUARTER', 'UTILIZATIONS', (r) => r.utilQ1),
    _numCol('u_q2', '2ND QUARTER', 'UTILIZATIONS', (r) => r.utilQ2),
    _numCol('u_q3', '3RD QUARTER', 'UTILIZATIONS', (r) => r.utilQ3),
    _numCol('u_q4', '4TH QUARTER', 'UTILIZATIONS', (r) => r.utilQ4),
    _numCol(
      'u_tot',
      'TOTAL UTILIZATION',
      'UTILIZATIONS',
      (r) => r.totalUtilization,
    ),
    // DISBURSEMENT (5 cols)
    _numCol('d_q1', '1ST QUARTER', 'DISBURSEMENT', (r) => r.disbQ1),
    _numCol('d_q2', '2ND QUARTER', 'DISBURSEMENT', (r) => r.disbQ2),
    _numCol('d_q3', '3RD QUARTER', 'DISBURSEMENT', (r) => r.disbQ3),
    _numCol('d_q4', '4TH QUARTER', 'DISBURSEMENT', (r) => r.disbQ4),
    _numCol(
      'd_tot',
      'TOTAL DISBURSEMENT',
      'DISBURSEMENT',
      (r) => r.totalDisbursement,
    ),
    // BALANCE (4 cols)
    _numCol(
      'bal_un',
      'UNUTILIZED BUDGET',
      'BALANCE',
      (r) => r.unutilizedBudget,
    ),
    _numCol(
      'bal_dd',
      'DUE AND DEMANDABLE',
      'BALANCE',
      (r) => r.dueAndDemandable,
    ),
    _numCol('bal_ny', 'NYDDO', 'BALANCE', (r) => r.nyddo),
    _numCol(
      'bal_tu',
      'TOTAL UNPAID UTILIZATION',
      'BALANCE',
      (r) => r.totalUnpaidUtilization,
    ),
  ];

  List<_MatrixColSpec> get _registriesColumns => [
    _MatrixColSpec(
      key: 'programs',
      label: 'PROGRAMS',
      superGroup: 'CLASSIFICATION',
      width: 210,
      numeric: false,
      textValue: (r) => r.mfoProgram,
    ),
    _MatrixColSpec(
      key: 'activities',
      label: 'ACTIVITIES/PROJECTS',
      superGroup: 'CLASSIFICATION',
      width: 165,
      numeric: false,
      textValue: (r) => r.activityProject,
    ),
    _MatrixColSpec(
      key: 'allotment_class',
      label: 'ALLOTMENT CLASS',
      superGroup: 'CLASSIFICATION',
      width: 150,
      numeric: false,
      textValue: (r) => r.allotmentClass,
    ),
    _MatrixColSpec(
      key: 'object',
      label: 'OBJECT OF EXPENDITURES',
      superGroup: 'CLASSIFICATION',
      width: 215,
      numeric: false,
      textValue: (r) => r.objectOfExpenditures,
    ),
    // BUDGET (2 cols)
    _numCol(
      'beg_bal',
      'BEGINNING BALANCE',
      'BUDGET',
      (r) => r.beginningBalance,
    ),
    _numCol('b_app', 'APPROVED BUDGET', 'BUDGET', (r) => r.currentYearBudget),
    // ADJUSTED BUDGET (2 cols)
    _numCol(
      'm_tot',
      'TOTAL MODIFICATION',
      'ADJUSTED BUDGET',
      (r) => r.totalModification,
    ),
    _numCol(
      'adj_b',
      'ADJUSTED BUDGET',
      'ADJUSTED BUDGET',
      (r) => r.adjustedBudget,
    ),
    // UTILIZATIONS (5 cols)
    _numCol('u_q1', '1ST QUARTER', 'UTILIZATIONS', (r) => r.utilQ1),
    _numCol('u_q2', '2ND QUARTER', 'UTILIZATIONS', (r) => r.utilQ2),
    _numCol('u_q3', '3RD QUARTER', 'UTILIZATIONS', (r) => r.utilQ3),
    _numCol('u_q4', '4TH QUARTER', 'UTILIZATIONS', (r) => r.utilQ4),
    _numCol(
      'u_tot',
      'TOTAL UTILIZATION',
      'UTILIZATIONS',
      (r) => r.totalUtilization,
    ),
    // DISBURSEMENT (5 cols)
    _numCol('d_q1', '1ST QUARTER', 'DISBURSEMENT', (r) => r.disbQ1),
    _numCol('d_q2', '2ND QUARTER', 'DISBURSEMENT', (r) => r.disbQ2),
    _numCol('d_q3', '3RD QUARTER', 'DISBURSEMENT', (r) => r.disbQ3),
    _numCol('d_q4', '4TH QUARTER', 'DISBURSEMENT', (r) => r.disbQ4),
    _numCol(
      'd_tot',
      'TOTAL DISBURSEMENT',
      'DISBURSEMENT',
      (r) => r.totalDisbursement,
    ),
    // BALANCE (4 cols)
    _numCol(
      'bal_un',
      'UNUTILIZED BUDGET',
      'BALANCE',
      (r) => r.unutilizedBudget,
    ),
    _numCol(
      'bal_dd',
      'DUE AND DEMANDABLE',
      'BALANCE',
      (r) => r.dueAndDemandable,
    ),
    _numCol('bal_ny', 'NYDDO', 'BALANCE', (r) => r.nyddo),
    _numCol(
      'bal_tu',
      'TOTAL UNPAID UTILIZATION',
      'BALANCE',
      (r) => r.totalUnpaidUtilization,
    ),
  ];

  _MatrixColSpec _numCol(
    String key,
    String label,
    String superGroup,
    double Function(CentralReportRow row) getter,
  ) {
    return _MatrixColSpec(
      key: key,
      label: label,
      superGroup: superGroup,
      width: 142,
      numeric: true,
      textValue: (r) => BrmsFormatters.formatNumber(getter(r)),
      numericValue: getter,
    );
  }

  List<_SuperHeaderSpan> _buildSuperHeaderSpans(List<_MatrixColSpec> cols) {
    final spans = <_SuperHeaderSpan>[];
    for (final col in cols) {
      if (spans.isNotEmpty && spans.last.title == col.superGroup) {
        final prev = spans.removeLast();
        spans.add(
          _SuperHeaderSpan(title: prev.title, width: prev.width + col.width),
        );
      } else {
        spans.add(_SuperHeaderSpan(title: col.superGroup, width: col.width));
      }
    }
    return spans;
  }

  Widget _buildPinnedMatrixTable({
    required List<CentralReportRow> rows,
    required List<_MatrixColSpec> cols,
  }) {
    final pinnedCols = cols.take(4).toList();
    final metricCols = cols.skip(4).toList();
    final filtered = _filterCentralRows(rows, cols);
    final totalRow = sumCentralRows(filtered);

    final leftWidth = pinnedCols.fold<double>(0.0, (s, c) => s + c.width);
    final rightWidth = metricCols.fold<double>(0.0, (s, c) => s + c.width);
    final rightSpans = _buildSuperHeaderSpans(metricCols);

    Widget buildHeaderCell(_MatrixColSpec col) {
      final selectedVal = _columnFilters[col.key] ?? '__ALL__';
      final isFiltered = selectedVal != '__ALL__';

      final items = <DropdownMenuItem<String>>[
        const DropdownMenuItem(value: '__ALL__', child: Text('All')),
        if (!col.numeric)
          ...rows
              .map((r) => col.textValue(r))
              .toSet()
              .where((v) => v.isNotEmpty)
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text(v, overflow: TextOverflow.ellipsis),
                ),
              )
        else ...const [
          DropdownMenuItem(value: '__NONZERO__', child: Text('Non-zero (≠ 0)')),
          DropdownMenuItem(
            value: '__POSITIVE__',
            child: Text('Positive (> 0)'),
          ),
          DropdownMenuItem(
            value: '__NEGATIVE__',
            child: Text('Negative (< 0)'),
          ),
          DropdownMenuItem(value: '__ZERO__', child: Text('Zero (0.00)')),
        ],
      ];

      return Container(
        width: col.width,
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: const BoxDecoration(
          color: BrmsColors.primary,
          border: Border(
            right: BorderSide(color: Color(0xFF334155), width: 0.6),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                col.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: col.numeric ? TextAlign.right : TextAlign.left,
                style: BrmsTheme.mono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 2),
            PopupMenuButton<String>(
              tooltip: 'Filter ${col.label}',
              padding: EdgeInsets.zero,
              iconSize: 15,
              color: BrmsColors.surface,
              onSelected: (val) =>
                  setState(() => _columnFilters[col.key] = val),
              itemBuilder: (_) => items
                  .map(
                    (i) => PopupMenuItem<String>(
                      value: i.value,
                      height: 32,
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 12,
                          color: BrmsColors.onSurface,
                        ),
                        child: i.child,
                      ),
                    ),
                  )
                  .toList(),
              child: Icon(
                isFiltered ? Icons.filter_alt : Icons.arrow_drop_down,
                size: 16,
                color: isFiltered
                    ? Colors.amberAccent
                    : const Color(0xFFCBD5E1),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildDataRow(
      CentralReportRow row, {
      required bool isTotal,
      required int index,
    }) {
      final bg = isTotal
          ? BrmsColors.surfaceContainerHigh
          : (index.isOdd ? BrmsColors.surfaceContainerLow : BrmsColors.surface);

      Widget cell(_MatrixColSpec col) {
        final txt = isTotal && !col.numeric
            ? (col.key == 'programs' ? 'GRAND TOTAL' : '')
            : col.textValue(row);
        return Container(
          width: col.width,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: col.numeric ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              right: const BorderSide(
                color: BrmsColors.outlineVariant,
                width: 0.6,
              ),
              bottom: BorderSide(
                color: BrmsColors.outlineVariant,
                width: isTotal ? 1.2 : 0.6,
              ),
            ),
          ),
          child: Text(
            txt,
            overflow: TextOverflow.ellipsis,
            textAlign: col.numeric ? TextAlign.right : TextAlign.left,
            style: col.numeric
                ? BrmsTheme.mono(
                    fontSize: 11,
                    fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                    color: BrmsColors.onSurface,
                  )
                : TextStyle(
                    fontSize: 11,
                    fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                    color: BrmsColors.onSurface,
                  ),
          ),
        );
      }

      return Row(children: cols.map(cell).toList());
    }

    return BrmsCard(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final usePinnedSplit = constraints.maxWidth > leftWidth + 240;

          if (!usePinnedSplit) {
            return BrmsHorizontalTableScroll(
              showTopScrollbar: true,
              child: SizedBox(
                width: leftWidth + rightWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: _buildSuperHeaderSpans(cols)
                          .map(
                            (sp) => Container(
                              width: sp.width,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: BrmsColors.primaryContainer,
                                border: Border(
                                  right: BorderSide(
                                    color: Color(0xFF475569),
                                    width: 0.8,
                                  ),
                                ),
                              ),
                              child: Text(
                                sp.title,
                                style: BrmsTheme.mono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    Row(children: cols.map(buildHeaderCell).toList()),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No matching records for the selected filters.',
                            style: TextStyle(
                              fontSize: 12,
                              color: BrmsColors.secondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(
                        filtered.length,
                        (i) =>
                            buildDataRow(filtered[i], isTotal: false, index: i),
                      ),
                    buildDataRow(
                      totalRow,
                      isTotal: true,
                      index: filtered.length,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pinned Header Row (Left Classification + Right Scrollable Metrics)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: leftWidth,
                    child: Column(
                      children: [
                        Container(
                          width: leftWidth,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: BrmsColors.surfaceContainerLow,
                            border: Border(
                              right: BorderSide(
                                color: BrmsColors.outlineVariant,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: leftWidth,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: BrmsColors.primaryContainer,
                            border: Border(
                              right: BorderSide(
                                color: Color(0xFF475569),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Text(
                            'CLASSIFICATION',
                            style: BrmsTheme.mono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(children: pinnedCols.map(buildHeaderCell).toList()),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: _rightHeaderScroll,
                      thumbVisibility: true,
                      interactive: true,
                      scrollbarOrientation: ScrollbarOrientation.top,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SingleChildScrollView(
                          controller: _rightHeaderScroll,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: rightWidth,
                            child: Column(
                              children: [
                                Row(
                                  children: rightSpans
                                      .map(
                                        (sp) => Container(
                                          width: sp.width,
                                          height: 30,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                            color: BrmsColors.primaryContainer,
                                            border: Border(
                                              right: BorderSide(
                                                color: Color(0xFF475569),
                                                width: 0.8,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            sp.title,
                                            style: BrmsTheme.mono(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                Row(
                                  children: metricCols
                                      .map(buildHeaderCell)
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(36),
                  child: Center(
                    child: Text(
                      'No allocations or obligations match the selected filters.',
                      style: TextStyle(
                        fontSize: 12,
                        color: BrmsColors.secondary,
                      ),
                    ),
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pinned Left Rows + Grand Total
                    SizedBox(
                      width: leftWidth,
                      child: Column(
                        children: [
                          ...List.generate(filtered.length, (i) {
                            final r = filtered[i];
                            final bg = i.isOdd
                                ? BrmsColors.surfaceContainerLow
                                : BrmsColors.surface;
                            return Row(
                              children: pinnedCols
                                  .map(
                                    (col) => Container(
                                      width: col.width,
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      decoration: BoxDecoration(
                                        color: bg,
                                        border: const Border(
                                          right: BorderSide(
                                            color: BrmsColors.outlineVariant,
                                            width: 0.8,
                                          ),
                                          bottom: BorderSide(
                                            color: BrmsColors.outlineVariant,
                                            width: 0.6,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        col.textValue(r),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: BrmsColors.onSurface,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          }),
                          // Left Grand Total
                          Row(
                            children: pinnedCols
                                .map(
                                  (col) => Container(
                                    width: col.width,
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    decoration: const BoxDecoration(
                                      color: BrmsColors.surfaceContainerHigh,
                                      border: Border(
                                        right: BorderSide(
                                          color: BrmsColors.outlineVariant,
                                          width: 0.8,
                                        ),
                                        top: BorderSide(
                                          color: BrmsColors.primary,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      col.key == 'programs'
                                          ? 'GRAND TOTAL'
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: BrmsColors.onSurface,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    // Scrollable Right Metric Rows + Grand Total
                    Expanded(
                      child: Scrollbar(
                        controller: _rightBodyScroll,
                        thumbVisibility: true,
                        interactive: true,
                        scrollbarOrientation: ScrollbarOrientation.bottom,
                        child: SingleChildScrollView(
                          controller: _rightBodyScroll,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: rightWidth,
                          child: Column(
                            children: [
                              ...List.generate(filtered.length, (i) {
                                final r = filtered[i];
                                final bg = i.isOdd
                                    ? BrmsColors.surfaceContainerLow
                                    : BrmsColors.surface;
                                return Row(
                                  children: metricCols
                                      .map(
                                        (col) => Container(
                                          width: col.width,
                                          height: 40,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          alignment: Alignment.centerRight,
                                          decoration: BoxDecoration(
                                            color: bg,
                                            border: const Border(
                                              right: BorderSide(
                                                color:
                                                    BrmsColors.outlineVariant,
                                                width: 0.6,
                                              ),
                                              bottom: BorderSide(
                                                color:
                                                    BrmsColors.outlineVariant,
                                                width: 0.6,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            col.textValue(r),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                            style: BrmsTheme.mono(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: BrmsColors.onSurface,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                );
                              }),
                              // Right Grand Total
                              Row(
                                children: metricCols
                                    .map(
                                      (col) => Container(
                                        width: col.width,
                                        height: 42,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        alignment: Alignment.centerRight,
                                        decoration: const BoxDecoration(
                                          color:
                                              BrmsColors.surfaceContainerHigh,
                                          border: Border(
                                            right: BorderSide(
                                              color: BrmsColors.outlineVariant,
                                              width: 0.6,
                                            ),
                                            top: BorderSide(
                                              color: BrmsColors.primary,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          col.textValue(totalRow),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                          style: BrmsTheme.mono(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: BrmsColors.onSurface,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FAR 2 (10 Columns — Hierarchical Program/MFO Pivot)
  // ---------------------------------------------------------------------------

  Widget _buildFar2Table(UnifiedReportBundle bundle) {
    final q = _searchQuery.trim().toLowerCase();
    final expandedMfos = ref.watch(far2ExpandedMfosProvider);
    final rows = <DataRow>[];
    var grandTotal = const ReportMetrics();

    for (final group in bundle.far2Groups) {
      if (_far2MfoFilter != 'ALL' && group.mfoProgram != _far2MfoFilter) {
        continue;
      }
      final matchesParent = group.mfoProgram.toLowerCase().contains(q);
      final matchingChildren = group.children.where((c) {
        if (_far2ClassFilter != 'ALL' && c.allotmentClass != _far2ClassFilter) {
          return false;
        }
        if (!_matchesMetricActivity(c.metrics)) return false;
        if (q.isNotEmpty && !matchesParent) {
          return c.label.toLowerCase().contains(q);
        }
        return true;
      }).toList();

      if (matchingChildren.isEmpty &&
          (_far2ClassFilter != 'ALL' ||
              _metricActivityFilter != 'ALL' ||
              (q.isNotEmpty && !matchesParent))) {
        continue;
      }

      final groupTotal = matchingChildren.fold<ReportMetrics>(
        const ReportMetrics(),
        (s, c) => s + c.metrics,
      );
      grandTotal = grandTotal + groupTotal;

      final isExpanded = expandedMfos.contains(group.mfoProgram);
      rows.add(
        DataRow(
          color: WidgetStateProperty.all(BrmsColors.surfaceContainerLow),
          onSelectChanged: (_) {
            ref
                .read(far2ExpandedMfosProvider.notifier)
                .toggle(group.mfoProgram);
          },
          cells: [
            DataCell(
              SizedBox(
                width: 310,
                child: Row(
                  children: [
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 16,
                      color: BrmsColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        group.mfoProgram,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: BrmsColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ..._metricDataCells(groupTotal, bold: true),
          ],
        ),
      );

      if (isExpanded) {
        for (final child in matchingChildren) {
          rows.add(
            DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 310,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Text(
                        child.label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BrmsColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                ..._metricDataCells(child.metrics),
              ],
            ),
          );
        }
      }
    }

    rows.add(
      DataRow(
        color: WidgetStateProperty.all(BrmsColors.surfaceContainerHigh),
        cells: [
          const DataCell(
            SizedBox(
              width: 310,
              child: Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: BrmsColors.onSurface,
                ),
              ),
            ),
          ),
          ..._metricDataCells(grandTotal, bold: true),
        ],
      ),
    );

    return BrmsCard(
      padding: EdgeInsets.zero,
      child: BrmsHorizontalTableScroll(
        ensureMinWidth: true,
        showTopScrollbar: true,
        child: DataTable(
          showCheckboxColumn: false,
          headingRowColor: WidgetStateProperty.all(BrmsColors.primary),
          headingTextStyle: BrmsTheme.mono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          columnSpacing: 20,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 44,
          columns: const [
            DataColumn(label: Text('Row Labels')),
            DataColumn(label: Text('APPROVED BUDGET'), numeric: true),
            DataColumn(label: Text('TOTAL MODIFICATION'), numeric: true),
            DataColumn(label: Text('ADJUSTED BUDGET'), numeric: true),
            DataColumn(label: Text('TOTAL UTILIZATIONS'), numeric: true),
            DataColumn(label: Text('TOTAL DISBURSEMENT'), numeric: true),
            DataColumn(label: Text('UNUTILIZED BUDGET'), numeric: true),
            DataColumn(label: Text('DUE AND DEMANDABLE'), numeric: true),
            DataColumn(label: Text('NYDDO'), numeric: true),
            DataColumn(label: Text('TOTAL UNPAID UTILIZATION'), numeric: true),
          ],
          rows: rows,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FAR 2-A (10 Columns — By Object of Expenditures)
  // ---------------------------------------------------------------------------

  Widget _buildFar2ATable(UnifiedReportBundle bundle) {
    final q = _searchQuery.trim().toLowerCase();
    final visibleGroups = _selectedCat == 'ALL'
        ? bundle.far2AGroups
        : bundle.far2AGroups
              .where((g) => g.allotmentClass == _selectedCat)
              .toList();

    final rows = <DataRow>[];
    var grandTotal = const ReportMetrics();

    for (final g in visibleGroups) {
      final matchingRows = g.rows.where((r) {
        if (!_matchesMetricActivity(r.metrics)) return false;
        if (q.isNotEmpty) {
          return r.particulars.toLowerCase().contains(q) ||
              r.accountCode.toLowerCase().contains(q);
        }
        return true;
      }).toList();

      if ((q.isNotEmpty || _metricActivityFilter != 'ALL') &&
          matchingRows.isEmpty) {
        continue;
      }

      rows.add(
        DataRow(
          color: WidgetStateProperty.all(BrmsColors.surfaceContainerLow),
          cells: [
            DataCell(
              SizedBox(
                width: 310,
                child: Text(
                  g.sectionTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: BrmsColors.onSurface,
                  ),
                ),
              ),
            ),
            ...List.generate(9, (_) => const DataCell(Text(''))),
          ],
        ),
      );

      if (matchingRows.isEmpty) {
        rows.add(
          DataRow(
            cells: [
              const DataCell(
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    'No objects recorded in this classification',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: BrmsColors.secondary,
                    ),
                  ),
                ),
              ),
              ..._metricDataCells(const ReportMetrics()),
            ],
          ),
        );
      } else {
        for (final r in matchingRows) {
          rows.add(
            DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 310,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        r.particulars,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BrmsColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                ..._metricDataCells(r.metrics),
              ],
            ),
          );
        }
      }

      final sectionSubtotal = q.isEmpty
          ? g.subtotal
          : matchingRows.fold<ReportMetrics>(
              const ReportMetrics(),
              (s, r) => s + r.metrics,
            );
      grandTotal = grandTotal + sectionSubtotal;

      rows.add(
        DataRow(
          color: WidgetStateProperty.all(BrmsColors.surfaceContainerLow),
          cells: [
            DataCell(
              SizedBox(
                width: 310,
                child: Text(
                  'Subtotal - ${g.sectionTitle}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: BrmsColors.secondary,
                  ),
                ),
              ),
            ),
            ..._metricDataCells(sectionSubtotal, bold: true),
          ],
        ),
      );
    }

    rows.add(
      DataRow(
        color: WidgetStateProperty.all(BrmsColors.surfaceContainerHigh),
        cells: [
          const DataCell(
            SizedBox(
              width: 310,
              child: Text(
                'GRAND TOTAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: BrmsColors.onSurface,
                ),
              ),
            ),
          ),
          ..._metricDataCells(grandTotal, bold: true),
        ],
      ),
    );

    return BrmsCard(
      padding: EdgeInsets.zero,
      child: BrmsHorizontalTableScroll(
        ensureMinWidth: true,
        showTopScrollbar: true,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(BrmsColors.primary),
          headingTextStyle: BrmsTheme.mono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          columnSpacing: 20,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 44,
          columns: const [
            DataColumn(label: Text('PARTICULARS')),
            DataColumn(label: Text('APPROVED BUDGET'), numeric: true),
            DataColumn(label: Text('TOTAL MODIFICATION'), numeric: true),
            DataColumn(label: Text('ADJUSTED BUDGET'), numeric: true),
            DataColumn(label: Text('TOTAL UTILIZATIONS'), numeric: true),
            DataColumn(label: Text('TOTAL DISBURSEMENT'), numeric: true),
            DataColumn(label: Text('UNUTILIZED BUDGET'), numeric: true),
            DataColumn(label: Text('DUE AND DEMANDABLE'), numeric: true),
            DataColumn(label: Text('NYDDO'), numeric: true),
            DataColumn(label: Text('TOTAL UNPAID UTILIZATION'), numeric: true),
          ],
          rows: rows,
        ),
      ),
    );
  }

  List<DataCell> _metricDataCells(ReportMetrics m, {bool bold = false}) {
    final values = [
      m.approvedBudget,
      m.totalModification,
      m.adjustedBudget,
      m.totalUtilizations,
      m.totalDisbursement,
      m.unutilizedBudget,
      m.dueAndDemandable,
      m.nyddo,
      m.totalUnpaidUtilization,
    ];
    return values.map((v) {
      return DataCell(
        SizedBox(
          width: 118,
          child: Text(
            BrmsFormatters.formatNumber(v),
            textAlign: TextAlign.right,
            style: BrmsTheme.mono(
              fontSize: 11,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: BrmsColors.onSurface,
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _StatutoryMeta extends StatelessWidget {
  const _StatutoryMeta({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: BrmsTheme.mono(
              fontSize: 10,
              color: BrmsColors.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: mono
                ? BrmsTheme.mono(fontSize: 12, fontWeight: FontWeight.w600)
                : const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BrmsColors.onSurface,
                  ),
          ),
        ],
      ),
    );
  }
}

class _LabeledSelect<T> extends StatelessWidget {
  const _LabeledSelect({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: BrmsTheme.mono(
            fontSize: 11,
            color: BrmsColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: BrmsColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: BrmsColors.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              style: BrmsTheme.mono(fontSize: 11, fontWeight: FontWeight.w500),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _FarMetricCard extends StatelessWidget {
  const _FarMetricCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.subLeft,
    required this.subRight,
    required this.progress,
  });

  final String label;
  final IconData icon;
  final String value;
  final String subLeft;
  final String subRight;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return BrmsCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: BrmsTheme.mono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: BrmsColors.secondary,
                ),
              ),
              Icon(icon, size: 18, color: BrmsColors.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: BrmsTheme.mono(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  subLeft,
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
                  subRight,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: BrmsTheme.mono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BrmsProgressBar(value: progress, height: 4),
        ],
      ),
    );
  }
}

class _CatTab extends StatelessWidget {
  const _CatTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? BrmsColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: BrmsTheme.mono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : BrmsColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? BrmsColors.primaryContainer
                    : BrmsColors.surfaceContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                count,
                style: BrmsTheme.mono(
                  fontSize: 10,
                  color: selected
                      ? const Color(0xFFE2E8F0)
                      : BrmsColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
