import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> openExportedFileIfLocal(Uri uri, String prefix) async {
  if (uri.scheme == 'file') {
    final path = uri.toFilePath();
    if (await File(path).exists()) {
      await OpenFilex.open(path);
      return '$prefix to $path';
    }
  }
  return '$prefix.';
}

Future<bool> localFileExists(String path) => File(path).exists();

Future<void> deleteLocalFileIfExists(String path) async {
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
  }
}

Future<String> copyFileToDocumentsSubfolder({
  required String sourcePath,
  required String subfolder,
  required String targetFilename,
}) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final targetDir = Directory(p.join(docsDir.path, subfolder));
  if (!await targetDir.exists()) {
    await targetDir.create(recursive: true);
  }
  final targetPath = p.join(targetDir.path, targetFilename);
  final sourceFile = File(sourcePath);
  if (sourceFile.absolute.path != File(targetPath).absolute.path) {
    await sourceFile.copy(targetPath);
  }
  return targetPath;
}

Future<String?> openLocalFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return 'Attachment file not found at $path';
  }
  final result = await OpenFilex.open(path);
  if (result.type != ResultType.done) {
    return result.message.isNotEmpty
        ? result.message
        : 'Unable to open PDF attachment.';
  }
  return null;
}

Future<List<int>?> readLocalFileBytes(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  return file.readAsBytes();
}

Future<void> writeLocalFileBytes(String path, List<int> bytes) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
}
