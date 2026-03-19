import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'crypto_exception.dart';
import 'hashed_password.dart';

/// A singleton for **one-way PBKDF2-HMAC-SHA256 password hashing**.
///
/// Use this when you only need to *verify* a password at login — you never
/// need the original value back. This is the most secure approach for
/// passwords stored in Firestore.
///
/// If you genuinely need to recover the original password later, use
/// [CryptoKit] for two-way AES encryption instead.
///
/// ---
///
/// ## Firestore workflow
///
/// ```dart
/// // ── On registration ──────────────────────────────────────────────────────
/// final hashed = PasswordHasher.instance.hash(passwordCtrl.text);
///
/// await FirebaseFirestore.instance.collection('users').doc(uid).set({
///   'passwordHash': hashed.combined,  // "310000:saltBase64:hashBase64"
/// });
///
/// // ── On login ─────────────────────────────────────────────────────────────
/// final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
/// final ok = PasswordHasher.instance.verify(
///   password: passwordCtrl.text,
///   combined: doc['passwordHash'] as String,
/// );
/// if (!ok) throw Exception('Wrong password');
/// ```
///
/// ## Why PBKDF2-HMAC-SHA256?
///
/// - **Salt** — a unique 32-byte random salt per password prevents rainbow
///   table and pre-computation attacks.
/// - **Iterations** — 310,000 rounds (OWASP 2023 recommendation for
///   HMAC-SHA256) make brute-force computationally expensive.
/// - **Constant-time comparison** — [verify] uses a timing-safe comparison
///   to prevent timing attacks even if an attacker can measure response times.
class PasswordHasher {
  PasswordHasher._();

  /// The single instance.
  static final PasswordHasher instance = PasswordHasher._();

  /// PBKDF2 iterations — OWASP 2023 recommendation for HMAC-SHA256.
  ///
  /// Increasing this raises the cost for both legitimate users and attackers.
  /// Never decrease it; old hashes store their own iteration count so they
  /// remain verifiable even after you raise this value.
  static const int defaultIterations = 310000;

  /// Salt length in bytes (256 bits).
  static const int _saltLength = 32;

  /// Derived key length in bytes (256 bits).
  static const int _keyLength = 32;

  // ─── Hash ──────────────────────────────────────────────────────────────────

  /// Hashes [password] using PBKDF2-HMAC-SHA256.
  ///
  /// A fresh [_saltLength]-byte random salt is generated on every call, so
  /// hashing the same password twice always produces a different result.
  ///
  /// The returned [HashedPassword.combined] string is what you store in
  /// Firestore — format: `iterations:saltBase64:hashBase64`.
  ///
  /// Throws [CryptoException] if [password] is empty.
  HashedPassword hash(String password) {
    if (password.isEmpty) {
      throw const CryptoException(message: 'Cannot hash an empty password.');
    }
    try {
      final salt = _randomBytes(_saltLength);
      final key = _pbkdf2(
        password: password,
        salt: salt,
        iterations: defaultIterations,
      );

      final saltB64 = base64Encode(salt);
      final hashB64 = base64Encode(key);
      final combined = '$defaultIterations:$saltB64:$hashB64';

      return HashedPassword.create(
        hash: hashB64,
        salt: saltB64,
        iterations: defaultIterations,
        combined: combined,
      );
    } catch (e, st) {
      throw CryptoException(
        message: 'Password hashing failed.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── Verify ────────────────────────────────────────────────────────────────

  /// Verifies [password] against a [combined] string from [hash].
  ///
  /// Returns `true` if the password is correct, `false` otherwise.
  ///
  /// The comparison is **constant-time** — execution time does not reveal
  /// whether the password was almost-right or completely wrong, which
  /// prevents timing attacks.
  ///
  /// The iteration count is read from [combined] itself, so this method
  /// stays correct even for old hashes generated with a lower iteration count.
  ///
  /// Throws [CryptoException] if [combined] is malformed.
  bool verify({required String password, required String combined}) {
    if (password.isEmpty) return false;
    try {
      final stored = HashedPassword.fromCombined(combined);
      final salt = base64Decode(stored.salt);
      final storedHash = base64Decode(stored.hash);

      final candidateHash = _pbkdf2(
        password: password,
        salt: salt,
        iterations: stored.iterations,
      );

      return _constantTimeEquals(storedHash, candidateHash);
    } on ArgumentError catch (e) {
      throw CryptoException(message: e.message.toString(), cause: e);
    } catch (e, st) {
      throw CryptoException(
        message: 'Password verification failed.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── Utility ───────────────────────────────────────────────────────────────

  /// Returns `true` if [value] looks like a valid [HashedPassword.combined].
  bool isValidHash(String value) {
    final parts = value.split(':');
    if (parts.length != 3) return false;
    if (int.tryParse(parts[0]) == null) return false;
    try {
      base64Decode(parts[1]);
      base64Decode(parts[2]);
      return parts[1].isNotEmpty && parts[2].isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  Uint8List _pbkdf2({
    required String password,
    required List<int> salt,
    required int iterations,
  }) {
    final params = Pbkdf2Parameters(
      Uint8List.fromList(salt),
      iterations,
      _keyLength,
    );
    final kdf = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))..init(params);
    return kdf.process(Uint8List.fromList(utf8.encode(password)));
  }

  Uint8List _randomBytes(int length) {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rng.nextInt(256)),
    );
  }

  /// Constant-time byte comparison — prevents timing attacks.
  ///
  /// The XOR loop never short-circuits, so execution time is always
  /// proportional to the byte length, not the position of the first mismatch.
  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}
