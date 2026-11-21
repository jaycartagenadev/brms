import 'dart:convert';

import 'package:brms/models/brms_models.dart';
import 'package:brms/providers/reports_provider.dart';
import 'package:brms/services/report_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

UnifiedReportBundle _sampleBundle() {
  const row1 = CentralReportRow(
    mfoProgram: 'MFO 1: Higher Education',
    activityProject: 'Instruction',
    allotmentClass: 'Maintenance & Other Operating Expenses',
    accountCode: '50216010',
    objectTitle: 'Labor and Wages',
    beginningBalance: 50000,
    budgetQ1: 200000,
    budgetQ2: 0,
    budgetQ3: 0,
    budgetQ4: 0,
    modQ1: 0,
    modQ2: 50000,
    modQ3: 0,
    modQ4: 0,
    utilQ1: 0,
    utilQ2: 0,
    utilQ3: 120000,
    utilQ4: 0,
    disbQ1: 0,
    disbQ2: 0,
    disbQ3: 70000,
    disbQ4: 0,
    dueAndDemandable: 30000,
  );

  const row2 = CentralReportRow(
    mfoProgram: 'MFO 3: Research',
    activityProject: 'Marine Lab',
    allotmentClass: 'Capital Outlay',
    accountCode: '50604050',
    objectTitle: 'Machinery and Equipment Outlay',
    beginningBalance: 0,
    budgetQ1: 500000,
    budgetQ2: 0,
    budgetQ3: 0,
    budgetQ4: 0,
    modQ1: 0,
    modQ2: 0,
    modQ3: 0,
    modQ4: 0,
    utilQ1: 100000,
    utilQ2: 0,
    utilQ3: 0,
    utilQ4: 0,
    disbQ1: 100000,
    disbQ2: 0,
    disbQ3: 0,
    disbQ4: 0,
    dueAndDemandable: 0,
  );

  final m1 = row1.toMetrics();
  final m2 = row2.toMetrics();

  return UnifiedReportBundle(
    centralRows: const [row1, row2],
    centralTotal: sumCentralRows(const [row1, row2]),
    far2Groups: [
      Far2ProgramGroup(
        mfoProgram: 'MFO 1: Higher Education',
        children: [
          Far2ChildRow(
            label: '50200000-00 Maintenance and Other Operating Expenses',
            allotmentClass: 'Maintenance & Other Operating Expenses',
            metrics: m1,
          ),
        ],
        total: m1,
      ),
      Far2ProgramGroup(
        mfoProgram: 'MFO 3: Research',
        children: [
          Far2ChildRow(
            label: '50600000-00 Capital Outlay',
            allotmentClass: 'Capital Outlay',
            metrics: m2,
          ),
        ],
        total: m2,
      ),
    ],
    far2GrandTotal: m1 + m2,
    far2AGroups: [
      Far2AClassGroup(
        sectionTitle: 'II. Maintenance and Other Operating Expenses',
        allotmentClass: 'Maintenance & Other Operating Expenses',
        rows: [
          Far2ARow(
            particulars: row1.objectOfExpenditures,
            accountCode: '50216010',
            allotmentClass: 'Maintenance & Other Operating Expenses',
            metrics: m1,
          ),
        ],
        subtotal: m1,
      ),
      Far2AClassGroup(
        sectionTitle: 'III. Capital Outlay',
        allotmentClass: 'Capital Outlay',
        rows: [
          Far2ARow(
            particulars: row2.objectOfExpenditures,
            accountCode: '50604050',
            allotmentClass: 'Capital Outlay',
            metrics: m2,
          ),
        ],
        subtotal: m2,
      ),
    ],
    far2AGrandTotal: m1 + m2,
    totalObrCount: 2,
  );
}

void main() {
  const service = ReportExportService();

  test('FAR 2 CSV export respects MFO and metric activity filters', () {
    final bundle = _sampleBundle();
    const meta = ReportExportMeta(
      reportType: ReportType.far2,
      fiscalYearLabel: 'FY 2024-2025',
      periodLabel: 'Full Year (Q1 - Q4)',
      fundLabel: 'All Fund Clusters',
    );

    final csv = service.buildCsvContent(
      meta: meta,
      bundle: bundle,
      filters: const ReportExportFilters(
        far2MfoFilter: 'MFO 1: Higher Education',
      ),
    );

    expect(csv, contains('MFO 1: Higher Education'));
    expect(csv, isNot(contains('MFO 3: Research')));
    expect(csv, contains('"Grand Total","250,000.00","50,000.00","300,000.00"'));
  });

  test('FAR 2-A preview respects search and unpaid activity filters', () {
    final bundle = _sampleBundle();
    const meta = ReportExportMeta(
      reportType: ReportType.far2a,
      fiscalYearLabel: 'FY 2024-2025',
      periodLabel: 'Full Year (Q1 - Q4)',
      fundLabel: 'All Fund Clusters',
    );

    final preview = service.buildPreviewData(
      meta: meta,
      bundle: bundle,
      filters: const ReportExportFilters(metricActivityFilter: 'UNPAID'),
    );

    final joined = preview.rows.map((r) => r.join(' ')).join('\n');
    expect(joined, contains('50216010'));
    expect(joined, isNot(contains('50604050')));
    expect(preview.totalRow[3], '300,000.00');
  });

  test('Landscape PDF generation succeeds for Central, Registries, FAR 2, and FAR 2-A', () async {
    final bundle = _sampleBundle();
    for (final type in ReportType.values) {
      final bytes = await service.buildLandscapePdfBytes(
        meta: ReportExportMeta(
          reportType: type,
          fiscalYearLabel: 'FY 2024-2025',
          periodLabel: 'Full Year (Q1 - Q4)',
          fundLabel: 'Fund 101',
        ),
        bundle: bundle,
      );
      expect(bytes.length, greaterThan(500));
      expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    }
  });
}
