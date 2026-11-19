import 'package:flutter/material.dart';
import '../models/brms_models.dart';
import '../theme/brms_theme.dart';
import '../widgets/brms_common.dart';

/// Screen 4: BRMS CSU Aparri - Obligation Registry (Monochrome).
class ObligationRegistryScreen extends StatefulWidget {
  const ObligationRegistryScreen({super.key});

  @override
  State<ObligationRegistryScreen> createState() =>
      _ObligationRegistryScreenState();
}

class _ObligationRegistryScreenState extends State<ObligationRegistryScreen> {
  RegistryObrRecord _selectedObr = BrmsMockData.registryObrs.first;
  String _fundFilter = 'Fund Source: All (101, 161, 164, 184)';
  String _classFilter = 'Class: All (PS, MOOE, CO)';
  String _periodFilter = 'Period: Current FY 2024-2025';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPageTitleBar(context),
        const SizedBox(height: 16),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterControlsBar(),
                  const SizedBox(height: 18),
                  _buildMasterDetailSplit(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageTitleBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: BrmsColors.surface,
        border: Border(
          top: BorderSide(color: BrmsColors.outlineVariant),
          bottom: BorderSide(color: BrmsColors.outlineVariant),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OBLIGATION REGISTRIES',
                    style: BrmsTheme.heading(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Cagayan State University Aparri • Registry of Allotments, Obligations and Balances (FAR No. 1-A)',
                    style: TextStyle(fontSize: 12, color: BrmsColors.secondary),
                  ),
                ],
              ),
              SizedBox(width: 25),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrmsButton(
                    label: 'Create new',
                    icon: Icons.add,
                    onPressed: () => showBrmsNotice(
                      context,
                      'Create OBR dialog (static UI showcase).',
                    ),
                  ),
                  const SizedBox(width: 8),
                  BrmsButton(
                    label: 'Export CSV',
                    icon: Icons.file_download_outlined,
                    primary: false,
                    onPressed: () => showBrmsNotice(
                      context,
                      'Exporting Obligation Log to CSV (showcase).',
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

  Widget _buildFilterControlsBar() {
    return BrmsCard(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 300,
            height: 36,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                  color: BrmsColors.outline,
                ),
                hintText: 'Search OBR No., Payee, Particular, or UACS...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: BrmsColors.outline,
                ),
                filled: true,
                fillColor: BrmsColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: BrmsColors.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: BrmsColors.primary),
                ),
              ),
            ),
          ),
          _CompactSelect(
            icon: Icons.account_balance_outlined,
            value: _fundFilter,
            items: const [
              'Fund Source: All (101, 161, 164, 184)',
              '101 - Regular Agency Fund',
              '161 - Special Account (Locally Funded)',
              '164 - Special Trust Fund (Tuition)',
              '184 - Revolving Fund (Agri/Fish Enterprise)',
            ],
            onChanged: (v) {
              if (v != null) setState(() => _fundFilter = v);
            },
          ),
          _CompactSelect(
            icon: Icons.category_outlined,
            value: _classFilter,
            items: const [
              'Class: All (PS, MOOE, CO)',
              'PS - Personnel Services',
              'MOOE - Maintenance & Other',
              'CO - Capital Outlay',
            ],
            onChanged: (v) {
              if (v != null) setState(() => _classFilter = v);
            },
          ),
          _CompactSelect(
            icon: Icons.calendar_today_outlined,
            value: _periodFilter,
            items: const [
              'Period: Current FY 2024-2025',
              'Q1 (Jan - Mar)',
              'Q2 (Apr - Jun)',
              'Q3 (Jul - Sep)',
              'Q4 (Oct - Dec)',
            ],
            onChanged: (v) {
              if (v != null) setState(() => _periodFilter = v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMasterDetailSplit(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;
        final masterTable = _buildMasterLedgerCard();
        final detailPanel = _buildDetailInspectionPanel(context);

        if (!isWide) {
          return Column(
            children: [masterTable, const SizedBox(height: 18), detailPanel],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: masterTable),
            const SizedBox(width: 20),
            Expanded(flex: 5, child: detailPanel),
          ],
        );
      },
    );
  }

  Widget _buildMasterLedgerCard() {
    return BrmsCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: BrmsColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 18,
                      color: Color(0xFFCBD5E1),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'OBLIGATION LOG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Total Obligations: Php 262,244.41  |  3 of 3 entries',
                  style: BrmsTheme.mono(
                    fontSize: 11,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              showCheckboxColumn: false,
              headingRowColor: WidgetStateProperty.all(
                BrmsColors.surfaceContainerLow,
              ),
              headingTextStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BrmsColors.onSurfaceVariant,
              ),
              columns: const [
                DataColumn(label: Text('DATE')),
                DataColumn(label: Text('OBR NO.')),
                DataColumn(label: Text('ALLOTMENT CLASSIFICATION')),
                DataColumn(label: Text('PAYEE')),
                DataColumn(label: Text('PARTICULAR')),
                DataColumn(label: Text('GROSS AMOUNT'), numeric: true),
                DataColumn(label: Text('ACTION')),
              ],
              rows: BrmsMockData.registryObrs.map((obr) {
                final isSelected = obr.obrNo == _selectedObr.obrNo;
                return DataRow(
                  selected: isSelected,
                  color: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (isSelected) return BrmsColors.surfaceContainerLow;
                    return null;
                  }),
                  onSelectChanged: (_) => setState(() => _selectedObr = obr),
                  cells: [
                    DataCell(
                      Text(
                        obr.date,
                        style: BrmsTheme.mono(
                          fontSize: 11,
                          color: BrmsColors.secondary,
                        ),
                      ),
                    ),
                    DataCell(BrmsBadge(label: obr.obrNo, filled: isSelected)),
                    DataCell(BrmsBadge(label: obr.allotmentClass)),
                    DataCell(
                      Text(
                        obr.payee,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          obr.particular,
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
                        obr.grossAmount,
                        style: BrmsTheme.mono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DataCell(
                      BrmsButton(
                        label: 'View full details',
                        primary: isSelected,
                        height: 28,
                        onPressed: () => setState(() => _selectedObr = obr),
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
              color: BrmsColors.surface,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border(top: BorderSide(color: BrmsColors.outlineVariant)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing 3 of 3 items',
                  style: BrmsTheme.mono(
                    fontSize: 11,
                    color: BrmsColors.secondary,
                  ),
                ),
                const BrmsBadge(label: '1', filled: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInspectionPanel(BuildContext context) {
    final d = _selectedObr;
    return BrmsCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: BrmsColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.receipt_outlined,
                          size: 16,
                          color: BrmsColors.outline,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'RECORD DETAILS',
                          style: BrmsTheme.mono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: BrmsColors.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'OBR No. ${d.obrNo}',
                      style: BrmsTheme.heading(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: BrmsColors.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: BrmsColors.outline,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        d.status,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BrmsColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: BrmsColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetaCell(
                              label: 'DATE',
                              value: d.date,
                              mono: true,
                            ),
                          ),
                          Expanded(
                            child: _MetaCell(
                              label: 'FUND CODE',
                              value: d.fundCode,
                              mono: true,
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 16,
                        color: BrmsColors.outlineVariant,
                      ),
                      _MetaCell(
                        label: 'ACCOUNT CODE (UACS)',
                        value: d.uacsCode,
                        mono: true,
                      ),
                      const Divider(
                        height: 16,
                        color: BrmsColors.outlineVariant,
                      ),
                      _MetaCell(
                        label: 'ALLOTMENT CLASSIFICATION',
                        value: d.allotmentClass,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'PAYEE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: BrmsColors.secondary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BrmsColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: BrmsColors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 18,
                        color: BrmsColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        d.payee,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'PARTICULAR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: BrmsColors.secondary,
                    letterSpacing: 0.6,
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
                  child: Text(
                    d.particular,
                    style: const TextStyle(
                      fontSize: 12,
                      color: BrmsColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BrmsColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: BrmsColors.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'GROSS AMOUNT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: BrmsColors.secondary,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        d.grossAmount,
                        style: BrmsTheme.mono(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BrmsColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: BrmsColors.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SUPPORTING ATTACHMENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: BrmsColors.secondary,
                            ),
                          ),
                          Text(
                            'PDF Document',
                            style: TextStyle(
                              fontSize: 10,
                              color: BrmsColors.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: BrmsColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: BrmsColors.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BrmsColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: BrmsColors.outlineVariant,
                                ),
                              ),
                              child: const Icon(
                                Icons.picture_as_pdf_outlined,
                                size: 17,
                                color: BrmsColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.attachmentName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    d.attachmentMeta,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: BrmsColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            BrmsButton(
                              label: 'Open',
                              icon: Icons.open_in_new,
                              primary: false,
                              height: 28,
                              onPressed: () => showBrmsNotice(
                                context,
                                'Opening ${d.attachmentName} (showcase).',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: BrmsColors.outlineVariant),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BrmsButton(
                      label: 'Back',
                      icon: Icons.arrow_back,
                      primary: false,
                      height: 32,
                      onPressed: () =>
                          showBrmsNotice(context, 'Selection reset.'),
                    ),
                    BrmsButton(
                      label: 'Edit',
                      icon: Icons.edit_outlined,
                      height: 32,
                      onPressed: () => showBrmsNotice(
                        context,
                        'Editing OBR No. ${d.obrNo} (showcase).',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: BrmsColors.secondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: mono
              ? BrmsTheme.mono(fontSize: 12, fontWeight: FontWeight.w700)
              : const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _CompactSelect extends StatelessWidget {
  const _CompactSelect({
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: BrmsColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BrmsColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: BrmsColors.secondary),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: BrmsColors.onSurface,
              ),
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
