import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/brms_models.dart';
import '../providers/brms_providers.dart';
import '../theme/brms_theme.dart';
import '../widgets/brms_common.dart';

/// Screen 6: BRMS CSU Aparri - Account Management (Monochrome).
class AccountManagementScreen extends ConsumerStatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  ConsumerState<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState
    extends ConsumerState<AccountManagementScreen> {
  static const int _pageSize = 5;
  static const String _allRolesValue = 'ALL_ROLES';

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _roleFilter = _allRolesValue;
  String _accessLevelFilter = 'ALL';
  String _statusFilter = 'All States';
  int _currentPage = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SystemUserRecord> _applyFilters(List<SystemUserRecord> users) {
    final query = _searchQuery.trim().toLowerCase();
    return users.where((user) {
      if (query.isNotEmpty) {
        final haystack = [
          user.fullName,
          user.handleAndId,
          user.roleTitle,
          user.office,
          user.workstation,
          user.accessLevel,
        ].join(' ').toLowerCase();
        if (!haystack.contains(query)) return false;
      }

      if (_roleFilter != _allRolesValue) {
        if (_roleFilter == 'Accounting Staff') {
          final isAccounting =
              user.roleTitle.toLowerCase().contains('accounting') ||
              user.roleTitle.toLowerCase().contains('budget analyst') ||
              user.office.toLowerCase().contains('accounting');
          if (!isAccounting) return false;
        } else if (_roleFilter == 'COA Resident Auditor') {
          final isAuditor =
              user.fullName.toLowerCase().contains('auditor') ||
              user.roleTitle.toLowerCase().contains('auditor');
          if (!isAuditor) return false;
        } else if (user.roleTitle != _roleFilter) {
          return false;
        }
      }

      if (_accessLevelFilter != 'ALL' &&
          user.accessLevel != _accessLevelFilter) {
        return false;
      }

      switch (_statusFilter) {
        case 'Active Workstation':
          if (user.status != 'ACTIVE') return false;
        case 'Read-Only Audit':
          if (user.status != 'READ-ONLY') return false;
        case 'Restricted':
          if (user.status != 'RESTRICTED') return false;
      }

      return true;
    }).toList();
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _roleFilter = _allRolesValue;
      _accessLevelFilter = 'ALL';
      _statusFilter = 'All States';
      _currentPage = 1;
    });
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  void _openAuditLogsDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => const _AuditLogsDialog(),
    );
  }

  void _openAddUserDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => _AddUserDialog(
        onProvisioned: (fullName) {
          setState(() => _currentPage = 1);
          showBrmsNotice(context, 'Account provisioned for $fullName.');
        },
      ),
    );
  }

  void _openChangeTerminalPinDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => _ChangeTerminalPinDialog(
        onUpdated: () {
          showBrmsNotice(context, 'Terminal PIN updated successfully.');
        },
      ),
    );
  }

  void _openEditPermissionsDialog(SystemUserRecord user) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditPermissionsDialog(
        user: user,
        onSaved: () {
          showBrmsNotice(
            context,
            'Permissions updated for ${user.fullName}.',
          );
        },
      ),
    );
  }

  void _openResetPinDialog(SystemUserRecord user) {
    showDialog<void>(
      context: context,
      builder: (_) => _ResetPinDialog(
        user: user,
        onPinReset: (pin) {
          showBrmsNotice(
            context,
            'Temporary PIN ($pin) issued for ${user.fullName}.',
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(accountManagementProvider);

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
              _buildOfficerAndSecurityRow(context, accountState),
              const SizedBox(height: 18),
              _buildDirectoryCard(context, accountState),
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
              onPressed: _openAuditLogsDialog,
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

  Widget _buildOfficerAndSecurityRow(
    BuildContext context,
    AccountManagementState accountState,
  ) {
    final primaryOfficer = accountState.users.firstWhere(
      (u) => u.isSuperAdmin,
      orElse: () => accountState.users.first,
    );

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
                        primaryOfficer.initials,
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
                          children: [
                            Text(
                              primaryOfficer.fullName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: BrmsColors.onSurface,
                              ),
                            ),
                            BrmsBadge(
                              label: primaryOfficer.handleAndId
                                  .split(' ')
                                  .first,
                            ),
                            BrmsBadge(
                              label: primaryOfficer.accessLevel,
                              filled: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${primaryOfficer.roleTitle} • Designated Fiscal Custodian',
                          style: const TextStyle(
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
                                  primaryOfficer.workstation,
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
                        value: accountState.autoLock,
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
                          if (v != null) {
                            ref
                                .read(accountManagementProvider.notifier)
                                .setAutoLock(v);
                            showBrmsNotice(
                              context,
                              'Workstation auto-lock set to $v.',
                            );
                          }
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
                      onPressed: _openChangeTerminalPinDialog,
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

  Widget _buildDirectoryCard(
    BuildContext context,
    AccountManagementState accountState,
  ) {
    final filteredUsers = _applyFilters(accountState.users);
    final totalItems = filteredUsers.length;
    final totalPages = max(1, (totalItems / _pageSize).ceil());
    final safePage = _currentPage.clamp(1, totalPages);
    final startIdx = (safePage - 1) * _pageSize;
    final endIdx = min(startIdx + _pageSize, totalItems);
    final pagedUsers = totalItems == 0
        ? const <SystemUserRecord>[]
        : filteredUsers.sublist(startIdx, endIdx);

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
                    controller: _searchController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                        BrmsInputLimits.maxSearchLength,
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _searchQuery = v;
                        _currentPage = 1;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: BrmsColors.secondary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              tooltip: 'Clear Search',
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _currentPage = 1;
                                });
                              },
                            )
                          : null,
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
                      items: [
                        DropdownMenuItem(
                          value: _allRolesValue,
                          child: Text(
                            'All Roles (${accountState.users.length})',
                          ),
                        ),
                        const DropdownMenuItem(
                          value: 'Campus Budget Officer',
                          child: Text('Campus Budget Officer'),
                        ),
                        const DropdownMenuItem(
                          value: 'Accounting Staff',
                          child: Text('Accounting Staff'),
                        ),
                        const DropdownMenuItem(
                          value: 'Campus Executive Officer',
                          child: Text('Campus Executive Officer'),
                        ),
                        const DropdownMenuItem(
                          value: 'COA Resident Auditor',
                          child: Text('COA Resident Auditor'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _roleFilter = v;
                            _currentPage = 1;
                          });
                        }
                      },
                    ),
                    _DropdownChip(
                      label: 'ACCESS:',
                      value: accountState.users.any(
                                (u) => u.accessLevel == _accessLevelFilter,
                              )
                          ? _accessLevelFilter
                          : 'ALL',
                      items: [
                        const DropdownMenuItem(
                          value: 'ALL',
                          child: Text('All Levels'),
                        ),
                        ...(accountState.users
                              .map((u) => u.accessLevel)
                              .toSet()
                              .toList()
                            ..sort())
                            .map(
                              (lvl) => DropdownMenuItem(
                                value: lvl,
                                child: Text(lvl),
                              ),
                            ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _accessLevelFilter = v;
                            _currentPage = 1;
                          });
                        }
                      },
                    ),
                    _DropdownChip(
                      label: 'STATUS:',
                      value: _statusFilter,
                      items: const [
                        DropdownMenuItem(
                          value: 'All States',
                          child: Text('All States'),
                        ),
                        DropdownMenuItem(
                          value: 'Active Workstation',
                          child: Text('Active Workstation'),
                        ),
                        DropdownMenuItem(
                          value: 'Read-Only Audit',
                          child: Text('Read-Only Audit'),
                        ),
                        DropdownMenuItem(
                          value: 'Restricted',
                          child: Text('Restricted'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _statusFilter = v;
                            _currentPage = 1;
                          });
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'Refresh Table',
                      onPressed: () {
                        _resetFilters();
                        showBrmsNotice(context, 'Directory refreshed.');
                      },
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
          if (pagedUsers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
              child: Column(
                children: [
                  const Icon(
                    Icons.person_search_outlined,
                    size: 36,
                    color: BrmsColors.secondary,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No accounts match your current search or filter criteria.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: BrmsColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  BrmsButton(
                    label: 'Clear Filters',
                    primary: false,
                    onPressed: _resetFilters,
                  ),
                ],
              ),
            )
          else
            BrmsHorizontalTableScroll(
              ensureMinWidth: true,
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
                rows: pagedUsers.map((user) {
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
                              onPressed: () => _openEditPermissionsDialog(user),
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
                              onPressed: () => _openResetPinDialog(user),
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
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  totalItems == 0
                      ? 'Showing 0 of 0 accounts'
                      : 'Showing ${startIdx + 1}–$endIdx of $totalItems accounts',
                  style: BrmsTheme.mono(
                    fontSize: 11,
                    color: BrmsColors.secondary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PaginationButton(
                      label: 'Previous',
                      enabled: safePage > 1,
                      onTap: () => setState(() => _currentPage = safePage - 1),
                    ),
                    const SizedBox(width: 6),
                    for (int page = 1; page <= totalPages; page++) ...[
                      _PaginationButton(
                        label: '$page',
                        filled: page == safePage,
                        enabled: true,
                        onTap: () => setState(() => _currentPage = page),
                      ),
                      const SizedBox(width: 6),
                    ],
                    _PaginationButton(
                      label: 'Next',
                      enabled: safePage < totalPages,
                      onTap: () => setState(() => _currentPage = safePage + 1),
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

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: BrmsBadge(label: label, filled: filled),
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
  final List<DropdownMenuItem<String>> items;
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
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogDropdownField extends StatelessWidget {
  const _DialogDropdownField({
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
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          style: const TextStyle(fontSize: 12, color: BrmsColors.onSurface),
          decoration: InputDecoration(
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: BrmsColors.error, width: 1.4),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: BrmsColors.error, width: 1.6),
            ),
            errorStyle: const TextStyle(
              color: BrmsColors.error,
              fontSize: 11,
              fontWeight: FontWeight.w500,
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
}

class _DrawerInput extends StatelessWidget {
  const _DrawerInput({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.suffixIcon,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;

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
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 12, color: BrmsColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 12,
              color: BrmsColors.secondary,
            ),
            suffixIcon: suffixIcon,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: BrmsColors.error, width: 1.4),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: BrmsColors.error, width: 1.6),
            ),
            errorStyle: const TextStyle(
              color: BrmsColors.error,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuditLogsDialog extends ConsumerStatefulWidget {
  const _AuditLogsDialog();

  @override
  ConsumerState<_AuditLogsDialog> createState() => _AuditLogsDialogState();
}

class _AuditLogsDialogState extends ConsumerState<_AuditLogsDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(accountManagementProvider).auditLogs;
    final filteredLogs = _filterQuery.isEmpty
        ? logs
        : logs.where((entry) {
            final text = [
              entry.timestamp,
              entry.actor,
              entry.action,
              entry.detail,
              entry.workstation,
            ].join(' ').toLowerCase();
            return text.contains(_filterQuery.toLowerCase());
          }).toList();

    return Dialog(
      backgroundColor: BrmsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(22),
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
                        'SECURITY & ACCESS TELEMETRY',
                        style: BrmsTheme.mono(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: BrmsColors.secondary,
                        ),
                      ),
                      Text(
                        'Audit Access Logs (${filteredLogs.length})',
                        style: BrmsTheme.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: TextField(
                  controller: _searchCtrl,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      BrmsInputLimits.maxSearchLength,
                    ),
                  ],
                  onChanged: (v) => setState(() => _filterQuery = v.trim()),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 16,
                      color: BrmsColors.secondary,
                    ),
                    hintText: 'Filter by actor, action, or workstation...',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: BrmsColors.secondary,
                    ),
                    filled: true,
                    fillColor: BrmsColors.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: BrmsColors.outlineVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredLogs.isEmpty
                    ? const Center(
                        child: Text(
                          'No audit entries match your filter.',
                          style: TextStyle(
                            fontSize: 12,
                            color: BrmsColors.secondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredLogs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          final log = filteredLogs[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: BrmsColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: BrmsColors.outlineVariant,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          BrmsBadge(
                                            label: log.action,
                                            filled: true,
                                          ),
                                          Text(
                                            log.actor,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        log.detail,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: BrmsColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      log.timestamp,
                                      style: BrmsTheme.mono(
                                        fontSize: 11,
                                        color: BrmsColors.secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      log.workstation,
                                      style: BrmsTheme.mono(
                                        fontSize: 10,
                                        color: BrmsColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BrmsButton(
                    label: 'Close',
                    primary: false,
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

class _AddUserDialog extends ConsumerStatefulWidget {
  const _AddUserDialog({required this.onProvisioned});

  final ValueChanged<String> onProvisioned;

  @override
  ConsumerState<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _employeeIdCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _officeCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _workstationCtrl = TextEditingController(text: 'Terminal-APA-05');
  String _selectedAccessLevel = 'ENCODER';

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _employeeIdCtrl.dispose();
    _usernameCtrl.dispose();
    _officeCtrl.dispose();
    _roleCtrl.dispose();
    _workstationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: BrmsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
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
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DrawerInput(
                  label: 'FULL LEGAL NAME',
                  hint: 'e.g., Prof. Juan Dela Cruz',
                  controller: _fullNameCtrl,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      BrmsInputLimits.maxNameLength,
                    ),
                  ],
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Full name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DrawerInput(
                        label: 'FACULTY / EMPLOYEE ID',
                        hint: 'ID-2026-0101',
                        controller: _employeeIdCtrl,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            BrmsInputLimits.maxShortCodeLength,
                          ),
                        ],
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Employee ID is required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DrawerInput(
                        label: 'SYSTEM USERNAME',
                        hint: '@jdelacruz',
                        controller: _usernameCtrl,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            BrmsInputLimits.maxShortCodeLength,
                          ),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Username is required';
                          }
                          final clean = v.trim().startsWith('@')
                              ? v.trim().toLowerCase()
                              : '@${v.trim().toLowerCase()}';
                          final existing = ref
                              .read(accountManagementProvider)
                              .users
                              .any(
                                (u) => u.handleAndId
                                    .toLowerCase()
                                    .startsWith('$clean '),
                              );
                          if (existing) return 'Username already exists';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DrawerInput(
                  label: 'CAMPUS DEPARTMENT / OFFICE',
                  hint: 'Accounting & Disbursement Unit',
                  controller: _officeCtrl,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      BrmsInputLimits.maxNameLength,
                    ),
                  ],
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Department / office is required'
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DrawerInput(
                        label: 'DESIGNATED SYSTEM ROLE',
                        hint: 'Accounting Clerk',
                        controller: _roleCtrl,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            BrmsInputLimits.maxNameLength,
                          ),
                        ],
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Role title is required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DrawerInput(
                        label: 'BOUND WORKSTATION',
                        hint: 'Terminal-APA-05',
                        controller: _workstationCtrl,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            BrmsInputLimits.maxWorkstationLength,
                          ),
                        ],
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Workstation is required'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DialogDropdownField(
                  label: 'ACCESS LEVEL',
                  value: _selectedAccessLevel,
                  items: const [
                    'ENCODER',
                    'ENCODER / WRITER',
                    'EXECUTIVE REVIEWER',
                    'READ-ONLY AUDIT',
                    'SUPER ADMIN',
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedAccessLevel = v);
                    }
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BrmsButton(
                      label: 'Cancel',
                      primary: false,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    BrmsButton(
                      label: 'Provision Account',
                      icon: Icons.person_add_outlined,
                      onPressed: () {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        final name = _fullNameCtrl.text.trim();
                        ref.read(accountManagementProvider.notifier).addUser(
                              fullName: name,
                              employeeId: _employeeIdCtrl.text.trim(),
                              username: _usernameCtrl.text.trim(),
                              office: _officeCtrl.text.trim(),
                              roleTitle: _roleCtrl.text.trim(),
                              accessLevel: _selectedAccessLevel,
                              workstation: _workstationCtrl.text.trim(),
                            );
                        Navigator.of(context).pop();
                        widget.onProvisioned(name);
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
}

class _ChangeTerminalPinDialog extends ConsumerStatefulWidget {
  const _ChangeTerminalPinDialog({required this.onUpdated});

  final VoidCallback onUpdated;

  @override
  ConsumerState<_ChangeTerminalPinDialog> createState() =>
      _ChangeTerminalPinDialogState();
}

class _ChangeTerminalPinDialogState
    extends ConsumerState<_ChangeTerminalPinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPinCtrl = TextEditingController();
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  String? _pinError;

  @override
  void dispose() {
    _currentPinCtrl.dispose();
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: BrmsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
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
                          'TERMINAL SECURITY',
                          style: BrmsTheme.mono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: BrmsColors.secondary,
                          ),
                        ),
                        Text(
                          'Change Station PIN',
                          style: BrmsTheme.heading(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BrmsColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: BrmsColors.outlineVariant),
                  ),
                  child: const Text(
                    'Enter your current 6-digit hardened PIN (default: 123456) and choose a new 6-digit numeric PIN.',
                    style: TextStyle(fontSize: 11, color: BrmsColors.secondary),
                  ),
                ),
                const SizedBox(height: 14),
                _DrawerInput(
                  label: 'CURRENT 6-DIGIT PIN',
                  hint: '••••••',
                  controller: _currentPinCtrl,
                  obscureText: _obscureCurrent,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 16,
                    ),
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  validator: (v) {
                    if (v == null || v.length != 6) {
                      return 'Enter your 6-digit current PIN';
                    }
                    return null;
                  },
                ),
                if (_pinError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _pinError!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFB3261E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _DrawerInput(
                  label: 'NEW 6-DIGIT PIN',
                  hint: 'Enter 6 digits',
                  controller: _newPinCtrl,
                  obscureText: _obscureNew,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 16,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  validator: (v) {
                    if (v == null || v.length != 6) {
                      return 'New PIN must be exactly 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _DrawerInput(
                  label: 'CONFIRM NEW PIN',
                  hint: 'Re-enter 6 digits',
                  controller: _confirmPinCtrl,
                  obscureText: _obscureNew,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (v) {
                    if (v != _newPinCtrl.text) {
                      return 'PINs do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BrmsButton(
                      label: 'Cancel',
                      primary: false,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    BrmsButton(
                      label: 'Update PIN',
                      icon: Icons.lock_reset,
                      onPressed: () {
                        setState(() => _pinError = null);
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        final ok = ref
                            .read(accountManagementProvider.notifier)
                            .changeTerminalPin(
                              currentPin: _currentPinCtrl.text,
                              newPin: _newPinCtrl.text,
                            );
                        if (!ok) {
                          setState(
                            () => _pinError = 'Current PIN is incorrect.',
                          );
                          return;
                        }
                        Navigator.of(context).pop();
                        widget.onUpdated();
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
}

class _EditPermissionsDialog extends ConsumerStatefulWidget {
  const _EditPermissionsDialog({required this.user, required this.onSaved});

  final SystemUserRecord user;
  final VoidCallback onSaved;

  @override
  ConsumerState<_EditPermissionsDialog> createState() =>
      _EditPermissionsDialogState();
}

class _EditPermissionsDialogState
    extends ConsumerState<_EditPermissionsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _roleCtrl;
  late final TextEditingController _officeCtrl;
  late final TextEditingController _workstationCtrl;
  late String _accessLevel;
  late String _status;
  late Set<String> _currentPerms;

  @override
  void initState() {
    super.initState();
    _roleCtrl = TextEditingController(text: widget.user.roleTitle);
    _officeCtrl = TextEditingController(text: widget.user.office);
    _workstationCtrl = TextEditingController(text: widget.user.workstation);
    _accessLevel = widget.user.accessLevel;
    _status = widget.user.status;
    _currentPerms = Set<String>.from(
      ref
              .read(accountManagementProvider)
              .userPermissions[widget.user.handleAndId] ??
          BrmsPermission.defaultsForAccessLevel(widget.user.accessLevel),
    );
  }

  @override
  void dispose() {
    _roleCtrl.dispose();
    _officeCtrl.dispose();
    _workstationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: BrmsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                            'ACCESS CONTROL MATRIX',
                            style: BrmsTheme.mono(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: BrmsColors.secondary,
                            ),
                          ),
                          Text(
                            'Edit Permissions — ${widget.user.fullName}',
                            overflow: TextOverflow.ellipsis,
                            style: BrmsTheme.heading(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DrawerInput(
                        label: 'DESIGNATED ROLE',
                        hint: 'Role title',
                        controller: _roleCtrl,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            BrmsInputLimits.maxNameLength,
                          ),
                        ],
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DrawerInput(
                        label: 'BOUND WORKSTATION',
                        hint: 'Terminal-APA-01',
                        controller: _workstationCtrl,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            BrmsInputLimits.maxWorkstationLength,
                          ),
                        ],
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DrawerInput(
                  label: 'CAMPUS DEPARTMENT / OFFICE',
                  hint: 'Department or unit',
                  controller: _officeCtrl,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      BrmsInputLimits.maxNameLength,
                    ),
                  ],
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DialogDropdownField(
                        label: 'ACCESS LEVEL',
                        value: _accessLevel,
                        items: const [
                          'SUPER ADMIN',
                          'ENCODER / WRITER',
                          'ENCODER',
                          'EXECUTIVE REVIEWER',
                          'READ-ONLY AUDIT',
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _accessLevel = v;
                            _currentPerms =
                                BrmsPermission.defaultsForAccessLevel(v);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DialogDropdownField(
                        label: 'ACCOUNT STATUS',
                        value: _status,
                        items: const ['ACTIVE', 'RESTRICTED', 'READ-ONLY'],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _status = v);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'GRANULAR CAPABILITIES',
                  style: BrmsTheme.mono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: BrmsColors.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                Material(
                  color: BrmsColors.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: BrmsColors.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: BrmsPermission.all.map((perm) {
                      final checked = _currentPerms.contains(perm);
                      return CheckboxListTile(
                        dense: true,
                        value: checked,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: BrmsColors.primary,
                        title: Text(
                          perm,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            if (val ?? false) {
                              _currentPerms.add(perm);
                            } else {
                              _currentPerms.remove(perm);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BrmsButton(
                      label: 'Cancel',
                      primary: false,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    BrmsButton(
                      label: 'Save Permissions',
                      icon: Icons.check,
                      onPressed: () {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        ref
                            .read(accountManagementProvider.notifier)
                            .updateUserPermissions(
                              handleAndId: widget.user.handleAndId,
                              roleTitle: _roleCtrl.text,
                              office: _officeCtrl.text,
                              workstation: _workstationCtrl.text,
                              accessLevel: _accessLevel,
                              status: _status,
                              permissions: _currentPerms,
                            );
                        Navigator.of(context).pop();
                        widget.onSaved();
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
}

class _ResetPinDialog extends ConsumerStatefulWidget {
  const _ResetPinDialog({required this.user, required this.onPinReset});

  final SystemUserRecord user;
  final ValueChanged<String> onPinReset;

  @override
  ConsumerState<_ResetPinDialog> createState() => _ResetPinDialogState();
}

class _ResetPinDialogState extends ConsumerState<_ResetPinDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _pinCtrl;

  @override
  void initState() {
    super.initState();
    _pinCtrl = TextEditingController(text: _generateSixDigitPin());
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  static String _generateSixDigitPin() {
    final rng = Random();
    return List.generate(6, (_) => rng.nextInt(10)).join();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: BrmsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                            'CREDENTIAL RECOVERY',
                            style: BrmsTheme.mono(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: BrmsColors.secondary,
                            ),
                          ),
                          Text(
                            'Reset PIN — ${widget.user.fullName}',
                            overflow: TextOverflow.ellipsis,
                            style: BrmsTheme.heading(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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
                const SizedBox(height: 12),
                Text(
                  'Workstation: ${widget.user.workstation} (${widget.user.handleAndId})',
                  style: BrmsTheme.mono(
                    fontSize: 11,
                    color: BrmsColors.secondary,
                  ),
                ),
                const SizedBox(height: 14),
                _DrawerInput(
                  label: 'TEMPORARY 6-DIGIT PIN',
                  hint: '6-digit PIN',
                  controller: _pinCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Generate Random PIN',
                        icon: const Icon(Icons.refresh, size: 16),
                        onPressed: () => setState(
                          () => _pinCtrl.text = _generateSixDigitPin(),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy PIN',
                        icon: const Icon(Icons.copy, size: 15),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _pinCtrl.text));
                          showBrmsNotice(
                            context,
                            'Temporary PIN copied to clipboard.',
                          );
                        },
                      ),
                    ],
                  ),
                  validator: (v) {
                    if (v == null || v.length != 6) {
                      return 'PIN must be exactly 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BrmsButton(
                      label: 'Cancel',
                      primary: false,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    BrmsButton(
                      label: 'Confirm PIN Reset',
                      icon: Icons.password,
                      onPressed: () {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        final pin = _pinCtrl.text;
                        ref
                            .read(accountManagementProvider.notifier)
                            .resetUserPin(
                              handleAndId: widget.user.handleAndId,
                              newPin: pin,
                            );
                        Navigator.of(context).pop();
                        widget.onPinReset(pin);
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
}
