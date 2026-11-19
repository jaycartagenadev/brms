import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../providers/brms_providers.dart';
import '../theme/brms_theme.dart';
import '../utils/brms_formatters.dart';
import '../widgets/brms_common.dart';

/// Screen 3: BRMS CSU Aparri - Set Budget Allocation (Monochrome).
class SetBudgetScreen extends ConsumerStatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  ConsumerState<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends ConsumerState<SetBudgetScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _editingAllocationId;
  String _selectedFy = '2024-2025';
  String _selectedFundCode = '101';
  String _selectedAllotmentClass = BrmsFormatters.allotmentClasses.first;
  String? _selectedAccountCode;
  DateTime _selectedDate = DateTime.now();

  late final TextEditingController _dateController;
  final _amountController = TextEditingController();
  final _tableSearchController = TextEditingController();
  String _tableSearchQuery = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: BrmsFormatters.toDisplayDate(_selectedDate),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _tableSearchController.dispose();
    super.dispose();
  }

  void _resetForm({List<UacsCode>? uacsList}) {
    setState(() {
      _editingAllocationId = null;
      _selectedFy = '2024-2025';
      _selectedFundCode = '101';
      _selectedAllotmentClass = BrmsFormatters.allotmentClasses.first;
      _selectedDate = DateTime.now();
      _dateController.text = BrmsFormatters.toDisplayDate(_selectedDate);
      _amountController.clear();
      _selectedAccountCode = _defaultAccountCodeForClass(
        _selectedAllotmentClass,
        uacsList ?? const [],
      );
    });
  }

  String? _defaultAccountCodeForClass(
    String allotmentClass,
    List<UacsCode> uacsList,
  ) {
    final matching =
        uacsList.where((u) => u.allotmentClass == allotmentClass).toList();
    return matching.isNotEmpty ? matching.first.accountCode : null;
  }

  Future<void> _pickAllocationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = BrmsFormatters.toDisplayDate(picked);
      });
    }
  }

  void _populateForEdit(BudgetAllocation row) {
    final parsedDate =
        BrmsFormatters.parseIsoDate(row.dateOfAllocation) ?? DateTime.now();
    setState(() {
      _editingAllocationId = row.id;
      _selectedFy = BrmsFormatters.fiscalYears.contains(row.fiscalYear)
          ? row.fiscalYear
          : BrmsFormatters.fiscalYears.first;
      _selectedFundCode = row.fundCode;
      _selectedAllotmentClass =
          BrmsFormatters.allotmentClasses.contains(row.allotmentClass)
              ? row.allotmentClass
              : BrmsFormatters.allotmentClasses.first;
      _selectedAccountCode = row.accountCode;
      _selectedDate = parsedDate;
      _dateController.text = BrmsFormatters.toDisplayDate(parsedDate);
      _amountController.text = BrmsFormatters.formatNumber(
        row.allotmentReceived,
      );
    });
  }

  Future<void> _saveAllocation(List<UacsCode> uacsList) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = BrmsFormatters.parseAmount(_amountController.text);
    if (amount == null || amount <= 0) {
      showBrmsNotice(context, 'Enter a valid positive allocation amount.');
      return;
    }

    final isoDate = BrmsFormatters.toIsoDate(_selectedDate);
    final validUacs = uacsList
        .where((u) => u.allotmentClass == _selectedAllotmentClass)
        .map((u) => u.accountCode)
        .toSet();
    final accountCode =
        (_selectedAccountCode != null && validUacs.contains(_selectedAccountCode))
            ? _selectedAccountCode
            : null;

    setState(() => _isSaving = true);
    try {
      final db = ref.read(databaseProvider);
      if (_editingAllocationId == null) {
        await db.insertBudgetAllocation(
          fiscalYear: _selectedFy,
          fundCode: _selectedFundCode,
          allotmentClass: _selectedAllotmentClass,
          accountCode: accountCode,
          amount: amount,
          dateOfAllocation: isoDate,
        );
        if (mounted) {
          showBrmsNotice(
            context,
            'Saved budget allocation for Fund $_selectedFundCode ($_selectedFy).',
          );
        }
      } else {
        await db.updateBudgetAllocation(
          id: _editingAllocationId!,
          fiscalYear: _selectedFy,
          fundCode: _selectedFundCode,
          allotmentClass: _selectedAllotmentClass,
          accountCode: accountCode,
          amount: amount,
          dateOfAllocation: isoDate,
        );
        if (mounted) {
          showBrmsNotice(
            context,
            'Updated budget allocation for Fund $_selectedFundCode ($_selectedFy).',
          );
        }
      }
      if (mounted) {
        _resetForm(uacsList: uacsList);
      }
    } catch (e) {
      if (mounted) {
        showBrmsNotice(context, 'Failed to save allocation: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleHide(BudgetAllocation row) async {
    final db = ref.read(databaseProvider);
    final nextHidden = row.isHidden == 0;
    await db.setBudgetAllocationHidden(id: row.id, hidden: nextHidden);
    if (mounted) {
      showBrmsNotice(
        context,
        nextHidden
            ? 'Allocation for Fund ${row.fundCode} hidden from active balances.'
            : 'Allocation for Fund ${row.fundCode} restored to active balances.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fundsAsync = ref.watch(fundSourcesProvider);
    final uacsAsync = ref.watch(uacsCodesProvider);
    final allocationsAsync = ref.watch(budgetAllocationsProvider);

    final funds = fundsAsync.value ?? const <FundSource>[];
    final uacsList = uacsAsync.value ?? const <UacsCode>[];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSetBudgetFormCard(funds: funds, uacsList: uacsList),
              const SizedBox(height: 24),
              _buildSummaryTableCard(allocationsAsync),
              const SizedBox(height: 24),
              const Divider(color: BrmsColors.outlineVariant),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Cagayan State University Aparri Campus • Budget Allocation Ledger',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BrmsColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetBudgetFormCard({
    required List<FundSource> funds,
    required List<UacsCode> uacsList,
  }) {
    final fundItems = funds.isNotEmpty
        ? funds.map((f) => f.fundCode).toList()
        : const ['101', '161', '164', '184'];
    final activeFundCode = fundItems.contains(_selectedFundCode)
        ? _selectedFundCode
        : fundItems.first;

    final filteredUacs = uacsList
        .where((u) => u.allotmentClass == _selectedAllotmentClass)
        .toList();
    final activeAccountCode = filteredUacs.any(
      (u) => u.accountCode == _selectedAccountCode,
    )
        ? _selectedAccountCode
        : (filteredUacs.isNotEmpty ? filteredUacs.first.accountCode : null);

    return BrmsCard(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editingAllocationId == null
                          ? 'Set Budget'
                          : 'Edit Budget Allocation',
                      style: BrmsTheme.heading(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Allocate statutory appropriations and allotment ceilings for CSU Aparri Campus fiscal funds.',
                      style: TextStyle(
                        fontSize: 12,
                        color: BrmsColors.secondary,
                      ),
                    ),
                  ],
                ),
                if (_editingAllocationId != null)
                  const BrmsBadge(label: 'EDIT MODE', filled: true),
              ],
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, constraints) {
                final isTwoCol = constraints.maxWidth >= 680;

                final fyField = _buildDropdownField<String>(
                  label: 'FISCAL YEAR',
                  value: _selectedFy,
                  items: BrmsFormatters.fiscalYears
                      .map((fy) => DropdownMenuItem(value: fy, child: Text(fy)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedFy = v);
                  },
                );

                final dateField = _buildDateField(
                  label: 'DATE OF ALLOCATION',
                  controller: _dateController,
                  onTap: _pickAllocationDate,
                );

                final fundField = _buildDropdownField<String>(
                  label: 'FUND CODE',
                  value: activeFundCode,
                  items: funds.isNotEmpty
                      ? funds
                          .map(
                            (f) => DropdownMenuItem(
                              value: f.fundCode,
                              child: Text('${f.fundCode} - ${f.fundName}'),
                            ),
                          )
                          .toList()
                      : fundItems
                          .map(
                            (code) => DropdownMenuItem(
                              value: code,
                              child: Text(code),
                            ),
                          )
                          .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedFundCode = v);
                  },
                );

                final classField = _buildDropdownField<String>(
                  label: 'ALLOTMENT CLASSIFICATION',
                  value: _selectedAllotmentClass,
                  items: BrmsFormatters.allotmentClasses
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _selectedAllotmentClass = v;
                        _selectedAccountCode = _defaultAccountCodeForClass(
                          v,
                          uacsList,
                        );
                      });
                    }
                  },
                );

                final uacsField = _buildDropdownField<String?>(
                  label: 'ACCOUNT CODE (UACS)',
                  value: activeAccountCode,
                  items: filteredUacs.isNotEmpty
                      ? filteredUacs
                          .map(
                            (u) => DropdownMenuItem<String?>(
                              value: u.accountCode,
                              child: Text(
                                '${u.accountCode} - ${u.objectTitle}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList()
                      : const [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              'No UACS code seeded for this class (Optional)',
                              style: TextStyle(color: BrmsColors.secondary),
                            ),
                          ),
                        ],
                  onChanged: filteredUacs.isNotEmpty
                      ? (v) => setState(() => _selectedAccountCode = v)
                      : null,
                );

                final amountField = _buildInputField(
                  label: 'AMOUNT (₱)',
                  controller: _amountController,
                  prefixText: 'Php ',
                  hintText: '0.00',
                  mono: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (val) {
                    final parsed = BrmsFormatters.parseAmount(val ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a positive amount';
                    }
                    return null;
                  },
                );

                if (!isTwoCol) {
                  return Column(
                    children: [
                      fyField,
                      const SizedBox(height: 16),
                      dateField,
                      const SizedBox(height: 16),
                      fundField,
                      const SizedBox(height: 16),
                      classField,
                      const SizedBox(height: 16),
                      uacsField,
                      const SizedBox(height: 16),
                      amountField,
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: fyField),
                        const SizedBox(width: 20),
                        Expanded(child: dateField),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: fundField),
                        const SizedBox(width: 20),
                        Expanded(child: classField),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: uacsField),
                        const SizedBox(width: 20),
                        Expanded(child: amountField),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                BrmsButton(
                  label: 'Cancel',
                  primary: false,
                  onPressed: _isSaving
                      ? null
                      : () {
                          _resetForm(uacsList: uacsList);
                          showBrmsNotice(context, 'Allocation form reset.');
                        },
                ),
                const SizedBox(width: 10),
                BrmsButton(
                  label: _editingAllocationId == null ? 'Save' : 'Update',
                  onPressed:
                      _isSaving ? null : () => _saveAllocation(uacsList),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTableCard(
    AsyncValue<List<BudgetAllocation>> allocationsAsync,
  ) {
    return BrmsCard(
      padding: const EdgeInsets.all(24),
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
                  Text(
                    'Summary of Allocated Budgets',
                    style: BrmsTheme.heading(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Master list of registered fiscal appropriations and releases',
                    style: TextStyle(fontSize: 12, color: BrmsColors.secondary),
                  ),
                ],
              ),
              SizedBox(
                width: 220,
                height: 34,
                child: TextField(
                  controller: _tableSearchController,
                  onChanged: (v) =>
                      setState(() => _tableSearchQuery = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 16,
                      color: BrmsColors.secondary,
                    ),
                    hintText: 'Filter records...',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: BrmsColors.secondary,
                    ),
                    filled: true,
                    fillColor: BrmsColors.surfaceContainerLow,
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
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: BrmsColors.outlineVariant),
          allocationsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error loading allocations: $err',
                style: const TextStyle(color: BrmsColors.error, fontSize: 12),
              ),
            ),
            data: (rows) {
              final filtered = _tableSearchQuery.isEmpty
                  ? rows
                  : rows.where((r) {
                      return r.fiscalYear.toLowerCase().contains(
                                _tableSearchQuery,
                              ) ||
                          r.fundCode.toLowerCase().contains(
                                _tableSearchQuery,
                              ) ||
                          r.allotmentClass.toLowerCase().contains(
                                _tableSearchQuery,
                              ) ||
                          (r.accountCode ?? '').toLowerCase().contains(
                                _tableSearchQuery,
                              );
                    }).toList();

              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No budget allocations recorded yet. Use the form above to add one.',
                      style: TextStyle(
                        fontSize: 12,
                        color: BrmsColors.secondary,
                      ),
                    ),
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        headingTextStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: BrmsColors.secondary,
                          letterSpacing: 0.4,
                        ),
                        columns: const [
                          DataColumn(label: Text('FISCAL YEAR')),
                          DataColumn(label: Text('FUND CODE')),
                          DataColumn(label: Text('ALLOTMENT CLASS')),
                          DataColumn(label: Text('DATE OF ALLOCATION')),
                          DataColumn(label: Text('AMOUNT'), numeric: true),
                          DataColumn(label: Center(child: Text('ACTION'))),
                        ],
                        rows: filtered.map((entry) {
                          final isHidden = entry.isHidden == 1;
                          final textColor = isHidden
                              ? BrmsColors.outline
                              : BrmsColors.onSurface;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  entry.fiscalYear,
                                  style: BrmsTheme.mono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      entry.fundCode,
                                      style: BrmsTheme.mono(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                    if (isHidden) ...[
                                      const SizedBox(width: 6),
                                      const BrmsBadge(label: 'HIDDEN'),
                                    ],
                                  ],
                                ),
                              ),
                              DataCell(
                                BrmsBadge(
                                  label: BrmsFormatters.shortAllotmentLabel(
                                    entry.allotmentClass,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  BrmsFormatters.isoToDisplay(
                                    entry.dateOfAllocation,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isHidden
                                        ? BrmsColors.outline
                                        : BrmsColors.secondary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  BrmsFormatters.formatPhp(
                                    entry.allotmentReceived,
                                  ),
                                  style: BrmsTheme.mono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => _populateForEdit(entry),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: BrmsColors.onSurface,
                                          side: const BorderSide(
                                            color: BrmsColors.outlineVariant,
                                          ),
                                          shape: const StadiumBorder(),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          minimumSize: Size.zero,
                                        ),
                                        child: const Text(
                                          'Edit',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: () => _toggleHide(entry),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: BrmsColors.secondary,
                                          side: const BorderSide(
                                            color: BrmsColors.outlineVariant,
                                          ),
                                          shape: const StadiumBorder(),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          minimumSize: Size.zero,
                                        ),
                                        child: Text(
                                          isHidden ? 'Unhide' : 'Hide',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: BrmsColors.secondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          key: ValueKey(value),
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: BrmsColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: BrmsColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: BrmsColors.primary),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: BrmsColors.secondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: BrmsTheme.mono(fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: BrmsColors.secondary,
            ),
            filled: true,
            fillColor: BrmsColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: BrmsColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: BrmsColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? prefixText,
    String? hintText,
    bool mono = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: BrmsColors.secondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: mono
              ? BrmsTheme.mono(fontSize: 13, fontWeight: FontWeight.w700)
              : const TextStyle(fontSize: 13, color: BrmsColors.onSurface),
          decoration: InputDecoration(
            prefixText: prefixText,
            hintText: hintText,
            filled: true,
            fillColor: BrmsColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: BrmsColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: BrmsColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: BrmsColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: BrmsColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
