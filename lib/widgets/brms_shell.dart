import 'package:flutter/material.dart';
import '../models/brms_models.dart';
import '../theme/brms_theme.dart';
import '../screens/executive_dashboard_screen.dart';
import '../screens/set_budget_screen.dart';
import '../screens/obligation_registry_screen.dart';
import '../screens/far_1a_report_screen.dart';
import '../screens/account_management_screen.dart';

/// Main desktop/web shell containing the floating header, pill navigation,
/// and active BRMS module content.
class BrmsShell extends StatefulWidget {
  const BrmsShell({
    super.key,
    required this.onSignOut,
    this.initialModule = BrmsModule.dashboard,
  });

  final VoidCallback onSignOut;
  final BrmsModule initialModule;

  @override
  State<BrmsShell> createState() => _BrmsShellState();
}

class _BrmsShellState extends State<BrmsShell> {
  late BrmsModule _activeModule = widget.initialModule;

  void _selectModule(BrmsModule module) {
    setState(() => _activeModule = module);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrmsColors.background,
      body: Column(
        children: [
          _buildFloatingHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildModuleNavBar(),
                  const SizedBox(height: 16),
                  _buildBody(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader(BuildContext context) {
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
                  onTap: () => _selectModule(BrmsModule.dashboard),
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
                // Right controls
                LayoutBuilder(
                  builder: (context, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // User profile pill (navigates to Account Management)
                        InkWell(
                          onTap: () => _selectModule(BrmsModule.accounts),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _activeModule == BrmsModule.accounts
                                  ? BrmsColors.surfaceContainerHigh
                                  : BrmsColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _activeModule == BrmsModule.accounts
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
                          onPressed: widget.onSignOut,
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
                          onPressed: widget.onSignOut,
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleNavBar() {
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
            final isSelected = module == _activeModule;
            return InkWell(
              onTap: () => _selectModule(module),
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
      case BrmsModule.farReports:
        return Icons.assessment_outlined;
      case BrmsModule.accounts:
        return Icons.manage_accounts_outlined;
    }
  }

  Widget _buildBody() {
    switch (_activeModule) {
      case BrmsModule.dashboard:
        return ExecutiveDashboardScreen(onNavigate: _selectModule);
      case BrmsModule.setBudget:
        return const SetBudgetScreen();
      case BrmsModule.obligations:
        return const ObligationRegistryScreen();
      case BrmsModule.farReports:
        return const Far1AReportScreen();
      case BrmsModule.accounts:
        return const AccountManagementScreen();
    }
  }
}
