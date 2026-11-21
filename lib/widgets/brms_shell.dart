import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/brms_models.dart';
import '../providers/brms_providers.dart';
import '../theme/brms_theme.dart';
import 'brms_common.dart';
import 'brms_confirm_dialog.dart';

/// Main desktop/web shell containing the floating header, pill navigation,
/// database backup/restore controls (Desktop), and routed BRMS module content.
class BrmsShell extends ConsumerWidget {
  const BrmsShell({
    super.key,
    required this.activeModule,
    required this.selectedReportType,
    required this.onSignOut,
    required this.child,
  });

  final BrmsModule activeModule;
  final ReportType selectedReportType;
  final VoidCallback onSignOut;
  final Widget child;

  void _navigateModule(BuildContext context, BrmsModule module) {
    if (module == BrmsModule.reports) {
      context.go(selectedReportType.routePath);
    } else {
      context.go(module.routePath);
    }
  }

  void _navigateReport(BuildContext context, ReportType reportType) {
    context.go(reportType.routePath);
  }

  Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
    final msg = await ref.read(databaseBackupServiceProvider).backupDatabase();
    if (msg != null && context.mounted) {
      showBrmsNotice(context, msg);
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final confirmed = await showBrmsConfirmDialog(
      context,
      title: 'Restore Local Database',
      message:
          'Restoring from a .sqlite backup will overwrite all current local '
          'budget allocations, modifications, and obligation records. Continue?',
      confirmLabel: 'Choose Backup File',
    );
    if (!confirmed || !context.mounted) return;

    final result = await ref
        .read(databaseBackupServiceProvider)
        .restoreDatabase(
          closeDatabase: () => ref.read(databaseProvider).close(),
        );
    if (result.restored) {
      ref.invalidate(databaseProvider);
    }
    if (result.message != null && context.mounted) {
      showBrmsNotice(context, result.message!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: BrmsColors.background,
      body: Column(
        children: [
          _buildFloatingHeader(context, ref),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildModuleNavBar(context),
                  const SizedBox(height: 16),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: BrmsColors.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BrmsColors.outlineVariant.withValues(alpha: 0.8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left institutional brand
                InkWell(
                  onTap: () => _navigateModule(context, BrmsModule.dashboard),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: BrmsColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.account_balance,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'CSU APARRI',
                                style: BrmsTheme.heading(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: BrmsColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'BRMS',
                                  style: BrmsTheme.mono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: BrmsColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Budget Resource Monitoring System',
                            style: TextStyle(
                              fontSize: 11,
                              color: BrmsColors.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!kIsWeb) ...[
                      PopupMenuButton<String>(
                        tooltip: 'Database Backup & Restore',
                        offset: const Offset(0, 40),
                        color: BrmsColors.surface,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: BrmsColors.outlineVariant,
                          ),
                        ),
                        onSelected: (action) {
                          if (action == 'backup') {
                            _handleBackup(context, ref);
                          } else if (action == 'restore') {
                            _handleRestore(context, ref);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'backup',
                            height: 38,
                            child: Row(
                              children: [
                                Icon(Icons.backup_outlined, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Backup Database (.sqlite)',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'restore',
                            height: 38,
                            child: Row(
                              children: [
                                Icon(Icons.restore_outlined, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Restore Database (.sqlite)',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: BrmsColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: BrmsColors.outlineVariant,
                            ),
                          ),
                          child: const Icon(
                            Icons.storage_outlined,
                            size: 18,
                            color: BrmsColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // User profile pill (navigates to Account Management)
                    InkWell(
                      onTap: () => _navigateModule(context, BrmsModule.accounts),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: activeModule == BrmsModule.accounts
                              ? BrmsColors.surfaceContainerHigh
                              : BrmsColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: activeModule == BrmsModule.accounts
                                ? BrmsColors.primary
                                : BrmsColors.outlineVariant,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: BrmsColors.primary,
                          child: Center(
                            child: Text(
                              'JT',
                              textAlign: TextAlign.center,
                              style: BrmsTheme.mono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 22,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: BrmsColors.outlineVariant,
                    ),
                    IconButton(
                      tooltip: 'Lock Session',
                      onPressed: onSignOut,
                      icon: const Icon(Icons.lock_outline, size: 18),
                      style: IconButton.styleFrom(
                        foregroundColor: BrmsColors.secondary,
                        backgroundColor: BrmsColors.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: BrmsColors.outlineVariant,
                          ),
                        ),
                        fixedSize: const Size(34, 34),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Sign Out',
                      onPressed: onSignOut,
                      icon: const Icon(Icons.logout, size: 18),
                      style: IconButton.styleFrom(
                        foregroundColor: BrmsColors.secondary,
                        backgroundColor: BrmsColors.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: BrmsColors.outlineVariant,
                          ),
                        ),
                        fixedSize: const Size(34, 34),
                        padding: EdgeInsets.zero,
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
  }

  Widget _buildModuleNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: BrmsColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: BrmsColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: BrmsModule.values.map((module) {
            final isSelected = module == activeModule;
            if (module == BrmsModule.reports) {
              return PopupMenuButton<ReportType>(
                tooltip: 'Select Report',
                offset: const Offset(0, 42),
                color: BrmsColors.surface,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: BrmsColors.outlineVariant),
                ),
                onSelected: (type) => _navigateReport(context, type),
                itemBuilder: (context) => ReportType.values.map((type) {
                  final isCurrent = isSelected && type == selectedReportType;
                  return PopupMenuItem<ReportType>(
                    value: type,
                    height: 38,
                    child: Row(
                      children: [
                        Icon(
                          isCurrent
                              ? Icons.check
                              : Icons.description_outlined,
                          size: 15,
                          color: isCurrent
                              ? BrmsColors.primary
                              : BrmsColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: BrmsColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? BrmsColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _iconForModule(module),
                        size: 16,
                        color: isSelected ? Colors.white : BrmsColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        module.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : BrmsColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: isSelected ? Colors.white : BrmsColors.secondary,
                      ),
                    ],
                  ),
                ),
              );
            }

            return InkWell(
              onTap: () => _navigateModule(context, module),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? BrmsColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconForModule(module),
                      size: 16,
                      color: isSelected ? Colors.white : BrmsColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      module.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? Colors.white : BrmsColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _iconForModule(BrmsModule module) {
    switch (module) {
      case BrmsModule.dashboard:
        return Icons.dashboard_outlined;
      case BrmsModule.setBudget:
        return Icons.account_balance_wallet_outlined;
      case BrmsModule.obligations:
        return Icons.receipt_long_outlined;
      case BrmsModule.reports:
        return Icons.assessment_outlined;
      case BrmsModule.accounts:
        return Icons.manage_accounts_outlined;
    }
  }
}
