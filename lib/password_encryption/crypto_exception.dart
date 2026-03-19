/// Exception thrown by any operation in [crypto_kit].
class CryptoException implements Exception {
  const CryptoException({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  /// Human-readable description of what went wrong.
  final String message;

  /// The original exception that triggered this error, if any.
  final Object? cause;

  /// The original stack trace, if available.
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buf = StringBuffer('CryptoException: $message');
    if (cause != null) buf.write('\nCaused by: $cause');
    return buf.toString();
  }
}
