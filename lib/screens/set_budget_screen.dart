import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../providers/brms_providers.dart';
import '../theme/brms_theme.dart';
import '../utils/brms_formatters.dart';
import '../widgets/brms_common.dart';
import '../widgets/brms_confirm_dialog.dart';
import '../widgets/uacs_management_dialog.dart';

/// Screen 3: BRMS CSU Aparri - Set Budget Allocation (Monochrome).
class SetBudgetScreen extends ConsumerStatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  ConsumerState<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends ConsumerState<SetBudgetScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _editingAllocationId;
  String _selectedFy = BrmsFormatters.currentFiscalYear;
  String _selectedFundCode = '101';
  String _selectedMfoProgram = BrmsFormatters.mfoPrograms.first;
  String _selectedAllotmentClass = BrmsFormatters.allotmentClasses.first;
  String? _selectedAccountCode;
  DateTime _selectedDate = DateTime.now();

  late final TextEditingController _dateController;
  final _activityController = TextEditingController(text: 'General Operations');
  final _activityFocusNode = FocusNode();
  final _accountCodeController = TextEditingController();
  final _accountCodeFocusNode = FocusNode();
  final _beginningBalanceController = TextEditingController();
  final _amountController = TextEditingController();
  final _modificationController = TextEditingController();
  final _tableSearchController = TextEditingController();
  String _tableSearchQuery = '';
  String _tableFyFilter = 'ALL';
  String _tableFundFilter = 'ALL';
  String _tableProgramFilter = 'ALL';
  String _tableClassFilter = 'ALL';
  String _tableVisibilityFilter = 'ALL';

  final _modSearchController = TextEditingController();
  String _modSearchQuery = '';
  String _modFyFilter = 'ALL';
  String _modFundFilter = 'ALL';
  String _modClassFilter = 'ALL';
  String _modDirectionFilter = 'ALL';
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
    _activityController.dispose();
    _activityFocusNode.dispose();
    _accountCodeController.dispose();
    _accountCodeFocusNode.dispose();
    _beginningBalanceController.dispose();
    _amountController.dispose();
    _modificationController.dispose();
    _tableSearchController.dispose();
    _modSearchController.dispose();
    super.dispose();
  }

  void _resetForm({List<UacsCode>? uacsList}) {
    setState(() {
      _editingAllocationId = null;
      _selectedFy = BrmsFormatters.currentFiscalYear;
      _selectedFundCode = '101';
      _selectedMfoProgram = BrmsFormatters.mfoPrograms.first;
      _selectedAllotmentClass = BrmsFormatters.allotmentClasses.first;
      _selectedDate = DateTime.now();
      _dateController.text = BrmsFormatters.toDisplayDate(_selectedDate);
      _activityController.text = 'General Operations';
      _beginningBalanceController.clear();
      _amountController.clear();
      _modificationController.clear();
      _selectedAccountCode = _defaultAccountCodeForClass(
        _selectedAllotmentClass,
        uacsList ?? const [],
      );
      _accountCodeController.text = _selectedAccountCode ?? '';
    });
  }

  String? _defaultAccountCodeForClass(
    String allotmentClass,
    List<UacsCode> uacsList,
  ) {
    final matching = uacsList
        .where((u) => u.allotmentClass == allotmentClass)
        .toList();
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
      _selectedMfoProgram = BrmsFormatters.mfoPrograms.contains(row.mfoProgram)
          ? row.mfoProgram
          : BrmsFormatters.mfoPrograms.first;
      _activityController.text = row.activityProject;
      _selectedAllotmentClass =
          BrmsFormatters.allotmentClasses.contains(row.allotmentClass)
          ? row.allotmentClass
          : BrmsFormatters.allotmentClasses.first;
      _selectedAccountCode = row.accountCode;
      _accountCodeController.text = row.accountCode ?? '';
      _selectedDate = parsedDate;
      _dateController.text = BrmsFormatters.toDisplayDate(parsedDate);
      _beginningBalanceController.text = row.beginningBalance == 0
          ? ''
          : BrmsFormatters.formatNumber(row.beginningBalance);
      _amountController.text = row.authorizedAppropriations == 0
          ? ''
          : BrmsFormatters.formatNumber(row.authorizedAppropriations);
      _modificationController.clear();
    });
  }

  Future<void> _saveAllocation(List<UacsCode> uacsList) async {
    final beginningBalance =
        BrmsFormatters.parseAmount(_beginningBalanceController.text) ?? 0.0;
    final amount = BrmsFormatters.parseAmount(_amountController.text) ?? 0.0;
    final modAmount =
        BrmsFormatters.parseAmount(_modificationController.text) ?? 0.0;

    if (!(_formKey.currentState?.validate() ?? false)) {
      showBrmsNotice(context, 'Please fill in the highlighted required fields.');
      return;
    }

    if (beginningBalance <= 0 && amount <= 0 && modAmount == 0) {
      showBrmsNotice(
        context,
        'Enter a positive Budget Amount, Beginning Balance, or Modification.',
      );
      return;
    }

    final activityProject = _activityController.text.trim().isEmpty
        ? 'General Operations'
        : _activityController.text.trim();
    final isoDate = BrmsFormatters.toIsoDate(_selectedDate);
    final typedCode = _accountCodeController.text.trim();
    final validUacs = uacsList
        .where((u) => u.allotmentClass == _selectedAllotmentClass)
        .map((u) => u.accountCode)
        .toSet();
    final accountCode = validUacs.contains(typedCode)
        ? typedCode
        : (validUacs.contains(_selectedAccountCode)
              ? _selectedAccountCode
              : null);

    setState(() => _isSaving = true);
    try {
      final db = ref.read(databaseProvider);
      int allocationId;
      if (_editingAllocationId == null) {
        allocationId = await db.insertBudgetAllocation(
          fiscalYear: _selectedFy,
          fundCode: _selectedFundCode,
          mfoProgram: _selectedMfoProgram,
          activityProject: activityProject,
          allotmentClass: _selectedAllotmentClass,
          accountCode: accountCode,
          beginningBalance: beginningBalance,
          amount: amount,
          dateOfAllocation: isoDate,
        );
      } else {
        allocationId = _editingAllocationId!;
        await db.updateBudgetAllocation(
          id: allocationId,
          fiscalYear: _selectedFy,
          fundCode: _selectedFundCode,
          mfoProgram: _selectedMfoProgram,
          activityProject: activityProject,
          allotmentClass: _selectedAllotmentClass,
          accountCode: accountCode,
          beginningBalance: beginningBalance,
          amount: amount,
          dateOfAllocation: isoDate,
        );
      }

      if (modAmount != 0.0) {
        await db.insertBudgetModification(
          allocationId: allocationId,
          fiscalYear: _selectedFy,
          fundCode: _selectedFundCode,
          mfoProgram: _selectedMfoProgram,
          activityProject: activityProject,
          allotmentClass: _selectedAllotmentClass,
          accountCode: accountCode,
          modificationAmount: modAmount,
          modificationDate: isoDate,
        );
      }

      if (mounted) {
        showBrmsNotice(
          context,
          _editingAllocationId == null
              ? 'Saved budget allocation for Fund $_selectedFundCode ($_selectedFy).'
              : 'Updated budget allocation for Fund $_selectedFundCode ($_selectedFy).',
        );
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
    final modificationsAsync = ref.watch(budgetModificationsProvider);
    final activities =
        ref.watch(distinctActivityProjectsProvider).value ??
        const ['General Operations'];

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
              _buildSetBudgetFormCard(
                funds: funds,
                uacsList: uacsList,
                activities: activities,
              ),
              const SizedBox(height: 24),
              _buildSummaryTableCard(allocationsAsync),
              const SizedBox(height: 24),
              _buildModificationsTableCard(modificationsAsync),
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
    required List<String> activities,
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
                Expanded(
                  child: Column(
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
                        'Allocate statutory appropriations, beginning balances, and quarterly modifications for CSU Aparri Campus.',
                        style: TextStyle(
                          fontSize: 12,
                          color: BrmsColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_editingAllocationId != null) ...[
                  const SizedBox(width: 12),
                  const BrmsBadge(label: 'EDIT MODE', filled: true),
                ],
                const SizedBox(width: 10),
                BrmsButton(
                  label: 'Manage UACS',
                  icon: Icons.list_alt_outlined,
                  primary: false,
                  height: 32,
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const UacsManagementDialog(),
                  ),
                ),
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

                final programField = _buildDropdownField<String>(
                  label: 'PROGRAM / MFO',
                  value: _selectedMfoProgram,
                  items: BrmsFormatters.mfoPrograms
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(m, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedMfoProgram = v);
                  },
                );

                final activityField = _buildStringAutocomplete(
                  label: 'ACTIVITY / PROJECT',
                  controller: _activityController,
                  focusNode: _activityFocusNode,
                  options: activities,
                  hintText: 'e.g., General Operations',
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
                        _accountCodeController.text =
                            _selectedAccountCode ?? '';
                      });
                    }
                  },
                );

                final uacsField = _buildUacsAutocomplete(filteredUacs);

                final beginningField = _buildInputField(
                  label: 'BEGINNING BALANCE (₱)',
                  controller: _beginningBalanceController,
                  prefixText: 'Php ',
                  hintText: '0.00',
                  mono: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    BrmsMoneyInputFormatter(),
                    LengthLimitingTextInputFormatter(
                      BrmsInputLimits.maxMoneyLength,
                    ),
                  ],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return null;
                    final parsed = BrmsFormatters.parseAmount(val);
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid non-negative balance';
                    }
                    if (parsed > BrmsInputLimits.maxMoneyAmount) {
                      return 'Amount exceeds maximum limit';
                    }
                    return null;
                  },
                );

                final amountField = _buildInputField(
                  label: 'BUDGET AMOUNT (₱)',
                  controller: _amountController,
                  prefixText: 'Php ',
                  hintText: '0.00',
                  mono: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    BrmsMoneyInputFormatter(),
                    LengthLimitingTextInputFormatter(
                      BrmsInputLimits.maxMoneyLength,
                    ),
                  ],
                  validator: (val) {
                    final beg =
                        BrmsFormatters.parseAmount(
                          _beginningBalanceController.text,
                        ) ??
                        0.0;
                    final mod =
                        BrmsFormatters.parseAmount(
                          _modificationController.text,
                        ) ??
                        0.0;
                    if (val == null || val.trim().isEmpty) {
                      if (beg <= 0 && mod == 0) {
                        return 'Budget Amount is required';
                      }
                      return null;
                    }
                    final parsed = BrmsFormatters.parseAmount(val);
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid amount';
                    }
                    if (parsed > BrmsInputLimits.maxMoneyAmount) {
                      return 'Amount exceeds maximum limit';
                    }
                    if (parsed <= 0 && beg <= 0 && mod == 0) {
                      return 'Budget Amount is required';
                    }
                    return null;
                  },
                );

                final modField = _buildInputField(
                  label: 'MODIFICATION / ADJUSTMENT (±₱)',
                  controller: _modificationController,
                  prefixText: 'Php ',
                  hintText: '0.00 (optional +/-)',
                  mono: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    BrmsMoneyInputFormatter(allowNegative: true),
                    LengthLimitingTextInputFormatter(
                      BrmsInputLimits.maxMoneyLength,
                    ),
                  ],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return null;
                    final parsed = BrmsFormatters.parseAmount(val);
                    if (parsed == null) {
                      return 'Enter a valid number (can be negative)';
                    }
                    if (parsed.abs() > BrmsInputLimits.maxMoneyAmount) {
                      return 'Amount exceeds maximum limit';
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
                      programField,
                      const SizedBox(height: 16),
                      activityField,
                      const SizedBox(height: 16),
                      classField,
                      const SizedBox(height: 16),
                      uacsField,
                      const SizedBox(height: 16),
                      beginningField,
                      const SizedBox(height: 16),
                      amountField,
                      const SizedBox(height: 16),
                      modField,
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
                        const SizedBox(width: 20),
                        Expanded(child: fundField),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: programField),
                        const SizedBox(width: 20),
                        Expanded(child: activityField),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: classField),
                        const SizedBox(width: 20),
                        Expanded(child: uacsField),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: beginningField),
                        const SizedBox(width: 20),
                        Expanded(child: amountField),
                        const SizedBox(width: 20),
                        Expanded(child: modField),
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
                  onPressed: _isSaving ? null : () => _saveAllocation(uacsList),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUacsAutocomplete(List<UacsCode> filteredUacs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCOUNT CODE (UACS)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: BrmsColors.secondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        RawAutocomplete<UacsCode>(
          textEditingController: _accountCodeController,
          focusNode: _accountCodeFocusNode,
          displayStringForOption: (u) => u.accountCode,
          optionsBuilder: (textEditingValue) {
            final q = textEditingValue.text.trim().toLowerCase();
            if (q.isEmpty) return filteredUacs;
            return filteredUacs.where(
              (u) =>
                  u.accountCode.toLowerCase().contains(q) ||
                  u.objectTitle.toLowerCase().contains(q),
            );
          },
          onSelected: (selected) {
            setState(() {
              _selectedAccountCode = selected.accountCode;
            });
          },
          fieldViewBuilder: (context, fieldCtrl, focusNode, onSubmitted) {
            return TextFormField(
              controller: fieldCtrl,
              focusNode: focusNode,
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                  BrmsInputLimits.maxShortCodeLength,
                ),
              ],
              onChanged: (v) {
                _selectedAccountCode = v.trim().isEmpty ? null : v.trim();
              },
              style: BrmsTheme.mono(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: filteredUacs.isEmpty
                    ? 'Optional for Capital Outlay'
                    : 'e.g., ${filteredUacs.first.accountCode}',
                filled: true,
                fillColor: BrmsColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                    color: BrmsColors.error,
                    width: 1.4,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                    color: BrmsColors.error,
                    width: 1.6,
                  ),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: BrmsColors.surface,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                    maxWidth: 380,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final u = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(
                          '${u.accountCode} — ${u.objectTitle}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => onSelected(u),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStringAutocomplete({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required List<String> options,
    required String hintText,
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
        RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: focusNode,
          optionsBuilder: (textEditingValue) {
            final q = textEditingValue.text.trim().toLowerCase();
            if (q.isEmpty) return options;
            return options.where((o) => o.toLowerCase().contains(q));
          },
          fieldViewBuilder: (context, fieldCtrl, fieldFocusNode, onSubmitted) {
            return TextFormField(
              controller: fieldCtrl,
              focusNode: fieldFocusNode,
              inputFormatters: [
                LengthLimitingTextInputFormatter(BrmsInputLimits.maxNameLength),
              ],
              style: const TextStyle(fontSize: 13, color: BrmsColors.onSurface),
              decoration: InputDecoration(
                hintText: hintText,
                filled: true,
                fillColor: BrmsColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                    color: BrmsColors.error,
                    width: 1.4,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                    color: BrmsColors.error,
                    width: 1.6,
                  ),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, opts) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: BrmsColors.surface,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                    maxWidth: 380,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: opts.length,
                    itemBuilder: (context, index) {
                      final option = opts.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(
                          option,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
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
                    'Master list of registered fiscal appropriations, MFOs, and beginning balances',
                    style: TextStyle(fontSize: 12, color: BrmsColors.secondary),
                  ),
                ],
              ),
              SizedBox(
                width: 220,
                height: 34,
                child: TextField(
                  controller: _tableSearchController,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      BrmsInputLimits.maxSearchLength,
                    ),
                  ],
                  onChanged: (v) => setState(
                    () => _tableSearchQuery = v.trim().toLowerCase(),
                  ),
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
              child: BrmsErrorState(
                title: 'Failed to load budget allocations',
                error: err,
                onRetry: () {
                  ref.invalidate(databaseProvider);
                  ref.invalidate(budgetAllocationsProvider);
                },
              ),
            ),
            data: (rows) {
              final fyValues = rows.map((r) => r.fiscalYear).toSet().toList()
                ..sort();
              final fundValues = rows.map((r) => r.fundCode).toSet().toList()
                ..sort();
              final programValues = rows
                  .map((r) => r.mfoProgram)
                  .toSet()
                  .toList()
                ..sort();
              final classValues = rows
                  .map((r) => r.allotmentClass)
                  .toSet()
                  .toList()
                ..sort();

              final activeFy = fyValues.contains(_tableFyFilter)
                  ? _tableFyFilter
                  : 'ALL';
              final activeFund = fundValues.contains(_tableFundFilter)
                  ? _tableFundFilter
                  : 'ALL';
              final activeProgram = programValues.contains(_tableProgramFilter)
                  ? _tableProgramFilter
                  : 'ALL';
              final activeClass = classValues.contains(_tableClassFilter)
                  ? _tableClassFilter
                  : 'ALL';

              final hasTableFilters = activeFy != 'ALL' ||
                  activeFund != 'ALL' ||
                  activeProgram != 'ALL' ||
                  activeClass != 'ALL' ||
                  _tableVisibilityFilter != 'ALL' ||
                  _tableSearchQuery.isNotEmpty;

              final filtered = rows.where((r) {
                if (activeFy != 'ALL' && r.fiscalYear != activeFy) return false;
                if (activeFund != 'ALL' && r.fundCode != activeFund) {
                  return false;
                }
                if (activeProgram != 'ALL' && r.mfoProgram != activeProgram) {
                  return false;
                }
                if (activeClass != 'ALL' && r.allotmentClass != activeClass) {
                  return false;
                }
                if (_tableVisibilityFilter == 'ACTIVE' && r.isHidden != 0) {
                  return false;
                }
                if (_tableVisibilityFilter == 'HIDDEN' && r.isHidden == 0) {
                  return false;
                }
                if (_tableSearchQuery.isNotEmpty) {
                  final match =
                      r.fiscalYear.toLowerCase().contains(_tableSearchQuery) ||
                      r.fundCode.toLowerCase().contains(_tableSearchQuery) ||
                      r.mfoProgram.toLowerCase().contains(_tableSearchQuery) ||
                      r.activityProject.toLowerCase().contains(
                        _tableSearchQuery,
                      ) ||
                      r.allotmentClass.toLowerCase().contains(
                        _tableSearchQuery,
                      ) ||
                      (r.accountCode ?? '').toLowerCase().contains(
                        _tableSearchQuery,
                      );
                  if (!match) return false;
                }
                return true;
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (rows.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          BrmsTableFilterSelect<String>(
                            label: 'FY:',
                            value: activeFy,
                            items: [
                              const DropdownMenuItem(
                                value: 'ALL',
                                child: Text('All Years'),
                              ),
                              ...fyValues.map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(v),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _tableFyFilter = v);
                              }
                            },
                          ),
                          BrmsTableFilterSelect<String>(
                            label: 'FUND:',
                            value: activeFund,
                            items: [
                              const DropdownMenuItem(
                                value: 'ALL',
                                child: Text('All Funds'),
                              ),
                              ...fundValues.map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text('Fund $v'),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _tableFundFilter = v);
                              }
                            },
                          ),
                          BrmsTableFilterSelect<String>(
                            label: 'PROGRAM:',
                            value: activeProgram,
                            items: [
                              const DropdownMenuItem(
                                value: 'ALL',
                                child: Text('All Programs'),
                              ),
                              ...programValues.map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(
                                    v,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _tableProgramFilter = v);
                              }
                            },
                          ),
                          BrmsTableFilterSelect<String>(
                            label: 'CLASS:',
                            value: activeClass,
                            items: [
                              const DropdownMenuItem(
                                value: 'ALL',
                                child: Text('All Classes'),
                              ),
                              ...classValues.map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(
                                    BrmsFormatters.shortAllotmentLabel(v),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _tableClassFilter = v);
                              }
                            },
                          ),
                          BrmsTableFilterSelect<String>(
                            label: 'STATUS:',
                            value: _tableVisibilityFilter,
                            items: const [
                              DropdownMenuItem(
                                value: 'ALL',
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: 'ACTIVE',
                                child: Text('Active Only'),
                              ),
                              DropdownMenuItem(
                                value: 'HIDDEN',
                                child: Text('Hidden Only'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _tableVisibilityFilter = v);
                              }
                            },
                          ),
                          if (hasTableFilters)
                            BrmsButton(
                              label: 'Reset',
                              primary: false,
                              height: 34,
                              onPressed: () {
                                _tableSearchController.clear();
                                setState(() {
                                  _tableSearchQuery = '';
                                  _tableFyFilter = 'ALL';
                                  _tableFundFilter = 'ALL';
                                  _tableProgramFilter = 'ALL';
                                  _tableClassFilter = 'ALL';
                                  _tableVisibilityFilter = 'ALL';
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: BrmsColors.outlineVariant),
                  ],
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          rows.isEmpty
                              ? 'No budget allocations recorded yet. Use the form above to add one.'
                              : 'No budget allocations match the active filters.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: BrmsColors.secondary,
                          ),
                        ),
                      ),
                    )
                  else
                    BrmsHorizontalTableScroll(
                      ensureMinWidth: true,
                      child: DataTable(
                        columnSpacing: 20,
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
                          DataColumn(label: Text('PROGRAM / ACTIVITY')),
                          DataColumn(label: Text('ALLOTMENT CLASS')),
                          DataColumn(label: Text('DATE')),
                          DataColumn(
                            label: Text('BEGINNING BAL.'),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text('BUDGET AMOUNT'),
                            numeric: true,
                          ),
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
                                SizedBox(
                                  width: 220,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.mfoProgram,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        entry.activityProject,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: BrmsColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
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
                                    entry.beginningBalance,
                                  ),
                                  style: BrmsTheme.mono(
                                    fontSize: 12,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  BrmsFormatters.formatPhp(
                                    entry.authorizedAppropriations,
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
                                        onPressed: () =>
                                            _populateForEdit(entry),
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
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModificationsTableCard(
    AsyncValue<List<BudgetModification>> modificationsAsync,
  ) {
    final mods = modificationsAsync.value ?? const <BudgetModification>[];
    if (mods.isEmpty) return const SizedBox.shrink();

    final fyValues = mods.map((m) => m.fiscalYear).toSet().toList()..sort();
    final fundValues = mods.map((m) => m.fundCode).toSet().toList()..sort();
    final classValues = mods.map((m) => m.allotmentClass).toSet().toList()
      ..sort();

    final activeFy = fyValues.contains(_modFyFilter) ? _modFyFilter : 'ALL';
    final activeFund = fundValues.contains(_modFundFilter)
        ? _modFundFilter
        : 'ALL';
    final activeClass = classValues.contains(_modClassFilter)
        ? _modClassFilter
        : 'ALL';
    final hasModFilters = activeFy != 'ALL' ||
        activeFund != 'ALL' ||
        activeClass != 'ALL' ||
        _modDirectionFilter != 'ALL' ||
        _modSearchQuery.isNotEmpty;

    final filteredMods = mods.where((m) {
      if (activeFy != 'ALL' && m.fiscalYear != activeFy) return false;
      if (activeFund != 'ALL' && m.fundCode != activeFund) return false;
      if (activeClass != 'ALL' && m.allotmentClass != activeClass) return false;
      if (_modDirectionFilter == 'ADD' && m.modificationAmount <= 0) {
        return false;
      }
      if (_modDirectionFilter == 'DEDUCT' && m.modificationAmount >= 0) {
        return false;
      }
      if (_modSearchQuery.isNotEmpty) {
        final match = m.mfoProgram.toLowerCase().contains(_modSearchQuery) ||
            m.activityProject.toLowerCase().contains(_modSearchQuery) ||
            m.fundCode.toLowerCase().contains(_modSearchQuery) ||
            m.fiscalYear.toLowerCase().contains(_modSearchQuery);
        if (!match) return false;
      }
      return true;
    }).toList();

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
                    'Quarterly Budget Modifications & Realignments',
                    style: BrmsTheme.heading(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Adjustments applied to Adjusted Budget columns across Central, Registries, FAR 2, and FAR 2-A',
                    style: TextStyle(fontSize: 12, color: BrmsColors.secondary),
                  ),
                ],
              ),
              SizedBox(
                width: 220,
                height: 34,
                child: TextField(
                  controller: _modSearchController,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      BrmsInputLimits.maxSearchLength,
                    ),
                  ],
                  onChanged: (v) => setState(
                    () => _modSearchQuery = v.trim().toLowerCase(),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 16,
                      color: BrmsColors.secondary,
                    ),
                    hintText: 'Filter modifications...',
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              BrmsTableFilterSelect<String>(
                label: 'FY:',
                value: activeFy,
                items: [
                  const DropdownMenuItem(
                    value: 'ALL',
                    child: Text('All Years'),
                  ),
                  ...fyValues.map(
                    (v) => DropdownMenuItem(value: v, child: Text(v)),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _modFyFilter = v);
                },
              ),
              BrmsTableFilterSelect<String>(
                label: 'FUND:',
                value: activeFund,
                items: [
                  const DropdownMenuItem(
                    value: 'ALL',
                    child: Text('All Funds'),
                  ),
                  ...fundValues.map(
                    (v) => DropdownMenuItem(value: v, child: Text('Fund $v')),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _modFundFilter = v);
                },
              ),
              BrmsTableFilterSelect<String>(
                label: 'CLASS:',
                value: activeClass,
                items: [
                  const DropdownMenuItem(
                    value: 'ALL',
                    child: Text('All Classes'),
                  ),
                  ...classValues.map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text(BrmsFormatters.shortAllotmentLabel(v)),
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _modClassFilter = v);
                },
              ),
              BrmsTableFilterSelect<String>(
                label: 'TYPE:',
                value: _modDirectionFilter,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All')),
                  DropdownMenuItem(value: 'ADD', child: Text('Additions (+)')),
                  DropdownMenuItem(
                    value: 'DEDUCT',
                    child: Text('Deductions (-)'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _modDirectionFilter = v);
                },
              ),
              if (hasModFilters)
                BrmsButton(
                  label: 'Reset',
                  primary: false,
                  height: 34,
                  onPressed: () {
                    _modSearchController.clear();
                    setState(() {
                      _modSearchQuery = '';
                      _modFyFilter = 'ALL';
                      _modFundFilter = 'ALL';
                      _modClassFilter = 'ALL';
                      _modDirectionFilter = 'ALL';
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: BrmsColors.outlineVariant),
          if (filteredMods.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No budget modifications match the active filters.',
                  style: TextStyle(fontSize: 12, color: BrmsColors.secondary),
                ),
              ),
            )
          else
            BrmsHorizontalTableScroll(
              ensureMinWidth: true,
              child: DataTable(
                columnSpacing: 20,
                horizontalMargin: 12,
                headingTextStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: BrmsColors.secondary,
                ),
                columns: const [
                  DataColumn(label: Text('DATE')),
                  DataColumn(label: Text('FY')),
                  DataColumn(label: Text('FUND')),
                  DataColumn(label: Text('PROGRAM / ACTIVITY')),
                  DataColumn(label: Text('CLASS')),
                  DataColumn(label: Text('MODIFICATION'), numeric: true),
                  DataColumn(label: Text('ACTION')),
                ],
                rows: filteredMods.map((m) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        BrmsFormatters.isoToDisplay(m.modificationDate),
                        style: BrmsTheme.mono(fontSize: 11),
                      ),
                    ),
                    DataCell(
                      Text(m.fiscalYear, style: BrmsTheme.mono(fontSize: 11)),
                    ),
                    DataCell(BrmsBadge(label: m.fundCode)),
                    DataCell(
                      Text(
                        '${m.mfoProgram} • ${m.activityProject}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    DataCell(
                      BrmsBadge(
                        label: BrmsFormatters.shortAllotmentLabel(
                          m.allotmentClass,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        BrmsFormatters.formatPhp(m.modificationAmount),
                        style: BrmsTheme.mono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DataCell(
                      OutlinedButton(
                        onPressed: () async {
                          final confirmed = await showBrmsConfirmDialog(
                            context,
                            title: 'Remove Budget Modification',
                            message:
                                'Remove the ${BrmsFormatters.formatPhp(m.modificationAmount)} modification for Fund ${m.fundCode} (${m.fiscalYear})? This will immediately recalculate adjusted balances.',
                            confirmLabel: 'Remove',
                          );
                          if (!confirmed || !mounted) return;
                          await ref
                              .read(databaseProvider)
                              .deleteBudgetModification(m.id);
                          if (mounted) {
                            showBrmsNotice(context, 'Modification removed.');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: BrmsColors.error,
                          side: const BorderSide(
                            color: BrmsColors.outlineVariant,
                          ),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'Remove',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
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
    List<TextInputFormatter>? inputFormatters,
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
        Focus(
          onFocusChange: (hasFocus) =>
              clearZeroTextOnFocus(controller, hasFocus),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
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
        ),
      ],
    );
  }
}
