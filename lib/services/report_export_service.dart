import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/brms_models.dart';
import '../providers/reports_provider.dart';
import '../utils/brms_formatters.dart';
import 'file_ops.dart';

/// Metadata displayed in official CSU-Aparri export headers.
class ReportExportMeta {
  const ReportExportMeta({
    required this.reportType,
    required this.fiscalYearLabel,
    required this.periodLabel,
    required this.fundLabel,
    this.classFilterLabel,
  });

  final ReportType reportType;
  final String fiscalYearLabel;
  final String periodLabel;
  final String fundLabel;
  final String? classFilterLabel;
}

/// Active on-screen filters forwarded from [ReportsScreen] so exports match
/// what the user sees on screen.
class ReportExportFilters {
  const ReportExportFilters({
    this.searchQuery = '',
    this.far2MfoFilter = 'ALL',
    this.far2ClassFilter = 'ALL',
    this.far2aClassFilter = 'ALL',
    this.metricActivityFilter = 'ALL',
  });

  final String searchQuery;
  final String far2MfoFilter;
  final String far2ClassFilter;
  final String far2aClassFilter;
  final String metricActivityFilter;

  bool matchesMetricActivity(ReportMetrics m) {
    switch (metricActivityFilter) {
      case 'BUDGET':
        return m.adjustedBudget != 0.0 || m.approvedBudget != 0.0;
      case 'UTILIZED':
        return m.totalUtilizations != 0.0;
      case 'UNPAID':
        return m.totalUnpaidUtilization != 0.0;
      default:
        return true;
    }
  }
}

/// Generates official CSV (Excel-compatible) and landscape PDF exports for
/// FAR 2, FAR 2-A, Registries, and Central reports.
class ReportExportService {
  const ReportExportService();

  static const String _department = 'SUCs';
  static const String _agency = 'CAGAYAN STATE UNIVERSITY - APARRI CAMPUS';
  static const String _orgCode = '08 022 0000000';

  /// Builds tabular preview data for the active report without writing a file.
  TabularReportData buildPreviewData({
    required ReportExportMeta meta,
    required UnifiedReportBundle bundle,
    List<CentralReportRow>? filteredCentralRows,
    ReportExportFilters filters = const ReportExportFilters(),
  }) {
    return _buildTabularData(
      meta: meta,
      bundle: bundle,
      filteredCentralRows: filteredCentralRows,
      filters: filters,
    );
  }

  /// Builds CSV text (without BOM) for testing and export.
  String buildCsvContent({
    required ReportExportMeta meta,
    required UnifiedReportBundle bundle,
    List<CentralReportRow>? filteredCentralRows,
    ReportExportFilters filters = const ReportExportFilters(),
    TabularReportData? overrideTable,
  }) {
    final table = overrideTable ??
        _buildTabularData(
          meta: meta,
          bundle: bundle,
          filteredCentralRows: filteredCentralRows,
          filters: filters,
        );

    final buffer = StringBuffer();
    buffer.writeln(_csvRow(['DEPARTMENT', _department]));
    buffer.writeln(_csvRow(['AGENCY', _agency]));
    buffer.writeln(_csvRow(['ORGANIZATIONAL CODE', _orgCode]));
    buffer.writeln(
      _csvRow(['REPORT', '${meta.reportType.label} - ${meta.reportType.subtitle}']),
    );
    buffer.writeln(_csvRow(['FISCAL YEAR', meta.fiscalYearLabel]));
    buffer.writeln(_csvRow(['REPORTING PERIOD', meta.periodLabel]));
    buffer.writeln(_csvRow(['FUND CLUSTER', meta.fundLabel]));
    if (meta.classFilterLabel != null) {
      buffer.writeln(_csvRow(['ALLOTMENT FILTER', meta.classFilterLabel!]));
    }
    buffer.writeln();

    if (table.superHeaderRow != null) {
      buffer.writeln(_csvRow(table.superHeaderRow!));
    }
    buffer.writeln(_csvRow(table.headers));
    for (final row in table.rows) {
      buffer.writeln(_csvRow(row));
    }
    buffer.writeln(_csvRow(table.totalRow));
    return buffer.toString();
  }

  /// Exports arbitrary tabular rows as an Excel-compatible UTF-8 CSV file.
  Future<String?> exportGenericCsv({
    required String dialogTitle,
    required String fileName,
    required List<String> headers,
    required List<List<String>> rows,
    List<List<String>>? metadataRows,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln(_csvRow(['DEPARTMENT', _department]));
    buffer.writeln(_csvRow(['AGENCY', _agency]));
    buffer.writeln(_csvRow(['ORGANIZATIONAL CODE', _orgCode]));
    if (metadataRows != null) {
      for (final row in metadataRows) {
        buffer.writeln(_csvRow(row));
      }
    }
    buffer.writeln();
    buffer.writeln(_csvRow(headers));
    for (final row in rows) {
      buffer.writeln(_csvRow(row));
    }

    final bytes = Uint8List.fromList([
      0xEF,
      0xBB,
      0xBF,
      ...utf8.encode(buffer.toString()),
    ]);

    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'text/csv',
      dialogTitle: dialogTitle,
    );
    if (uri == null) return null;

    return openExportedFileIfLocal(uri, 'Exported CSV');
  }

  /// Exports the active report as an Excel-compatible UTF-8 CSV file.
  Future<String?> exportCsv({
    required ReportExportMeta meta,
    required UnifiedReportBundle bundle,
    List<CentralReportRow>? filteredCentralRows,
    ReportExportFilters filters = const ReportExportFilters(),
    TabularReportData? overrideTable,
  }) async {
    final csv = buildCsvContent(
      meta: meta,
      bundle: bundle,
      filteredCentralRows: filteredCentralRows,
      filters: filters,
      overrideTable: overrideTable,
    );

    // UTF-8 BOM so Microsoft Excel opens numeric & peso text cleanly.
    final bytes = Uint8List.fromList([
      0xEF,
      0xBB,
      0xBF,
      ...utf8.encode(csv),
    ]);

    final fileName = _defaultFileName(meta.reportType, 'csv');
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'text/csv',
      dialogTitle: 'Export ${meta.reportType.label} CSV',
    );
    if (uri == null) return null;

    return openExportedFileIfLocal(uri, 'Exported ${meta.reportType.label} CSV');
  }

  /// Builds PDF document bytes without writing to disk (useful for tests).
  Future<Uint8List> buildLandscapePdfBytes({
    required ReportExportMeta meta,
    required UnifiedReportBundle bundle,
    List<CentralReportRow>? filteredCentralRows,
    ReportExportFilters filters = const ReportExportFilters(),
    TabularReportData? overrideTable,
  }) async {
    final table = overrideTable ??
        _buildTabularData(
          meta: meta,
          bundle: bundle,
          filteredCentralRows: filteredCentralRows,
          filters: filters,
        );

    final doc = pw.Document(
      title: '${meta.reportType.label} - $_agency',
      author: _agency,
    );

    final allRows = <List<String>>[...table.rows, table.totalRow];

    // Wide matrices (Central 30 cols, Registries 22 cols) are split into
    // readable column-group sections repeating the 4 classification columns,
    // so text stays at a crisp 6.5pt instead of shrinking to ~4.6pt.
    if (overrideTable == null &&
        (meta.reportType == ReportType.central ||
            meta.reportType == ReportType.registries)) {
      final sections = meta.reportType == ReportType.central
          ? const [
              (
                title: 'PART 1 OF 3 - BUDGET & ADJUSTED BUDGET',
                metricStart: 4,
                metricEnd: 16,
              ),
              (
                title: 'PART 2 OF 3 - QUARTERLY UTILIZATIONS & DISBURSEMENTS',
                metricStart: 16,
                metricEnd: 26,
              ),
              (
                title: 'PART 3 OF 3 - BALANCES & UNPAID UTILIZATIONS',
                metricStart: 26,
                metricEnd: 30,
              ),
            ]
          : const [
              (
                title: 'PART 1 OF 2 - BUDGET, MODIFICATIONS & UTILIZATIONS',
                metricStart: 4,
                metricEnd: 13,
              ),
              (
                title: 'PART 2 OF 2 - DISBURSEMENTS & BALANCES',
                metricStart: 13,
                metricEnd: 22,
              ),
            ];

      for (final sec in sections) {
        final colIndices = [
          0,
          1,
          2,
          3,
          for (int i = sec.metricStart; i < sec.metricEnd; i++) i,
        ];
        final secHeaders = colIndices.map((i) => table.headers[i]).toList();
        final secRows = allRows
            .map((r) => colIndices.map((i) => i < r.length ? r[i] : '').toList())
            .toList();

        doc.addPage(
          _buildPdfMultiPage(
            meta: meta,
            sectionBanner: sec.title,
            headers: secHeaders,
            rows: secRows,
            labelColumnCount: 4,
            fontSize: 6.5,
          ),
        );
      }
    } else {
      doc.addPage(
        _buildPdfMultiPage(
          meta: meta,
          sectionBanner: table.superHeaderLabels,
          headers: table.headers,
          rows: allRows,
          labelColumnCount: table.labelColumnCount,
          fontSize: 7.2,
        ),
      );
    }

    return Uint8List.fromList(await doc.save());
  }

  pw.MultiPage _buildPdfMultiPage({
    required ReportExportMeta meta,
    required String? sectionBanner,
    required List<String> headers,
    required List<List<String>> rows,
    required int labelColumnCount,
    required double fontSize,
  }) {
    return pw.MultiPage(
      pageFormat: PdfPageFormat.legal.landscape,
      margin: const pw.EdgeInsets.all(18),
      header: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '$_agency - BRMS',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '${meta.reportType.label}: ${meta.reportType.subtitle}',
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'DEPARTMENT: $_department  |  ORG CODE: $_orgCode',
                    style: const pw.TextStyle(fontSize: 7.5),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'FY: ${meta.fiscalYearLabel}  |  ${meta.periodLabel}  |  ${meta.fundLabel}',
                    style: const pw.TextStyle(fontSize: 7.5),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Divider(thickness: 0.8),
          pw.SizedBox(height: 4),
        ],
      ),
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by CSU-Aparri Budget Resource Monitoring System (BRMS)',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
          ),
        ],
      ),
      build: (ctx) => [
        if (sectionBanner != null) ...[
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            color: PdfColors.grey200,
            child: pw.Text(
              sectionBanner,
              style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 3),
        ],
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: rows,
          headerStyle: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.blueGrey900,
          ),
          cellStyle: pw.TextStyle(fontSize: fontSize),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 3.5,
            vertical: 3.5,
          ),
          border: pw.TableBorder.all(
            color: PdfColors.grey400,
            width: 0.4,
          ),
          cellAlignments: {
            for (int c = 0; c < headers.length; c++)
              c: c < labelColumnCount
                  ? pw.Alignment.centerLeft
                  : pw.Alignment.centerRight,
          },
          oddRowDecoration: const pw.BoxDecoration(
            color: PdfColors.grey100,
          ),
        ),
      ],
    );
  }

  /// Exports the active report as a landscape PDF with CSU-Aparri headers.
  Future<String?> exportLandscapePdf({
    required ReportExportMeta meta,
    required UnifiedReportBundle bundle,
    List<CentralReportRow>? filteredCentralRows,
    ReportExportFilters filters = const ReportExportFilters(),
    TabularReportData? overrideTable,
  }) async {
    final pdfBytes = await buildLandscapePdfBytes(
      meta: meta,
      bundle: bundle,
      filteredCentralRows: filteredCentralRows,
      filters: filters,
      overrideTable: overrideTable,
    );
    final fileName = _defaultFileName(meta.reportType, 'pdf');
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: pdfBytes,
      mimeType: 'application/pdf',
      dialogTitle: 'Save Official ${meta.reportType.label} Landscape PDF',
    );
    if (uri == null) return null;

    return openExportedFileIfLocal(uri, 'Saved ${meta.reportType.label} PDF');
  }

  String _defaultFileName(ReportType type, String ext) {
    final slug = type.name.toLowerCase();
    final date = BrmsFormatters.toIsoDate(DateTime.now());
    return 'csu_aparri_${slug}_$date.$ext';
  }

  String _csvRow(List<String> cells) {
    return cells.map((cell) {
      final escaped = cell.replaceAll('"', '""');
      return '"$escaped"';
    }).join(',');
  }

  TabularReportData _buildTabularData({
    required ReportExportMeta meta,
    required UnifiedReportBundle bundle,
    List<CentralReportRow>? filteredCentralRows,
    required ReportExportFilters filters,
  }) {
    String fmt(double v) => BrmsFormatters.formatNumber(v);
    final q = filters.searchQuery.trim().toLowerCase();

    List<String> metricCells(ReportMetrics m) => [
          fmt(m.approvedBudget),
          fmt(m.totalModification),
          fmt(m.adjustedBudget),
          fmt(m.totalUtilizations),
          fmt(m.totalDisbursement),
          fmt(m.unutilizedBudget),
          fmt(m.dueAndDemandable),
          fmt(m.nyddo),
          fmt(m.totalUnpaidUtilization),
        ];

    switch (meta.reportType) {
      case ReportType.central:
        final rows = filteredCentralRows ?? bundle.centralRows;
        final total = sumCentralRows(rows);
        List<String> rowCells(CentralReportRow r) => [
              r.mfoProgram,
              r.activityProject,
              r.allotmentClass,
              r.objectOfExpenditures,
              fmt(r.beginningBalance),
              fmt(r.budgetQ1),
              fmt(r.budgetQ2),
              fmt(r.budgetQ3),
              fmt(r.budgetQ4),
              fmt(r.approvedBudget),
              fmt(r.modQ1),
              fmt(r.modQ2),
              fmt(r.modQ3),
              fmt(r.modQ4),
              fmt(r.totalModification),
              fmt(r.adjustedBudget),
              fmt(r.utilQ1),
              fmt(r.utilQ2),
              fmt(r.utilQ3),
              fmt(r.utilQ4),
              fmt(r.totalUtilization),
              fmt(r.disbQ1),
              fmt(r.disbQ2),
              fmt(r.disbQ3),
              fmt(r.disbQ4),
              fmt(r.totalDisbursement),
              fmt(r.unutilizedBudget),
              fmt(r.dueAndDemandable),
              fmt(r.nyddo),
              fmt(r.totalUnpaidUtilization),
            ];
        return TabularReportData(
          labelColumnCount: 4,
          superHeaderLabels:
              'CLASSIFICATION (Cols 1-4)  |  BUDGET (Cols 5-10)  |  ADJUSTED BUDGET (Cols 11-16)  |  UTILIZATIONS (Cols 17-21)  |  DISBURSEMENT (Cols 22-26)  |  BALANCE (Cols 27-30)',
          superHeaderRow: const [
            'CLASSIFICATION',
            '',
            '',
            '',
            'BUDGET',
            '',
            '',
            '',
            '',
            '',
            'ADJUSTED BUDGET',
            '',
            '',
            '',
            '',
            '',
            'UTILIZATIONS',
            '',
            '',
            '',
            '',
            'DISBURSEMENT',
            '',
            '',
            '',
            '',
            'BALANCE',
            '',
            '',
            '',
          ],
          headers: const [
            'PROGRAMS',
            'ACTIVITIES/PROJECTS',
            'ALLOTMENT CLASS',
            'OBJECT OF EXPENDITURES',
            'BEGINNING BALANCE',
            'BUDGET Q1',
            'BUDGET Q2',
            'BUDGET Q3',
            'BUDGET Q4',
            'APPROVED BUDGET',
            'MOD Q1',
            'MOD Q2',
            'MOD Q3',
            'MOD Q4',
            'TOTAL MODIFICATION',
            'ADJUSTED BUDGET',
            'UTIL Q1',
            'UTIL Q2',
            'UTIL Q3',
            'UTIL Q4',
            'TOTAL UTILIZATION',
            'DISB Q1',
            'DISB Q2',
            'DISB Q3',
            'DISB Q4',
            'TOTAL DISBURSEMENT',
            'UNUTILIZED BUDGET',
            'DUE AND DEMANDABLE',
            'NYDDO',
            'TOTAL UNPAID UTILIZATION',
          ],
          rows: rows.map(rowCells).toList(),
          totalRow: rowCells(total),
        );

      case ReportType.registries:
        final rows = filteredCentralRows ?? bundle.centralRows;
        final total = sumCentralRows(rows);
        List<String> regCells(CentralReportRow r) => [
              r.mfoProgram,
              r.activityProject,
              r.allotmentClass,
              r.objectOfExpenditures,
              fmt(r.beginningBalance),
              fmt(r.currentYearBudget),
              fmt(r.totalModification),
              fmt(r.adjustedBudget),
              fmt(r.utilQ1),
              fmt(r.utilQ2),
              fmt(r.utilQ3),
              fmt(r.utilQ4),
              fmt(r.totalUtilization),
              fmt(r.disbQ1),
              fmt(r.disbQ2),
              fmt(r.disbQ3),
              fmt(r.disbQ4),
              fmt(r.totalDisbursement),
              fmt(r.unutilizedBudget),
              fmt(r.dueAndDemandable),
              fmt(r.nyddo),
              fmt(r.totalUnpaidUtilization),
            ];
        return TabularReportData(
          labelColumnCount: 4,
          superHeaderLabels:
              'CLASSIFICATION (Cols 1-4)  |  BUDGET (Cols 5-6)  |  ADJUSTED BUDGET (Cols 7-8)  |  UTILIZATIONS (Cols 9-13)  |  DISBURSEMENT (Cols 14-18)  |  BALANCE (Cols 19-22)',
          superHeaderRow: const [
            'CLASSIFICATION',
            '',
            '',
            '',
            'BUDGET',
            '',
            'ADJUSTED BUDGET',
            '',
            'UTILIZATIONS',
            '',
            '',
            '',
            '',
            'DISBURSEMENT',
            '',
            '',
            '',
            '',
            'BALANCE',
            '',
            '',
            '',
          ],
          headers: const [
            'PROGRAMS',
            'ACTIVITIES/PROJECTS',
            'ALLOTMENT CLASS',
            'OBJECT OF EXPENDITURES',
            'BEGINNING BALANCE',
            'APPROVED BUDGET',
            'TOTAL MODIFICATION',
            'ADJUSTED BUDGET',
            'UTIL Q1',
            'UTIL Q2',
            'UTIL Q3',
            'UTIL Q4',
            'TOTAL UTILIZATION',
            'DISB Q1',
            'DISB Q2',
            'DISB Q3',
            'DISB Q4',
            'TOTAL DISBURSEMENT',
            'UNUTILIZED BUDGET',
            'DUE AND DEMANDABLE',
            'NYDDO',
            'TOTAL UNPAID UTILIZATION',
          ],
          rows: rows.map(regCells).toList(),
          totalRow: regCells(total),
        );

      case ReportType.far2:
        final rows = <List<String>>[];
        var grandTotal = const ReportMetrics();
        for (final g in bundle.far2Groups) {
          if (filters.far2MfoFilter != 'ALL' &&
              g.mfoProgram != filters.far2MfoFilter) {
            continue;
          }
          final matchesParent = g.mfoProgram.toLowerCase().contains(q);
          final matchingChildren = g.children.where((c) {
            if (filters.far2ClassFilter != 'ALL' &&
                c.allotmentClass != filters.far2ClassFilter) {
              return false;
            }
            if (!filters.matchesMetricActivity(c.metrics)) return false;
            if (q.isNotEmpty && !matchesParent) {
              return c.label.toLowerCase().contains(q);
            }
            return true;
          }).toList();

          if (matchingChildren.isEmpty &&
              (filters.far2ClassFilter != 'ALL' ||
                  filters.metricActivityFilter != 'ALL' ||
                  (q.isNotEmpty && !matchesParent))) {
            continue;
          }

          final groupTotal = matchingChildren.fold<ReportMetrics>(
            const ReportMetrics(),
            (s, c) => s + c.metrics,
          );
          grandTotal = grandTotal + groupTotal;
          rows.add([g.mfoProgram, ...metricCells(groupTotal)]);
          for (final c in matchingChildren) {
            rows.add(['    ${c.label}', ...metricCells(c.metrics)]);
          }
        }
        return TabularReportData(
          labelColumnCount: 1,
          headers: const [
            'Row Labels',
            'APPROVED BUDGET',
            'TOTAL MODIFICATION',
            'ADJUSTED BUDGET',
            'TOTAL UTILIZATIONS',
            'TOTAL DISBURSEMENT',
            'UNUTILIZED BUDGET',
            'DUE AND DEMANDABLE',
            'NYDDO',
            'TOTAL UNPAID UTILIZATION',
          ],
          rows: rows,
          totalRow: ['Grand Total', ...metricCells(grandTotal)],
        );

      case ReportType.far2a:
        final groups = filters.far2aClassFilter == 'ALL'
            ? bundle.far2AGroups
            : bundle.far2AGroups
                .where((g) => g.allotmentClass == filters.far2aClassFilter)
                .toList();
        final rows = <List<String>>[];
        var grandTotal = const ReportMetrics();
        for (final g in groups) {
          final matchingRows = g.rows.where((r) {
            if (!filters.matchesMetricActivity(r.metrics)) return false;
            if (q.isNotEmpty) {
              return r.particulars.toLowerCase().contains(q) ||
                  r.accountCode.toLowerCase().contains(q);
            }
            return true;
          }).toList();

          if ((q.isNotEmpty || filters.metricActivityFilter != 'ALL') &&
              matchingRows.isEmpty) {
            continue;
          }

          rows.add([g.sectionTitle, '', '', '', '', '', '', '', '', '']);
          for (final r in matchingRows) {
            rows.add(['  ${r.particulars}', ...metricCells(r.metrics)]);
          }
          final sectionSubtotal = matchingRows.fold<ReportMetrics>(
            const ReportMetrics(),
            (s, r) => s + r.metrics,
          );
          rows.add([
            'Subtotal - ${g.sectionTitle}',
            ...metricCells(sectionSubtotal),
          ]);
          grandTotal = grandTotal + sectionSubtotal;
        }
        return TabularReportData(
          labelColumnCount: 1,
          headers: const [
            'PARTICULARS',
            'APPROVED BUDGET',
            'TOTAL MODIFICATION',
            'ADJUSTED BUDGET',
            'TOTAL UTILIZATIONS',
            'TOTAL DISBURSEMENT',
            'UNUTILIZED BUDGET',
            'DUE AND DEMANDABLE',
            'NYDDO',
            'TOTAL UNPAID UTILIZATION',
          ],
          rows: rows,
          totalRow: ['GRAND TOTAL', ...metricCells(grandTotal)],
        );
    }
  }
}

class TabularReportData {
  const TabularReportData({
    required this.labelColumnCount,
    this.superHeaderLabels,
    this.superHeaderRow,
    required this.headers,
    required this.rows,
    required this.totalRow,
  });

  final int labelColumnCount;
  final String? superHeaderLabels;
  final List<String>? superHeaderRow;
  final List<String> headers;
  final List<List<String>> rows;
  final List<String> totalRow;
}
