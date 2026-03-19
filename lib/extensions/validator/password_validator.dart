extension PasswordValidator on String {
  bool hasUppercase() => RegExp(r'[A-Z]').hasMatch(this);

  bool hasLowercase() => RegExp(r'[a-z]').hasMatch(this);

  bool hasDigit() => RegExp(r'\d').hasMatch(this);

  bool hasSpecialCharacter() =>
      RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]').hasMatch(this);

  bool hasWhitespace() => RegExp(r'\s').hasMatch(this);

  bool hasMixedCase() => hasUppercase() && hasLowercase();

  bool hasMultipleDigits() => RegExp(r'\d.*\d').hasMatch(this);

  bool hasMultipleSpecialChars() => RegExp(
    r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?].*[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]',
  ).hasMatch(this);

  bool isCommonPassword() {
    final List<String> commonPasswords = <String>[
      'password',
      '123456',
      '1234567',
      '12345678',
      '123456789',
      'qwerty',
      'abc123',
      'password123',
      'admin',
      '12345678',
      '1234567890',
      'letmein',
      'welcome',
      'monkey',
      '1234567',
      'password1',
      '123123',
      'dragon',
      'qwerty123',
      'football',
      'baseball',
      'welcome123',
    ];

    return commonPasswords.any(
      (String common) => toLowerCase().contains(common.toLowerCase()),
    );
  }

  bool hasSequentialCharacters() {
    // Check for sequential numbers (123, 234, etc.)
    for (int i = 0; i < length - 2; i++) {
      final String substr = substring(i, i + 3);
      if (RegExp(r'^\d{3}$').hasMatch(substr)) {
        final List<int> nums = substr.split('').map(int.parse).toList();
        if (nums[1] == nums[0] + 1 && nums[2] == nums[1] + 1) {
          return true;
        }
        if (nums[1] == nums[0] - 1 && nums[2] == nums[1] - 1) {
          return true;
        }
      }
    }

    // Check for sequential letters (abc, bcd, etc.)
    for (int i = 0; i < length - 2; i++) {
      final String substr = substring(i, i + 3).toLowerCase();
      if (RegExp(r'^[a-z]{3}$').hasMatch(substr)) {
        final List<int> codes = substr.codeUnits;
        if (codes[1] == codes[0] + 1 && codes[2] == codes[1] + 1) {
          return true;
        }
        if (codes[1] == codes[0] - 1 && codes[2] == codes[1] - 1) {
          return true;
        }
      }
    }

    return false;
  }

  bool hasExcessiveRepeatedCharacters() {
    // Check for more than 2 consecutive identical characters
    for (int i = 0; i < length - 2; i++) {
      if (this[i] == this[i + 1] && this[i + 1] == this[i + 2]) {
        return true;
      }
    }
    return false;
  }
}
