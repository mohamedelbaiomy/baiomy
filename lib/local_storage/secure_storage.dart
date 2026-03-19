import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_exception.dart';

/// A singleton wrapper around [FlutterSecureStorage] that provides typed
/// read / write / update / delete / clear operations with built-in error
/// handling.
///
/// All data is encrypted at rest using the platform's secure keychain
/// (Keychain on iOS, Keystore on Android, libsecret on Linux).
///
/// **Supported types:** `String`, `bool`, `int`, `double`, and any
/// JSON-serialisable object via [setObject] / [getObject].
///
/// Usage:
/// ```dart
/// await BaiomySecureStorage.instance.setString('access_token', 'abc123');
/// final token = await BaiomySecureStorage.instance.getString('access_token');
/// ```
class BaiomySecureStorage {
  BaiomySecureStorage._()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  /// The single instance of [SecureStorage].
  static final BaiomySecureStorage instance = BaiomySecureStorage._();

  final FlutterSecureStorage _storage;

  // ─── String ────────────────────────────────────────────────────────────────

  /// Encrypts and saves a [String] value under [key].
  ///
  /// If the key already exists, its value is overwritten.
  Future<void> setString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to set String',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Reads and returns the decrypted [String] stored under [key].
  ///
  /// Returns [defaultValue] (default `null`) if the key does not exist.
  Future<String?> getString(String key, {String? defaultValue}) async {
    try {
      return await _storage.read(key: key) ?? defaultValue;
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to get String',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── Bool ──────────────────────────────────────────────────────────────────

  /// Encrypts and saves a [bool] value (stored as `"true"` / `"false"`).
  Future<void> setBool(String key, {required bool value}) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to set bool',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Returns the stored [bool], or [defaultValue] if the key does not exist.
  Future<bool?> getBool(String key, {bool? defaultValue}) async {
    try {
      final raw = await _storage.read(key: key);
      if (raw == null) return defaultValue;
      return raw == 'true';
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to get bool',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── Int ───────────────────────────────────────────────────────────────────

  /// Encrypts and saves an [int] value.
  Future<void> setInt(String key, int value) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to set int',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Returns the stored [int], or [defaultValue] if the key does not exist.
  Future<int?> getInt(String key, {int? defaultValue}) async {
    try {
      final raw = await _storage.read(key: key);
      if (raw == null) return defaultValue;
      return int.tryParse(raw) ?? defaultValue;
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to get int',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── Double ────────────────────────────────────────────────────────────────

  /// Encrypts and saves a [double] value.
  Future<void> setDouble(String key, double value) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to set double',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Returns the stored [double], or [defaultValue] if the key does not exist.
  Future<double?> getDouble(String key, {double? defaultValue}) async {
    try {
      final raw = await _storage.read(key: key);
      if (raw == null) return defaultValue;
      return double.tryParse(raw) ?? defaultValue;
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to get double',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── JSON Object ───────────────────────────────────────────────────────────

  /// Serialises [value] to JSON, encrypts, and saves it under [key].
  Future<void> setObject(String key, Map<String, dynamic> value) async {
    try {
      await _storage.write(key: key, value: jsonEncode(value));
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to set Object',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Reads, decrypts, and decodes a JSON object stored under [key].
  ///
  /// Returns `null` if the key does not exist or the value cannot be parsed.
  Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final raw = await _storage.read(key: key);
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to get Object',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── Update ────────────────────────────────────────────────────────────────

  /// Updates an existing [String] key with a new value.
  ///
  /// Throws [StorageException] if the key does not exist.
  Future<void> updateString(String key, String newValue) async {
    await _assertExists(key);
    await setString(key, newValue);
  }

  /// Updates an existing [bool] key with a new value.
  Future<void> updateBool(String key, {required bool newValue}) async {
    await _assertExists(key);
    await setBool(key, value: newValue);
  }

  /// Updates an existing [int] key with a new value.
  Future<void> updateInt(String key, int newValue) async {
    await _assertExists(key);
    await setInt(key, newValue);
  }

  /// Updates an existing [double] key with a new value.
  Future<void> updateDouble(String key, double newValue) async {
    await _assertExists(key);
    await setDouble(key, newValue);
  }

  /// Updates an existing JSON object by merging [patch] into the stored value.
  ///
  /// Only the keys present in [patch] are overwritten; all other keys survive.
  Future<void> patchObject(String key, Map<String, dynamic> patch) async {
    await _assertExists(key);
    final existing = await getObject(key) ?? {};
    existing.addAll(patch);
    await setObject(key, existing);
  }

  // ─── Remove / Delete ───────────────────────────────────────────────────────

  /// Removes and destroys the value stored under [key].
  ///
  /// Does nothing if the key does not exist.
  Future<void> remove(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to remove key',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Removes a list of keys in a single call.
  Future<void> removeMany(List<String> keys) async {
    try {
      await Future.wait(keys.map((k) => _storage.delete(key: k)));
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to remove multiple keys',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Deletes ALL keys managed by [FlutterSecureStorage].
  ///
  /// ⚠️ This is irreversible – all encrypted values will be permanently lost.
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to clear secure storage',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── Utility ───────────────────────────────────────────────────────────────

  /// Returns `true` if [key] exists in the secure store.
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to check key existence',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Returns all key–value pairs currently stored.
  Future<Map<String, String>> getAll() async {
    try {
      return await _storage.readAll();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read all keys',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Returns all stored keys.
  Future<Set<String>> getKeys() async {
    final all = await getAll();
    return all.keys.toSet();
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  Future<void> _assertExists(String key) async {
    final exists = await containsKey(key);
    if (!exists) {
      throw StorageException(
        message: 'Cannot update a key that does not exist. Use set* instead.',
        key: key,
      );
    }
  }
}
