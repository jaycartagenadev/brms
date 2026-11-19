import 'package:flutter/material.dart';
import '../models/brms_models.dart';
import '../theme/brms_theme.dart';
import '../widgets/brms_common.dart';

/// Screen 6: BRMS CSU Aparri - Account Management (Monochrome).
class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  String _autoLock = 'Never (Offline Kiosk)';
  String _roleFilter = 'All Roles (6)';
  String _statusFilter = 'All States';

  void _openAddUserDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: BrmsColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FISCAL CREDENTIAL PROVISIONING',
                          style: BrmsTheme.mono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: BrmsColors.secondary,
                          ),
                        ),
                        Text(
                          'Add User Account',
                          style: BrmsTheme.heading(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _DrawerInput(
                  label: 'FULL LEGAL NAME',
                  hint: 'e.g., Prof. Juan Dela Cruz',
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                      child: _DrawerInput(
                        label: 'FACULTY / EMPLOYEE ID',
                        hint: 'ID-2024-XXXX',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _DrawerInput(
                        label: 'SYSTEM USERNAME',
                        hint: '@jdelacruz',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _DrawerInput(
                  label: 'CAMPUS DEPARTMENT / OFFICE',
                  hint: 'Accounting & Disbursement Unit',
                ),
                const SizedBox(height: 12),
                const _DrawerInput(
                  label: 'DESIGNATED SYSTEM ROLE',
                  hint: 'Accounting Clerk (Data Encoder)',
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BrmsButton(
                      label: 'Cancel',
                      primary: false,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    const SizedBox(width: 8),
                    BrmsButton(
                      label: 'Provision Account',
                      icon: Icons.person_add_outlined,
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        showBrmsNotice(
                          context,
                          'Account provisioned (static UI showcase).',
                        );
                      },
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
              _buildPageHeader(context),
              const SizedBox(height: 18),
              _buildOfficerAndSecurityRow(context),
              const SizedBox(height: 18),
              _buildDirectoryCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Text(
          'Account & Access Management',
          style: BrmsTheme.heading(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrmsButton(
              label: 'Audit Access Logs',
              icon: Icons.verified_user_outlined,
              primary: false,
              onPressed: () => showBrmsNotice(
                context,
                'Audit access logs viewed (showcase).',
              ),
            ),
            const SizedBox(width: 8),
            BrmsButton(
              label: 'Add User Account',
              icon: Icons.person_add_outlined,
              onPressed: _openAddUserDialog,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOfficerAndSecurityRow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 920;
        final profileCard = BrmsCard(
          child: Wrap(
            spacing: 20,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: BrmsColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'JT',
                        style: BrmsTheme.heading(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: const [
                          Text(
                            'Johnyrey Tumanu',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: BrmsColors.onSurface,
                            ),
                          ),
                          BrmsBadge(label: '@jtumanu'),
                          BrmsBadge(label: 'SUPER ADMIN', filled: true),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Campus Budget Officer • Designated Fiscal Custodian',
                        style: TextStyle(
                          fontSize: 12,
                          color: BrmsColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 6,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 15,
                                color: BrmsColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Active Session: 08:15 AM PHT',
                                style: BrmsTheme.mono(
                                  fontSize: 11,
                                  color: BrmsColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.desktop_windows_outlined,
                                size: 15,
                                color: BrmsColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Terminal-APA-01',
                                style: BrmsTheme.mono(
                                  fontSize: 11,
                                  color: BrmsColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'CURRENT SCOPE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: BrmsColors.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Fiscal Custody & OBR Approval',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: BrmsColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BrmsColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 3.5,
                          backgroundColor: BrmsColors.statusActiveDot,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Authenticated',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: BrmsColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        final securityCard = BrmsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TERMINAL ACCESS CONTROLS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: BrmsColors.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(
                    Icons.shield_outlined,
                    size: 18,
                    color: BrmsColors.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BrmsColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workstation Auto-Lock',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Require PIN when idle',
                            style: TextStyle(
                              fontSize: 11,
                              color: BrmsColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _autoLock,
                        isDense: true,
                        style: BrmsTheme.mono(fontSize: 11),
                        items: const [
                          DropdownMenuItem(
                            value: '30 Minutes',
                            child: Text('30 Minutes'),
                          ),
                          DropdownMenuItem(
                            value: '1 Hour',
                            child: Text('1 Hour'),
                          ),
                          DropdownMenuItem(
                            value: 'Never (Offline Kiosk)',
                            child: Text('Never (Offline Kiosk)'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _autoLock = v);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BrmsColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PIN Authentication',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Current: 6-Digit Hardened PIN',
                            style: TextStyle(
                              fontSize: 11,
                              color: BrmsColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    BrmsButton(
                      label: 'Change',
                      primary: false,
                      height: 30,
                      onPressed: () => showBrmsNotice(
                        context,
                        'PIN change dialog (static UI showcase).',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        if (!isWide) {
          return Column(
            children: [
              profileCard,
              const SizedBox(height: 14),
              securityCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 8, child: profileCard),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: securityCard),
          ],
        );
      },
    );
  }

  Widget _buildDirectoryCard(BuildContext context) {
    return BrmsCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: BrmsColors.surfaceContainerLow,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(color: BrmsColors.outlineVariant),
              ),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 360,
                  height: 36,
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: BrmsColors.secondary,
                      ),
                      hintText:
                          'Search full name, username, designated role, or workstation ID...',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: BrmsColors.secondary,
                      ),
                      filled: true,
                      fillColor: BrmsColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
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
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _DropdownChip(
                      label: 'ROLE:',
                      value: _roleFilter,
                      items: const [
                        'All Roles (6)',
                        'Campus Budget Officer',
                        'Accounting Staff',
                        'Campus Executive Officer',
                        'COA Resident Auditor',
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _roleFilter = v);
                      },
                    ),
                    _DropdownChip(
                      label: 'STATUS:',
                      value: _statusFilter,
                      items: const [
                        'All States',
                        'Active Workstation',
                        'Read-Only Audit',
                        'Restricted',
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _statusFilter = v);
                      },
                    ),
                    IconButton(
                      tooltip: 'Refresh Table',
                      onPressed: () =>
                          showBrmsNotice(context, 'Directory refreshed.'),
                      icon: const Icon(Icons.refresh, size: 18),
                      style: IconButton.styleFrom(
                        foregroundColor: BrmsColors.secondary,
                        backgroundColor: BrmsColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: BrmsColors.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                BrmsColors.surfaceContainerHigh.withValues(alpha: 0.7),
              ),
              headingTextStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BrmsColors.secondary,
                letterSpacing: 0.4,
              ),
              dataRowMinHeight: 58,
              dataRowMaxHeight: 62,
              columns: const [
                DataColumn(label: Text('USER IDENTITY & ACCOUNT')),
                DataColumn(label: Text('DESIGNATED OFFICE / ROLE')),
                DataColumn(label: Text('ACCESS LEVEL')),
                DataColumn(label: Text('BOUND WORKSTATION')),
                DataColumn(label: Text('LAST RECORDED ACTION')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: BrmsMockData.systemUsers.map((user) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: BrmsColors.surfaceContainerHighest,
                            child: Text(
                              user.initials,
                              style: BrmsTheme.mono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                user.handleAndId,
                                style: BrmsTheme.mono(
                                  fontSize: 11,
                                  color: BrmsColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.roleTitle,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            user.office,
                            style: const TextStyle(
                              fontSize: 11,
                              color: BrmsColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      BrmsBadge(
                        label: user.accessLevel,
                        filled: user.isSuperAdmin,
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.computer,
                            size: 15,
                            color: BrmsColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.workstation,
                            style: BrmsTheme.mono(
                              fontSize: 11,
                              color: BrmsColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.lastActionTime,
                            style: BrmsTheme.mono(fontSize: 11),
                          ),
                          Text(
                            user.lastActionDetail,
                            style: const TextStyle(
                              fontSize: 10,
                              color: BrmsColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 3.5,
                            backgroundColor: user.status == 'ACTIVE'
                                ? BrmsColors.statusActiveDot
                                : BrmsColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.status,
                            style: BrmsTheme.mono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: user.status == 'ACTIVE'
                                  ? BrmsColors.onSurface
                                  : BrmsColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit Permissions',
                            onPressed: () => showBrmsNotice(
                              context,
                              'Inspecting permissions for ${user.fullName}.',
                            ),
                            icon: const Icon(Icons.tune, size: 16),
                            style: IconButton.styleFrom(
                              foregroundColor: BrmsColors.secondary,
                              side: const BorderSide(
                                color: BrmsColors.outlineVariant,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            tooltip: 'Reset PIN',
                            onPressed: () => showBrmsNotice(
                              context,
                              'PIN reset triggered for ${user.fullName}.',
                            ),
                            icon: const Icon(Icons.password, size: 16),
                            style: IconButton.styleFrom(
                              foregroundColor: BrmsColors.secondary,
                              side: const BorderSide(
                                color: BrmsColors.outlineVariant,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
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
              color: BrmsColors.surfaceContainerLow,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BrmsBadge(label: 'Previous'),
                SizedBox(width: 6),
                BrmsBadge(label: '1', filled: true),
                SizedBox(width: 6),
                BrmsBadge(label: 'Next'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  const _DropdownChip({
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
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: BrmsColors.secondary,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: BrmsColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: BrmsColors.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              style: const TextStyle(fontSize: 12, color: BrmsColors.onSurface),
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

class _DrawerInput extends StatelessWidget {
  const _DrawerInput({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: BrmsTheme.mono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: BrmsColors.secondary,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 12,
              color: BrmsColors.secondary,
            ),
            filled: true,
            fillColor: BrmsColors.surfaceContainerLow,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: BrmsColors.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }
}
