import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/brms_models.dart';
import '../providers/reports_provider.dart';
import '../utils/brms_formatters.dart';

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

/// Generates official CSV (Excel-compatible) and landscape PDF exports for
/// FAR 2, FAR 2-A, Registries, and Central reports.
class ReportExportService {
  const ReportExportService();

  static const String _department = 'SUCs';
  static const String _agency = 'CAGAYAN STATE UNIVERSITY - APARRI CAMPUS';
  static const String _orgCode = '08 022 0000000';

  /// Exports the active report as an Excel-compatible UTF-8 CSV file.
  Future<String?> exportCsv({
    required ReportExportMeta meta,
    required UnifiedReportBundle bundle,
    List<CentralReportRow>? filteredCentralRows,
    String far2aClassFilter = 'ALL',
  }) async {
    final table = _buildTabularData(
      meta: meta,
      bundle: bundle,
      filteredCentralRows: filteredCentralRows,
      far2aClassFilter: far2aClassFilter,
    );

    final buffer = StringBuffer();
    buffer.writeln(_csvRow(['DEPARTMENT', _department]));
    buffer.writeln(_csvRow(['AGENCY', _agency]));
    buffer.writeln(_csvRow(['ORGANIZATIONAL CODE', _orgCode]));
    buffer.writeln(_csvRow(['REPORT', '${meta.reportType.label} - ${meta.reportType.subtitle}']));
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

    // UTF-8 BOM so Microsoft Excel opens numeric & peso text cleanly.
    final bytes = Uint8List.fromList([
      0xEF,
      0xBB,
      0xBF,
      ...utf8.encode(buffer.toString()),
    ]);

    final fileName = _defaultFileName(meta.reportType, 'csv');
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'text/csv',
      dialogTitle: 'Export ${meta.reportType.label} CSV',
    );
    if (uri == null) return null;

    return _openIfLocalFile(uri, 'Exported ${meta.reportType.label} CSV');
  }

  /// Exports the active report as a landscape PDF with CSU-Aparri headers.
  Future<String?> exportLandscapePdf({
    required ReportExportMeta meta,
    required UnifiedReportBundle bundle,
    List<CentralReportRow>? filteredCentralRows,
    String far2aClassFilter = 'ALL',
  }) async {
    final table = _buildTabularData(
      meta: meta,
      bundle: bundle,
      filteredCentralRows: filteredCentralRows,
      far2aClassFilter: far2aClassFilter,
    );

    final doc = pw.Document(
      title: '${meta.reportType.label} - $_agency',
      author: _agency,
    );

    final isWideMatrix =
        meta.reportType == ReportType.central ||
        meta.reportType == ReportType.registries;
    final bodyFontSize = meta.reportType == ReportType.central
        ? 4.6
        : (meta.reportType == ReportType.registries ? 5.3 : 7.0);
    final headerFontSize = meta.reportType == ReportType.central
        ? 4.6
        : (meta.reportType == ReportType.registries ? 5.2 : 7.0);

    doc.addPage(
      pw.MultiPage(
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
                      '$_agency • BRMS',
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
              'Generated by CSU-Aparri Budget Resource Monitoring System (Offline Desktop)',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
            ),
            pw.Text(
              'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
            ),
          ],
        ),
        build: (ctx) {
          final allRows = <List<String>>[
            ...table.rows,
            table.totalRow,
          ];

          return [
            if (table.superHeaderLabels != null) ...[
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                color: PdfColors.grey200,
                child: pw.Text(
                  table.superHeaderLabels!,
                  style: pw.TextStyle(
                    fontSize: headerFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
            ],
            pw.TableHelper.fromTextArray(
              headers: table.headers,
              data: allRows,
              headerStyle: pw.TextStyle(
                fontSize: headerFontSize,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey900,
              ),
              cellStyle: pw.TextStyle(fontSize: bodyFontSize),
              cellPadding: pw.EdgeInsets.symmetric(
                horizontal: isWideMatrix ? 2.5 : 4,
                vertical: isWideMatrix ? 3 : 4,
              ),
              border: pw.TableBorder.all(
                color: PdfColors.grey400,
                width: 0.4,
              ),
              cellAlignments: {
                for (int c = 0; c < table.headers.length; c++)
                  c: c < table.labelColumnCount
                      ? pw.Alignment.centerLeft
                      : pw.Alignment.centerRight,
              },
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
            ),
          ];
        },
      ),
    );

    final pdfBytes = await doc.save();
    final fileName = _defaultFileName(meta.reportType, 'pdf');
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: Uint8List.fromList(pdfBytes),
      mimeType: 'application/pdf',
      dialogTitle: 'Save Official ${meta.reportType.label} Landscape PDF',
    );
    if (uri == null) return null;

    return _openIfLocalFile(uri, 'Saved ${meta.reportType.label} PDF');
  }

  Future<String> _openIfLocalFile(Uri uri, String prefix) async {
    if (uri.scheme == 'file') {
      final path = uri.toFilePath();
      if (await File(path).exists()) {
        await OpenFilex.open(path);
        return '$prefix to $path';
      }
    }
    return '$prefix.';
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

  _TabularReportData _buildTabularData({
    required ReportExportMeta meta,
    required UnifiedReportBundle bundle,
    List<CentralReportRow>? filteredCentralRows,
    required String far2aClassFilter,
  }) {
    String fmt(double v) => BrmsFormatters.formatNumber(v);

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
        return _TabularReportData(
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
        return _TabularReportData(
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
        for (final g in bundle.far2Groups) {
          rows.add([g.mfoProgram, ...metricCells(g.total)]);
          for (final c in g.children) {
            rows.add(['    ${c.label}', ...metricCells(c.metrics)]);
          }
        }
        return _TabularReportData(
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
          totalRow: ['Grand Total', ...metricCells(bundle.far2GrandTotal)],
        );

      case ReportType.far2a:
        final groups = far2aClassFilter == 'ALL'
            ? bundle.far2AGroups
            : bundle.far2AGroups
                .where((g) => g.allotmentClass == far2aClassFilter)
                .toList();
        final rows = <List<String>>[];
        var grandTotal = const ReportMetrics();
        for (final g in groups) {
          rows.add([g.sectionTitle, '', '', '', '', '', '', '', '', '']);
          for (final r in g.rows) {
            rows.add(['  ${r.particulars}', ...metricCells(r.metrics)]);
          }
          rows.add([
            'Subtotal - ${g.sectionTitle}',
            ...metricCells(g.subtotal),
          ]);
          grandTotal = grandTotal + g.subtotal;
        }
        return _TabularReportData(
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

class _TabularReportData {
  const _TabularReportData({
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
