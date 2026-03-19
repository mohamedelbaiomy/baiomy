import 'package:flutter/services.dart';

/// A comprehensive collection of input formatters for text validation and filtering
/// Designed to be scalable and easily extensible for future requirements
class BaiomyInputFormatters {
  // Private constructor to prevent instantiation
  BaiomyInputFormatters._();

  // ==================== REGEX PATTERNS ====================

  /// Comprehensive emoji and symbol regex pattern
  static final RegExp _emojiPattern = RegExp(
    r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]'
    r'|[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]'
    r'|[\u{1F900}-\u{1F9FF}]|[\u{1FA70}-\u{1FAFF}]|[\u{2600}-\u{26FF}]'
    r'|[\u{2700}-\u{27BF}])',
    unicode: true,
  );

  /// Pattern for numbers only
  static final RegExp _numbersOnlyPattern = RegExp(r'[^0-9]');

  /// Pattern for letters only (including Arabic and other languages)
  static final RegExp _lettersOnlyPattern = RegExp(
    r'[^a-zA-Z\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s]',
  );

  /// Pattern for alphanumeric characters
  static final RegExp _alphanumericPattern = RegExp(
    r'[^a-zA-Z0-9\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s]',
  );

  /// Pattern for special characters commonly used in passwords
  static final RegExp _specialCharsPattern = RegExp(
    r'[^a-zA-Z0-9!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\?]',
  );

  /// Pattern for phone numbers (digits, +, -, (, ), spaces)
  static final RegExp _phonePattern = RegExp(r'[^0-9+\-\(\)\s]');

  /// Pattern for email-safe characters
  static final RegExp _emailUnsafePattern = RegExp(r'[^a-zA-Z0-9@._\-+]');

  /// Pattern for URL-safe characters
  static final RegExp _urlUnsafePattern = RegExp(r'[^a-zA-Z0-9:\/\._\-?=&%#]');

  /// Pattern for profanity and inappropriate content (basic example)
  static final RegExp _profanityPattern = RegExp(
    r'\b(badword1|badword2|inappropriate)\b',
    caseSensitive: false,
  );

  // ==================== BASIC FORMATTERS ====================

  /// Denies emoji and special Unicode symbols
  /// Most commonly used formatter for names and basic text inputs
  static List<TextInputFormatter> get denyEmojis => <TextInputFormatter>[
    FilteringTextInputFormatter.deny(_emojiPattern),
  ];

  /// Allows only numeric characters
  /// Useful for phone numbers, IDs, and numeric inputs
  static List<TextInputFormatter> get numbersOnly => <TextInputFormatter>[
    FilteringTextInputFormatter.deny(_numbersOnlyPattern),
  ];

  /// Allows only letters and spaces (supports multiple languages)
  /// Ideal for names in different languages
  static List<TextInputFormatter> get lettersOnly => <TextInputFormatter>[
    FilteringTextInputFormatter.deny(_lettersOnlyPattern),
  ];

  /// Allows alphanumeric characters and spaces
  /// Good for usernames and mixed content
  static List<TextInputFormatter> get alphanumericOnly => <TextInputFormatter>[
    FilteringTextInputFormatter.deny(_alphanumericPattern),
  ];

  /// Allows characters typically used in passwords
  /// Includes letters, numbers, and common special characters
  static List<TextInputFormatter> get passwordSafe => <TextInputFormatter>[
    FilteringTextInputFormatter.deny(_specialCharsPattern),
  ];

  /// Allows phone number characters
  /// Includes digits, +, -, (, ), and spaces
  static List<TextInputFormatter> get phoneNumberSafe => <TextInputFormatter>[
    FilteringTextInputFormatter.deny(_phonePattern),
  ];

  /// Allows email-safe characters
  /// Includes letters, numbers, @, ., _, -, and +
  static List<TextInputFormatter> get emailSafe => <TextInputFormatter>[
    FilteringTextInputFormatter.deny(_emailUnsafePattern),
  ];

  /// Allows URL-safe characters
  /// Useful for website inputs and links
  static List<TextInputFormatter> get urlSafe => <TextInputFormatter>[
    FilteringTextInputFormatter.deny(_urlUnsafePattern),
  ];

  /// Basic profanity filter
  /// Can be extended with more comprehensive word lists
  static List<TextInputFormatter> get denyProfanity => <TextInputFormatter>[
    FilteringTextInputFormatter.deny(_profanityPattern),
  ];

  // ==================== COMBINED FORMATTERS ====================

  /// Most common combination for user names
  /// Denies emojis and allows letters/spaces only
  static List<TextInputFormatter> get nameField => <TextInputFormatter>[
    ...denyEmojis,
    ...lettersOnly,
  ];

  /// For phone number inputs
  /// Denies emojis and allows only phone-safe characters
  static List<TextInputFormatter> get phoneField => <TextInputFormatter>[
    ...denyEmojis,
    ...phoneNumberSafe,
  ];

  /// For general text inputs that need to be clean
  /// Denies emojis and profanity, allows alphanumeric
  static List<TextInputFormatter> get cleanText => <TextInputFormatter>[
    ...denyEmojis,
    ...denyProfanity,
    ...alphanumericOnly,
  ];

  /// For notes and descriptions
  /// More permissive but still blocks emojis and profanity
  static List<TextInputFormatter> get notesField => <TextInputFormatter>[
    ...denyEmojis,
    ...denyProfanity,
  ];

  /// For email inputs (additional client-side validation)
  /// Note: Server-side validation is still required
  static List<TextInputFormatter> get emailField => <TextInputFormatter>[
    ...denyEmojis,
    ...emailSafe,
  ];

  /// For password inputs
  /// Allows password-safe characters but denies emojis
  static List<TextInputFormatter> get passwordField => <TextInputFormatter>[
    ...denyEmojis,
    ...passwordSafe,
  ];

  // ==================== CUSTOM LENGTH FORMATTERS ====================

  /// Creates a formatter that limits text length
  /// [maxLength] - Maximum allowed characters
  static List<TextInputFormatter> lengthLimit(int maxLength) =>
      <TextInputFormatter>[LengthLimitingTextInputFormatter(maxLength)];

  /// Creates a formatter for names with length limit
  /// [maxLength] - Maximum allowed characters (default: 35)
  static List<TextInputFormatter> nameWithLength([int maxLength = 35]) =>
      <TextInputFormatter>[...nameField, ...lengthLimit(maxLength)];

  /// Creates a formatter for phone with exact length
  /// [exactLength] - Exact required length (default: 11)
  static List<TextInputFormatter> phoneWithLength([int exactLength = 11]) =>
      <TextInputFormatter>[...phoneField, ...lengthLimit(exactLength)];

  /// Creates a formatter for notes with length limit
  /// [maxLength] - Maximum allowed characters (default: 500)
  static List<TextInputFormatter> notesWithLength([int maxLength = 500]) =>
      <TextInputFormatter>[...notesField, ...lengthLimit(maxLength)];

  // ==================== ADVANCED FORMATTERS ====================

  /// Creates a custom formatter with multiple regex patterns
  /// [patterns] - List of RegExp patterns to deny
  /// [allowEmojis] - Whether to allow emojis (default: false)
  static List<TextInputFormatter> customDeny(
    List<RegExp> patterns, {
    bool allowEmojis = false,
  }) {
    final List<TextInputFormatter> formatters = <TextInputFormatter>[];

    if (!allowEmojis) {
      formatters.addAll(denyEmojis);
    }

    for (final RegExp pattern in patterns) {
      formatters.add(FilteringTextInputFormatter.deny(pattern));
    }

    return formatters;
  }

  /// Creates a custom formatter that only allows specified patterns
  /// [patterns] - List of RegExp patterns to allow
  static List<TextInputFormatter> customAllow(List<RegExp> patterns) {
    return patterns
        .map((RegExp pattern) => FilteringTextInputFormatter.allow(pattern))
        .toList();
  }

  /// Creates a case formatter (uppercase/lowercase)
  /// [uppercase] - true for uppercase, false for lowercase
  static List<TextInputFormatter> caseFormatter({bool uppercase = true}) =>
      <TextInputFormatter>[
        uppercase ? UpperCaseTextFormatter() : LowerCaseTextFormatter(),
      ];

  // ==================== SPECIALIZED FORMATTERS ====================

  /// For credit card numbers (digits with spaces every 4 characters)
  static List<TextInputFormatter> get creditCard => <TextInputFormatter>[
    ...denyEmojis,
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(19), // 16 digits + 3 spaces
    CreditCardFormatter(),
  ];

  /// For currency inputs (numbers with decimal points)
  static List<TextInputFormatter> get currency => <TextInputFormatter>[
    ...denyEmojis,
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
    CurrencyInputFormatter(),
  ];

  /// For username inputs (alphanumeric with specific symbols)
  static List<TextInputFormatter> get username => <TextInputFormatter>[
    ...denyEmojis,
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._-]')),
    LengthLimitingTextInputFormatter(30),
  ];

  // ==================== VALIDATION HELPERS ====================

  /// Checks if text contains emojis
  static bool containsEmojis(String text) {
    return _emojiPattern.hasMatch(text);
  }

  /// Checks if text contains only numbers
  static bool isNumericOnly(String text) {
    return !_numbersOnlyPattern.hasMatch(text);
  }

  /// Checks if text contains profanity
  static bool containsProfanity(String text) {
    return _profanityPattern.hasMatch(text);
  }

  /// Gets character count excluding emojis
  static int getCleanCharacterCount(String text) {
    return text.replaceAll(_emojiPattern, '').length;
  }
}

// ==================== CUSTOM FORMATTER CLASSES ====================

/// Custom formatter for uppercase text
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// Custom formatter for lowercase text
class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toLowerCase());
}

/// Custom formatter for credit card numbers (adds spaces every 4 digits)
class CreditCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text.replaceAll(' ', '');
    final StringBuffer formatted = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted.write(' ');
      }
      formatted.write(text[i]);
    }

    return newValue.copyWith(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Custom formatter for currency inputs
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text;

    // Allow only one decimal point
    final int decimalCount = text.split('.').length - 1;
    if (decimalCount > 1) {
      return oldValue;
    }

    // Limit decimal places to 2
    if (text.contains('.')) {
      final List<String> parts = text.split('.');
      if (parts.length > 1 && parts[1].length > 2) {
        return oldValue;
      }
    }

    return newValue;
  }
}
