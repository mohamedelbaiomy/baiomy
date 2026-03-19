/// A unified exception thrown by all storage operations in [baiomy-local_storage].
/// Wraps the original error and stack trace for easier debugging.
class StorageException implements Exception {
  const StorageException({
    required this.message,
    this.key,
    this.cause,
    this.stackTrace,
  });

  /// Human-readable description of what went wrong.
  final String message;

  /// The storage key involved in the failed operation, if applicable.
  final String? key;

  /// The original exception that caused this error.
  final Object? cause;

  /// The original stack trace, if available.
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buffer = StringBuffer('StorageException: $message');
    if (key != null) buffer.write(' [key: $key]');
    if (cause != null) buffer.write('\nCaused by: $cause');
    return buffer.toString();
  }
}
