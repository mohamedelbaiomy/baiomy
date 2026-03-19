import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'storage_exception.dart';

/// A singleton wrapper around [SharedPreferences] that provides typed
/// get / set / update / remove / clear operations with built-in error handling.
///
/// **Supported types:** `String`, `int`, `double`, `bool`, `List<String>`,
/// and any JSON-serialisable object via [setObject] / [getObject].
///
/// Usage:
/// ```dart
/// await BaiomySharedPrefs.instance.init();
/// await BaiomySharedPrefs.instance.setString('username', 'Ahmad');
/// final name = await BaiomySharedPrefs.instance.getString('username');
/// ```
class BaiomySharedPrefs {
  BaiomySharedPrefs._();

  /// The single instance of [BaiomySharedPrefs].
  static final BaiomySharedPrefs instance = BaiomySharedPrefs._();

  SharedPreferences? _prefs;

  // ─── Initialisation ────────────────────────────────────────────────────────

  /// Must be called once before using any other method.
  ///
  /// Safe to call multiple times – subsequent calls are no-ops.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _store {
    if (_prefs == null) {
      throw const StorageException(
        message:
            'BaiomySharedPrefs is not initialised. Call BaiomySharedPrefs.instance.init() first.',
      );
    }
    return _prefs!;
  }

  // ─── String ────────────────────────────────────────────────────────────────

  /// Saves or overwrites a [String] value.
  Future<void> setString(String key, String value) async {
    try {
      await _store.setString(key, value);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to set String',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Returns the stored [String], or [defaultValue] if not found.
  String? getString(String key, {String? defaultValue}) {
    try {
      return _store.getString(key) ?? defaultValue;
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to get String',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── Int ───────────────────────────────────────────────────────────────────

  /// Saves or overwrites an [int] value.
  Future<void> setInt(String key, int value) async {
    try {
      await _store.setInt(key, value);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to set int',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Returns the stored [int], or [defaultValue] if not found.
  int? getInt(String key, {int? defaultValue}) {
    try {
      return _store.getInt(key) ?? defaultValue;
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

  /// Saves or overwrites a [double] value.
  Future<void> setDouble(String key, double value) async {
    try {
      await _store.setDouble(key, value);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to set double',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Returns the stored [double], or [defaultValue] if not found.
  double? getDouble(String key, {double? defaultValue}) {
    try {
      return _store.getDouble(key) ?? defaultValue;
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to get double',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── Bool ──────────────────────────────────────────────────────────────────

  /// Saves or overwrites a [bool] value.
  Future<void> setBool(String key, {required bool value}) async {
    try {
      await _store.setBool(key, value);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to set bool',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Returns the stored [bool], or [defaultValue] if not found.
  bool? getBool(String key, {bool? defaultValue}) {
    try {
      return _store.getBool(key) ?? defaultValue;
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to get bool',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── List<String> ──────────────────────────────────────────────────────────

  /// Saves or overwrites a `List<String>` value.
  Future<void> setStringList(String key, List<String> value) async {
    try {
      await _store.setStringList(key, value);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to set StringList',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Returns the stored `List<String>`, or [defaultValue] if not found.
  List<String>? getStringList(String key, {List<String>? defaultValue}) {
    try {
      return _store.getStringList(key) ?? defaultValue;
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to get StringList',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── JSON Object ───────────────────────────────────────────────────────────

  /// Serialises [value] to JSON and saves it under [key].
  ///
  /// [value] must be a JSON-serialisable map (e.g. from `toJson()`).
  Future<void> setObject(String key, Map<String, dynamic> value) async {
    try {
      await _store.setString(key, jsonEncode(value));
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to set Object',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Retrieves and decodes a JSON object stored under [key].
  ///
  /// Returns `null` if the key does not exist.
  Map<String, dynamic>? getObject(String key) {
    try {
      final raw = _store.getString(key);
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

  // ─── Update (alias for set* with existence check) ──────────────────────────

  /// Updates an existing key with a new [String] value.
  ///
  /// Throws [StorageException] if the key does not exist yet.
  /// Use [setString] if you want an upsert behaviour.
  Future<void> updateString(String key, String newValue) async {
    _assertExists(key);
    await setString(key, newValue);
  }

  /// Updates an existing key with a new [int] value.
  Future<void> updateInt(String key, int newValue) async {
    _assertExists(key);
    await setInt(key, newValue);
  }

  /// Updates an existing key with a new [double] value.
  Future<void> updateDouble(String key, double newValue) async {
    _assertExists(key);
    await setDouble(key, newValue);
  }

  /// Updates an existing key with a new [bool] value.
  Future<void> updateBool(String key, {required bool newValue}) async {
    _assertExists(key);
    await setBool(key, value: newValue);
  }

  /// Updates an existing JSON object by merging [patch] into the stored value.
  ///
  /// Only the keys present in [patch] are overwritten; other keys are kept.
  Future<void> patchObject(String key, Map<String, dynamic> patch) async {
    _assertExists(key);
    final existing = getObject(key) ?? {};
    existing.addAll(patch);
    await setObject(key, existing);
  }

  // ─── Remove ────────────────────────────────────────────────────────────────

  /// Removes the value stored under [key].
  ///
  /// Does nothing if the key does not exist.
  Future<void> remove(String key) async {
    try {
      await _store.remove(key);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to remove key',
        key: key,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Removes all values from SharedPreferences.
  ///
  /// ⚠️ Use with caution – this wipes everything including third-party keys.
  Future<void> clear() async {
    try {
      await _store.clear();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to clear preferences',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── Utility ───────────────────────────────────────────────────────────────

  /// Returns `true` if [key] exists in the store.
  bool containsKey(String key) => _store.containsKey(key);

  /// Returns all stored keys.
  Set<String> getKeys() => _store.getKeys();

  /// Returns the raw dynamic value for [key], or `null` if not found.
  dynamic get(String key) => _store.get(key);

  // ─── Private helpers ───────────────────────────────────────────────────────

  void _assertExists(String key) {
    if (!containsKey(key)) {
      throw StorageException(
        message: 'Cannot update a key that does not exist. Use set* instead.',
        key: key,
      );
    }
  }
}
