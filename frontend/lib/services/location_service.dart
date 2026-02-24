import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String WS_URL = 'ws://127.0.0.1:8000/api/ws';
const String API_URL = 'http://127.0.0.1:8000/api';

class LocationService {
  final _storage = const FlutterSecureStorage();
  
  Timer? _locationTimer;
  String? _activeJobId;
  WebSocketChannel? _channel;
  
  final _liveLocationController = StreamController<Map<String, dynamic>?>.broadcast();

  // Connect WebSocket to receive/send real-time location
  Future<void> connectWebSocket() async {
    final userId = await _storage.read(key: 'userId');
    if (userId == null) return;

    _channel = WebSocketChannel.connect(Uri.parse('$WS_URL/$userId'));
    _channel?.stream.listen((message) {
      final decoded = jsonDecode(message);
      if (decoded['type'] == 'location_update') {
         _liveLocationController.add(decoded['data']);
      }
    });
  }

  // ============================================
  // GET CURRENT LOCATION
  // ============================================

  Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  // ============================================
  // LIVE LOCATION TRACKING (Worker)
  // ============================================

  void startLiveTracking(String jobId) {
    _activeJobId = jobId;
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _updateLiveLocation(),
    );
    _updateLiveLocation();
  }

  void stopLiveTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _activeJobId = null;
  }

  Future<void> _updateLiveLocation() async {
    if (_activeJobId == null || _channel == null) return;

    try {
      final position = await getCurrentLocation();
      if (position == null) return;

      // Broadcast location directly via WebSocket
      _channel?.sink.add(jsonEncode({
        'type': 'location_update',
        'jobId': _activeJobId,
        'data': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'heading': position.heading,
          'speed': position.speed,
        }
      }));
    } catch (e) {
      debugPrint('Error updating live location: $e');
    }
  }

  // ============================================
  // STREAM LIVE LOCATION (Customer)
  // ============================================

  Stream<Map<String, dynamic>?> streamLiveLocation(String jobId) {
    return _liveLocationController.stream;
  }

  // ============================================
  // WORKER STATUS
  // ============================================

  Future<void> updateWorkerStatus({
    required bool isOnline,
    Position? location,
  }) async {
    try {
      // In a real application, this would be an HTTP POST
      // to update the user's `is_online` and `latitude`/`longitude` fields.
      // E.g., http.put('$API_URL/users/status', body: { isOnline, ... })
    } catch (e) {
      debugPrint('Error updating worker status: $e');
      rethrow;
    }
  }

  void dispose() {
    stopLiveTracking();
    _channel?.sink.close();
    _liveLocationController.close();
  }
}
