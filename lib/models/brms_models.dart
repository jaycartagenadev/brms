/// Navigation modules in the authenticated BRMS desktop/web shell.
enum BrmsModule {
  dashboard('Dashboard', '/dashboard'),
  setBudget('Set Budget', '/budget'),
  obligations('Obligation Registry', '/obligations'),
  reports('Reports', '/reports/far2'),
  accounts('Accounts', '/accounts');

  const BrmsModule(this.label, this.routePath);
  final String label;
  final String routePath;
}

/// Sub-report options under the Reports dropdown.
enum ReportType {
  far2(
    'FAR 2',
    'STATEMENT OF APPROVED BUDGET, UTILIZATIONS, DISBURSEMENTS & BALANCES',
    'far2',
  ),
  far2a(
    'FAR 2 - A',
    'SUMMARY OF APPROVED BUDGET, UTILIZATIONS, DISBURSEMENTS & BALANCES BY OBJECT',
    'far2a',
  ),
  registries(
    'Registries',
    'REGISTRY OF ALLOTMENTS, OBLIGATIONS AND BALANCES',
    'registries',
  ),
  central(
    'Central',
    'CENTRAL OFFICE CONSOLIDATED FINANCIAL ACCOUNTABILITY REPORT',
    'central',
  );

  const ReportType(this.label, this.subtitle, this.slug);
  final String label;
  final String subtitle;
  final String slug;

  String get routePath => '/reports/$slug';

  static ReportType fromSlug(String? slug) {
    return ReportType.values.firstWhere(
      (r) => r.slug == slug,
      orElse: () => ReportType.far2,
    );
  }
}

class SystemUserRecord {
  const SystemUserRecord({
    required this.initials,
    required this.fullName,
    required this.handleAndId,
    required this.roleTitle,
    required this.office,
    required this.accessLevel,
    required this.isSuperAdmin,
    required this.workstation,
    required this.lastActionTime,
    required this.lastActionDetail,
    required this.status,
  });

  final String initials;
  final String fullName;
  final String handleAndId;
  final String roleTitle;
  final String office;
  final String accessLevel;
  final bool isSuperAdmin;
  final String workstation;
  final String lastActionTime;
  final String lastActionDetail;
  final String status; // 'ACTIVE', 'RESTRICTED', 'READ-ONLY'
}

class QuarterlyBurnPoint {
  const QuarterlyBurnPoint({
    required this.quarter,
    required this.obligatedMillions,
    required this.disbursedMillions,
    required this.obrCount,
  });

  final String quarter;
  final double obligatedMillions;
  final double disbursedMillions;
  final int obrCount;
}

class BrmsMockData {
  const BrmsMockData._();

  static const List<SystemUserRecord> systemUsers = [
    SystemUserRecord(
      initials: 'JT',
      fullName: 'Johnyrey Tumanu',
      handleAndId: '@jtumanu • ID-2018-0044',
      roleTitle: 'Campus Budget Officer',
      office: 'Office of the Budget Officer',
      accessLevel: 'SUPER ADMIN',
      isSuperAdmin: true,
      workstation: 'Terminal-APA-01',
      lastActionTime: 'Active Now',
      lastActionDetail: 'FAR 1-A Allocation Run',
      status: 'ACTIVE',
    ),
    SystemUserRecord(
      initials: 'AP',
      fullName: 'Amanda Perez',
      handleAndId: '@amanda.p • ID-2020-0192',
      roleTitle: 'Accounting Clerk',
      office: 'Accounting & Disbursement Unit',
      accessLevel: 'ENCODER / WRITER',
      isSuperAdmin: false,
      workstation: 'Terminal-APA-02',
      lastActionTime: '42 min ago',
      lastActionDetail: 'OBR Entry #2024-10-098',
      status: 'ACTIVE',
    ),
    SystemUserRecord(
      initials: 'GG',
      fullName: 'Goodness Gracious',
      handleAndId: '@ggracious • ID-2021-0310',
      roleTitle: 'Budget Analyst Assistant',
      office: 'Office of the Budget Officer',
      accessLevel: 'ENCODER',
      isSuperAdmin: false,
      workstation: 'Terminal-APA-04',
      lastActionTime: 'Yesterday, 4:45 PM',
      lastActionDetail: 'Registry Reconciliation',
      status: 'ACTIVE',
    ),
    SystemUserRecord(
      initials: 'SR',
      fullName: 'Simeon R. Rabanal Jr.',
      handleAndId: '@s.rabanal • ID-2012-0003',
      roleTitle: 'Campus Executive Officer',
      office: 'Office of the Campus Executive',
      accessLevel: 'EXECUTIVE REVIEWER',
      isSuperAdmin: false,
      workstation: 'Terminal-APA-EXEC',
      lastActionTime: 'Oct 24, 2024',
      lastActionDetail: 'Quarterly Summary Clearance',
      status: 'ACTIVE',
    ),
    SystemUserRecord(
      initials: 'MS',
      fullName: 'Maria Santos',
      handleAndId: '@msantos • ID-2022-0451',
      roleTitle: 'Accounting Clerk',
      office: 'Accounting & Disbursement Unit',
      accessLevel: 'ENCODER',
      isSuperAdmin: false,
      workstation: 'Terminal-APA-03',
      lastActionTime: 'Oct 12, 2024',
      lastActionDetail: 'Station Rotated',
      status: 'RESTRICTED',
    ),
    SystemUserRecord(
      initials: 'CA',
      fullName: 'COA Resident Auditor',
      handleAndId: '@coa.aparri • EXT-AUDIT-01',
      roleTitle: 'State Auditor IV',
      office: 'Commission on Audit (COA) Station',
      accessLevel: 'READ-ONLY AUDIT',
      isSuperAdmin: false,
      workstation: 'Terminal-APA-AUDIT',
      lastActionTime: '3 days ago',
      lastActionDetail: 'FAR 1-A Inspection Read',
      status: 'READ-ONLY',
    ),
  ];
}
