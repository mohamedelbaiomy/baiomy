# 🚀 Baiomy

> **Built once, used everywhere.**

A powerful, all-in-one Flutter toolkit for local storage, password encryption, Egyptian ID parsing, input validation, utilities, and widgets — all behind a single import.

```dart
import 'package:baiomy/baiomy.dart';
```

---

## 📦 What's Inside

| Module | Classes / APIs |
|---|---|
| 🗂️ **Local Storage** | `BaiomySharedPrefs` · `BaiomySecureStorage` · `StorageException` |
| 🔐 **Password Encryption** | `BaiomyPasswordEncryption` · `PasswordHasher` · `EncryptedPayload` · `HashedPassword` · `CryptoException` |
| 🌍 **Egyptian ID Parser** | `BaiomyEgyptianIdParser` |
| 🧩 **Extensions** | `BuildContextExtension` · `FormAutoScroll` · `EmailValidator` · `PasswordValidator` · `NotesValidator` · `DomainValidator` |
| 🛠️ **Utils** | `BaiomyInputFormatters` · `inputDecoration()` |
| 🎨 **Widgets** | `AppToasts` · `AvatarGlow` · `ConditionalBuilder` · `CustomSizedBox` · `CustomValueListenable` · `LoadingItem` |

---

## 📥 Installation

```yaml
dependencies:
  baiomy:
    git:
      url: https://github.com/mohamedelbaiomy/baiomy.git
```

```bash
flutter pub get
```

---

## ⚡ Setup — once in `main.dart`

```dart
import 'package:baiomy/baiomy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Required before using BaiomySharedPrefs
  await BaiomySharedPrefs.instance.init();

  // Required before using BaiomyPasswordEncryption
  BaiomyPasswordEncryption.instance.configure(keyPhrase: 'your-secret-phrase');

  runApp(const MyApp());
}
```

---

## 🗂️ Local Storage

### BaiomySharedPrefs

Non-sensitive data — settings, flags, UI state. Backed by **SharedPreferences**.
Reads are **synchronous** after `init()`.

```dart
final prefs = BaiomySharedPrefs.instance;

// ── Write ──────────────────────────────────────────────────────────────
await prefs.setString('theme', 'dark');
await prefs.setInt('launch_count', 1);
await prefs.setBool('onboarding_done', value: true);
await prefs.setDouble('font_size', 16.0);
await prefs.setStringList('tags', ['flutter', 'dart']);
await prefs.setObject('config', {'lang': 'en', 'theme': 'dark'});

// ── Read ───────────────────────────────────────────────────────────────
final theme  = prefs.getString('theme', defaultValue: 'light');
final count  = prefs.getInt('launch_count', defaultValue: 0);
final done   = prefs.getBool('onboarding_done');
final size   = prefs.getDouble('font_size');
final tags   = prefs.getStringList('tags');
final config = prefs.getObject('config');     // Map<String, dynamic>?

// ── Update (key must already exist, throws otherwise) ──────────────────
await prefs.updateString('theme', 'light');
await prefs.updateInt('launch_count', 2);
await prefs.updateBool('onboarding_done', newValue: false);
await prefs.updateDouble('font_size', 18.0);
await prefs.patchObject('config', {'theme': 'light'}); // partial update

// ── Remove ─────────────────────────────────────────────────────────────
await prefs.remove('theme');
await prefs.clear(); // ⚠️ wipes everything

// ── Utility ────────────────────────────────────────────────────────────
prefs.containsKey('theme'); // bool
prefs.getKeys();            // Set<String>
prefs.get('theme');         // dynamic
```

---

### BaiomySecureStorage

Sensitive data — tokens, passwords, PII. Encrypted at rest via platform
**Keychain (iOS)** / **Keystore (Android)**. All reads are `async`.

```dart
final secure = BaiomySecureStorage.instance;

// ── Write ──────────────────────────────────────────────────────────────
await secure.setString('access_token', 'eyJhbGci...');
await secure.setBool('biometrics_enabled', value: true);
await secure.setInt('user_id', 42);
await secure.setDouble('score', 9.5);
await secure.setObject('session', {'expires_at': 1700000000});

// ── Read ───────────────────────────────────────────────────────────────
final token   = await secure.getString('access_token');
final enabled = await secure.getBool('biometrics_enabled');
final uid     = await secure.getInt('user_id');
final session = await secure.getObject('session');

// ── Update (key must already exist, throws otherwise) ──────────────────
await secure.updateString('access_token', 'newToken');
await secure.updateBool('biometrics_enabled', newValue: false);
await secure.updateInt('user_id', 99);
await secure.updateDouble('score', 10.0);
await secure.patchObject('session', {'scope': 'read write'});

// ── Remove ─────────────────────────────────────────────────────────────
await secure.remove('access_token');
await secure.removeMany(['access_token', 'session']); // batch
await secure.clear(); // ⚠️ wipes everything

// ── Utility ────────────────────────────────────────────────────────────
await secure.containsKey('access_token'); // Future<bool>
await secure.getKeys();                   // Future<Set<String>>
await secure.getAll();                    // Future<Map<String, String>>
```

---

## 🔐 Password Encryption

### Which one should I use?

```
Need to recover the original password later?  →  BaiomyPasswordEncryption  (AES-256 two-way)
Just need to verify it at login?              →  PasswordHasher            (PBKDF2 one-way)
```

---

### BaiomyPasswordEncryption — Two-way AES-256-CBC

Encrypts any string and lets you get the original value back.
Every encrypt call produces a **different** ciphertext even for the same input
because a fresh random IV is generated each time.

**Configure once in `main()`:**
```dart
BaiomyPasswordEncryption.instance.configure(keyPhrase: 'your-secret-phrase');
```

**Encrypt & store in Firestore:**
```dart
final payload = BaiomyPasswordEncryption.instance.encrypt(passwordController.text);

// payload.combined   → "ivBase64:ciphertextBase64"  ← store this
// payload.iv         → IV used, Base64-encoded
// payload.cipherText → encrypted value, Base64-encoded

await FirebaseFirestore.instance.collection('users').doc(uid).set({
  'password': payload.combined,
});
```

**Decrypt — recover the original:**
```dart
final doc  = await FirebaseFirestore.instance.collection('users').doc(uid).get();
final pass = BaiomyPasswordEncryption.instance.decrypt(doc['password'] as String);
```

**Convenience — encrypt directly to a string:**
```dart
final stored = BaiomyPasswordEncryption.instance.encryptToString(passwordController.text);
```

**Validate a stored value:**
```dart
BaiomyPasswordEncryption.instance.isValidPayload(stored); // bool
```

---

### PasswordHasher — One-way PBKDF2-HMAC-SHA256

Best for login systems where you never need the original password back.
Uses **310,000 iterations** (OWASP 2023) + a unique 32-byte random salt.
Uses **constant-time comparison** to prevent timing attacks.
The original password **cannot** be recovered — ever.

**Hash on registration:**
```dart
final hashed = PasswordHasher.instance.hash(passwordController.text);

// hashed.combined   → "310000:saltBase64:hashBase64"  ← store this
// hashed.hash       → derived key, Base64-encoded
// hashed.salt       → random salt, Base64-encoded
// hashed.iterations → 310000

await FirebaseFirestore.instance.collection('users').doc(uid).set({
  'passwordHash': hashed.combined,
});
```

**Verify on login:**
```dart
final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

final ok = PasswordHasher.instance.verify(
  password: passwordController.text,
  combined: doc['passwordHash'] as String,
);

if (!ok) throw Exception('Wrong password');
```

**Validate a stored hash string:**
```dart
PasswordHasher.instance.isValidHash(storedValue); // bool
```

---

## 🌍 Egyptian ID Parser

Parse and extract full information from a 14-digit Egyptian National ID.

```dart
final parser = BaiomyEgyptianIdParser('29901011234567');

print(parser.birthDate);    // e.g. "1999-01-01"
print(parser.governorate);  // e.g. "Cairo"
print(parser.gender);       // e.g. "Male"
print(parser.age);          // Age object
```

---

## 🧩 Extensions

### BuildContextExtension

```dart
// Navigation
context.pop();
context.popWithValue('result');
await context.mayBePop(); // Future<bool>

// Screen dimensions
final width  = context.screenWidth;   // double
final height = context.screenHeight;  // double
final dpr    = context.devicePixelRatio; // double
```

### FormAutoScroll

Automatically scrolls to the first invalid field on form submission.
Called as an extension on `GlobalKey<FormState>`:

```dart
final _formKey = GlobalKey<FormState>();

// Instead of _formKey.currentState!.validate()
final isValid = _formKey.validateAndScroll(); // bool
// Scrolls to the first field with an error if invalid
```

### EmailValidator

```dart
'user@gmail.com'.isValidEmail();          // true
'not-an-email'.isValidEmail();            // false
'user@uni.edu.eg'.isAcademicEmail();      // true
'user@company.com'.isCorporateEmail();    // true
'test@test.com'.hasSuspiciousEmailPattern(); // true
'user@gmail.com'.capitalize();            // 'User@gmail.com'
```

### PasswordValidator

```dart
'MyPass1!'.hasUppercase();                // true
'MyPass1!'.hasLowercase();                // true
'MyPass1!'.hasDigit();                    // true
'MyPass1!'.hasSpecialCharacter();         // true
'MyPass1!'.hasWhitespace();              // false
'MyPass1!'.hasMixedCase();               // true
'MyPass1!'.hasMultipleDigits();          // false
'MyPass1!'.hasMultipleSpecialChars();    // false
'password123'.isCommonPassword();         // true
'abc123'.hasSequentialCharacters();       // true
'aaabbb'.hasExcessiveRepeatedCharacters(); // true
```

### NotesValidator

```dart
'spam content'.hasInappropriateContent();       // true
'Hello!!!!!!'.hasExcessiveSpecialCharacters();  // true
'aaaaaaa note'.hasExcessiveRepeatedText();      // true
'Study near the library'.hasMeaningfulContent(); // true
'Valid Note.'.hasProperStructure();             // true
'Room 101 level 2'.hasSpecificDetails();        // true
'Near the faculty building'.hasLocationDetails(); // true
'Near university campus'.hasEducationalContext(); // true
'Hello world'.getWordCount();                   // 2
'Hello world'.getCharacterCountWithoutSpaces(); // 10
```

### DomainValidator

```dart
'flutter.dev'.isDomainValid();          // true
'mail.uni.edu.eg'.isDomainValid();      // true
'invalid'.isDomainValid();              // false
'مثال.com'.isInternationalDomain();    // true
```

---

## 🛠️ Utils

### BaiomyInputFormatters

Apply as `inputFormatters` on any `TextFormField`:

```dart
// ── Ready-made formatters ──────────────────────────────────────────────
TextFormField(inputFormatters: BaiomyInputFormatters.nameField);
TextFormField(inputFormatters: BaiomyInputFormatters.phoneField);
TextFormField(inputFormatters: BaiomyInputFormatters.emailField);
TextFormField(inputFormatters: BaiomyInputFormatters.passwordField);
TextFormField(inputFormatters: BaiomyInputFormatters.notesField);
TextFormField(inputFormatters: BaiomyInputFormatters.cleanText);
TextFormField(inputFormatters: BaiomyInputFormatters.username);
TextFormField(inputFormatters: BaiomyInputFormatters.creditCard);
TextFormField(inputFormatters: BaiomyInputFormatters.currency);

// ── Basic formatters ───────────────────────────────────────────────────
BaiomyInputFormatters.denyEmojis
BaiomyInputFormatters.numbersOnly
BaiomyInputFormatters.lettersOnly
BaiomyInputFormatters.alphanumericOnly
BaiomyInputFormatters.phoneNumberSafe
BaiomyInputFormatters.emailSafe
BaiomyInputFormatters.urlSafe
BaiomyInputFormatters.passwordSafe
BaiomyInputFormatters.denyProfanity

// ── With length limits ─────────────────────────────────────────────────
BaiomyInputFormatters.lengthLimit(10)
BaiomyInputFormatters.nameWithLength(35)      // default 35
BaiomyInputFormatters.phoneWithLength(11)     // default 11
BaiomyInputFormatters.notesWithLength(500)    // default 500

// ── Custom ─────────────────────────────────────────────────────────────
BaiomyInputFormatters.customDeny([RegExp(r'[xyz]')], allowEmojis: false)
BaiomyInputFormatters.customAllow([RegExp(r'[0-9]')])
BaiomyInputFormatters.caseFormatter(uppercase: true)

// ── Validation helpers (no TextFormField needed) ───────────────────────
BaiomyInputFormatters.containsEmojis('hello 😊');      // true
BaiomyInputFormatters.isNumericOnly('12345');           // true
BaiomyInputFormatters.containsProfanity('some text');  // false
BaiomyInputFormatters.getCleanCharacterCount('hi 😊'); // 3
```

### inputDecoration()

A global function that returns a styled `InputDecoration`:

```dart
// Underline style (default)
TextFormField(
  decoration: inputDecoration(
    'Enter your email',
    Theme.of(context),
    suffixIcon: const Icon(Icons.email),
    helperText: 'We will never share your email',
  ),
)

// Outlined style
TextFormField(
  decoration: inputDecoration(
    'Enter your password',
    Theme.of(context),
    isOutlined: true,
    suffixIcon: const Icon(Icons.lock),
  ),
)
```

---

## 🎨 Widgets

> Widget files are in `lib/widgets/`. Refer to each file for full constructor details as the APIs depend on your local implementation.

### BaiomyToast
Quick snackbar-style notifications.

### BaiomyAvatarGlow
Avatar widget with an animated glow effect.

### BaiomyConditionalBuilder
Renders different widgets based on a condition.

### CustomSizedBox
Convenient spacing widget using extension.

### BaiomyValueListenableBuilder2
Reactive widget that rebuilds when a `ValueListenable` changes.

### BaiomyLoadingItem
Loading skeleton / overlay widget (from `widgets/loading/loading_item.dart`).

---

## 🛡️ Error Handling

Every module throws its own typed exception — never a raw platform error.

```dart
// Storage errors
try {
  await BaiomySecureStorage.instance.updateString('missing_key', 'value');
} on StorageException catch (e) {
  print(e.message);    // 'Cannot update a key that does not exist.'
  print(e.key);        // 'missing_key'
  print(e.cause);      // original platform error
  print(e.stackTrace); // original stack trace
}

// Crypto errors
try {
  BaiomyPasswordEncryption.instance.decrypt('bad_format');
} on CryptoException catch (e) {
  print(e.message); // 'Decryption failed. The key may be wrong...'
  print(e.cause);   // original error
}
```

---

## 📁 Package Structure

```
lib/
├── egyptian_id_parser/
│   ├── impl/
│   ├── models/
│   ├── repo/
│   └── country_id_parser_base.dart    → BaiomyEgyptianIdParser
├── extensions/
│   ├── validator/
│   │   ├── domain_validator.dart      → DomainValidator (extension)
│   │   ├── email_validator.dart       → EmailValidator (extension)
│   │   ├── notes_validator.dart       → NotesValidator (extension)
│   │   └── password_validator.dart    → PasswordValidator (extension)
│   ├── build_context_extensions.dart  → BuildContextExtension (extension)
│   └── form_auto_scroll.dart          → FormAutoScroll (extension on GlobalKey)
├── local_storage/
│   ├── shared_preferences.dart        → BaiomySharedPrefs
│   ├── secure_storage.dart            → BaiomySecureStorage
│   └── storage_exception.dart         → StorageException
├── password_encryption/
│   ├── password_encryption.dart       → BaiomyPasswordEncryption
│   ├── password_hasher.dart           → PasswordHasher
│   ├── encrypted_payload.dart         → EncryptedPayload
│   ├── hashed_password.dart           → HashedPassword
│   └── crypto_exception.dart          → CryptoException
├── utils/
│   ├── app_input_formatters.dart      → BaiomyInputFormatters
│   ├── logger_class.dart
│   └── text_form_field_decoration.dart → inputDecoration()
├── widgets/
│   ├── loading/
│   │   └── loading_item.dart
│   ├── app_toasts.dart
│   ├── avatar_glow.dart
│   ├── conditional_builder.dart
│   ├── custom_sized_box.dart
│   └── custom_value_listenable.dart
└── baiomy.dart
```

---

## ⚖️ License

```
Copyright (c) 2026 Mohamed Elbaiomy. All Rights Reserved.

This software is proprietary. Unauthorized copying, modification,
distribution, or use of this package, via any medium, is strictly
prohibited without prior written permission from the author.
```

See the [LICENSE](LICENSE) file for full details.

---

<p align="center">
  Built with ❤️ by <strong><a href="https://github.com/mohamedelbaiomy">Baiomy</a></strong>
</p>
