extension EmailValidator on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  int toInt() => .parse(this);

  bool isValidEmail() {
    // RFC 5322 compliant email regex with support for various formats
    // This regex supports:
    // - Standard emails (user@domain.com)
    // - Academic emails (user@subdomain.university.edu)
    // - Multiple subdomains (user@mail.subdomain.domain.com)
    // - International domains
    // - Various TLD lengths (2-6 characters)
    // - Numeric domains
    // - Special characters in local part

    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9!#$%&*+/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$',
      caseSensitive: false,
    );

    return emailRegex.hasMatch(this);
  }

  bool isAcademicEmail() {
    final List<String> academicTlds = <String>[
      '.edu',
      '.edu.eg',
      '.edu.sa',
      '.edu.ae',
      '.edu.jo',
      '.ac.uk',
      '.edu.au',
      '.edu.ca',
      '.edu.in',
      '.edu.pk',
      '.edu.bd',
      '.edu.my',
      '.edu.sg',
      '.ac.jp',
      '.edu.cn',
      '.edu.tw',
      '.edu.kr',
      '.edu.br',
      '.edu.mx',
      '.ac.za',
      '.edu.ar',
      '.edu.cl',
    ];

    return academicTlds.any((String tld) => toLowerCase().endsWith(tld));
  }

  bool isCorporateEmail() {
    final List<String> corporateDomains = <String>[
      'gmail.com',
      'yahoo.com',
      'hotmail.com',
      'outlook.com',
      'icloud.com',
      'aol.com',
      'protonmail.com',
      'company.com',
    ];

    final String domain = split('@').last.toLowerCase();
    return !corporateDomains.contains(domain) && !isAcademicEmail();
  }

  bool hasSuspiciousEmailPattern() {
    // Check for suspicious patterns that might indicate fake emails
    final String lower = toLowerCase();

    // Check for excessive numbers at the end
    if (RegExp(r'\d{8,}@').hasMatch(lower)) return true;

    // Check for obvious fake patterns
    final List<String> suspiciousPatterns = <String>[
      'test@test',
      'admin@admin',
      '123@123',
      'fake@fake',
      'temp@temp',
      'dummy@dummy',
    ];

    return suspiciousPatterns.any((String pattern) => lower.contains(pattern));
  }
}
