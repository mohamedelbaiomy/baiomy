extension DomainValidator on String {
  bool isDomainValid() {
    if (isEmpty) return false;

    // Check for valid domain format
    // Supports: domain.com, subdomain.domain.com, mail.university.edu.eg, etc.
    final RegExp domainRegex = RegExp(
      r'^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$',
      caseSensitive: false,
    );

    if (!domainRegex.hasMatch(this)) return false;

    final List<String> parts = split('.');

    // Must have at least 2 parts (domain.tld)
    if (parts.length < 2) return false;

    // TLD should be 2-6 characters
    final String tld = parts.last;
    if (tld.length < 2 || tld.length > 6) return false;

    // Each part should not be empty and not exceed 63 characters
    for (final String part in parts) {
      if (part.isEmpty || part.length > 63) return false;
      // Should not start or end with hyphen
      if (part.startsWith('-') || part.endsWith('-')) return false;
    }

    return true;
  }

  bool isInternationalDomain() {
    // Check for international domains (non-ASCII characters)
    return RegExp(r'[^\x00-\x7F]').hasMatch(this);
  }
}
