import 'package:cloud_firestore/cloud_firestore.dart';

/// A professional, singleton-based Firestore repository.
///
/// Usage:
/// ```dart
/// await BaiomyFirestoreRepo.instance.createCollectionWithDoc(...);
/// ```
class BaiomyFirestoreRepo {
  BaiomyFirestoreRepo._();

  static final BaiomyFirestoreRepo _instance = BaiomyFirestoreRepo._();

  /// The singleton instance of [BaiomyFirestoreRepo].
  static BaiomyFirestoreRepo get instance => _instance;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // WRITE OPERATIONS
  // ---------------------------------------------------------------------------

  /// Creates or overwrites a document at [collectionName]/[docName].
  Future<void> createCollectionWithDoc({
    required String collectionName,
    required String docName,
    required Map<String, dynamic> data,
  }) async => await _db.collection(collectionName).doc(docName).set(data);

  /// Adds a new document with an auto-generated ID to [collectionName].
  /// Returns the [DocumentReference] of the newly created document.
  Future<DocumentReference<Map<String, dynamic>>> createCollection({
    required String collectionName,
    required Map<String, dynamic> data,
  }) async => await _db.collection(collectionName).add(data);

  /// Creates or overwrites a sub-collection document.
  Future<void> createSubCollectionWithDoc({
    required String firstCollectionName,
    required String secondCollectionName,
    required String firstDocName,
    required String secondDocName,
    required Map<String, dynamic> data,
  }) async => await _db
      .collection(firstCollectionName)
      .doc(firstDocName)
      .collection(secondCollectionName)
      .doc(secondDocName)
      .set(data);

  /// Updates specific fields in [collectionName]/[docName].
  /// Only the provided [data] fields are modified; others remain untouched.
  Future<void> updateData({
    required String collectionName,
    required String docName,
    required Map<String, dynamic> data,
  }) async => await _db.collection(collectionName).doc(docName).update(data);

  /// Updates specific fields in a sub-collection document.
  Future<void> updateSubCollectionDoc({
    required String firstCollectionName,
    required String secondCollectionName,
    required String firstDocName,
    required String secondDocName,
    required Map<String, dynamic> data,
  }) async => await _db
      .collection(firstCollectionName)
      .doc(firstDocName)
      .collection(secondCollectionName)
      .doc(secondDocName)
      .update(data);

  /// Performs multiple write operations atomically using a [WriteBatch].
  ///
  /// Example:
  /// ```dart
  /// await FirestoreRepo.instance.batchWrite((batch, db) {
  ///   batch.set(db.collection('users').doc('u1'), {'name': 'Alice'});
  ///   batch.update(db.collection('posts').doc('p1'), {'likes': 10});
  /// });
  /// ```
  Future<void> batchWrite(
    void Function(WriteBatch batch, FirebaseFirestore db) operations,
  ) async {
    final WriteBatch batch = _db.batch();
    operations(batch, _db);
    await batch.commit();
  }

  /// Runs a Firestore transaction.
  ///
  /// Use this when reads and writes must be atomic and consistent.
  ///
  /// Example:
  /// ```dart
  /// await FirestoreRepo.instance.runTransaction((tx) async {
  ///   final snap = await tx.get(docRef);
  ///   tx.update(docRef, {'count': snap['count'] + 1});
  /// });
  /// ```
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) handler,
  ) async => await _db.runTransaction(handler);

  // ---------------------------------------------------------------------------
  // READ OPERATIONS
  // ---------------------------------------------------------------------------

  /// Fetches all documents from [collectionName].
  Future<QuerySnapshot<Map<String, dynamic>>> getData({
    required String collectionName,
  }) async => await _db.collection(collectionName).get();

  /// Fetches a single document at [collectionName]/[docName].
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocData(
    String collectionName,
    String docName,
  ) async => await _db.collection(collectionName).doc(docName).get();

  /// Fetches all documents from a sub-collection.
  Future<QuerySnapshot<Map<String, dynamic>>> getSubCollectionDocData(
    String firstCollectionName,
    String secondCollectionName,
    String docName,
  ) async => await _db
      .collection(firstCollectionName)
      .doc(docName)
      .collection(secondCollectionName)
      .get();

  /// Fetches a paginated list of documents from [collectionName].
  ///
  /// Pass [lastDocument] to continue from the previous page.
  /// Optionally sort with [orderByField] and control direction with [descending].
  Future<QuerySnapshot<Map<String, dynamic>>> getDataWithPagination({
    required String collectionName,
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    String? orderByField,
    bool descending = true,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection(collectionName);

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.limit(limit).get();
  }

  /// Fetches a paginated list of documents from a sub-collection.
  ///
  /// Pass [lastDocument] to continue from the previous page.
  Future<QuerySnapshot<Map<String, dynamic>>>
  getSubCollectionDocDataWithPagination({
    required String firstCollectionName,
    required String secondCollectionName,
    required String docName,
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    String? orderByField,
    bool descending = true,
  }) async {
    Query<Map<String, dynamic>> query = _db
        .collection(firstCollectionName)
        .doc(docName)
        .collection(secondCollectionName);

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.limit(limit).get();
  }

  /// Queries documents in [collectionName] where [field] matches [value].
  Future<QuerySnapshot<Map<String, dynamic>>> getDataWhere({
    required String collectionName,
    required String field,
    required Object? value,
    String? orderByField,
    bool descending = true,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _db
        .collection(collectionName)
        .where(field, isEqualTo: value);

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    return await query.get();
  }

  /// Checks whether a document exists at [collectionName]/[docName].
  Future<bool> documentExists({
    required String collectionName,
    required String docName,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _db
        .collection(collectionName)
        .doc(docName)
        .get();
    return doc.exists;
  }

  // ---------------------------------------------------------------------------
  // DELETE OPERATIONS
  // ---------------------------------------------------------------------------

  /// Deletes the document at [collectionName]/[documentId].
  Future<void> deleteData({
    required String collectionName,
    required String documentId,
  }) async => await _db.collection(collectionName).doc(documentId).delete();

  /// Deletes a single document inside a sub-collection.
  Future<void> deleteSubCollectionWithDoc({
    required String firstCollectionName,
    required String secondCollectionName,
    required String docName,
    required String subDocId,
  }) async => await _db
      .collection(firstCollectionName)
      .doc(docName)
      .collection(secondCollectionName)
      .doc(subDocId)
      .delete();

  /// Deletes **all** documents inside a sub-collection using a [WriteBatch].
  ///
  /// ⚠️ Firestore does not delete sub-collections automatically.
  /// For very large sub-collections, prefer a Cloud Function instead.
  Future<void> deleteSubCollection({
    required String firstCollectionName,
    required String secondCollectionName,
    required String docName,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection(firstCollectionName)
        .doc(docName)
        .collection(secondCollectionName)
        .get(const GetOptions(source: Source.server));

    final WriteBatch batch = _db.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // STREAM OPERATIONS
  // ---------------------------------------------------------------------------

  /// Returns a real-time stream of a single document.
  Stream<DocumentSnapshot<Map<String, dynamic>>> documentStream({
    required String collectionName,
    required String docName,
  }) => _db.collection(collectionName).doc(docName).snapshots();

  /// Returns a real-time stream of all documents in [collectionName].
  ///
  /// Optionally filter with [whereField] / [whereValue],
  /// sort with [orderByField], or cap the results with [limit].
  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream({
    required String collectionName,
    String? whereField,
    Object? whereValue,
    String? orderByField,
    bool descending = true,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _db.collection(collectionName);

    if (whereField != null && whereValue != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  /// Returns a real-time stream of all documents in a sub-collection.
  Stream<QuerySnapshot<Map<String, dynamic>>> subCollectionStream({
    required String firstCollectionName,
    required String secondCollectionName,
    required String docName,
    String? orderByField,
    bool descending = true,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection(firstCollectionName)
        .doc(docName)
        .collection(secondCollectionName);

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }
}
