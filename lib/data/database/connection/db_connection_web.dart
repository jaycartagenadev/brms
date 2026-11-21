import 'package:drift/drift.dart';
// ignore: deprecated_member_use
import 'package:drift/web.dart';

Future<String?> getBrmsDatabasePath() async => null;

QueryExecutor openBrmsConnection() {
  return LazyDatabase(() async {
    final storage = await DriftWebStorage.indexedDbIfSupported('brms_database');
    return WebDatabase.withStorage(storage);
  });
}
