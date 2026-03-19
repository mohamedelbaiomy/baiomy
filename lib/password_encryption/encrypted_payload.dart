/// Immutable value object returned by [CryptoKit.encrypt].
///
/// The [combined] string (`ivBase64:ciphertextBase64`) is what you store in
/// Firestore / your database.
class EncryptedPayload {
  /// Internal constructor used by [CryptoKit.encrypt] to build this object.
  const EncryptedPayload.create({
    required this.iv,
    required this.cipherText,
    required this.combined,
  });

  /// Parses a [combined] string produced by [CryptoKit.encrypt].
  ///
  /// Use this to reconstruct an [EncryptedPayload] from a value you read back
  /// from Firestore before passing it to [CryptoKit.decrypt].
  factory EncryptedPayload.fromCombined(String combined) {
    final parts = combined.split(':');
    if (parts.length != 2) {
      throw ArgumentError(
        'Invalid EncryptedPayload format. '
        'Expected "ivBase64:ciphertextBase64", got: "$combined"',
      );
    }
    return EncryptedPayload.create(
      iv: parts[0],
      cipherText: parts[1],
      combined: combined,
    );
  }

  /// The Initialisation Vector, Base64-encoded.
  ///
  /// A fresh IV is generated for every [CryptoKit.encrypt] call — two
  /// encryptions of the same plaintext always produce different output.
  final String iv;

  /// The encrypted value, Base64-encoded.
  final String cipherText;

  /// A portable string: `ivBase64:ciphertextBase64`.
  ///
  /// **This is what you store in Firestore.**
  ///
  /// ```json
  /// { "password": "ivBase64==:ciphertextBase64==" }
  /// ```
  final String combined;

  @override
  String toString() => combined;
}
