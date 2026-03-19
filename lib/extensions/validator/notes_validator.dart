extension NotesValidator on String {
  /// Check for inappropriate content patterns
  bool hasInappropriateContent() {
    final String lowerNote = toLowerCase();

    // List of inappropriate patterns to check
    final List<String> inappropriatePatterns = <String>[
      'spam',
      'test test',
      'aaaaa',
      'bbbbb',
      '11111',
      '22222',
      'fake',
      'dummy',
      'invalid',
      'none',
      'n/a',
      'nothing',
    ];

    return inappropriatePatterns.any(
      (String pattern) => lowerNote.contains(pattern),
    );
  }

  /// Check for excessive special characters
  bool hasExcessiveSpecialCharacters() {
    final int specialCharCount = RegExp(
      r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>?/~`]',
    ).allMatches(this).length;

    // More than 20% special characters is excessive
    return specialCharCount > (length * 0.2);
  }

  /// Check for excessive repeated text patterns
  bool hasExcessiveRepeatedText() {
    // Check for same character repeated more than 4 times
    if (RegExp(r'(.)\1{4,}').hasMatch(this)) return true;

    // Check for same word repeated more than 2 times
    final List<String> words = split(RegExp(r'\s+'));
    for (final String word in words) {
      if (word.length > 2) {
        final int wordCount = words
            .where((String w) => w.toLowerCase() == word.toLowerCase())
            .length;
        if (wordCount > 2) return true;
      }
    }

    return false;
  }

  /// Check if note contains meaningful content
  bool hasMeaningfulContent() {
    final String cleanNote = trim().toLowerCase();

    // Must contain at least one alphabetic word of 3+ characters
    final bool hasRealWords = RegExp(r'\b[a-zA-Z]{3,}\b').hasMatch(this);
    if (!hasRealWords) return false;

    // Should contain some descriptive content
    final List<String> meaningfulWords = <String>[
      'faculty',
      'university',
      'college',
      'school',
      'department',
      'level',
      'floor',
      'room',
      'building',
      'campus',
      'student',
      'study',
      'exam',
      'class',
      'course',
      'near',
      'close',
      'next',
      'opposite',
      'behind',
      'engineering',
      'medicine',
      'science',
      'arts',
      'business',
      'library',
      'cafeteria',
      'lab',
      'lecture',
      'hall',
    ];

    return meaningfulWords.any((String word) => cleanNote.contains(word)) ||
        hasEducationalContext() ||
        hasLocationDetails();
  }

  /// Check if note has proper structure (punctuation, capitalization)
  bool hasProperStructure() {
    // Check for proper sentence structure
    final bool hasCapitalLetter = RegExp(r'[A-Z]').hasMatch(this);
    final bool hasProperSpacing = !RegExp(r'\s{3,}').hasMatch(this);
    final bool hasReasonableLength = length >= 10 && length <= 200;

    return hasCapitalLetter && hasProperSpacing && hasReasonableLength;
  }

  bool hasSpecificDetails() {
    // Look for specific patterns that indicate detailed information
    final List<RegExp> specificPatterns = <RegExp>[
      RegExp(r'\blevel\s+\d+\b', caseSensitive: false),
      RegExp(r'\bfloor\s+\d+\b', caseSensitive: false),
      RegExp(r'\broom\s+\d+\b', caseSensitive: false),
      RegExp(r'\bbuilding\s+[a-zA-Z]+\b', caseSensitive: false),
      RegExp(r'\byear\s+\d+\b', caseSensitive: false),
    ];

    return specificPatterns.any((RegExp pattern) => pattern.hasMatch(this));
  }

  bool hasEducationalContext() {
    final List<String> educationalKeywords = <String>[
      'faculty',
      'university',
      'college',
      'school',
      'department',
      'student',
      'study',
      'exam',
      'class',
      'course',
      'degree',
      'bachelor',
      'master',
      'phd',
      'diploma',
      'certificate',
    ];

    final String lowerNote = toLowerCase();
    return educationalKeywords.any(
      (String keyword) => lowerNote.contains(keyword),
    );
  }

  bool hasLocationDetails() {
    final List<String> locationKeywords = <String>[
      'near',
      'next',
      'opposite',
      'behind',
      'front',
      'beside',
      'level',
      'floor',
      'room',
      'building',
      'block',
      'wing',
      'campus',
      'area',
      'section',
      'zone',
      'district',
    ];

    final String lowerNote = toLowerCase();
    return locationKeywords.any(
      (String keyword) => lowerNote.contains(keyword),
    );
  }

  int getWordCount() => trim()
      .split(RegExp(r'\s+'))
      .where((String word) => word.isNotEmpty)
      .length;

  int getCharacterCountWithoutSpaces() => replaceAll(RegExp(r'\s'), '').length;
}
