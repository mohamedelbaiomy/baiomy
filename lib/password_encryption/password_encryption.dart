import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart';
import 'crypto_exception.dart';
import 'encrypted_payload.dart';

/// A singleton for **two-way AES-256-CBC encryption and decryption**.
///
/// Use this when you need to recover the original value later —
/// for example, encrypting a password before storing it in Firestore
/// and decrypting it when you need to authenticate against a service.
///
/// If you only need to *verify* a password at login (and never read it back),
/// use [PasswordHasher] instead — one-way hashing is more secure for that case.
///
/// ---
///
/// ## Firestore workflow
///
/// ```dart
/// // ── On registration (void main) ──────────────────────────────────────────────────────
/// await BaiomyPasswordEncryption.instance.configure(keyPhrase: 'load-from-secure-vault');
///
/// final payload = BaiomyPasswordEncryption.instance.encrypt(passwordCtrl.text);
///
/// await FirebaseFirestore.instance.collection('users').doc(uid).set({
///   'password': payload.combined,   // "ivBase64:ciphertextBase64"
/// });
///
/// // ── On login / when you need the original password ───────────────────────
/// final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
/// final plain = BaiomyPasswordEncryption.instance.decrypt(doc['password'] as String);
/// ```
///
/// ## Key management
///
/// Call [configure] **once** before first use (e.g. in `main()`), passing a
/// passphrase you load from a secure vault, environment variable, or
/// [flutter_secure_storage]. Never hardcode it.
///
/// ```dart
/// await BaiomyPasswordEncryption.instance.configure(keyPhrase: 'from-your-vault');
/// ```
///
/// If [configure] is never called, [defaultKeyPhrase] is used automatically
/// so development keeps working — but always override it before shipping.
class BaiomyPasswordEncryption {
  BaiomyPasswordEncryption._();

  /// The single instance.
  static final BaiomyPasswordEncryption instance = BaiomyPasswordEncryption._();

  // ─── Key configuration ─────────────────────────────────────────────────────

  /// Fallback key phrase used when [configure] has never been called.
  ///
  /// ⚠️ Replace this before shipping. Ideally load the real passphrase from a
  /// secure vault and call [configure] in `main()`.
  static const String defaultKeyPhrase =
      'crypto_kit_default_phrase_CHANGE_ME_before_prod';

  /// A fixed, app-specific string mixed into the AES key derivation.
  ///
  /// Not secret, but must stay **constant** across all app versions — changing
  /// it will invalidate every existing ciphertext in your database.
  static const String _aesKeySalt = 'CK_AES_KEY_SALT_v1';

  /// PBKDF2 iterations used to derive the AES-256 key from the passphrase.
  ///
  /// Done once on startup; has no impact on per-encrypt performance.
  static const int _keyDerivationIterations = 100000;

  late enc.Key _aesKey;
  bool _configured = false;

  /// Derives and caches the AES-256 key from [keyPhrase].
  ///
  /// Call once in `main()` before any encrypt/decrypt operations.
  /// Safe to call again to rotate the key — but note: data encrypted with
  /// the old key can only be decrypted with the old key.
  void configure({required String keyPhrase}) {
    _aesKey = _deriveKey(keyPhrase);
    _configured = true;
  }

  enc.Key get _key {
    if (!_configured) {
      _aesKey = _deriveKey(defaultKeyPhrase);
      _configured = true;
    }
    return _aesKey;
  }

  // ─── Encrypt ───────────────────────────────────────────────────────────────

  /// Encrypts [plainText] with AES-256-CBC and a fresh random 16-byte IV.
  ///
  /// Every call produces a **different** ciphertext even for the same input,
  /// because the IV is re-randomised each time.
  ///
  /// The returned [EncryptedPayload.combined] string is what you store in
  /// Firestore — format: `ivBase64:ciphertextBase64`.
  ///
  /// Throws [CryptoException] if [plainText] is empty or encryption fails.
  EncryptedPayload encrypt(String plainText) {
    if (plainText.isEmpty) {
      throw const CryptoException(message: 'Cannot encrypt an empty string.');
    }
    try {
      final iv = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: iv);

      return EncryptedPayload.create(
        iv: iv.base64,
        cipherText: encrypted.base64,
        combined: '${iv.base64}:${encrypted.base64}',
      );
    } catch (e, st) {
      throw CryptoException(
        message: 'Encryption failed.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── Decrypt ───────────────────────────────────────────────────────────────

  /// Decrypts a [combined] string produced by [encrypt].
  ///
  /// [combined] must be in the format `ivBase64:ciphertextBase64` — exactly
  /// what [EncryptedPayload.combined] contains and what you stored in Firestore.
  ///
  /// Throws [CryptoException] if the format is invalid, the key is wrong,
  /// or the data has been tampered with.
  String decrypt(String combined) {
    if (combined.isEmpty) {
      throw const CryptoException(message: 'Cannot decrypt an empty string.');
    }
    try {
      final payload = EncryptedPayload.fromCombined(combined);
      final iv = enc.IV.fromBase64(payload.iv);
      final cipherText = enc.Encrypted.fromBase64(payload.cipherText);
      final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
      return encrypter.decrypt(cipherText, iv: iv);
    } on ArgumentError catch (e) {
      throw CryptoException(message: e.message.toString(), cause: e);
    } catch (e, st) {
      throw CryptoException(
        message:
            'Decryption failed. '
            'The key may be wrong or the data has been tampered with.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Convenience: encrypts [plainText] and returns the combined string directly.
  ///
  /// Equivalent to `BaiomyPasswordEncryption.instance.encrypt(plain).combined`.
  String encryptToString(String plainText) => encrypt(plainText).combined;

  // ─── Utility ───────────────────────────────────────────────────────────────

  /// Returns `true` if [value] is a valid `ivBase64:ciphertextBase64` string.
  bool isValidPayload(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return false;
    try {
      base64Decode(parts[0]);
      base64Decode(parts[1]);
      return parts[0].isNotEmpty && parts[1].isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  enc.Key _deriveKey(String passphrase) {
    final derived = _pbkdf2(
      password: passphrase,
      salt: utf8.encode(_aesKeySalt),
      iterations: _keyDerivationIterations,
      keyLength: 32, // 256 bits
    );
    return enc.Key(derived);
  }

  Uint8List _pbkdf2({
    required String password,
    required List<int> salt,
    required int iterations,
    required int keyLength,
  }) {
    final params = Pbkdf2Parameters(
      Uint8List.fromList(salt),
      iterations,
      keyLength,
    );
    final kdf = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))..init(params);
    return kdf.process(Uint8List.fromList(utf8.encode(password)));
  }
}
