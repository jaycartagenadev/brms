import 'package:intl/intl.dart';

/// Shared formatting and parsing utilities for BRMS currency and ISO-8601 dates.
class BrmsFormatters {
  const BrmsFormatters._();

  static final NumberFormat _phpCurrencyFormat = NumberFormat('#,##0.00', 'en_US');
  static final DateFormat _isoDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFormat = DateFormat('MM-dd-yyyy');

  /// Standard allotment classifications aligned with FAR No. 1-A.
  static const List<String> allotmentClasses = [
    'Personal Service',
    'Maintenance & Other Operating Expenses',
    'Capital Outlay',
  ];

  /// Standard fiscal year options.
  static const List<String> fiscalYears = [
    '2022-2023',
    '2023-2024',
    '2024-2025',
    '2025-2026',
  ];

  /// Formats [amount] as `Php #,##0.00`.
  static String formatPhp(double amount) {
    return 'Php ${_phpCurrencyFormat.format(amount)}';
  }

  /// Formats [amount] as `#,##0.00` without currency prefix (e.g., for input fields).
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
