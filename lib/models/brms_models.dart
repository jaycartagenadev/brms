/// Navigation modules in the authenticated BRMS desktop shell.
enum BrmsModule {
  dashboard('Dashboard'),
  setBudget('Set Budget'),
  obligations('Obligation Registry'),
  reports('Reports'),
  accounts('Accounts');

  const BrmsModule(this.label);
  final String label;
}

/// Sub-report options under the Reports dropdown.
enum ReportType {
  far2(
    'FAR 2',
    'STATEMENT OF APPROVED BUDGET, UTILIZATIONS, DISBURSEMENTS & BALANCES',
  ),
  far2a(
    'FAR 2 - A',
    'SUMMARY OF APPROVED BUDGET, UTILIZATIONS, DISBURSEMENTS & BALANCES BY OBJECT',
  ),
  registries(
    'Registries',
    'REGISTRY OF ALLOTMENTS, OBLIGATIONS AND BALANCES',
  ),
  central(
    'Central',
    'CENTRAL OFFICE CONSOLIDATED FINANCIAL ACCOUNTABILITY REPORT',
  );

  const ReportType(this.label, this.subtitle);
  final String label;
  final String subtitle;
}

class FundCluster {
  const FundCluster({
    required this.code,
    required this.name,
    required this.tag,
    required this.subtitle,
    required this.allotment,
    required this.obligated,
    required this.unobligated,
    required this.percent,
  });

  final String code;
  final String name;
  final String tag;
  final String subtitle;
  final String allotment;
  final String obligated;
  final String unobligated;
  final double percent;
}

class ExpenseClassItem {
  const ExpenseClassItem({
    required this.code,
    required this.title,
    required this.amount,
    required this.obligatedText,
    required this.rightMeta,
    required this.ratio,
  });

  final String code;
  final String title;
  final String amount;
  final String obligatedText;
  final String rightMeta;
  final double ratio;
}

class DashboardObrRow {
  const DashboardObrRow({
    required this.obrNo,
    required this.dateRecorded,
    required this.fundCode,
    required this.uacsDescription,
    required this.payee,
    required this.particulars,
    required this.amount,
    required this.status,
  });

  final String obrNo;
  final String dateRecorded;
  final String fundCode;
  final String uacsDescription;
  final String payee;
  final String particulars;
  final String amount;
  final String status;
}

class RegistryObrRecord {
  const RegistryObrRecord({
    required this.obrNo,
    required this.date,
    required this.fundCode,
    required this.uacsCode,
    required this.allotmentClass,
    required this.payee,
    required this.particular,
    required this.grossAmount,
    required this.attachmentName,
    required this.attachmentMeta,
    required this.status,
  });

  final String obrNo;
  final String date;
  final String fundCode;
  final String uacsCode;
  final String allotmentClass;
  final String payee;
  final String particular;
  final String grossAmount;
  final String attachmentName;
  final String attachmentMeta;
  final String status;
}

class BudgetAllocationEntry {
  const BudgetAllocationEntry({
    required this.fiscalYear,
    required this.fundCode,
    required this.allocationDate,
    required this.amount,
  });

  final String fiscalYear;
  final String fundCode;
  final String allocationDate;
  final String amount;
}

class Far1ARow {
  const Far1ARow({
    required this.particulars,
    required this.uacsCode,
    required this.category,
    required this.authorized,
    required this.appropAdj,
    required this.adjusted,
    required this.received,
    required this.allotAdj,
    required this.totalAllot,
    required this.obQ1,
    required this.obQ2,
    required this.obQ3,
    required this.obTotal,
    required this.disbQ1,
    required this.disbQ2,
    required this.disbQ3,
    required this.disbTotal,
    required this.unobligated,
    required this.unpaidDue,
  });

  final String particulars;
  final String uacsCode;
  final String category; // 'ps', 'mooe', 'co'
  final String authorized;
  final String appropAdj;
  final String adjusted;
  final String received;
  final String allotAdj;
  final String totalAllot;
  final String obQ1;
  final String obQ2;
  final String obQ3;
  final String obTotal;
  final String disbQ1;
  final String disbQ2;
  final String disbQ3;
  final String disbTotal;
  final String unobligated;
  final String unpaidDue;
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

class CampusUnitUtilization {
  const CampusUnitUtilization({
    required this.unitName,
    required this.spentLabel,
    required this.ratio,
  });

  final String unitName;
  final String spentLabel;
  final double ratio;
}

class BrmsMockData {
  const BrmsMockData._();

  static const List<QuarterlyBurnPoint> quarterlyBurn = [
    QuarterlyBurnPoint(
      quarter: 'Q1 (Jan–Mar)',
      obligatedMillions: 9.42,
      disbursedMillions: 8.95,
      obrCount: 38,
    ),
    QuarterlyBurnPoint(
      quarter: 'Q2 (Apr–Jun)',
      obligatedMillions: 10.85,
      disbursedMillions: 9.88,
      obrCount: 49,
    ),
    QuarterlyBurnPoint(
      quarter: 'Q3 (Jul–Sep)',
      obligatedMillions: 11.58,
      disbursedMillions: 9.66,
      obrCount: 55,
    ),
    QuarterlyBurnPoint(
      quarter: 'Q4 (Target)',
      obligatedMillions: 12.10,
      disbursedMillions: 10.90,
      obrCount: 44,
    ),
  ];

  static const List<CampusUnitUtilization> campusUnits = [
    CampusUnitUtilization(
      unitName: 'College of Fisheries & Marine Science (CFMS)',
      spentLabel: '₱ 9.80M / ₱ 12.50M',
      ratio: 0.784,
    ),
    CampusUnitUtilization(
      unitName: 'College of Information & Computing (CICS)',
      spentLabel: '₱ 6.92M / ₱ 10.00M',
      ratio: 0.692,
    ),
    CampusUnitUtilization(
      unitName: 'Admin, Utilities & Campus Operations',
      spentLabel: '₱ 10.04M / ₱ 15.50M',
      ratio: 0.648,
    ),
    CampusUnitUtilization(
      unitName: 'Research, Extension & Mangrove Grants',
      spentLabel: '₱ 1.47M / ₱ 2.80M',
      ratio: 0.523,
    ),
    CampusUnitUtilization(
      unitName: 'Student Services & Fiduciary (RA 10931)',
      spentLabel: '₱ 3.62M / ₱ 7.45M',
      ratio: 0.486,
    ),
  ];

  static const List<FundCluster> fundClusters = [
    FundCluster(
      code: '101',
      name: 'Fund 101 - Regular Agency Fund',
      tag: 'GAA Direct',
      subtitle: 'General Fund National Budget (PS, MOOE, Faculty Compensation)',
      allotment: '₱ 26,450,000.00',
      obligated: '₱ 18,911,750.00',
      unobligated: '₱ 7,538,250.00',
      percent: 0.715,
    ),
    FundCluster(
      code: '161',
      name: 'Fund 161 - Income Generating Projects (IGP)',
      tag: 'Revolving',
      subtitle: 'Fish Hatchery, Brackish Aqua-demo Farm, Dormitory Operations',
      allotment: '₱ 7,800,000.00',
      obligated: '₱ 4,524,000.00',
      unobligated: '₱ 3,276,000.00',
      percent: 0.580,
    ),
    FundCluster(
      code: '164',
      name: 'Fund 164 - Special Trust / Tuition Fees',
      tag: 'Fiduciary',
      subtitle: 'RA 10931 Free Higher Ed Subsidy, Lab Fees & Campus Dev',
      allotment: '₱ 11,200,000.00',
      obligated: '₱ 6,944,000.00',
      unobligated: '₱ 4,256,000.00',
      percent: 0.620,
    ),
    FundCluster(
      code: '184',
      name: 'Fund 184 - Research & Mangrove Conservation',
      tag: 'DOST-PCAARRD',
      subtitle: 'Aparri Mangrove Ecosystem & Marine Sanctuary Research Projects',
      allotment: '₱ 2,800,000.00',
      obligated: '₱ 1,465,460.50',
      unobligated: '₱ 1,334,539.50',
      percent: 0.523,
    ),
  ];

  static const List<ExpenseClassItem> expenseClasses = [
    ExpenseClassItem(
      code: 'PS',
      title: 'Personnel Services',
      amount: '₱ 25,090,000.00',
      obligatedText: 'Obligated: ₱ 17,563,000.00 (70.0%)',
      rightMeta: 'Ceiling: 55.0% Max Cap',
      ratio: 0.70,
    ),
    ExpenseClassItem(
      code: 'MOOE',
      title: 'Maintenance & Other Operating Exp.',
      amount: '₱ 15,922,500.00',
      obligatedText: 'Obligated: ₱ 10,827,300.00 (68.0%)',
      rightMeta: 'Available: ₱ 5,095,200.00',
      ratio: 0.68,
    ),
    ExpenseClassItem(
      code: 'CO',
      title: 'Capital Outlays (Equipment & Bldgs)',
      amount: '₱ 7,237,500.00',
      obligatedText: 'Obligated: ₱ 3,454,910.50 (47.7%)',
      rightMeta: 'Fishery Lab Facilities Grant',
      ratio: 0.477,
    ),
  ];

  static const List<DashboardObrRow> dashboardObrRows = [
    DashboardObrRow(
      obrNo: 'OBR-2024-09-0142',
      dateRecorded: '2024-09-24',
      fundCode: '101',
      uacsDescription: '[ 5-02-03-010 ] Office Supplies',
      payee: 'Aparri Commercial Printing Corp.',
      particulars: 'Midterm Examination Questionnaires - CFMS',
      amount: '₱ 145,800.00',
      status: 'FULLY OBLIGATED',
    ),
    DashboardObrRow(
      obrNo: 'OBR-2024-09-0141',
      dateRecorded: '2024-09-22',
      fundCode: '161',
      uacsDescription: '[ 5-02-13-050 ] Aquafeed & Fingerlings',
      payee: 'Northern Agri-Ventures Inc.',
      particulars: 'Feeds for Aqua-Demo Pond Cycle 4',
      amount: '₱ 380,450.00',
      status: 'FULLY OBLIGATED',
    ),
    DashboardObrRow(
      obrNo: 'OBR-2024-09-0140',
      dateRecorded: '2024-09-20',
      fundCode: '184',
      uacsDescription: '[ 5-02-01-010 ] Field Traveling Expenses',
      payee: 'Dr. Maricel G. Batang, et al.',
      particulars: 'Babuyan Channel Marine Salinity Survey',
      amount: '₱ 62,500.00',
      status: 'LIQUIDATED',
    ),
    DashboardObrRow(
      obrNo: 'OBR-2024-09-0139',
      dateRecorded: '2024-09-18',
      fundCode: '164',
      uacsDescription: '[ 1-07-05-020 ] IT Equipment Outlay',
      payee: 'Infotech Solutions Tuguegarao',
      particulars: '15 Client Terminals for Main CompLab',
      amount: '₱ 720,000.00',
      status: 'PROCESSING DV',
    ),
    DashboardObrRow(
      obrNo: 'OBR-2024-09-0138',
      dateRecorded: '2024-09-15',
      fundCode: '101',
      uacsDescription: '[ 5-02-04-010 ] Electricity Expenses',
      payee: 'CAGELCO II (Cagayan Electric Coop)',
      particulars: 'Campus Electricity Consumption Billing - Aug 2024',
      amount: '₱ 412,620.15',
      status: 'LIQUIDATED',
    ),
  ];

  static const List<RegistryObrRecord> registryObrs = [
    RegistryObrRecord(
      obrNo: '159',
      date: '01-21-2025',
      fundCode: '101',
      uacsCode: '50211990',
      allotmentClass: 'Maintenance & Other Operating Expenses',
      payee: 'Juan Dela Cruz',
      particular: 'Salary June 1- 30, 2024',
      grossAmount: 'Php 20,418.97',
      attachmentName: 'budget attachment.pdf',
      attachmentMeta: '281.1 kb • Verified Copy',
      status: 'Committed',
    ),
    RegistryObrRecord(
      obrNo: '158',
      date: '12-18-2024',
      fundCode: '101',
      uacsCode: '50205020',
      allotmentClass: 'Maintenance & Other Operating Expenses',
      payee: 'Jane Doe',
      particular: 'Communication Services',
      grossAmount: 'Php 30,400.00',
      attachmentName: 'comm_voucher_158.pdf',
      attachmentMeta: '412.4 kb • Verified Copy',
      status: 'Committed',
    ),
    RegistryObrRecord(
      obrNo: '157',
      date: '09-27-2024',
      fundCode: '101',
      uacsCode: '50101010',
      allotmentClass: 'Personnel Services',
      payee: 'Pedro Penduko',
      particular: 'Salary for Regular Staff',
      grossAmount: 'Php 211,425.44',
      attachmentName: 'payroll_obr_157.pdf',
      attachmentMeta: '1.15 MB • Verified Copy',
      status: 'Committed',
    ),
  ];

  static const List<BudgetAllocationEntry> budgetAllocations = [
    BudgetAllocationEntry(
      fiscalYear: '2024-2025',
      fundCode: '101',
      allocationDate: 'January 3, 2024',
      amount: '15,500,000',
    ),
    BudgetAllocationEntry(
      fiscalYear: '2023-2024',
      fundCode: '161',
      allocationDate: 'December 10, 2022',
      amount: '14,000,000',
    ),
    BudgetAllocationEntry(
      fiscalYear: '2022-2023',
      fundCode: '184',
      allocationDate: 'December 2, 2022',
      amount: '14,500,000',
    ),
  ];

  static const List<Far1ARow> far1ARows = [
    Far1ARow(
      particulars: 'Salaries and Wages - Regular',
      uacsCode: '5-01-01-010-01',
      category: 'ps',
      authorized: '32,500,000.00',
      appropAdj: '-',
      adjusted: '32,500,000.00',
      received: '32,500,000.00',
      allotAdj: '-',
      totalAllot: '32,500,000.00',
      obQ1: '8,125,000.00',
      obQ2: '8,125,000.00',
      obQ3: '8,125,000.00',
      obTotal: '24,375,000.00',
      disbQ1: '8,125,000.00',
      disbQ2: '8,125,000.00',
      disbQ3: '8,125,000.00',
      disbTotal: '24,375,000.00',
      unobligated: '8,125,000.00',
      unpaidDue: '0.00',
    ),
    Far1ARow(
      particulars: 'Personnel Economic Relief Allowance (PERA)',
      uacsCode: '5-01-02-010-01',
      category: 'ps',
      authorized: '2,880,000.00',
      appropAdj: '-',
      adjusted: '2,880,000.00',
      received: '2,880,000.00',
      allotAdj: '-',
      totalAllot: '2,880,000.00',
      obQ1: '720,000.00',
      obQ2: '720,000.00',
      obQ3: '720,000.00',
      obTotal: '2,160,000.00',
      disbQ1: '720,000.00',
      disbQ2: '720,000.00',
      disbQ3: '720,000.00',
      disbTotal: '2,160,000.00',
      unobligated: '720,000.00',
      unpaidDue: '0.00',
    ),
    Far1ARow(
      particulars: 'Representation & Transportation Allowance',
      uacsCode: '5-01-02-020-00',
      category: 'ps',
      authorized: '960,000.00',
      appropAdj: '-',
      adjusted: '960,000.00',
      received: '960,000.00',
      allotAdj: '-',
      totalAllot: '960,000.00',
      obQ1: '240,000.00',
      obQ2: '240,000.00',
      obQ3: '240,000.00',
      obTotal: '720,000.00',
      disbQ1: '240,000.00',
      disbQ2: '240,000.00',
      disbQ3: '240,000.00',
      disbTotal: '720,000.00',
      unobligated: '240,000.00',
      unpaidDue: '0.00',
    ),
    Far1ARow(
      particulars: 'Traveling Expenses - Local',
      uacsCode: '5-02-01-010-00',
      category: 'mooe',
      authorized: '1,850,000.00',
      appropAdj: '-',
      adjusted: '1,850,000.00',
      received: '1,850,000.00',
      allotAdj: '-',
      totalAllot: '1,850,000.00',
      obQ1: '420,500.00',
      obQ2: '510,200.00',
      obQ3: '485,000.00',
      obTotal: '1,415,700.00',
      disbQ1: '410,000.00',
      disbQ2: '498,200.00',
      disbQ3: '430,000.00',
      disbTotal: '1,338,200.00',
      unobligated: '434,300.00',
      unpaidDue: '77,500.00',
    ),
    Far1ARow(
      particulars: 'Office Supplies & Instructional Materials',
      uacsCode: '5-02-03-010-02',
      category: 'mooe',
      authorized: '4,200,000.00',
      appropAdj: '150,000.00',
      adjusted: '4,350,000.00',
      received: '4,350,000.00',
      allotAdj: '-',
      totalAllot: '4,350,000.00',
      obQ1: '980,000.00',
      obQ2: '1,120,400.00',
      obQ3: '1,045,800.00',
      obTotal: '3,146,200.00',
      disbQ1: '980,000.00',
      disbQ2: '1,100,000.00',
      disbQ3: '890,000.00',
      disbTotal: '2,970,000.00',
      unobligated: '1,203,800.00',
      unpaidDue: '176,200.00',
    ),
    Far1ARow(
      particulars: 'Electricity & Water Utilities Expenses',
      uacsCode: '5-02-04-020-00',
      category: 'mooe',
      authorized: '6,800,000.00',
      appropAdj: '-',
      adjusted: '6,800,000.00',
      received: '6,800,000.00',
      allotAdj: '-',
      totalAllot: '6,800,000.00',
      obQ1: '1,610,200.00',
      obQ2: '1,740,500.00',
      obQ3: '1,692,410.50',
      obTotal: '5,043,110.50',
      disbQ1: '1,610,200.00',
      disbQ2: '1,740,500.00',
      disbQ3: '1,280,000.00',
      disbTotal: '4,630,700.00',
      unobligated: '1,756,889.50',
      unpaidDue: '412,410.50',
    ),
    Far1ARow(
      particulars: 'Technical & Scientific Equipment (Marine Lab)',
      uacsCode: '1-07-05-140-00',
      category: 'co',
      authorized: '12,500,000.00',
      appropAdj: '-',
      adjusted: '12,500,000.00',
      received: '12,500,000.00',
      allotAdj: '-',
      totalAllot: '12,500,000.00',
      obQ1: '1,200,000.00',
      obQ2: '4,850,000.00',
      obQ3: '2,950,000.00',
      obTotal: '9,000,000.00',
      disbQ1: '1,200,000.00',
      disbQ2: '4,850,000.00',
      disbQ3: '1,500,000.00',
      disbTotal: '7,550,000.00',
      unobligated: '3,500,000.00',
      unpaidDue: '1,450,000.00',
    ),
    Far1ARow(
      particulars: 'ICT Equipment & Campus Network Infrastructure',
      uacsCode: '1-07-05-030-00',
      category: 'co',
      authorized: '5,400,000.00',
      appropAdj: '-',
      adjusted: '5,400,000.00',
      received: '5,400,000.00',
      allotAdj: '-',
      totalAllot: '5,400,000.00',
      obQ1: '850,000.00',
      obQ2: '1,920,000.00',
      obQ3: '1,120,000.00',
      obTotal: '3,890,000.00',
      disbQ1: '850,000.00',
      disbQ2: '1,920,000.00',
      disbQ3: '400,000.00',
      disbTotal: '3,170,000.00',
      unobligated: '1,510,000.00',
      unpaidDue: '720,000.00',
    ),
  ];

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
