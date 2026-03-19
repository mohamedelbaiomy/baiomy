/// Immutable value object returned by [PasswordHasher.hash].
///
/// The [combined] string (`iterations:saltBase64:hashBase64`) is what you
/// store in Firestore. The original password **cannot** be recovered from it.
class HashedPassword {
  /// Internal constructor used by [PasswordHasher.hash] to build this object.
  const HashedPassword.create({
    required this.hash,
    required this.salt,
    required this.iterations,
    required this.combined,
  });

  /// Parses a [combined] string produced by [PasswordHasher.hash].
  ///
  /// Use this to reconstruct a [HashedPassword] from a value you read back
  /// from Firestore before passing it to [PasswordHasher.verify].
  factory HashedPassword.fromCombined(String combined) {
    final parts = combined.split(':');
    if (parts.length != 3) {
      throw ArgumentError(
        'Invalid HashedPassword format. '
        'Expected "iterations:saltBase64:hashBase64", got: "$combined"',
      );
    }
    final iterations = int.tryParse(parts[0]);
    if (iterations == null) {
      throw ArgumentError(
          'Iteration count is not a valid integer: ${parts[0]}');
    }
    return HashedPassword.create(
      iterations: iterations,
      salt: parts[1],
      hash: parts[2],
      combined: combined,
    );
  }

  /// The PBKDF2-derived key, Base64-encoded.
  final String hash;

  /// The random salt used during derivation, Base64-encoded.
  ///
  /// A fresh 32-byte salt is generated per call — two hashes of the same
  /// password always produce different output.
  final String salt;

  /// The PBKDF2 iteration count used.
  ///
  /// Stored inside [combined] so [PasswordHasher.verify] can reproduce the
  /// exact derivation even after you raise the default iteration count.
  final int iterations;

  /// A portable string: `iterations:saltBase64:hashBase64`.
  ///
  /// **This is what you store in Firestore.**
  ///
  /// ```json
  /// { "passwordHash": "310000:saltBase64==:hashBase64==" }
  /// ```
  final String combined;

  @override
  String toString() => combined;
}
