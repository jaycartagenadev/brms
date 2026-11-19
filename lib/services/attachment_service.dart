import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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

/// Manages local PDF attachments inside `<app_docs>/brms_attachments/`.
class AttachmentService {
  const AttachmentService();

  static const String _attachmentsFolderName = 'brms_attachments';

  /// Opens the native file picker restricted to `.pdf` files.
  Future<PickedPdfAttachment?> pickPdf() async {
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
    final docsDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory(
      p.join(docsDir.path, _attachmentsFolderName),
    );
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    final safeObr = _sanitizeSegment(obrNo);
    final baseName = _sanitizeSegment(p.basenameWithoutExtension(originalFilename));
    final ext = p.extension(originalFilename).toLowerCase() == '.pdf'
        ? '.pdf'
        : '.pdf';
    final targetFilename = '${safeObr}_$baseName$ext';
    final targetPath = p.join(attachmentsDir.path, targetFilename);

    final sourceFile = File(sourcePath);
    if (sourceFile.absolute.path != File(targetPath).absolute.path) {
      await sourceFile.copy(targetPath);
    }

    return (filename: targetFilename, localPath: targetPath);
  }

  /// Opens a local PDF file using the OS default viewer via `open_filex`.
  /// Returns `null` on success, or an error message if opening fails.
  Future<String?> openAttachment(String? localPath) async {
    if (localPath == null || localPath.trim().isEmpty) {
      return 'No PDF attachment is linked to this OBR.';
    }
    final file = File(localPath);
    if (!await file.exists()) {
      return 'Attachment file not found at $localPath';
    }
    final result = await OpenFilex.open(localPath);
    if (result.type != ResultType.done) {
      return result.message.isNotEmpty
          ? result.message
          : 'Unable to open PDF attachment.';
    }
    return null;
  }

  String _sanitizeSegment(String input) {
    final sanitized = input.trim().replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return sanitized.isEmpty ? 'attachment' : sanitized;
  }
}
