import 'package:drift/drift.dart';

import 'db_connection_stub.dart'
    if (dart.library.io) 'db_connection_native.dart'
    if (dart.library.js_interop) 'db_connection_web.dart' as impl;

QueryExecutor openBrmsConnection() => impl.openBrmsConnection();

Future<String?> getBrmsDatabasePath() => impl.getBrmsDatabasePath();
