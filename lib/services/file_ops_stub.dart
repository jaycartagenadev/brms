Future<String> openExportedFileIfLocal(Uri uri, String prefix) async {
  return '$prefix.';
}

Future<bool> localFileExists(String path) async => false;

Future<void> deleteLocalFileIfExists(String path) async {}

Future<String> copyFileToDocumentsSubfolder({
  required String sourcePath,
  required String subfolder,
  required String targetFilename,
}) async {
  throw UnsupportedError(
    'Local file attachment storage is only available on Desktop.',
  );
}

Future<String?> openLocalFile(String path) async {
  return 'Opening local PDF attachments is only supported on Desktop.';
}

Future<List<int>?> readLocalFileBytes(String path) async => null;

Future<void> writeLocalFileBytes(String path, List<int> bytes) async {
  throw UnsupportedError('Local file writing is only supported on Desktop.');
}
