import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// A professional, singleton-based Firebase Storage repository.
///
/// Mirrors the patterns used in [BaiomyAuthRepo] and [BaiomyFirestoreRepo].
///
/// Usage:
/// ```dart
/// final url = await BaiomyStorageRepo.instance.uploadFile(
///   path: 'users/uid123/avatar.jpg',
///   file: File('/local/path/avatar.jpg'),
/// );
/// ```
class BaiomyStorageRepo {
  BaiomyStorageRepo._();

  static final BaiomyStorageRepo _instance = BaiomyStorageRepo._();

  /// The singleton instance of [BaiomyStorageRepo].
  static BaiomyStorageRepo get instance => _instance;

  FirebaseStorage get _storage => FirebaseStorage.instance;

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  /// Returns a [Reference] for the given [path].
  Reference _ref(String path) => _storage.ref(path);

  // ---------------------------------------------------------------------------
  // UPLOAD OPERATIONS
  // ---------------------------------------------------------------------------

  /// Uploads a [File] to [path] and returns its public download URL.
  ///
  /// Optionally provide [metadata] (e.g. content type, cache control).
  ///
  /// Throws [FirebaseException] on failure — handle in the provider/caller.
  ///
  /// Example:
  /// ```dart
  /// final url = await BaiomyStorageRepo.instance.uploadFile(
  ///   path: 'users/$uid/avatar.jpg',
  ///   file: File('/local/avatar.jpg'),
  ///   metadata: SettableMetadata(contentType: 'image/jpeg'),
  /// );
  /// ```
  Future<String> uploadFile({
    required String path,
    required File file,
    SettableMetadata? metadata,
  }) async {
    final UploadTask task = _ref(path).putFile(file, metadata);
    final TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  /// Uploads raw [bytes] to [path] and returns its public download URL.
  ///
  /// Useful for uploading in-memory data (e.g. cropped images, generated PDFs).
  ///
  /// Throws [FirebaseException] on failure — handle in the provider/caller.
  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
    SettableMetadata? metadata,
  }) async {
    final UploadTask task = _ref(path).putData(bytes, metadata);
    final TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  /// Uploads a file from a [fileUrl] string to [path] and returns the
  /// public download URL.
  ///
  /// Useful for uploading files accessible via a local URI or a string path.
  ///
  /// Throws [FirebaseException] on failure — handle in the provider/caller.
  Future<String> uploadFromString({
    required String path,
    required String fileUrl,
    PutStringFormat format = PutStringFormat.raw,
    SettableMetadata? metadata,
  }) async {
    final UploadTask task = _ref(
      path,
    ).putString(fileUrl, format: format, metadata: metadata);
    final TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  /// Uploads a [File] and exposes a [TaskSnapshot] stream to track progress.
  ///
  /// Listen to the stream to update a progress bar, then `await` the
  /// returned [UploadTask] for the final [TaskSnapshot].
  ///
  /// Example:
  /// ```dart
  /// final task = BaiomyStorageRepo.instance.uploadFileWithProgress(
  ///   path: 'videos/intro.mp4',
  ///   file: videoFile,
  /// );
  /// task.snapshotEvents.listen((snapshot) {
  ///   final progress = snapshot.bytesTransferred / snapshot.totalBytes;
  ///   print('${(progress * 100).toStringAsFixed(1)} %');
  /// });
  /// final snapshot = await task;
  /// final url = await snapshot.ref.getDownloadURL();
  /// ```
  UploadTask uploadFileWithProgress({
    required String path,
    required File file,
    SettableMetadata? metadata,
  }) => _ref(path).putFile(file, metadata);

  // ---------------------------------------------------------------------------
  // READ OPERATIONS
  // ---------------------------------------------------------------------------

  /// Returns the public download URL for the file at [path].
  ///
  /// Throws [FirebaseException] if the file does not exist.
  Future<String> getDownloadUrl({required String path}) async =>
      await _ref(path).getDownloadURL();

  /// Returns the [FullMetadata] for the file at [path].
  ///
  /// Useful for reading content type, size, creation time, custom metadata, etc.
  ///
  /// Throws [FirebaseException] if the file does not exist.
  Future<FullMetadata> getMetadata({required String path}) async =>
      await _ref(path).getMetadata();

  /// Downloads the file at [path] into memory and returns its bytes.
  ///
  /// Pass [maxSize] (in bytes) to guard against unexpectedly large downloads.
  /// Defaults to 10 MB.
  ///
  /// Throws [FirebaseException] on failure — handle in the provider/caller.
  Future<Uint8List?> downloadBytes({
    required String path,
    int maxSize = 10 * 1024 * 1024,
  }) async => await _ref(path).getData(maxSize);

  /// Lists all items (files) directly inside a storage [path].
  ///
  /// Returns a [ListResult] containing [items] (files) and [prefixes]
  /// (sub-folders). Use [listAll] to recurse into sub-folders.
  ///
  /// Example:
  /// ```dart
  /// final result = await BaiomyStorageRepo.instance.listItems(
  ///   path: 'users/$uid',
  /// );
  /// for (final ref in result.items) {
  ///   print(ref.name);
  /// }
  /// ```
  Future<ListResult> listItems({required String path}) async =>
      await _ref(path).list();

  /// Recursively lists **all** items under [path], including sub-folders.
  ///
  /// ⚠️ Avoid using this on large directories — prefer [listItemsPaginated]
  /// for better performance and cost control.
  Future<ListResult> listAll({required String path}) async =>
      await _ref(path).listAll();

  /// Lists items inside [path] with pagination support.
  ///
  /// Pass [pageToken] (from a previous [ListResult.nextPageToken]) to fetch
  /// the next page.
  ///
  /// Example:
  /// ```dart
  /// final first = await BaiomyStorageRepo.instance.listItemsPaginated(
  ///   path: 'photos',
  ///   maxResults: 20,
  /// );
  /// final second = await BaiomyStorageRepo.instance.listItemsPaginated(
  ///   path: 'photos',
  ///   maxResults: 20,
  ///   pageToken: first.nextPageToken,
  /// );
  /// ```
  Future<ListResult> listItemsPaginated({
    required String path,
    int maxResults = 20,
    String? pageToken,
  }) async => await _ref(
    path,
  ).list(ListOptions(maxResults: maxResults, pageToken: pageToken));

  /// Checks whether a file exists at [path].
  ///
  /// Returns `true` if the file exists, `false` if it does not.
  Future<bool> fileExists({required String path}) async {
    try {
      await _ref(path).getMetadata();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return false;
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE OPERATIONS
  // ---------------------------------------------------------------------------

  /// Updates (replaces) the file at [path] with a new [File].
  ///
  /// Internally calls [uploadFile]; the old file is overwritten.
  /// Returns the new public download URL.
  Future<String> updateFile({
    required String path,
    required File newFile,
    SettableMetadata? metadata,
  }) => uploadFile(path: path, file: newFile, metadata: metadata);

  /// Updates (replaces) the file at [path] with new [bytes].
  ///
  /// Internally calls [uploadBytes]; the old file is overwritten.
  /// Returns the new public download URL.
  Future<String> updateBytes({
    required String path,
    required Uint8List newBytes,
    SettableMetadata? metadata,
  }) => uploadBytes(path: path, bytes: newBytes, metadata: metadata);

  /// Updates only the [metadata] of the file at [path] without re-uploading
  /// the file itself.
  ///
  /// Throws [FirebaseException] if the file does not exist.
  Future<FullMetadata> updateMetadata({
    required String path,
    required SettableMetadata metadata,
  }) async => await _ref(path).updateMetadata(metadata);

  // ---------------------------------------------------------------------------
  // DELETE OPERATIONS
  // ---------------------------------------------------------------------------

  /// Deletes the file at [path].
  ///
  /// Throws [FirebaseException] on failure — handle in the provider/caller.
  Future<void> deleteFile({required String path}) async =>
      await _ref(path).delete();

  /// Deletes all files directly inside [path] (non-recursive).
  ///
  /// If you need to delete sub-folders too, use [deleteAll].
  ///
  /// ⚠️ Firebase Storage has no atomic bulk-delete — each file is deleted
  /// individually. For very large directories prefer a Cloud Function.
  Future<void> deleteFolder({required String path}) async {
    final ListResult result = await _ref(path).listAll();
    await Future.wait(result.items.map((ref) => ref.delete()));
  }

  /// Recursively deletes **all** files and sub-folders under [path].
  ///
  /// ⚠️ Firebase Storage has no atomic bulk-delete — each file is deleted
  /// individually. For very large trees prefer a Cloud Function.
  Future<void> deleteAll({required String path}) async {
    final ListResult result = await _ref(path).listAll();

    await Future.wait(<Future<void>>[
      // Delete all files at this level
      ...result.items.map((ref) => ref.delete()),
      // Recursively delete sub-folders
      ...result.prefixes.map((prefix) => deleteAll(path: prefix.fullPath)),
    ]);
  }
}
