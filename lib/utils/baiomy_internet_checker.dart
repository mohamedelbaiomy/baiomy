import 'dart:async';
import 'dart:io';

/// Reliable internet connectivity checker.
///
/// Strategy: DNS lookup on multiple reliable hosts (no HTTP overhead,
/// no CORS issues, no rate limits). Falls back to socket connection if DNS fails.
/// Fastest and most professional approach for production apps.
///
/// Usage:
///   in main :
///   await BaiomyInternetChecker.instance.initialize();
///   -------------------------------------------------
///   final checker = BaiomyInternetChecker.instance;
///   await checker.initialize();
///
///   // One-time check
///   bool online = await checker.hasConnection;
///
///   // React to changes
///   checker.onStatusChanged.listen((status) { ... });
///
///   // Use named states
///   if (checker.currentStatus == InternetStatus.connected) { ... }

enum InternetStatus { connected, disconnected, checking }

class BaiomyInternetChecker {
  BaiomyInternetChecker._();
  static final BaiomyInternetChecker instance = BaiomyInternetChecker._();

  // ─── Config ────────────────────────────────────────────────────────────────

  /// How often the background poller re-checks (default: 5 s).
  Duration pollingInterval = const Duration(seconds: 5);

  /// Per-host timeout before moving to the next candidate (default: 3 s).
  Duration lookupTimeout = const Duration(seconds: 3);

  /// DNS hosts tried in parallel — first success wins.
  final List<String> _hosts = [
    'google.com',
    'cloudflare.com',
    '1.1.1.1', // Cloudflare IP — works even when DNS is broken
    '8.8.8.8', // Google DNS IP
  ];

  // ─── State ─────────────────────────────────────────────────────────────────

  InternetStatus _currentStatus = InternetStatus.checking;
  InternetStatus get currentStatus => _currentStatus;

  /// `true`  → device is online.
  bool get isConnected => _currentStatus == InternetStatus.connected;

  /// `true`  → device is offline.
  bool get isDisconnected => _currentStatus == InternetStatus.disconnected;

  final StreamController<InternetStatus> _statusController =
      StreamController<InternetStatus>.broadcast();

  /// Emits every time connectivity status changes.
  Stream<InternetStatus> get onStatusChanged => _statusController.stream;

  Timer? _pollingTimer;
  bool _initialized = false;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Call once (e.g. in main() or your root widget's initState).
  /// Performs an immediate check and starts the background poller.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _check();
    _startPolling();
  }

  /// Single on-demand check — always hits the network.
  Future<bool> get hasConnection async {
    final result = await _lookup();
    _emit(result ? InternetStatus.connected : InternetStatus.disconnected);
    return result;
  }

  /// Stop the background poller (call in app lifecycle pause if desired).
  void dispose() {
    _pollingTimer?.cancel();
    _statusController.close();
    _initialized = false;
  }

  // ─── Core Logic ────────────────────────────────────────────────────────────

  /// Race all hosts; resolve as soon as ONE succeeds.
  Future<bool> _lookup() async {
    try {
      final futures = _hosts.map((host) => _singleLookup(host));
      // Returns true the moment any host resolves successfully.
      final result = await Future.any(futures);
      return result;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _singleLookup(String host) async {
    try {
      final result = await InternetAddress.lookup(host).timeout(lookupTimeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      // If DNS lookup fails, try a raw socket connection as fallback.
      return _socketFallback(host);
    }
  }

  /// Raw TCP handshake to port 80 — works when DNS itself is blocked.
  Future<bool> _socketFallback(String host) async {
    try {
      final socket = await Socket.connect(host, 80, timeout: lookupTimeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(pollingInterval, (_) => _check());
  }

  Future<void> _check() async {
    final online = await _lookup();
    _emit(online ? InternetStatus.connected : InternetStatus.disconnected);
  }

  void _emit(InternetStatus status) {
    if (_currentStatus == status) return; // no redundant events
    _currentStatus = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }
}
