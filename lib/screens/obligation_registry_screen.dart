import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../providers/brms_providers.dart';
import '../services/attachment_service.dart';
import '../theme/brms_theme.dart';
import '../utils/brms_formatters.dart';
import '../widgets/brms_common.dart';

enum _ObrSortOption {
  dateDesc('Sort: Date (Newest)'),
  dateAsc('Sort: Date (Oldest)'),
  amountDesc('Sort: Amount (High–Low)'),
  amountAsc('Sort: Amount (Low–High)');

  const _ObrSortOption(this.label);
  final String label;
}

/// Screen 4: BRMS CSU Aparri - Obligation Registry (Monochrome).
class ObligationRegistryScreen extends ConsumerStatefulWidget {
  const ObligationRegistryScreen({super.key});

  @override
  ConsumerState<ObligationRegistryScreen> createState() =>
      _ObligationRegistryScreenState();
}

class _ObligationRegistryScreenState
    extends ConsumerState<ObligationRegistryScreen> {
  // Master-detail & filter state
  int? _selectedObrId;
  bool _isFormOpen = false;
  ObligationRegistry? _editingObr;

  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _fundFilter = 'ALL';
  String _classFilter = 'ALL';
  String _periodFilter = 'ALL';
  _ObrSortOption _sortOption = _ObrSortOption.dateDesc;

  // Form state
  final _formKey = GlobalKey<FormState>();
  String _formFundCode = '101';
  String _formMfoProgram = BrmsFormatters.mfoPrograms.first;
  String _formAllotmentClass = BrmsFormatters.allotmentClasses.first;
  DateTime _formDate = DateTime.now();

  final _obrNoController = TextEditingController();
  final _activityController = TextEditingController(text: 'General Operations');
  final _accountCodeController = TextEditingController();
  final _dateController = TextEditingController();
  final _payeeController = TextEditingController();
  final _grossAmountController = TextEditingController();
  final _disbursementController = TextEditingController(text: '0.00');
  final _dueAndDemandableController = TextEditingController(text: '0.00');
  final _particularController = TextEditingController();
  final _descriptionController = TextEditingController();

  PickedPdfAttachment? _pickedAttachment;
  String? _existingAttachmentFilename;
  String? _existingAttachmentLocalPath;
  String? _obrUniqueError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = BrmsFormatters.toDisplayDate(_formDate);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _obrNoController.dispose();
    _activityController.dispose();
    _accountCodeController.dispose();
    _dateController.dispose();
    _payeeController.dispose();
    _grossAmountController.dispose();
    _disbursementController.dispose();
    _dueAndDemandableController.dispose();
    _particularController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openCreateForm() {
    setState(() {
      _isFormOpen = true;
      _editingObr = null;
      _formFundCode = '101';
      _formMfoProgram = BrmsFormatters.mfoPrograms.first;
      _formAllotmentClass = BrmsFormatters.allotmentClasses.first;
      _formDate = DateTime.now();
      _obrNoController.clear();
      _activityController.text = 'General Operations';
      _accountCodeController.clear();
      _dateController.text = BrmsFormatters.toDisplayDate(_formDate);
      _payeeController.clear();
      _grossAmountController.clear();
      _disbursementController.text = '0.00';
      _dueAndDemandableController.text = '0.00';
      _particularController.clear();
      _descriptionController.clear();
      _pickedAttachment = null;
      _existingAttachmentFilename = null;
      _existingAttachmentLocalPath = null;
      _obrUniqueError = null;
    });
  }

  void _openEditForm(ObligationRegistry obr) {
    final parsedDate = BrmsFormatters.parseIsoDate(obr.date) ?? DateTime.now();
    setState(() {
      _isFormOpen = true;
      _editingObr = obr;
      _formFundCode = obr.fundCode;
      _formMfoProgram = BrmsFormatters.mfoPrograms.contains(obr.mfoProgram)
          ? obr.mfoProgram
          : BrmsFormatters.mfoPrograms.first;
      _formAllotmentClass =
          BrmsFormatters.allotmentClasses.contains(obr.allotmentClassification)
          ? obr.allotmentClassification
          : BrmsFormatters.allotmentClasses.first;
      _formDate = parsedDate;
      _obrNoController.text = obr.obrNo;
      _activityController.text = obr.activityProject;
      _accountCodeController.text = obr.accountCode;
      _dateController.text = BrmsFormatters.toDisplayDate(parsedDate);
      _payeeController.text = obr.payee;
      _grossAmountController.text = BrmsFormatters.formatNumber(
        obr.grossAmount,
      );
      _disbursementController.text = BrmsFormatters.formatNumber(
        obr.disbursementAmount,
      );
      _dueAndDemandableController.text = BrmsFormatters.formatNumber(
        obr.dueAndDemandable,
      );
      _particularController.text = obr.particular;
      _descriptionController.text = obr.description ?? '';
      _pickedAttachment = null;
      _existingAttachmentFilename = obr.attachmentFilename;
      _existingAttachmentLocalPath = obr.attachmentLocalPath;
      _obrUniqueError = null;
    });
  }

  void _closeForm() {
    setState(() {
      _isFormOpen = false;
      _editingObr = null;
      _obrUniqueError = null;
    });
  }

  Future<void> _pickFormDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _formDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _formDate = picked;
        _dateController.text = BrmsFormatters.toDisplayDate(picked);
      });
    }
  }

  Future<void> _pickPdfFile() async {
    final picked = await ref.read(attachmentServiceProvider).pickPdf();
    if (picked != null && mounted) {
      setState(() {
        _pickedAttachment = picked;
      });
    }
  }

  Future<void> _saveForm({
    required List<UacsCode> uacsList,
    required double? remainingBalance,
  }) async {
    setState(() => _obrUniqueError = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final obrNo = _obrNoController.text.trim();
    final activityProject = _activityController.text.trim().isEmpty
        ? 'General Operations'
        : _activityController.text.trim();
    final accountCode = _accountCodeController.text.trim();
    final payee = _payeeController.text.trim();
    final particular = _particularController.text.trim();
    final description = _descriptionController.text.trim();
    final grossAmount = BrmsFormatters.parseAmount(_grossAmountController.text);
    final disbursementAmount =
        BrmsFormatters.parseAmount(_disbursementController.text) ?? 0.0;
    final dueAndDemandable =
        BrmsFormatters.parseAmount(_dueAndDemandableController.text) ?? 0.0;

    if (grossAmount == null || grossAmount <= 0) {
      showBrmsNotice(context, 'Enter a valid positive Gross Amount.');
      return;
    }

    if (remainingBalance == null || grossAmount > remainingBalance) {
      final avail = BrmsFormatters.formatPhp(remainingBalance ?? 0.0);
      showBrmsNotice(
        context,
        'Gross Amount exceeds remaining allotment ($avail) for Fund $_formFundCode.',
      );
      return;
    }

    final validUacs = uacsList.any((u) => u.accountCode == accountCode);
    if (!validUacs) {
      showBrmsNotice(
        context,
        'Select a valid UACS Account Code from the list.',
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final db = ref.read(databaseProvider);
      final isUnique = await db.isObrNoUnique(
        obrNo,
        excludeId: _editingObr?.id,
      );
      if (!isUnique) {
        if (mounted) {
          setState(() {
            _obrUniqueError = 'OBR No. "$obrNo" already exists.';
            _isSaving = false;
          });
        }
        return;
      }

      String? attachmentFilename = _existingAttachmentFilename;
      String? attachmentLocalPath = _existingAttachmentLocalPath;

      if (_pickedAttachment != null) {
        final saved = await ref
            .read(attachmentServiceProvider)
            .saveAttachment(
              sourcePath: _pickedAttachment!.sourcePath,
              originalFilename: _pickedAttachment!.originalFilename,
              obrNo: obrNo,
            );
        attachmentFilename = saved.filename;
        attachmentLocalPath = saved.localPath;
      }

      final companion = ObligationRegistriesCompanion(
        obrNo: Value(obrNo),
        date: Value(BrmsFormatters.toIsoDate(_formDate)),
        fundCode: Value(_formFundCode),
        mfoProgram: Value(_formMfoProgram),
        activityProject: Value(activityProject),
        accountCode: Value(accountCode),
        allotmentClassification: Value(_formAllotmentClass),
        payee: Value(payee),
        particular: Value(particular),
        description: Value(description.isEmpty ? null : description),
        grossAmount: Value(grossAmount),
        disbursementAmount: Value(disbursementAmount),
        dueAndDemandable: Value(dueAndDemandable),
        attachmentFilename: Value(attachmentFilename),
        attachmentLocalPath: Value(attachmentLocalPath),
      );

      int savedId;
      if (_editingObr == null) {
        savedId = await db.insertObligation(companion);
      } else {
        savedId = _editingObr!.id;
        await db.updateObligation(savedId, companion);
      }

      if (mounted) {
        setState(() {
          _selectedObrId = savedId;
          _isFormOpen = false;
          _editingObr = null;
        });
        showBrmsNotice(
          context,
          _editingObr == null
              ? 'Obligation $obrNo saved.'
              : 'Obligation $obrNo updated.',
        );
      }
    } catch (e) {
      if (mounted) {
        showBrmsNotice(context, 'Failed to save obligation: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<ObligationRegistry> _applyFiltersAndSort(
    List<ObligationRegistry> records,
  ) {
    final q = _searchQuery.trim().toLowerCase();
    final filtered = records.where((r) {
      if (_fundFilter != 'ALL' && r.fundCode != _fundFilter) return false;
      if (_classFilter != 'ALL' && r.allotmentClassification != _classFilter) {
        return false;
      }
      if (_periodFilter != 'ALL') {
        final quarter = BrmsFormatters.quarterOfIso(r.date);
        final expected = int.tryParse(_periodFilter.replaceAll('Q', ''));
        if (quarter != expected) return false;
      }
      if (q.isNotEmpty) {
        final match =
            r.obrNo.toLowerCase().contains(q) ||
            r.payee.toLowerCase().contains(q) ||
            r.particular.toLowerCase().contains(q) ||
            r.accountCode.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortOption) {
        case _ObrSortOption.dateDesc:
          final cmp = b.date.compareTo(a.date);
          return cmp != 0 ? cmp : b.obrNo.compareTo(a.obrNo);
        case _ObrSortOption.dateAsc:
          final cmp = a.date.compareTo(b.date);
          return cmp != 0 ? cmp : a.obrNo.compareTo(b.obrNo);
        case _ObrSortOption.amountDesc:
          return b.grossAmount.compareTo(a.grossAmount);
        case _ObrSortOption.amountAsc:
          return a.grossAmount.compareTo(b.grossAmount);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final obligationsAsync = ref.watch(obligationRegistriesProvider);
    final fundsAsync = ref.watch(fundSourcesProvider);
    final uacsAsync = ref.watch(uacsCodesProvider);

    final funds = fundsAsync.value ?? const <FundSource>[];
    final uacsList = uacsAsync.value ?? const <UacsCode>[];

    return Column(
      children: [
        _buildPageTitleBar(context),
        const SizedBox(height: 16),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _isFormOpen
                  ? _buildEntryFormCard(funds: funds, uacsList: uacsList)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFilterControlsBar(funds),
                        const SizedBox(height: 18),
                        _buildMasterDetailSplit(context, obligationsAsync),
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
              const SizedBox(width: 25),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isFormOpen)
                    BrmsButton(
                      label: 'Back to Ledger',
                      icon: Icons.arrow_back,
                      primary: false,
                      onPressed: _closeForm,
                    )
                  else ...[
                    BrmsButton(
                      label: 'Create new',
                      icon: Icons.add,
                      onPressed: _openCreateForm,
                    ),
                    const SizedBox(width: 8),
                    BrmsButton(
                      label: 'Export CSV',
                      icon: Icons.file_download_outlined,
                      primary: false,
                      onPressed: () => showBrmsNotice(
                        context,
                        'Exporting Obligation Log to CSV.',
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterControlsBar(List<FundSource> funds) {
    final fundItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem(
        value: 'ALL',
        child: Text('Fund Source: All (101, 161, 164, 184)'),
      ),
      ...funds.map(
        (f) => DropdownMenuItem(
          value: f.fundCode,
          child: Text('${f.fundCode} - ${f.fundName}'),
        ),
      ),
    ];

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
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
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
          _CompactSelect<String>(
            icon: Icons.account_balance_outlined,
            value: fundItems.any((i) => i.value == _fundFilter)
                ? _fundFilter
                : 'ALL',
            items: fundItems,
            onChanged: (v) {
              if (v != null) setState(() => _fundFilter = v);
            },
          ),
          _CompactSelect<String>(
            icon: Icons.category_outlined,
            value: _classFilter,
            items: [
              const DropdownMenuItem(
                value: 'ALL',
                child: Text('Class: All (PS, MOOE, CO)'),
              ),
              ...BrmsFormatters.allotmentClasses.map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text('${BrmsFormatters.shortAllotmentLabel(c)} - $c'),
                ),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _classFilter = v);
            },
          ),
          _CompactSelect<String>(
            icon: Icons.calendar_today_outlined,
            value: _periodFilter,
            items: const [
              DropdownMenuItem(
                value: 'ALL',
                child: Text('Period: All Quarters'),
              ),
              DropdownMenuItem(value: 'Q1', child: Text('Q1 (Jan - Mar)')),
              DropdownMenuItem(value: 'Q2', child: Text('Q2 (Apr - Jun)')),
              DropdownMenuItem(value: 'Q3', child: Text('Q3 (Jul - Sep)')),
              DropdownMenuItem(value: 'Q4', child: Text('Q4 (Oct - Dec)')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _periodFilter = v);
            },
          ),
          _CompactSelect<_ObrSortOption>(
            icon: Icons.swap_vert,
            value: _sortOption,
            items: _ObrSortOption.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _sortOption = v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMasterDetailSplit(
    BuildContext context,
    AsyncValue<List<ObligationRegistry>> obligationsAsync,
  ) {
    return obligationsAsync.when(
      loading: () => const BrmsCard(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, _) => BrmsCard(
        padding: const EdgeInsets.all(24),
        child: BrmsErrorState(
          title: 'Failed to load obligations',
          error: err,
          onRetry: () {
            ref.invalidate(databaseProvider);
            ref.invalidate(obligationRegistriesProvider);
          },
        ),
      ),
      data: (allRecords) {
        final filtered = _applyFiltersAndSort(allRecords);
        final effectiveSelectedId =
            _selectedObrId ?? (filtered.isNotEmpty ? filtered.first.id : null);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;
            final masterTable = _buildMasterLedgerCard(
              filtered: filtered,
              totalCount: allRecords.length,
              selectedId: effectiveSelectedId,
            );
            final detailPanel = _buildDetailInspectionPanel(
              context,
              selectedId: effectiveSelectedId,
            );

            if (!isWide) {
              return Column(
                children: [
                  masterTable,
                  const SizedBox(height: 18),
                  detailPanel,
                ],
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
      },
    );
  }

  Widget _buildMasterLedgerCard({
    required List<ObligationRegistry> filtered,
    required int totalCount,
    required int? selectedId,
  }) {
    final totalAmount = filtered.fold<double>(
      0.0,
      (sum, r) => sum + r.grossAmount,
    );

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
                  'Total Obligations: ${BrmsFormatters.formatPhp(totalAmount)}  |  ${filtered.length} of $totalCount entries',
                  style: BrmsTheme.mono(
                    fontSize: 11,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'No obligation records match the current view.',
                      style: TextStyle(
                        fontSize: 13,
                        color: BrmsColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BrmsButton(
                      label: 'Create new OBR',
                      icon: Icons.add,
                      onPressed: _openCreateForm,
                    ),
                  ],
                ),
              ),
            )
          else
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
                rows: filtered.map((obr) {
                  final isSelected = obr.id == selectedId;
                  return DataRow(
                    selected: isSelected,
                    color: WidgetStateProperty.resolveWith<Color?>((states) {
                      if (isSelected) return BrmsColors.surfaceContainerLow;
                      return null;
                    }),
                    onSelectChanged: (_) =>
                        setState(() => _selectedObrId = obr.id),
                    cells: [
                      DataCell(
                        Text(
                          BrmsFormatters.isoToDisplay(obr.date),
                          style: BrmsTheme.mono(
                            fontSize: 11,
                            color: BrmsColors.secondary,
                          ),
                        ),
                      ),
                      DataCell(BrmsBadge(label: obr.obrNo, filled: isSelected)),
                      DataCell(
                        BrmsBadge(
                          label: BrmsFormatters.shortAllotmentLabel(
                            obr.allotmentClassification,
                          ),
                        ),
                      ),
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
                          BrmsFormatters.formatPhp(obr.grossAmount),
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
                          onPressed: () =>
                              setState(() => _selectedObrId = obr.id),
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
                  'Showing ${filtered.length} of $totalCount items',
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

  Widget _buildDetailInspectionPanel(
    BuildContext context, {
    required int? selectedId,
  }) {
    if (selectedId == null) {
      return const BrmsCard(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Select an obligation from the ledger to inspect full details.',
            style: TextStyle(fontSize: 12, color: BrmsColors.secondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final detailAsync = ref.watch(obligationByIdProvider(selectedId));

    return detailAsync.when(
      loading: () => const BrmsCard(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, _) => BrmsCard(
        padding: const EdgeInsets.all(24),
        child: BrmsErrorState(
          title: 'Failed to load obligation record',
          error: err,
          onRetry: () {
            ref.invalidate(databaseProvider);
            ref.invalidate(obligationByIdProvider(selectedId));
          },
        ),
      ),
      data: (d) {
        if (d == null) {
          return const BrmsCard(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Record not found.',
                style: TextStyle(fontSize: 12, color: BrmsColors.secondary),
              ),
            ),
          );
        }

        final hasAttachment =
            d.attachmentFilename != null &&
            d.attachmentFilename!.trim().isNotEmpty;

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
                    Expanded(
                      child: Column(
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
                            overflow: TextOverflow.ellipsis,
                            style: BrmsTheme.heading(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
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
                          const Text(
                            'Obligated',
                            style: TextStyle(
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
                                  value: BrmsFormatters.isoToDisplay(d.date),
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
                            value: d.accountCode,
                            mono: true,
                          ),
                          const Divider(
                            height: 16,
                            color: BrmsColors.outlineVariant,
                          ),
                          _MetaCell(
                            label: 'ALLOTMENT CLASSIFICATION',
                            value: d.allotmentClassification,
                          ),
                          const Divider(
                            height: 16,
                            color: BrmsColors.outlineVariant,
                          ),
                          _MetaCell(
                            label: 'PROGRAM / MFO',
                            value: d.mfoProgram,
                          ),
                          const Divider(
                            height: 16,
                            color: BrmsColors.outlineVariant,
                          ),
                          _MetaCell(
                            label: 'ACTIVITY / PROJECT',
                            value: d.activityProject,
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
                          Expanded(
                            child: Text(
                              d.payee,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
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
                    if (d.description != null &&
                        d.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'DESCRIPTION',
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
                          d.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: BrmsColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BrmsColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: BrmsColors.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          Row(
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
                                BrmsFormatters.formatPhp(d.grossAmount),
                                style: BrmsTheme.mono(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 14,
                            color: BrmsColors.outlineVariant,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _MetaCell(
                                  label: 'DISBURSEMENT',
                                  value: BrmsFormatters.formatPhp(
                                    d.disbursementAmount,
                                  ),
                                  mono: true,
                                ),
                              ),
                              Expanded(
                                child: _MetaCell(
                                  label: 'DUE & DEMANDABLE',
                                  value: BrmsFormatters.formatPhp(
                                    d.dueAndDemandable,
                                  ),
                                  mono: true,
                                ),
                              ),
                            ],
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
                              border: Border.all(
                                color: BrmsColors.outlineVariant,
                              ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hasAttachment
                                            ? d.attachmentFilename!
                                            : 'No attachment uploaded',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        hasAttachment
                                            ? 'Stored in brms_attachments/'
                                            : 'Edit this OBR to attach a PDF',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: BrmsColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasAttachment) ...[
                                  const SizedBox(width: 8),
                                  BrmsButton(
                                    label: 'Open',
                                    icon: Icons.open_in_new,
                                    primary: false,
                                    height: 28,
                                    onPressed: () async {
                                      final err = await ref
                                          .read(attachmentServiceProvider)
                                          .openAttachment(
                                            d.attachmentLocalPath,
                                          );
                                      if (err != null && context.mounted) {
                                        showBrmsNotice(context, err);
                                      }
                                    },
                                  ),
                                ],
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
                              setState(() => _selectedObrId = null),
                        ),
                        BrmsButton(
                          label: 'Edit',
                          icon: Icons.edit_outlined,
                          height: 32,
                          onPressed: () => _openEditForm(d),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEntryFormCard({
    required List<FundSource> funds,
    required List<UacsCode> uacsList,
  }) {
    final payees = ref.watch(distinctPayeesProvider).value ?? const <String>[];
    final particulars =
        ref.watch(distinctParticularsProvider).value ?? const <String>[];
    final activities =
        ref.watch(distinctActivityProjectsProvider).value ??
        const ['General Operations'];

    final balanceAsync = ref.watch(
      remainingBalanceProvider(
        BalanceQueryKey(
          fundCode: _formFundCode,
          allotmentClass: _formAllotmentClass,
          excludeObligationId: _editingObr?.id,
        ),
      ),
    );
    final remainingBalance = balanceAsync.value;
    final enteredAmount = BrmsFormatters.parseAmount(
      _grossAmountController.text,
    );
    final exceedsBalance =
        remainingBalance != null &&
        enteredAmount != null &&
        enteredAmount > remainingBalance;

    final fundItems = funds.isNotEmpty
        ? funds.map((f) => f.fundCode).toList()
        : const ['101', '161', '164', '184'];
    final activeFundCode = fundItems.contains(_formFundCode)
        ? _formFundCode
        : fundItems.first;

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
                        _editingObr == null
                            ? 'New Obligation Request (OBR)'
                            : 'Edit Obligation Request (${_editingObr!.obrNo})',
                        style: BrmsTheme.heading(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Record and validate obligations against active fund allotments.',
                        style: TextStyle(
                          fontSize: 12,
                          color: BrmsColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                BrmsBadge(
                  label: _editingObr == null ? 'CREATE MODE' : 'EDIT MODE',
                  filled: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isTwoCol = constraints.maxWidth >= 680;

                final fundField = _buildFormDropdown<String>(
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
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _formFundCode = v);
                  },
                );

                final obrNoField = _buildFormTextField(
                  label: 'OBR NO.',
                  controller: _obrNoController,
                  hintText: 'e.g., 2024-01-0001',
                  mono: true,
                  errorText: _obrUniqueError,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'OBR No. is required'
                      : null,
                );

                final dateField = _buildFormTextField(
                  label: 'DATE (MM-DD-YYYY)',
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickFormDate,
                  suffixIcon: Icons.calendar_today_outlined,
                  mono: true,
                );

                final uacsField = _buildUacsAutocomplete(uacsList);

                final programField = _buildFormDropdown<String>(
                  label: 'PROGRAM / MFO',
                  value: _formMfoProgram,
                  items: BrmsFormatters.mfoPrograms
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(m, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _formMfoProgram = v);
                  },
                );

                final activityField = _buildStringAutocomplete(
                  label: 'ACTIVITY / PROJECT',
                  controller: _activityController,
                  options: activities,
                  hintText: 'e.g., General Operations',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Activity / Project is required'
                      : null,
                );

                final classField = _buildFormDropdown<String>(
                  label: 'ALLOTMENT CLASSIFICATION',
                  value: _formAllotmentClass,
                  items: BrmsFormatters.allotmentClasses
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _formAllotmentClass = v);
                  },
                );

                final payeeField = _buildStringAutocomplete(
                  label: 'PAYEE',
                  controller: _payeeController,
                  options: payees,
                  hintText: 'Enter or select payee',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Payee is required'
                      : null,
                );

                final grossAmountField = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormTextField(
                      label: 'GROSS AMOUNT (₱)',
                      controller: _grossAmountController,
                      prefixText: 'Php ',
                      hintText: '0.00',
                      mono: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        final parsed = BrmsFormatters.parseAmount(v ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid positive amount';
                        }
                        if (remainingBalance != null &&
                            parsed > remainingBalance) {
                          return 'Exceeds remaining allotment';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      remainingBalance == null
                          ? 'Calculating remaining balance...'
                          : 'Remaining Balance (${BrmsFormatters.shortAllotmentLabel(_formAllotmentClass)} / $_formFundCode): ${BrmsFormatters.formatPhp(remainingBalance)}',
                      style: BrmsTheme.mono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: exceedsBalance
                            ? BrmsColors.error
                            : BrmsColors.secondary,
                      ),
                    ),
                  ],
                );

                final disbursementField = _buildFormTextField(
                  label: 'DISBURSEMENT AMOUNT (₱)',
                  controller: _disbursementController,
                  prefixText: 'Php ',
                  hintText: '0.00',
                  mono: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final parsed = BrmsFormatters.parseAmount(v);
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid non-negative amount';
                    }
                    return null;
                  },
                );

                final dueAndDemandableField = _buildFormTextField(
                  label: 'DUE AND DEMANDABLE (₱)',
                  controller: _dueAndDemandableController,
                  prefixText: 'Php ',
                  hintText: '0.00',
                  mono: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final parsed = BrmsFormatters.parseAmount(v);
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid non-negative amount';
                    }
                    return null;
                  },
                );

                final particularField = _buildStringAutocomplete(
                  label: 'PARTICULAR',
                  controller: _particularController,
                  options: particulars,
                  hintText: 'Enter or select particular',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Particular is required'
                      : null,
                );

                final descriptionField = _buildFormTextField(
                  label: 'DESCRIPTION (OPTIONAL)',
                  controller: _descriptionController,
                  hintText: 'Additional details or remarks...',
                  maxLines: 3,
                );

                final attachmentWidget = _buildAttachmentPickerBox();

                if (!isTwoCol) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      fundField,
                      const SizedBox(height: 16),
                      obrNoField,
                      const SizedBox(height: 16),
                      dateField,
                      const SizedBox(height: 16),
                      programField,
                      const SizedBox(height: 16),
                      activityField,
                      const SizedBox(height: 16),
                      uacsField,
                      const SizedBox(height: 16),
                      classField,
                      const SizedBox(height: 16),
                      payeeField,
                      const SizedBox(height: 16),
                      grossAmountField,
                      const SizedBox(height: 16),
                      disbursementField,
                      const SizedBox(height: 16),
                      dueAndDemandableField,
                      const SizedBox(height: 16),
                      particularField,
                      const SizedBox(height: 16),
                      descriptionField,
                      const SizedBox(height: 16),
                      attachmentWidget,
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: fundField),
                        const SizedBox(width: 20),
                        Expanded(child: obrNoField),
                        const SizedBox(width: 20),
                        Expanded(child: dateField),
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
                        Expanded(child: uacsField),
                        const SizedBox(width: 20),
                        Expanded(child: classField),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: payeeField),
                        const SizedBox(width: 20),
                        Expanded(child: grossAmountField),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: disbursementField),
                        const SizedBox(width: 20),
                        Expanded(child: dueAndDemandableField),
                      ],
                    ),
                    const SizedBox(height: 16),
                    particularField,
                    const SizedBox(height: 16),
                    descriptionField,
                    const SizedBox(height: 16),
                    attachmentWidget,
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            const Divider(height: 1, color: BrmsColors.outlineVariant),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BrmsButton(
                  label: 'Cancel',
                  primary: false,
                  onPressed: _isSaving ? null : _closeForm,
                ),
                const SizedBox(width: 10),
                BrmsButton(
                  label: _editingObr == null ? 'Save' : 'Update',
                  onPressed: _isSaving
                      ? null
                      : () => _saveForm(
                          uacsList: uacsList,
                          remainingBalance: remainingBalance,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUacsAutocomplete(List<UacsCode> uacsList) {
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
        Autocomplete<UacsCode>(
          initialValue: TextEditingValue(text: _accountCodeController.text),
          displayStringForOption: (u) => u.accountCode,
          optionsBuilder: (textEditingValue) {
            final q = textEditingValue.text.trim().toLowerCase();
            if (q.isEmpty) return uacsList;
            return uacsList.where(
              (u) =>
                  u.accountCode.toLowerCase().contains(q) ||
                  u.objectTitle.toLowerCase().contains(q),
            );
          },
          onSelected: (selected) {
            setState(() {
              _accountCodeController.text = selected.accountCode;
              if (BrmsFormatters.allotmentClasses.contains(
                selected.allotmentClass,
              )) {
                _formAllotmentClass = selected.allotmentClass;
              }
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            if (controller.text != _accountCodeController.text) {
              controller.text = _accountCodeController.text;
              controller.selection = TextSelection.collapsed(
                offset: controller.text.length,
              );
            }
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (v) => _accountCodeController.text = v,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Account Code is required';
                }
                if (!uacsList.any((u) => u.accountCode == v.trim())) {
                  return 'Select a valid UACS code';
                }
                return null;
              },
              style: BrmsTheme.mono(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: _inputDecoration(hintText: 'e.g., 50101010'),
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
                    maxHeight: 220,
                    maxWidth: 420,
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
                        subtitle: Text(
                          u.allotmentClass,
                          style: const TextStyle(
                            fontSize: 11,
                            color: BrmsColors.secondary,
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
    required List<String> options,
    required String hintText,
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
        Autocomplete<String>(
          initialValue: TextEditingValue(text: controller.text),
          optionsBuilder: (textEditingValue) {
            final q = textEditingValue.text.trim().toLowerCase();
            if (q.isEmpty) return options;
            return options.where((o) => o.toLowerCase().contains(q));
          },
          onSelected: (selected) => controller.text = selected,
          fieldViewBuilder: (context, fieldCtrl, focusNode, onSubmitted) {
            if (fieldCtrl.text != controller.text) {
              fieldCtrl.text = controller.text;
              fieldCtrl.selection = TextSelection.collapsed(
                offset: fieldCtrl.text.length,
              );
            }
            return TextFormField(
              controller: fieldCtrl,
              focusNode: focusNode,
              onChanged: (v) => controller.text = v,
              validator: validator,
              style: const TextStyle(fontSize: 13, color: BrmsColors.onSurface),
              decoration: _inputDecoration(hintText: hintText),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAttachmentPickerBox() {
    final displayName =
        _pickedAttachment?.originalFilename ??
        _existingAttachmentFilename ??
        'No PDF attached';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrmsColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BrmsColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: BrmsColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: BrmsColors.outlineVariant),
            ),
            child: const Icon(
              Icons.picture_as_pdf_outlined,
              size: 18,
              color: BrmsColors.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUPPORTING ATTACHMENT (PDF)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: BrmsColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          BrmsButton(
            label: 'Attach file',
            icon: Icons.attach_file,
            primary: false,
            height: 32,
            onPressed: _pickPdfFile,
          ),
        ],
      ),
    );
  }

  Widget _buildFormDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
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
          decoration: _inputDecoration(),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFormTextField({
    required String label,
    required TextEditingController controller,
    String? prefixText,
    String? hintText,
    String? errorText,
    IconData? suffixIcon,
    bool mono = false,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
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
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          style: mono
              ? BrmsTheme.mono(fontSize: 13, fontWeight: FontWeight.w600)
              : const TextStyle(fontSize: 13, color: BrmsColors.onSurface),
          decoration: _inputDecoration(
            prefixText: prefixText,
            hintText: hintText,
            errorText: errorText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    String? prefixText,
    String? hintText,
    String? errorText,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      prefixText: prefixText,
      hintText: hintText,
      errorText: errorText,
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, size: 16, color: BrmsColors.secondary)
          : null,
      filled: true,
      fillColor: BrmsColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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

class _CompactSelect<T> extends StatelessWidget {
  const _CompactSelect({
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

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
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: BrmsColors.onSurface,
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
