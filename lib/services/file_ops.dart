import 'file_ops_stub.dart'
    if (dart.library.io) 'file_ops_native.dart' as impl;

Future<String> openExportedFileIfLocal(Uri uri, String prefix) =>
    impl.openExportedFileIfLocal(uri, prefix);

Future<bool> localFileExists(String path) => impl.localFileExists(path);

Future<void> deleteLocalFileIfExists(String path) =>
    impl.deleteLocalFileIfExists(path);

Future<String> copyFileToDocumentsSubfolder({
  required String sourcePath,
  required String subfolder,
  required String targetFilename,
}) => impl.copyFileToDocumentsSubfolder(
  sourcePath: sourcePath,
  subfolder: subfolder,
  targetFilename: targetFilename,
);

Future<String?> openLocalFile(String path) => impl.openLocalFile(path);

Future<List<int>?> readLocalFileBytes(String path) =>
    impl.readLocalFileBytes(path);

Future<void> writeLocalFileBytes(String path, List<int> bytes) =>
    impl.writeLocalFileBytes(path, bytes);
