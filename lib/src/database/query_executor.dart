import 'package:database_repository/database_repository.dart';
import 'package:firedart/firedart.dart';
import 'package:uuid/uuid.dart';

import '../deps.dart';

/// Mixin that contains the logic on how to execute the query in firestore
mixin QueryExecutor implements DatabaseAdapter {
  /// Tries to store queries payload in firestore
  Future<QueryResult> create(Query query, Firestore db) async {
    final id = query.payload['id'] ?? Uuid().v1();
    final ref = db.collection(query.entityName).doc(id);
    final json = JSON.from(query.payload)..putIfAbsent('id', () => id);

    try {
      if (await ref.exists) {
        return QueryResult.failed(
          query,
          errorMsg: '${query.entityName} with id $id already exists.',
        );
      }
      await ref.set(json);
      return QueryResult.success(query, payload: json);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return QueryResult.failed(query, errorMsg: e.toString());
    }
  }

  /// Tries to store queries payload in firestore
  Future<QueryResult> update(Query query, Firestore db) async {
    final id = query.payload['id'] ?? Uuid().v1();
    final ref = db.collection(query.entityName).doc(id);
    final json = JSON.from(query.payload)..putIfAbsent('id', () => id);

    try {
      await ref.set(json);
      return QueryResult.success(query, payload: json);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return QueryResult.failed(query, errorMsg: e.toString());
    }
  }

  /// Tries to delete payload from firestore
  Future<QueryResult> delete(Query query, Firestore db) async {
    final id = query.payload['id'];

    if (null == id) {
      return QueryResult.failed(query, errorMsg: 'No id specified');
    }

    final ref = db.collection(query.entityName).doc(id);

    try {
      await ref.delete();
      return QueryResult.success(query);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return QueryResult.failed(query, errorMsg: e.toString());
    }
  }

  /// Tries to fetch payload from firestore
  Future<QueryResult> read(Query query, Firestore db) async {
    if (query.limit == 1 && null != query.payload['id']) {
      final id = query.payload['id'] ?? Uuid().v1();
      final ref = db.collection(query.entityName).doc(id);

      if (await ref.exists) {
        final snapshot = await ref.get();
        return QueryResult.success(query, payload: snapshot.map);
      }
    } else {
      final ref = db.collection(query.entityName);
      var dbQuery = QueryReference(ref.gateway, ref.path);

      if (query.limit != null && query.limit! > 0) {
        dbQuery = ref.limit(query.limit!);
      }

      for (final constraint in query.where) {
        dbQuery = _applyConstraint(constraint, dbQuery);
      }

      final result = await dbQuery.get();
      final json = <String, dynamic>{};

      if (result.isNotEmpty) {
        for (final snapshot in result) {
          json.putIfAbsent(snapshot.id, () => snapshot.map);
        }
      }

      return QueryResult.success(query, payload: json);
    }

    return QueryResult.failed(
      query,
      errorMsg: 'Could not read data from database',
    );
  }

  QueryReference _applyConstraint(
    Constraint constraint,
    QueryReference dbQuery,
  ) {
    if (constraint is Equals) {
      return dbQuery.where(constraint.key, isEqualTo: constraint.value);
    }

    if (constraint is NotEquals) {
      throw ConstraintUnsupportedException(
        constraint: constraint,
        adapter: this,
      );
    }

    if (constraint is GreaterThan) {
      return dbQuery.where(constraint.key, isGreaterThan: constraint.value);
    }

    if (constraint is GreaterThanOrEquals) {
      return dbQuery.where(
        constraint.key,
        isGreaterThanOrEqualTo: constraint.value,
      );
    }

    if (constraint is LessThan) {
      return dbQuery.where(constraint.key, isLessThan: constraint.value);
    }

    if (constraint is LessThanOrEquals) {
      return dbQuery.where(
        constraint.key,
        isLessThanOrEqualTo: constraint.value,
      );
    }

    if (constraint is IsNull) {
      return dbQuery.where(constraint.key, isNull: true);
    }

    if (constraint is IsNotNull) {
      return dbQuery.where(constraint.key, isNull: false);
    }

    if (constraint is IsFalse) {
      return dbQuery.where(constraint.key, isEqualTo: false);
    }

    if (constraint is IsTrue) {
      return dbQuery.where(constraint.key, isEqualTo: true);
    }

    if (constraint is IsFalsey) {
      throw ConstraintUnsupportedException(
        constraint: constraint,
        adapter: this,
      );
    }

    if (constraint is IsTruthy) {
      throw ConstraintUnsupportedException(
        constraint: constraint,
        adapter: this,
      );
    }

    if (constraint is IsSet) {
      throw ConstraintUnsupportedException(
        constraint: constraint,
        adapter: this,
      );
    }

    if (constraint is IsUnset) {
      throw ConstraintUnsupportedException(
        constraint: constraint,
        adapter: this,
      );
    }

    if (constraint is InList) {
      return dbQuery.where(constraint.key, whereIn: constraint.value as List);
    }

    if (constraint is NotInList) {
      throw ConstraintUnsupportedException(
        constraint: constraint,
        adapter: this,
      );
    }

    if (constraint is Contains) {
      if (constraint.value is Iterable) {
        for (final value in constraint.value) {
          dbQuery = dbQuery.where(constraint.key, arrayContains: value);
        }

        return dbQuery;
      }

      return dbQuery.where(constraint.key, arrayContains: constraint.value);
    }

    if (constraint is ContainsNot) {
      throw ConstraintUnsupportedException(
        constraint: constraint,
        adapter: this,
      );
    }

    throw ConstraintUnsupportedException(constraint: constraint, adapter: this);
  }
}

/// Implement the same interface as cloud_firestore
extension CloudFirestoreInterface on CollectionReference {
  /// Get a reference to a document
  DocumentReference doc(String id) => document(id);
}
