import 'package:database_repository/database_repository.dart';
import 'package:firedart/firedart.dart';

import 'query_executor.dart';

/// Adapter for Firebase.
///
/// Uses the firestore instance for given [firebaseProjectId]
class FiredartAdapter extends DatabaseAdapter with QueryExecutor {
  @override
  final String name;

  /// The id for the firebase project
  final String firebaseProjectId;

  /// Adapter for Firebase.
  ///
  /// Uses the firestore instance for given [firebaseProjectId]
  FiredartAdapter({this.name = 'firebase', required this.firebaseProjectId}) {
    try {
      Firestore.initialize(firebaseProjectId);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      // Already initialized
    }
  }

  @override
  Future<QueryResult> executeQuery(Query query) {
    switch (query.action) {
      case QueryAction.create:
        return create(query, Firestore.instance);
      case QueryAction.delete:
        return delete(query, Firestore.instance);
      case QueryAction.update:
        return update(query, Firestore.instance);
      case QueryAction.read:
        return read(query, Firestore.instance);
    }
  }
}
