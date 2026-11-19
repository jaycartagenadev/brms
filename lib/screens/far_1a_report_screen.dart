import 'package:flutter/material.dart';
import '../models/brms_models.dart';
import '../theme/brms_theme.dart';
import '../widgets/brms_common.dart';

/// Screen 5: BRMS CSU Aparri - FAR 1-A Report (Monochrome).
class Far1AReportScreen extends StatefulWidget {
  const Far1AReportScreen({super.key});

  @override
  State<Far1AReportScreen> createState() => _Far1AReportScreenState();
}

class _Far1AReportScreenState extends State<Far1AReportScreen> {
  String _selectedCat = 'all';
  String _fy = 'FY 2024-2025';
  String _period = '3rd Quarter (Jul 1 - Sep 30)';
  String _cluster = 'Fund 101 - General Fund (GAA)';
  String _campus = 'Aparri Main Campus (All Colleges)';

  List<Far1ARow> get _visibleRows {
    if (_selectedCat == 'all') return BrmsMockData.far1ARows;
    return BrmsMockData.far1ARows
        .where((r) => r.category == _selectedCat)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatutoryHeaderCard(context),
              const SizedBox(height: 14),
              _buildParameterFilterRibbon(context),
              const SizedBox(height: 14),
              _buildKpiCardsRow(),
              const SizedBox(height: 14),
              _buildCategoryTabsStrip(),
              const SizedBox(height: 12),
              _buildFarMatrixTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatutoryHeaderCard(BuildContext context) {
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
                      const BrmsBadge(label: 'GAM FAR NO. 1-A', filled: true),
                      Text(
                        'STATEMENT OF APPROPRIATIONS, ALLOTMENTS, OBLIGATIONS, DISBURSEMENTS & BALANCES',
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
                    'Financial Accountability Report (FAR No. 1-A)',
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
                    onPressed: () => showBrmsNotice(
                      context,
                      'Exporting FAR 1-A Workbook (showcase).',
                    ),
                  ),
                  const SizedBox(width: 8),
                  BrmsButton(
                    label: 'Print Official PDF',
                    icon: Icons.print_outlined,
                    onPressed: () => showBrmsNotice(
                      context,
                      'Generating GAM FAR 1-A PDF (showcase).',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 22, color: BrmsColors.outlineVariant),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: const [
              _StatutoryMeta(
                label: 'DEPARTMENT',
                value: 'SUCs (State Universities)',
              ),
              _StatutoryMeta(
                label: 'AGENCY / OPERATING UNIT',
                value: 'CSU Aparri Campus Budget Office',
              ),
              _StatutoryMeta(
                label: 'ORGANIZATION CODE (UACS)',
                value: '08 022 0000000',
                mono: true,
              ),
              _StatutoryMeta(
                label: 'FUND CLUSTER CODE',
                value: '01 - Regular Agency Fund',
              ),
              _StatutoryMeta(
                label: 'FUNDING SOURCE CODE',
                value: '101 (Specific Budgets - GAA)',
                mono: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParameterFilterRibbon(BuildContext context) {
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
              _LabeledSelect(
                label: 'FISCAL YEAR',
                value: _fy,
                items: const ['FY 2024-2025', 'FY 2023-2024'],
                onChanged: (v) {
                  if (v != null) setState(() => _fy = v);
                },
              ),
              _LabeledSelect(
                label: 'REPORTING PERIOD',
                value: _period,
                items: const [
                  '1st Quarter (Jan 1 - Mar 31)',
                  '2nd Quarter (Apr 1 - Jun 30)',
                  '3rd Quarter (Jul 1 - Sep 30)',
                  '4th Quarter (Oct 1 - Dec 31)',
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _period = v);
                },
              ),
              _LabeledSelect(
                label: 'FUND CLUSTER',
                value: _cluster,
                items: const [
                  'Fund 101 - General Fund (GAA)',
                  'Fund 164 - Special Trust Fund (STF / Tuition)',
                  'Fund 161 - Revolving Fund (IGP)',
                  'Fund 163 - Fiduciary Trust',
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _cluster = v);
                },
              ),
              _LabeledSelect(
                label: 'CAMPUS SUB-UNIT',
                value: _campus,
                items: const [
                  'Aparri Main Campus (All Colleges)',
                  'College of Fisheries & Marine Science',
                  'College of Information Technology',
                  'College of Hospitality Industry Management',
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _campus = v);
                },
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrmsButton(
                label: 'Apply Filters',
                icon: Icons.filter_alt_outlined,
                height: 32,
                onPressed: () =>
                    showBrmsNotice(context, 'FAR 1-A filters applied.'),
              ),
              const SizedBox(width: 8),
              BrmsButton(
                label: 'Reset',
                primary: false,
                height: 32,
                onPressed: () => setState(() {
                  _selectedCat = 'all';
                  _fy = 'FY 2024-2025';
                  _period = '3rd Quarter (Jul 1 - Sep 30)';
                  _cluster = 'Fund 101 - General Fund (GAA)';
                  _campus = 'Aparri Main Campus (All Colleges)';
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCardsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          const _FarMetricCard(
            label: 'TOTAL ALLOTMENTS RECEIVED',
            icon: Icons.account_balance_wallet_outlined,
            value: '₱82,450,000.00',
            subLeft: 'Adjusted Authorized',
            subRight: '₱82,450,000.00',
            progress: 1.0,
          ),
          const _FarMetricCard(
            label: 'CUMULATIVE OBLIGATIONS',
            icon: Icons.receipt_long_outlined,
            value: '₱62,390,410.50',
            subLeft: 'Total 142 Approved OBRs',
            subRight: '75.67% Utilization',
            progress: 0.7567,
          ),
          const _FarMetricCard(
            label: 'DISBURSEMENTS LIQUIDATED',
            icon: Icons.payments_outlined,
            value: '₱54,820,115.00',
            subLeft: 'Disbursement Rate',
            subRight: '87.87% of Oblig.',
            progress: 0.8787,
          ),
          const _FarMetricCard(
            label: 'UNOBLIGATED ALLOTMENT',
            icon: Icons.savings_outlined,
            value: '₱20,059,589.50',
            subLeft: 'Unpaid Obligations (AP)',
            subRight: '₱7,570,295.50',
            progress: 0.2433,
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

  Widget _buildCategoryTabsStrip() {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
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
                label: 'FAR 1-A Rollup',
                count: '46',
                selected: _selectedCat == 'all',
                onTap: () => setState(() => _selectedCat = 'all'),
              ),
              _CatTab(
                label: 'PS (Personal Services)',
                count: '12',
                selected: _selectedCat == 'ps',
                onTap: () => setState(() => _selectedCat = 'ps'),
              ),
              _CatTab(
                label: 'MOOE',
                count: '28',
                selected: _selectedCat == 'mooe',
                onTap: () => setState(() => _selectedCat = 'mooe'),
              ),
              _CatTab(
                label: 'CO (Capital Outlays)',
                count: '6',
                selected: _selectedCat == 'co',
                onTap: () => setState(() => _selectedCat = 'co'),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 240,
              height: 32,
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 16,
                    color: BrmsColors.outline,
                  ),
                  hintText: 'Search UACS or Object...',
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
              'Showing ${_visibleRows.length} Lines',
              style: BrmsTheme.mono(fontSize: 11, color: BrmsColors.secondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFarMatrixTable() {
    return BrmsCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(BrmsColors.primary),
          headingTextStyle: BrmsTheme.mono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          columnSpacing: 18,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 44,
          columns: const [
            DataColumn(label: Text('PARTICULARS / OBJECT')),
            DataColumn(label: Text('UACS CODE')),
            DataColumn(label: Text('AUTHORIZED'), numeric: true),
            DataColumn(label: Text('ADJ.'), numeric: true),
            DataColumn(label: Text('ADJUSTED'), numeric: true),
            DataColumn(label: Text('RECEIVED'), numeric: true),
            DataColumn(label: Text('TOTAL ALLOT.'), numeric: true),
            DataColumn(label: Text('OBLIG. Q1'), numeric: true),
            DataColumn(label: Text('OBLIG. Q2'), numeric: true),
            DataColumn(label: Text('OBLIG. Q3'), numeric: true),
            DataColumn(label: Text('OBLIG. TOTAL'), numeric: true),
            DataColumn(label: Text('DISB. TOTAL'), numeric: true),
            DataColumn(label: Text('UNOBLIGATED'), numeric: true),
            DataColumn(label: Text('UNPAID DUE'), numeric: true),
          ],
          rows: _visibleRows.map((row) {
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 240,
                    child: Text(
                      row.particulars,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    row.uacsCode,
                    style: BrmsTheme.mono(
                      fontSize: 11,
                      color: BrmsColors.secondary,
                    ),
                  ),
                ),
                DataCell(Text(row.authorized, style: BrmsTheme.mono(fontSize: 11))),
                DataCell(
                  Text(
                    row.appropAdj,
                    style: BrmsTheme.mono(
                      fontSize: 11,
                      color: BrmsColors.secondary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    row.adjusted,
                    style: BrmsTheme.mono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataCell(Text(row.received, style: BrmsTheme.mono(fontSize: 11))),
                DataCell(
                  Text(
                    row.totalAllot,
                    style: BrmsTheme.mono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataCell(Text(row.obQ1, style: BrmsTheme.mono(fontSize: 11))),
                DataCell(Text(row.obQ2, style: BrmsTheme.mono(fontSize: 11))),
                DataCell(Text(row.obQ3, style: BrmsTheme.mono(fontSize: 11))),
                DataCell(
                  Text(
                    row.obTotal,
                    style: BrmsTheme.mono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    row.disbTotal,
                    style: BrmsTheme.mono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    row.unobligated,
                    style: BrmsTheme.mono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    row.unpaidDue,
                    style: BrmsTheme.mono(
                      fontSize: 11,
                      color: BrmsColors.secondary,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
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

class _LabeledSelect extends StatelessWidget {
  const _LabeledSelect({
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
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              style: BrmsTheme.mono(fontSize: 11, fontWeight: FontWeight.w500),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
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
