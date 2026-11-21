import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/brms_theme.dart';
import '../utils/brms_formatters.dart';

/// Shared monochrome surface card matching Stitch's rounded-xl bordered container.
class BrmsCard extends StatelessWidget {
  const BrmsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor = BrmsColors.surface,
    this.borderColor = BrmsColors.outlineVariant,
    this.borderRadius = 12,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Monochrome pill badge for codes, statuses, and tags.
class BrmsBadge extends StatelessWidget {
  const BrmsBadge({
    super.key,
    required this.label,
    this.filled = false,
    this.fontSize = 10,
  });

  final String label;
  final bool filled;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? BrmsColors.primary : BrmsColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(5),
        border: filled ? null : Border.all(color: BrmsColors.outlineVariant),
      ),
      child: Text(
        label,
        style: BrmsTheme.mono(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: filled ? BrmsColors.onPrimary : BrmsColors.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Thin monochrome horizontal progress bar.
class BrmsProgressBar extends StatelessWidget {
  const BrmsProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.barColor = BrmsColors.barDark,
    this.trackColor = BrmsColors.surfaceContainer,
  });

  final double value;
  final double height;
  final Color barColor;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: trackColor,
        valueColor: AlwaysStoppedAnimation<Color>(barColor),
      ),
    );
  }
}

/// Standard monochrome primary or outlined action button.
class BrmsButton extends StatelessWidget {
  const BrmsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = true,
    this.height = 36,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bg = primary ? BrmsColors.primary : BrmsColors.surface;
    final fg = primary ? BrmsColors.onPrimary : BrmsColors.onSurface;
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: BorderSide(
            color: primary ? BrmsColors.primary : BrmsColors.outlineVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Monochrome error recovery state with a retry action.
class BrmsErrorState extends StatelessWidget {
  const BrmsErrorState({
    super.key,
    required this.title,
    required this.error,
    required this.onRetry,
  });

  final String title;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrmsColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BrmsColors.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 28,
            color: BrmsColors.error,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: BrmsTheme.heading(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              error.toString(),
              style: BrmsTheme.mono(
                fontSize: 11,
                color: BrmsColors.secondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 14),
          BrmsButton(
            label: 'Retry',
            icon: Icons.refresh,
            primary: false,
            height: 32,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

OverlayEntry? _activeBrmsNoticeEntry;

/// Dismisses any currently visible top-of-app notification.
void dismissBrmsNotice() {
  _activeBrmsNoticeEntry?.remove();
  _activeBrmsNoticeEntry = null;
}

/// Shows a clean monochrome notification banner at the top of the app,
/// rendered in the root [Overlay] so it appears above all screens and dialogs.
void showBrmsNotice(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: BrmsColors.primary,
          behavior: SnackBarBehavior.floating,
          width: 420,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    return;
  }

  dismissBrmsNotice();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _BrmsTopNotice(
      message: message,
      onDismissed: () {
        if (_activeBrmsNoticeEntry == entry) {
          dismissBrmsNotice();
        }
      },
    ),
  );

  _activeBrmsNoticeEntry = entry;
  overlay.insert(entry);
}

class _BrmsTopNotice extends StatefulWidget {
  const _BrmsTopNotice({
    required this.message,
    required this.onDismissed,
  });

  final String message;
  final VoidCallback onDismissed;

  @override
  State<_BrmsTopNotice> createState() => _BrmsTopNoticeState();
}

class _BrmsTopNoticeState extends State<_BrmsTopNotice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
    _autoDismissTimer = Timer(
      const Duration(seconds: 3),
      _dismiss,
    );
  }

  Future<void> _dismiss() async {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top + 16;

    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: IgnorePointer(
        ignoring: false,
        child: Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Material(
                  color: BrmsColors.primary,
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 17,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: _dismiss,
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.close,
                              size: 15,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps wide tables in a horizontal [SingleChildScrollView] with an
/// always-visible, interactive [Scrollbar] so desktop & web users can scroll
/// horizontally when columns exceed the available width.
class BrmsHorizontalTableScroll extends StatefulWidget {
  const BrmsHorizontalTableScroll({
    super.key,
    required this.child,
    this.controller,
    this.ensureMinWidth = false,
    this.showTopScrollbar = false,
  });

  final Widget child;
  final ScrollController? controller;
  final bool ensureMinWidth;
  final bool showTopScrollbar;

  @override
  State<BrmsHorizontalTableScroll> createState() =>
      _BrmsHorizontalTableScrollState();
}

class _BrmsHorizontalTableScrollState extends State<BrmsHorizontalTableScroll> {
  ScrollController? _internalController;

  ScrollController get _effectiveController =>
      widget.controller ?? (_internalController ??= ScrollController());

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  Widget _wrapWithScrollbars({
    required ScrollController controller,
    required Widget scrollView,
  }) {
    final bottomWrapped = Scrollbar(
      controller: controller,
      thumbVisibility: true,
      interactive: true,
      scrollbarOrientation: ScrollbarOrientation.bottom,
      child: scrollView,
    );

    if (!widget.showTopScrollbar) {
      return bottomWrapped;
    }

    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      interactive: true,
      scrollbarOrientation: ScrollbarOrientation.top,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: bottomWrapped,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _effectiveController;

    if (widget.ensureMinWidth) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return _wrapWithScrollbars(
            controller: controller,
            scrollView: SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: widget.child,
              ),
            ),
          );
        },
      );
    }

    return _wrapWithScrollbars(
      controller: controller,
      scrollView: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: widget.child,
      ),
    );
  }
}

/// Compact monochrome dropdown filter pill for BRMS data tables.
class BrmsTableFilterSelect<T> extends StatelessWidget {
  const BrmsTableFilterSelect({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: BrmsColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: BrmsColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: BrmsTheme.mono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: BrmsColors.secondary,
            ),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: BrmsColors.onSurface,
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Clears default zero text (e.g. `0.00`) when a numeric field gains focus so
/// it behaves like a placeholder rather than retaining `0.00` before user input.
void clearZeroTextOnFocus(TextEditingController controller, bool hasFocus) {
  if (!hasFocus) return;
  final trimmed = controller.text.trim();
  if (trimmed == '0' || trimmed == '0.0' || trimmed == '0.00') {
    controller.clear();
  }
}

/// Shared realistic input length and amount limits for BRMS text fields.
abstract final class BrmsInputLimits {
  static const int maxMoneyLength = 23;
  static const double maxMoneyAmount = 999999999999999.99;
  static const int maxSearchLength = 80;
  static const int maxShortCodeLength = 30;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 250;
  static const int maxWorkstationLength = 40;
  static const int maxAuthLength = 64;
}

/// Restricts currency/amount input to realistic numeric values:
/// optional leading `-` (if [allowNegative]), up to 15 integer digits (trillions,
/// commas allowed), and at most 2 decimal places.
class BrmsMoneyInputFormatter extends TextInputFormatter {
  BrmsMoneyInputFormatter({this.allowNegative = false});

  final bool allowNegative;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (allowNegative && text == '-') return newValue;

    final pattern = allowNegative
        ? RegExp(r'^-?[\d,]*\.?\d{0,2}$')
        : RegExp(r'^[\d,]*\.?\d{0,2}$');
    if (!pattern.hasMatch(text)) {
      return oldValue;
    }

    final unsigned = text.startsWith('-') ? text.substring(1) : text;
    final integerPart = unsigned.split('.').first.replaceAll(',', '');
    if (integerPart.length > 15) {
      return oldValue;
    }

    return newValue;
  }
}

/// Shows an interactive preview modal of the data to be exported, with live
/// keyword, column, value, column-visibility, and row-selection filters,
/// requiring an explicit `Export` click before writing the file.
Future<void> showBrmsExportPreviewDialog(
  BuildContext context, {
  required String title,
  required String formatLabel,
  required List<String> headers,
  required List<List<String>> rows,
  List<String>? totalRow,
  List<MapEntry<String, String>> metadata = const [],
  required Future<void> Function(
    List<String> exportHeaders,
    List<List<String>> exportRows,
    List<String>? exportTotalRow,
  )
  onConfirmExport,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _BrmsExportPreviewDialog(
      title: title,
      formatLabel: formatLabel,
      headers: headers,
      rows: rows,
      totalRow: totalRow,
      metadata: metadata,
      onConfirmExport: onConfirmExport,
    ),
  );
}

class _BrmsExportPreviewDialog extends StatefulWidget {
  const _BrmsExportPreviewDialog({
    required this.title,
    required this.formatLabel,
    required this.headers,
    required this.rows,
    required this.totalRow,
    required this.metadata,
    required this.onConfirmExport,
  });

  final String title;
  final String formatLabel;
  final List<String> headers;
  final List<List<String>> rows;
  final List<String>? totalRow;
  final List<MapEntry<String, String>> metadata;
  final Future<void> Function(
    List<String> exportHeaders,
    List<List<String>> exportRows,
    List<String>? exportTotalRow,
  )
  onConfirmExport;

  @override
  State<_BrmsExportPreviewDialog> createState() =>
      _BrmsExportPreviewDialogState();
}

class _BrmsExportPreviewDialogState extends State<_BrmsExportPreviewDialog> {
  static const int _maxPreviewRows = 60;
  static const int _allColumnsIndex = -1;
  static const String _allValuesToken = '__ALL_VALUES__';

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterCol = _allColumnsIndex;
  String _selectedColValue = _allValuesToken;
  bool _showColumnPicker = false;
  bool _isExporting = false;

  late final List<int> _selectedColIndices;
  late final Set<int> _excludedRowIndices;

  @override
  void initState() {
    super.initState();
    _selectedColIndices = List.generate(widget.headers.length, (i) => i);
    _excludedRowIndices = <int>{};
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> _distinctValuesForColumn(int colIdx) {
    if (colIdx < 0 || colIdx >= widget.headers.length) return const [];
    final values = widget.rows
        .map((r) => colIdx < r.length ? r[colIdx].trim() : '')
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList();
    values.sort();
    return values;
  }

  List<int> _matchingRowIndices() {
    final q = _searchQuery.trim().toLowerCase();
    final indices = <int>[];
    for (int i = 0; i < widget.rows.length; i++) {
      final row = widget.rows[i];

      if (_selectedFilterCol != _allColumnsIndex &&
          _selectedColValue != _allValuesToken) {
        final cellVal = _selectedFilterCol < row.length
            ? row[_selectedFilterCol].trim()
            : '';
        if (cellVal != _selectedColValue) continue;
      }

      if (q.isNotEmpty) {
        if (_selectedFilterCol != _allColumnsIndex) {
          final cellVal = _selectedFilterCol < row.length
              ? row[_selectedFilterCol].toLowerCase()
              : '';
          if (!cellVal.contains(q)) continue;
        } else {
          final matchesAny = row.any((cell) => cell.toLowerCase().contains(q));
          if (!matchesAny) continue;
        }
      }

      indices.add(i);
    }
    return indices;
  }

  List<String>? _computeExportTotalRow(
    List<int> colIndices,
    List<List<String>> selectedRows,
  ) {
    final origTotal = widget.totalRow;
    if (origTotal == null) return null;

    return colIndices.map((colIdx) {
      final origCell = colIdx < origTotal.length ? origTotal[colIdx] : '';
      final parsedOrig = BrmsFormatters.parseAmount(origCell);
      final looksNumeric =
          parsedOrig != null &&
          RegExp(r'^-?[\d,]+(\.\d+)?$').hasMatch(origCell.trim());
      if (!looksNumeric) {
        return origCell;
      }
      double sum = 0.0;
      for (final r in selectedRows) {
        if (colIdx < r.length) {
          sum += BrmsFormatters.parseAmount(r[colIdx]) ?? 0.0;
        }
      }
      return BrmsFormatters.formatNumber(sum);
    }).toList();
  }

  void _resetFilters() {
    _searchCtrl.clear();
    setState(() {
      _searchQuery = '';
      _selectedFilterCol = _allColumnsIndex;
      _selectedColValue = _allValuesToken;
      _excludedRowIndices.clear();
      _selectedColIndices
        ..clear()
        ..addAll(List.generate(widget.headers.length, (i) => i));
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchingIndices = _matchingRowIndices();
    final includedMatchingIndices = matchingIndices
        .where((i) => !_excludedRowIndices.contains(i))
        .toList();

    final activeColIndices = _selectedColIndices.toList()..sort();
    final exportHeaders = activeColIndices
        .map((i) => widget.headers[i])
        .toList();
    final exportRows = includedMatchingIndices.map((rowIdx) {
      final r = widget.rows[rowIdx];
      return activeColIndices.map((c) => c < r.length ? r[c] : '').toList();
    }).toList();

    final rawSelectedRows = includedMatchingIndices
        .map((rowIdx) => widget.rows[rowIdx])
        .toList();
    final exportTotalRow = _computeExportTotalRow(
      activeColIndices,
      rawSelectedRows,
    );

    final previewIndices = matchingIndices.length > _maxPreviewRows
        ? matchingIndices.take(_maxPreviewRows).toList()
        : matchingIndices;

    final allMatchingSelected =
        matchingIndices.isNotEmpty &&
        matchingIndices.every((i) => !_excludedRowIndices.contains(i));
    final hasActiveFilter =
        _searchQuery.isNotEmpty ||
        _selectedFilterCol != _allColumnsIndex ||
        _excludedRowIndices.isNotEmpty ||
        activeColIndices.length != widget.headers.length;

    final distinctColValues = _selectedFilterCol == _allColumnsIndex
        ? const <String>[]
        : _distinctValuesForColumn(_selectedFilterCol);

    return Dialog(
      backgroundColor: BrmsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            BrmsBadge(label: widget.formatLabel, filled: true),
                            const SizedBox(width: 8),
                            Text(
                              'EXPORT PREVIEW & FILTER',
                              style: BrmsTheme.mono(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: BrmsColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.title,
                          overflow: TextOverflow.ellipsis,
                          style: BrmsTheme.heading(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isExporting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              if (widget.metadata.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: widget.metadata
                      .map(
                        (m) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: BrmsColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: BrmsColors.outlineVariant,
                            ),
                          ),
                          child: Text(
                            '${m.key}: ${m.value}',
                            style: BrmsTheme.mono(
                              fontSize: 11,
                              color: BrmsColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BrmsColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: BrmsColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 240,
                          height: 34,
                          child: TextField(
                            controller: _searchCtrl,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(
                                BrmsInputLimits.maxSearchLength,
                              ),
                            ],
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 16,
                                color: BrmsColors.secondary,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close, size: 14),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              hintText: 'Filter rows by keyword...',
                              hintStyle: const TextStyle(
                                fontSize: 12,
                                color: BrmsColors.secondary,
                              ),
                              filled: true,
                              fillColor: BrmsColors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: BrmsColors.outlineVariant,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: BrmsColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: BrmsColors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: BrmsColors.outlineVariant,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedFilterCol,
                              isDense: true,
                              style: const TextStyle(
                                fontSize: 12,
                                color: BrmsColors.onSurface,
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: _allColumnsIndex,
                                  child: Text('Filter: All Columns'),
                                ),
                                for (int i = 0; i < widget.headers.length; i++)
                                  DropdownMenuItem(
                                    value: i,
                                    child: Text(
                                      widget.headers[i],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    _selectedFilterCol = v;
                                    _selectedColValue = _allValuesToken;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        if (_selectedFilterCol != _allColumnsIndex)
                          Container(
                            height: 34,
                            constraints: const BoxConstraints(maxWidth: 240),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: BrmsColors.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: BrmsColors.outlineVariant,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value:
                                    distinctColValues.contains(
                                      _selectedColValue,
                                    )
                                    ? _selectedColValue
                                    : _allValuesToken,
                                isDense: true,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: BrmsColors.onSurface,
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: _allValuesToken,
                                    child: Text('All Values'),
                                  ),
                                  ...distinctColValues.map(
                                    (val) => DropdownMenuItem(
                                      value: val,
                                      child: Text(
                                        val,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _selectedColValue = v);
                                  }
                                },
                              ),
                            ),
                          ),
                        BrmsButton(
                          label:
                              'Columns (${activeColIndices.length}/${widget.headers.length})',
                          icon: Icons.view_column_outlined,
                          primary: false,
                          height: 34,
                          onPressed: () => setState(
                            () => _showColumnPicker = !_showColumnPicker,
                          ),
                        ),
                        if (hasActiveFilter)
                          BrmsButton(
                            label: 'Reset',
                            primary: false,
                            height: 34,
                            onPressed: _resetFilters,
                          ),
                      ],
                    ),
                    if (_showColumnPicker) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: List.generate(widget.headers.length, (i) {
                          final selected = _selectedColIndices.contains(i);
                          return FilterChip(
                            label: Text(
                              widget.headers[i],
                              style: TextStyle(
                                fontSize: 11,
                                color: selected
                                    ? Colors.white
                                    : BrmsColors.onSurface,
                              ),
                            ),
                            selected: selected,
                            selectedColor: BrmsColors.primary,
                            checkmarkColor: Colors.white,
                            backgroundColor: BrmsColors.surface,
                            side: const BorderSide(
                              color: BrmsColors.outlineVariant,
                            ),
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _selectedColIndices.add(i);
                                } else if (_selectedColIndices.length > 1) {
                                  _selectedColIndices.remove(i);
                                }
                              });
                            },
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: BrmsColors.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: matchingIndices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'No rows match your current preview filters.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: BrmsColors.secondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              BrmsButton(
                                label: 'Reset Filters',
                                primary: false,
                                onPressed: _resetFilters,
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: BrmsHorizontalTableScroll(
                            ensureMinWidth: true,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                BrmsColors.primary,
                              ),
                              headingTextStyle: BrmsTheme.mono(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              columnSpacing: 18,
                              dataRowMinHeight: 34,
                              dataRowMaxHeight: 40,
                              columns: [
                                DataColumn(
                                  label: Checkbox(
                                    value: allMatchingSelected,
                                    side: const BorderSide(
                                      color: Colors.white70,
                                    ),
                                    activeColor: Colors.white,
                                    checkColor: BrmsColors.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val ?? false) {
                                          _excludedRowIndices.removeAll(
                                            matchingIndices,
                                          );
                                        } else {
                                          _excludedRowIndices.addAll(
                                            matchingIndices,
                                          );
                                        }
                                      });
                                    },
                                  ),
                                ),
                                ...exportHeaders.map(
                                  (h) => DataColumn(label: Text(h)),
                                ),
                              ],
                              rows: [
                                ...previewIndices.map((rowIdx) {
                                  final r = widget.rows[rowIdx];
                                  final isChecked = !_excludedRowIndices
                                      .contains(rowIdx);
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Checkbox(
                                          value: isChecked,
                                          activeColor: BrmsColors.primary,
                                          onChanged: (val) {
                                            setState(() {
                                              if (val ?? false) {
                                                _excludedRowIndices.remove(
                                                  rowIdx,
                                                );
                                              } else {
                                                _excludedRowIndices.add(rowIdx);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      ...activeColIndices.map(
                                        (colIdx) => DataCell(
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 260,
                                            ),
                                            child: Text(
                                              colIdx < r.length
                                                  ? r[colIdx]
                                                  : '',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isChecked
                                                    ? BrmsColors.onSurface
                                                    : BrmsColors.outline,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                if (exportTotalRow != null)
                                  DataRow(
                                    color: WidgetStateProperty.all(
                                      BrmsColors.surfaceContainerHigh,
                                    ),
                                    cells: [
                                      const DataCell(SizedBox.shrink()),
                                      ...exportTotalRow.map(
                                        (cell) => DataCell(
                                          Text(
                                            cell,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    matchingIndices.length > _maxPreviewRows
                        ? 'Previewing $_maxPreviewRows of ${matchingIndices.length} matching rows (${exportRows.length} selected for export)'
                        : 'Selected for export: ${exportRows.length} of ${widget.rows.length} rows',
                    style: BrmsTheme.mono(
                      fontSize: 11,
                      color: BrmsColors.secondary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BrmsButton(
                        label: 'Cancel',
                        primary: false,
                        onPressed: _isExporting
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      BrmsButton(
                        label: _isExporting ? 'Exporting...' : 'Export',
                        icon: Icons.file_download_outlined,
                        onPressed: _isExporting || exportRows.isEmpty
                            ? null
                            : () async {
                                setState(() => _isExporting = true);
                                try {
                                  await widget.onConfirmExport(
                                    exportHeaders,
                                    exportRows,
                                    exportTotalRow,
                                  );
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setState(() => _isExporting = false);
                                  }
                                }
                              },
                      ),
                    ],
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
