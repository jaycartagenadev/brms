import 'package:flutter/material.dart';
import '../models/brms_models.dart';
import '../theme/brms_theme.dart';
import '../widgets/brms_common.dart';

/// Screen 3: BRMS CSU Aparri - Set Budget Allocation (Monochrome).
class SetBudgetScreen extends StatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  String _selectedFy = '2024-2025';
  String _selectedFundCode = '101 - Regular Agency Fund';
  final _dateController = TextEditingController(text: '2024-01-03');
  final _amountController = TextEditingController(text: '15,500,000');

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSetBudgetFormCard(),
              const SizedBox(height: 24),
              _buildSummaryTableCard(),
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

  Widget _buildSetBudgetFormCard() {
    return BrmsCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Set Budget',
            style: BrmsTheme.heading(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Allocate statutory appropriations and allotment ceilings for CSU Aparri Campus fiscal funds.',
            style: TextStyle(fontSize: 12, color: BrmsColors.secondary),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoCol = constraints.maxWidth >= 680;
              final fyField = _buildDropdownField(
                label: 'FISCAL YEAR',
                value: _selectedFy,
                items: const ['2024-2025', '2023-2024', '2022-2023'],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedFy = v);
                },
              );
              final dateField = _buildInputField(
                label: 'DATE OF ALLOCATION',
                controller: _dateController,
                suffixIcon: Icons.calendar_today_outlined,
              );
              final fundField = _buildDropdownField(
                label: 'FUND CODE',
                value: _selectedFundCode,
                items: const [
                  '101 - Regular Agency Fund',
                  '161 - Income Generating Projects',
                  '164 - Internally Generated Fund',
                  '184 - Research and Mangrove Projects',
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedFundCode = v);
                },
              );
              final amountField = _buildInputField(
                label: 'AMOUNT (₱)',
                controller: _amountController,
                prefixText: '₱ ',
                mono: true,
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
                    amountField,
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: fyField),
                      const SizedBox(width: 20),
                      Expanded(child: dateField),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: fundField),
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
                onPressed: () {
                  _amountController.text = '15,500,000';
                  showBrmsNotice(context, 'Allocation form reset.');
                },
              ),
              const SizedBox(width: 10),
              BrmsButton(
                label: 'Save',
                onPressed: () => showBrmsNotice(
                  context,
                  'Budget allocation saved (static UI showcase).',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTableCard() {
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
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
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
                      DataColumn(label: Text('DATE OF ALLOCATION')),
                      DataColumn(label: Text('AMOUNT'), numeric: true),
                      DataColumn(
                        label: Center(child: Text('ACTION')),
                      ),
                    ],
                    rows: BrmsMockData.budgetAllocations.map((entry) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              entry.fiscalYear,
                              style: BrmsTheme.mono(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              entry.fundCode,
                              style: BrmsTheme.mono(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              entry.allocationDate,
                              style: const TextStyle(
                                fontSize: 12,
                                color: BrmsColors.secondary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              entry.amount,
                              style: BrmsTheme.mono(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => showBrmsNotice(
                                      context,
                                      'Editing Fund ${entry.fundCode} (${entry.fiscalYear})',
                                    ),
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
                                    onPressed: () => showBrmsNotice(
                                      context,
                                      'Hide action triggered for Fund ${entry.fundCode}.',
                                    ),
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
                                    child: const Text(
                                      'Hide',
                                      style: TextStyle(
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
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
        DropdownButtonFormField<String>(
          initialValue: value,
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
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? prefixText,
    IconData? suffixIcon,
    bool mono = false,
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
        TextField(
          controller: controller,
          style: mono
              ? BrmsTheme.mono(fontSize: 13, fontWeight: FontWeight.w700)
              : const TextStyle(fontSize: 13, color: BrmsColors.onSurface),
          decoration: InputDecoration(
            prefixText: prefixText,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, size: 16, color: BrmsColors.secondary)
                : null,
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
}
