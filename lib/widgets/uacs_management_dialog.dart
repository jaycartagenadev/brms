import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/brms_providers.dart';
import '../theme/brms_theme.dart';
import '../utils/brms_formatters.dart';
import 'brms_common.dart';
import 'brms_confirm_dialog.dart';

/// Modal dialog for viewing, adding, and safely removing UACS object codes.
class UacsManagementDialog extends ConsumerStatefulWidget {
  const UacsManagementDialog({super.key});

  @override
  ConsumerState<UacsManagementDialog> createState() =>
      _UacsManagementDialogState();
}

class _UacsManagementDialogState extends ConsumerState<UacsManagementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  String _selectedClass = BrmsFormatters.allotmentClasses.first;
  String _filterClass = 'ALL';
  bool _isSaving = false;

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _addUacs() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(databaseProvider).upsertUacsCode(
            accountCode: _codeController.text.trim(),
            objectTitle: _titleController.text.trim(),
            allotmentClass: _selectedClass,
          );
      if (mounted) {
        final code = _codeController.text.trim();
        _codeController.clear();
        _titleController.clear();
        showBrmsNotice(context, 'Saved UACS code $code.');
      }
    } catch (e) {
      if (mounted) {
        showBrmsNotice(context, 'Failed to save UACS code: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteUacs(String code, String title) async {
    final confirmed = await showBrmsConfirmDialog(
      context,
      title: 'Delete UACS Code',
      message: 'Remove "$code — $title"? Codes already used by allocations or '
          'OBRs cannot be deleted.',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !mounted) return;

    final deleted = await ref.read(databaseProvider).deleteUacsCode(code);
    if (!mounted) return;
    showBrmsNotice(
      context,
      deleted
          ? 'Removed UACS code $code.'
          : 'Cannot delete $code because it is referenced by existing records.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final uacsAsync = ref.watch(uacsCodesProvider);
    final allCodes = uacsAsync.value ?? const [];
    final filtered = _filterClass == 'ALL'
        ? allCodes
        : allCodes.where((u) => u.allotmentClass == _filterClass).toList();

    return Dialog(
      backgroundColor: BrmsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(22),
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
                          'Manage UACS Object Codes',
                          style: BrmsTheme.heading(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Add or maintain PS, MOOE, and Capital Outlay account codes used in allocations and OBRs.',
                          style: TextStyle(
                            fontSize: 12,
                            color: BrmsColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: BrmsColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: BrmsColors.outlineVariant),
                ),
                child: Form(
                  key: _formKey,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      SizedBox(
                        width: 150,
                        child: TextFormField(
                          controller: _codeController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                              BrmsInputLimits.maxShortCodeLength,
                            ),
                          ],
                          style: BrmsTheme.mono(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Code required'
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'UACS Code',
                            hintText: 'e.g. 50604050',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        child: TextFormField(
                          controller: _titleController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                              BrmsInputLimits.maxNameLength,
                            ),
                          ],
                          style: const TextStyle(fontSize: 12),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Object title required'
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Object Title',
                            hintText: 'e.g. ICT Equipment Outlay',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 210,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(_selectedClass),
                          initialValue: _selectedClass,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Allotment Class',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          items: BrmsFormatters.allotmentClasses
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    BrmsFormatters.shortAllotmentLabel(c),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedClass = v);
                          },
                        ),
                      ),
                      BrmsButton(
                        label: 'Add UACS',
                        icon: Icons.add,
                        height: 40,
                        onPressed: _isSaving ? null : _addUacs,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Registered UACS Codes (${filtered.length})',
                    style: BrmsTheme.mono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: BrmsColors.secondary,
                    ),
                  ),
                  BrmsTableFilterSelect<String>(
                    label: 'CLASS:',
                    value: _filterClass,
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
                      if (v != null) setState(() => _filterClass = v);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: BrmsColors.outlineVariant),
                  ),
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No UACS codes found.',
                            style: TextStyle(
                              fontSize: 12,
                              color: BrmsColors.secondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            color: BrmsColors.outlineVariant,
                          ),
                          itemBuilder: (ctx, i) {
                            final u = filtered[i];
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
                              trailing: IconButton(
                                tooltip: 'Delete UACS Code',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 17,
                                  color: BrmsColors.error,
                                ),
                                onPressed: () =>
                                    _deleteUacs(u.accountCode, u.objectTitle),
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BrmsButton(
                    label: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
