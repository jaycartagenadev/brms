import 'package:intl/intl.dart';

/// Shared formatting and parsing utilities for BRMS currency and ISO-8601 dates.
class BrmsFormatters {
  const BrmsFormatters._();

  static final NumberFormat _phpCurrencyFormat = NumberFormat(
    '#,##0.00',
    'en_US',
  );
  static final DateFormat _isoDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFormat = DateFormat('MM-dd-yyyy');

  /// Standard allotment classifications aligned with FAR No. 1-A / FAR 2.
  static const List<String> allotmentClasses = [
    'Personal Service',
    'Maintenance & Other Operating Expenses',
    'Capital Outlay',
  ];

  /// Dynamically generated fiscal year options from 2022-2023 through
  /// two years ahead of the current calendar year.
  static List<String> get fiscalYears {
    final endStartYear = DateTime.now().year + 2;
    const baseYear = 2022;
    final count = (endStartYear - baseYear + 1).clamp(4, 30);
    return List.generate(
      count,
      (i) => '${baseYear + i}-${baseYear + i + 1}',
      growable: false,
    );
  }

  /// Current default fiscal year string (e.g., `2026-2027`).
  static String get currentFiscalYear {
    final year = DateTime.now().year;
    return '$year-${year + 1}';
  }

  /// Derives a fiscal year label (`YYYY-(YYYY+1)`) from an ISO-8601 date.
  static String fiscalYearForIsoDate(String iso) {
    final parsed = parseIsoDate(iso);
    if (parsed == null) return currentFiscalYear;
    return '${parsed.year}-${parsed.year + 1}';
  }

  /// Fixed allowed `mfo_program` values in exact FAR 2 reporting order.
  static const List<String> mfoPrograms = [
    'A.I General Administration and Support',
    'A.II Support to Operations',
    'MFO 1: Higher Education',
    'MFO 2: Advance Education',
    'MFO 3: Research',
    'MFO 4: Extension Services',
  ];

  /// Formats [amount] as `Php #,##0.00`.
  static String formatPhp(double amount) {
    return 'Php ${_phpCurrencyFormat.format(amount)}';
  }

  /// Formats [amount] as `#,##0.00` without currency prefix (for report cells).
  static String formatNumber(double amount) {
    return _phpCurrencyFormat.format(amount);
  }

  /// Parses a currency or numeric string (e.g., `Php 15,500,000.00` or `15500000`)
  /// into a `double`, returning `null` if invalid.
  static double? parseAmount(String raw) {
    final cleaned = raw
        .replaceAll('Php', '')
        .replaceAll('PHP', '')
        .replaceAll('₱', '')
        .replaceAll(',', '')
        .trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  /// Formats a [DateTime] into ISO-8601 `YYYY-MM-DD`.
  static String toIsoDate(DateTime date) => _isoDateFormat.format(date);

  /// Formats a [DateTime] into human-readable `MM-DD-YYYY`.
  static String toDisplayDate(DateTime date) => _displayDateFormat.format(date);

  /// Parses an ISO-8601 `YYYY-MM-DD` string into a [DateTime], or `null`.
  static DateTime? parseIsoDate(String iso) {
    if (iso.trim().isEmpty) return null;
    return DateTime.tryParse(iso.trim());
  }

  /// Converts an ISO-8601 `YYYY-MM-DD` string to `MM-DD-YYYY` for UI display.
  static String isoToDisplay(String iso) {
    final parsed = parseIsoDate(iso);
    if (parsed == null) return iso;
    return _displayDateFormat.format(parsed);
  }

  /// Returns the calendar quarter (`1`–`4`) for an ISO-8601 `YYYY-MM-DD` date.
  static int? quarterOfIso(String iso) {
    final parsed = parseIsoDate(iso);
    if (parsed == null) return null;
    return ((parsed.month - 1) ~/ 3) + 1;
  }

  /// Returns a compact short label for an allotment classification badge.
  static String shortAllotmentLabel(String allotmentClass) {
    switch (allotmentClass) {
      case 'Personal Service':
        return 'PS';
      case 'Maintenance & Other Operating Expenses':
        return 'MOOE';
      case 'Capital Outlay':
        return 'CO';
      default:
        return allotmentClass;
    }
  }
}
