import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/brms_models.dart';

/// Granular BRMS workstation capabilities and role-based defaults.
class BrmsPermission {
  const BrmsPermission._();

  static const String manageBudget = 'Manage Budget Allocations';
  static const String manageObrs = 'Create / Edit OBRs';
  static const String viewReports = 'View Financial Reports (FAR 2 / 2-A / Central)';
  static const String exportReports = 'Export Official PDF & CSV';
  static const String manageAccounts = 'Manage User Accounts & PINs';
  static const String viewAuditLogs = 'View Audit Access Logs';

  static const List<String> all = [
    manageBudget,
    manageObrs,
    viewReports,
    exportReports,
    manageAccounts,
    viewAuditLogs,
  ];

  static Set<String> defaultsForAccessLevel(String accessLevel) {
    switch (accessLevel) {
      case 'SUPER ADMIN':
        return Set<String>.from(all);
      case 'ENCODER / WRITER':
        return {manageBudget, manageObrs, viewReports, exportReports};
      case 'ENCODER':
        return {manageObrs, viewReports};
      case 'EXECUTIVE REVIEWER':
        return {viewReports, exportReports, viewAuditLogs};
      case 'READ-ONLY AUDIT':
        return {viewReports, viewAuditLogs};
      default:
        return {viewReports};
    }
  }
}

/// Security and access telemetry log entry.
class AuditLogEntry {
  const AuditLogEntry({
    required this.timestamp,
    required this.actor,
    required this.action,
    required this.detail,
    required this.workstation,
  });

  final String timestamp;
  final String actor;
  final String action;
  final String detail;
  final String workstation;
}

/// Immutable state for the Account & Access Management screen.
class AccountManagementState {
  const AccountManagementState({
    required this.users,
    required this.autoLock,
    required this.terminalPin,
    required this.userPermissions,
    required this.auditLogs,
  });

  final List<SystemUserRecord> users;
  final String autoLock;
  final String terminalPin;
  final Map<String, Set<String>> userPermissions;
  final List<AuditLogEntry> auditLogs;

  AccountManagementState copyWith({
    List<SystemUserRecord>? users,
    String? autoLock,
    String? terminalPin,
    Map<String, Set<String>>? userPermissions,
    List<AuditLogEntry>? auditLogs,
  }) {
    return AccountManagementState(
      users: users ?? this.users,
      autoLock: autoLock ?? this.autoLock,
      terminalPin: terminalPin ?? this.terminalPin,
      userPermissions: userPermissions ?? this.userPermissions,
      auditLogs: auditLogs ?? this.auditLogs,
    );
  }
}

class AccountManagementNotifier extends Notifier<AccountManagementState> {
  @override
  AccountManagementState build() {
    final initialUsers = List<SystemUserRecord>.from(BrmsMockData.systemUsers);
    final initialPerms = <String, Set<String>>{
      for (final u in initialUsers)
        u.handleAndId: BrmsPermission.defaultsForAccessLevel(u.accessLevel),
    };
    return AccountManagementState(
      users: initialUsers,
      autoLock: '30 Minutes',
      terminalPin: '123456',
      userPermissions: initialPerms,
      auditLogs: const [
        AuditLogEntry(
          timestamp: '2024-10-25 09:12:04',
          actor: 'Johnyrey Tumanu',
          action: 'SESSION START',
          detail: 'Authenticated to CSU-Aparri Budget Office terminal',
          workstation: 'Terminal-APA-01',
        ),
        AuditLogEntry(
          timestamp: '2024-10-24 16:40:19',
          actor: 'Amanda Perez',
          action: 'OBR RECORDED',
          detail: 'Posted OBR #2024-10-098 under Fund 101',
          workstation: 'Terminal-APA-02',
        ),
        AuditLogEntry(
          timestamp: '2024-10-23 11:05:52',
          actor: 'COA Resident Auditor',
          action: 'AUDIT READ',
          detail: 'Reviewed FAR 1-A quarterly ledger snapshot',
          workstation: 'Terminal-APA-AUDIT',
        ),
      ],
    );
  }

  void setAutoLock(String value) {
    state = state.copyWith(
      autoLock: value,
      auditLogs: [
        AuditLogEntry(
          timestamp: _nowLabel(),
          actor: 'Johnyrey Tumanu',
          action: 'SECURITY POLICY',
          detail: 'Workstation auto-lock updated to $value',
          workstation: 'Terminal-APA-01',
        ),
        ...state.auditLogs,
      ],
    );
  }

  void addUser({
    required String fullName,
    required String employeeId,
    required String username,
    required String office,
    required String roleTitle,
    required String accessLevel,
    required String workstation,
  }) {
    final cleanUser = username.trim().startsWith('@')
        ? username.trim().toLowerCase()
        : '@${username.trim().toLowerCase()}';
    final handleAndId = '$cleanUser • ${employeeId.trim()}';
    final initials = _computeInitials(fullName);
    final newUser = SystemUserRecord(
      initials: initials,
      fullName: fullName.trim(),
      handleAndId: handleAndId,
      roleTitle: roleTitle.trim(),
      office: office.trim(),
      accessLevel: accessLevel,
      isSuperAdmin: accessLevel == 'SUPER ADMIN',
      workstation: workstation.trim(),
      lastActionTime: 'Just now',
      lastActionDetail: 'Account Provisioned',
      status: accessLevel == 'READ-ONLY AUDIT' ? 'READ-ONLY' : 'ACTIVE',
    );

    final nextPerms = Map<String, Set<String>>.from(state.userPermissions);
    nextPerms[handleAndId] = BrmsPermission.defaultsForAccessLevel(accessLevel);

    state = state.copyWith(
      users: [newUser, ...state.users],
      userPermissions: nextPerms,
      auditLogs: [
        AuditLogEntry(
          timestamp: _nowLabel(),
          actor: 'Johnyrey Tumanu',
          action: 'PROVISION ACCOUNT',
          detail: 'Provisioned $fullName ($handleAndId) as $accessLevel',
          workstation: workstation.trim(),
        ),
        ...state.auditLogs,
      ],
    );
  }

  bool changeTerminalPin({
    required String currentPin,
    required String newPin,
  }) {
    if (currentPin != state.terminalPin) return false;
    state = state.copyWith(
      terminalPin: newPin,
      auditLogs: [
        AuditLogEntry(
          timestamp: _nowLabel(),
          actor: 'Johnyrey Tumanu',
          action: 'TERMINAL PIN',
          detail: 'Updated local workstation terminal PIN',
          workstation: 'Terminal-APA-01',
        ),
        ...state.auditLogs,
      ],
    );
    return true;
  }

  void updateUserPermissions({
    required String handleAndId,
    required String roleTitle,
    required String office,
    required String workstation,
    required String accessLevel,
    required String status,
    required Set<String> permissions,
  }) {
    final updatedUsers = state.users.map((u) {
      if (u.handleAndId != handleAndId) return u;
      return SystemUserRecord(
        initials: u.initials,
        fullName: u.fullName,
        handleAndId: u.handleAndId,
        roleTitle: roleTitle.trim(),
        office: office.trim(),
        accessLevel: accessLevel,
        isSuperAdmin: accessLevel == 'SUPER ADMIN',
        workstation: workstation.trim(),
        lastActionTime: 'Just now',
        lastActionDetail: 'Permissions Updated ($status)',
        status: status,
      );
    }).toList();

    final nextPerms = Map<String, Set<String>>.from(state.userPermissions);
    nextPerms[handleAndId] = Set<String>.from(permissions);

    state = state.copyWith(
      users: updatedUsers,
      userPermissions: nextPerms,
      auditLogs: [
        AuditLogEntry(
          timestamp: _nowLabel(),
          actor: 'Johnyrey Tumanu',
          action: 'PERMISSIONS UPDATED',
          detail: 'Updated access matrix for $handleAndId ($accessLevel / $status)',
          workstation: workstation.trim(),
        ),
        ...state.auditLogs,
      ],
    );
  }

  void resetUserPin({
    required String handleAndId,
    required String newPin,
  }) {
    String targetWorkstation = 'Terminal-APA-01';
    final updatedUsers = state.users.map((u) {
      if (u.handleAndId != handleAndId) return u;
      targetWorkstation = u.workstation;
      return SystemUserRecord(
        initials: u.initials,
        fullName: u.fullName,
        handleAndId: u.handleAndId,
        roleTitle: u.roleTitle,
        office: u.office,
        accessLevel: u.accessLevel,
        isSuperAdmin: u.isSuperAdmin,
        workstation: u.workstation,
        lastActionTime: 'Just now',
        lastActionDetail: 'PIN Reset Issued',
        status: u.status,
      );
    }).toList();

    state = state.copyWith(
      users: updatedUsers,
      auditLogs: [
        AuditLogEntry(
          timestamp: _nowLabel(),
          actor: 'Johnyrey Tumanu',
          action: 'PIN RESET',
          detail: 'Issued temporary 6-digit PIN for $handleAndId',
          workstation: targetWorkstation,
        ),
        ...state.auditLogs,
      ],
    );
  }

  String _computeInitials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'US';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _nowLabel() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)} '
        '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }
}

final accountManagementProvider =
    NotifierProvider<AccountManagementNotifier, AccountManagementState>(
  AccountManagementNotifier.new,
);
