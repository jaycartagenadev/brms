import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../data/database/connection/db_connection.dart';
import '../utils/brms_formatters.dart';
import 'file_ops.dart';

/// Handles local SQLite database backup and restore on Desktop workstations.
class DatabaseBackupService {
  const DatabaseBackupService();

  static const List<int> _sqliteHeader = <int>[
    0x53, 0x51, 0x4C, 0x69, 0x74, 0x65, 0x20, 0x66, // "SQLite f"
    0x6F, 0x72, 0x6D, 0x61, 0x74, 0x20, 0x33, 0x00, // "ormat 3\0"
  ];

  /// Exports a copy of `brms_database.sqlite` to a user-chosen location.
  Future<String?> backupDatabase() async {
    if (kIsWeb) {
      return 'SQLite file backup is only available on Desktop workstations.';
    }
    final dbPath = await getBrmsDatabasePath();
    if (dbPath == null) return 'Unable to locate local database file.';

    final bytes = await readLocalFileBytes(dbPath);
    if (bytes == null || bytes.isEmpty) {
      return 'Local database file not found or empty.';
    }

    final date = BrmsFormatters.toIsoDate(DateTime.now());
    final uri = await FilePicker.saveFile(
      fileName: 'brms_backup_$date.sqlite',
      bytes: Uint8List.fromList(bytes),
      mimeType: 'application/x-sqlite3',
      dialogTitle: 'Save BRMS Database Backup',
    );
    if (uri == null) return null;

    return uri.scheme == 'file'
        ? 'Database backup saved to ${uri.toFilePath()}'
        : 'Database backup saved.';
  }

  /// Picks a `.sqlite` backup file, validates its SQLite header, invokes
  /// [closeDatabase] so the file handle is released, replaces the database,
  /// and returns a status message (`null` if cancelled).
  Future<({bool restored, String? message})> restoreDatabase({
    required Future<void> Function() closeDatabase,
  }) async {
    if (kIsWeb) {
      return (
        restored: false,
        message: 'SQLite file restore is only available on Desktop workstations.',
      );
    }

    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['sqlite', 'db'],
    );
    if (files.isEmpty) return (restored: false, message: null);

    final pickedPath = files.first.path;
    if (pickedPath == null || pickedPath.isEmpty) {
      return (restored: false, message: 'Selected backup file could not be read.');
    }

    final bytes = await readLocalFileBytes(pickedPath);
    if (bytes == null || !_isValidSqliteHeader(bytes)) {
      return (
        restored: false,
        message: 'Invalid backup file. Please choose a valid SQLite (.sqlite) backup.',
      );
    }

    final dbPath = await getBrmsDatabasePath();
    if (dbPath == null) {
      return (restored: false, message: 'Unable to resolve local database path.');
    }

    await closeDatabase();
    await writeLocalFileBytes(dbPath, bytes);
    return (
      restored: true,
      message: 'Database restored from ${files.first.name}.',
    );
  }

  bool _isValidSqliteHeader(List<int> bytes) {
    if (bytes.length < _sqliteHeader.length) return false;
    for (int i = 0; i < _sqliteHeader.length; i++) {
      if (bytes[i] != _sqliteHeader[i]) return false;
    }
    return true;
  }
}
