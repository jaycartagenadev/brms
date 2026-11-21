import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;

import 'file_ops.dart';

/// Represents a PDF file selected by the user before it is persisted to
/// `brms_attachments/`.
class PickedPdfAttachment {
  const PickedPdfAttachment({
    required this.sourcePath,
    required this.originalFilename,
  });

  final String sourcePath;
  final String originalFilename;
}

/// Manages local PDF attachments inside `<app_docs>/brms_attachments/` on Desktop
/// with graceful web handling.
class AttachmentService {
  const AttachmentService();

  static const String _attachmentsFolderName = 'brms_attachments';

  /// Opens the native file picker restricted to `.pdf` files.
  Future<PickedPdfAttachment?> pickPdf() async {
    if (kIsWeb) return null;
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (files.isEmpty) return null;

    final file = files.first;
    final path = file.path;
    if (path == null || path.isEmpty) return null;

    return PickedPdfAttachment(
      sourcePath: path,
      originalFilename: file.name,
    );
  }

  /// Copies [sourcePath] into `<app_docs>/brms_attachments/<obrNo>_<filename>.pdf`
  /// and returns the stored filename and absolute local path.
  Future<({String filename, String localPath})> saveAttachment({
    required String sourcePath,
    required String originalFilename,
    required String obrNo,
  }) async {
    final safeObr = _sanitizeSegment(obrNo);
    final baseName =
        _sanitizeSegment(p.basenameWithoutExtension(originalFilename));
    final targetFilename = '${safeObr}_$baseName.pdf';

    final targetPath = await copyFileToDocumentsSubfolder(
      sourcePath: sourcePath,
      subfolder: _attachmentsFolderName,
      targetFilename: targetFilename,
    );

    return (filename: targetFilename, localPath: targetPath);
  }

  /// Deletes a local attachment file if it exists (used when replacing/removing
  /// attachments or deleting an OBR).
  Future<void> deleteAttachment(String? localPath) async {
    if (kIsWeb || localPath == null || localPath.trim().isEmpty) return;
    await deleteLocalFileIfExists(localPath);
  }

  /// Opens a local PDF file using the OS default viewer on Desktop.
  /// Returns `null` on success, or an error message if opening fails.
  Future<String?> openAttachment(String? localPath) async {
    if (kIsWeb) {
      return 'Opening local PDF files is only supported on Desktop.';
    }
    if (localPath == null || localPath.trim().isEmpty) {
      return 'No PDF attachment is linked to this OBR.';
    }
    return openLocalFile(localPath);
  }

  String _sanitizeSegment(String input) {
    final sanitized = input.trim().replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return sanitized.isEmpty ? 'attachment' : sanitized;
  }
}
