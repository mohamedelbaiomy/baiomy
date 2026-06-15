import 'package:http/http.dart' as http;

class BaiomyGoogleMapsExtractor {
  /// A comprehensive utility class for extracting location information from Google Maps URLs.
  ///
  /// This enhanced version supports all known Google Maps URL formats including:
  /// - Standard map URLs with coordinates
  /// - Place URLs with embedded coordinates
  /// - Shortened URLs (goo.gl, maps.app.goo.gl)
  /// - Street View URLs
  /// - Directions URLs
  /// - Embedded map URLs
  /// - Mobile deep links
  /// - Plus codes
  /// - International Google domain variants
  ///
  /// Example usage:
  /// ```dart
  /// final url = 'https://maps.app.goo.gl/mWtb4a1cUE9zMWya7';
  /// final coordinates = await GoogleMapsExtractor.processGoogleMapsUrl(url);
  /// if (coordinates != null) {
  ///   print('Latitude: ${coordinates['latitude']}');
  ///   print('Longitude: ${coordinates['longitude']}');
  /// } else {
  ///   print('Failed to extract coordinates');
  /// }
  /// ```

  /// Expands shortened URLs with enhanced error handling and timeout
  static Future<String?> expandShortUrl(
    String shortUrl, {
    int timeoutSeconds = 10,
  }) async {
    http.Client? client;
    try {
      client = http.Client();
      final http.Request request = http.Request('GET', Uri.parse(shortUrl))
        ..followRedirects = false;

      final http.StreamedResponse response = await client
          .send(request)
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 307 ||
          response.statusCode == 308) {
        final String? location = response.headers['location'];
        return location;
      }

      // Some services return 200 with a redirect in the body
      if (response.statusCode == 200) {
        final String responseBody = await response.stream.bytesToString();

        // Look for meta refresh redirects
        final RegExp metaRefreshRegex = RegExp(
          r"url=([^\'>\s]+)",
          caseSensitive: false,
        );
        final RegExpMatch? match = metaRefreshRegex.firstMatch(responseBody);
        if (match != null) {
          return match.group(1);
        }

        // Look for JavaScript redirects - FIXED REGEX
        final RegExp jsRedirectRegex = RegExp(
          r"window\.location\.href\s*=\s*[\']([^\']+)[\']",
        );
        final RegExpMatch? jsMatch = jsRedirectRegex.firstMatch(responseBody);
        if (jsMatch != null) {
          return jsMatch.group(1);
        }
      }
    } catch (e) {
      print('Error expanding URL: $e');
    } finally {
      client?.close();
    }
    return null;
  }

  /// Enhanced coordinate extraction with comprehensive pattern matching
  static Map<String, double>? extractCoordinates(String url) {
    print('Extracting coordinates from: $url');

    final List<RegExp> patterns = <RegExp>[
      // Pattern 1: Standard embedded coordinates (!3d and !4d format)
      RegExp(r'!3d(-?\d+\.?\d*)!4d(-?\d+\.?\d*)'),

      // Pattern 2: Basic query coordinates (q=lat,lng) - FIXED WITH + HANDLING
      RegExp(r'[?&]q=(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 3: View mode coordinates (@lat,lng,zoom)
      RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*),'),

      // Pattern 4: Legacy lat/lng parameters (ll=lat,lng) - FIXED WITH + HANDLING
      RegExp(r'[?&]ll=(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 5: Center coordinates (center=lat,lng) - FIXED WITH + HANDLING
      RegExp(r'[?&]center=(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 6: Destination coordinates for directions - FIXED WITH + HANDLING
      RegExp(r'[?&]destination=(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 7: Origin coordinates for directions - FIXED WITH + HANDLING
      RegExp(r'[?&]origin=(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 8: Street View coordinates (cbll=lat,lng) - FIXED WITH + HANDLING
      RegExp(r'[?&]cbll=(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 9: Embed coordinates (pb parameter)
      RegExp(r'[?&]pb=.*?2d(-?\d+\.?\d*).*?3d(-?\d+\.?\d*)'),

      // Pattern 10: Data parameter coordinates - FIXED WITH + HANDLING
      RegExp(r'[?&]data=.*?(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 11: Alternative embed format - FIXED WITH + HANDLING
      RegExp(r'embed.*?(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 12: URL fragment coordinates (#lat,lng) - FIXED WITH + HANDLING
      RegExp(r'#(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 13: Place coordinates in URL path
      RegExp(r'/place/[^/]*/@(-?\d+\.?\d*),(-?\d+\.?\d*)'),

      // Pattern 14: Search coordinates - FIXED PATTERN FOR YOUR URL FORMAT
      RegExp(r'/search/(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 15: Mobile coordinates format - FIXED WITH + HANDLING
      RegExp(r'coordinates=(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 16: Alternative mobile format - FIXED WITH + HANDLING
      RegExp(r'loc:(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 17: Plus code coordinates extraction (rough approximation)
      RegExp(r'plus\.codes/(-?\d+\.?\d*)\+(-?\d+\.?\d*)'),

      // Pattern 18: International domain coordinates - FIXED WITH + HANDLING
      RegExp(r'google\.[a-z]{2,3}/maps.*?(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 19: Alternative view coordinates - FIXED WITH + HANDLING
      RegExp(r'[?&]z=\d+.*?(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 20: Satellite view coordinates - FIXED WITH + HANDLING
      RegExp(r'[?&]t=k.*?(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),

      // Pattern 21: Direct coordinates in maps/search path (NEW PATTERN FOR YOUR CASE)
      RegExp(r'/maps/search/(-?\d+\.?\d*),\+?(-?\d+\.?\d*)'),
    ];

    for (int i = 0; i < patterns.length; i++) {
      final RegExp pattern = patterns[i];
      final RegExpMatch? match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 2) {
        try {
          final double lat = double.parse(match.group(1)!);
          final double lng = double.parse(match.group(2)!);

          // Validate coordinates are within valid ranges
          if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
            print(
              'Found coordinates using pattern ${i + 1}: lat=$lat, lng=$lng',
            );
            return <String, double>{'latitude': lat, 'longitude': lng};
          }
        } catch (e) {
          print('Pattern ${i + 1} matched but failed to parse: $e');
          continue; // Try next pattern
        }
      }
    }
    print('No coordinates found in URL');
    return null;
  }

  /// Enhanced URL processing with multiple fallback strategies
  static Future<Map<String, double>?> processGoogleMapsUrl(String url) async {
    try {
      String processedUrl = url.trim();

      // Handle different URL schemes
      if (!processedUrl.startsWith('http')) {
        if (processedUrl.startsWith('maps.google.com') ||
            processedUrl.startsWith('google.com/maps')) {
          processedUrl = 'https://$processedUrl';
        }
      }

      // First, try direct coordinate extraction
      Map<String, double>? coordinates = extractCoordinates(processedUrl);
      if (coordinates != null) {
        return coordinates;
      }

      // If it's a shortened URL, expand it first
      if (processedUrl.contains('goo.gl') ||
          processedUrl.contains('maps.app.goo.gl') ||
          processedUrl.contains('t.co') ||
          processedUrl.contains('bit.ly')) {
        print('Attempting to expand shortened URL...');
        final String? expandedUrl = await expandShortUrl(processedUrl);

        if (expandedUrl != null) {
          print('Expanded URL: $expandedUrl');
          coordinates = extractCoordinates(expandedUrl);
          if (coordinates != null) {
            return coordinates;
          }

          // Try expanding again if it's still a short URL
          if (expandedUrl.contains('goo.gl') ||
              expandedUrl.contains('maps.app.goo.gl')) {
            final String? doubleExpandedUrl = await expandShortUrl(expandedUrl);
            if (doubleExpandedUrl != null) {
              print('Double expanded URL: $doubleExpandedUrl');
              coordinates = extractCoordinates(doubleExpandedUrl);
              if (coordinates != null) {
                return coordinates;
              }
            }
          }
        } else {
          print('Failed to expand short URL');
        }
      }

      return null;
    } catch (e) {
      print('Error processing Google Maps URL: $e');
      return null;
    }
  }

  /// Validates if a URL is likely to be a Google Maps URL
  static bool isGoogleMapsUrl(String url) {
    final List<String> validPatterns = <String>[
      'google.com/maps',
      'maps.google.com',
      'maps.google.', // For international domains
      'google.co.', // For country domains
      'google.ca/maps',
      'google.co.uk/maps',
      'google.com.au/maps',
      'goo.gl/maps',
      'maps.app.goo.gl',
      'plus.codes',
      'maps.google.co.',
    ];

    return validPatterns.any(
      (String pattern) => url.toLowerCase().contains(pattern),
    );
  }

  /// Extracts additional metadata from Google Maps URLs when available
  static Map<String, dynamic>? extractMetadata(String url) {
    final Map<String, dynamic> metadata = <String, dynamic>{};

    // Extract zoom level
    final RegExpMatch? zoomMatch = RegExp(r'[?&]z=(\d+)').firstMatch(url);
    if (zoomMatch != null) {
      metadata['zoom'] = int.tryParse(zoomMatch.group(1)!) ?? 15;
    }

    // Extract map type
    if (url.contains('t=k') || url.contains('layer=c')) {
      metadata['mapType'] = 'satellite';
    } else if (url.contains('t=h')) {
      metadata['mapType'] = 'hybrid';
    } else if (url.contains('t=p')) {
      metadata['mapType'] = 'terrain';
    } else {
      metadata['mapType'] = 'roadmap';
    }

    // Extract place name if available
    final RegExpMatch? placeMatch = RegExp(r'/place/([^/@]+)').firstMatch(url);
    if (placeMatch != null) {
      metadata['placeName'] = Uri.decodeComponent(
        placeMatch.group(1)!,
      ).replaceAll('+', ' ');
    }

    return metadata.isNotEmpty ? metadata : null;
  }
}
