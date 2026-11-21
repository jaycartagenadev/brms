import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String?> getBrmsDatabasePath() async {
  final docsDir = await getApplicationDocumentsDirectory();
  return p.join(docsDir.path, 'brms_database.sqlite');
}

QueryExecutor openBrmsConnection() {
  return LazyDatabase(() async {
    final dbPath = await getBrmsDatabasePath();
    final dbFile = File(dbPath!);
    await dbFile.parent.create(recursive: true);
    return NativeDatabase(dbFile);
  });
}
