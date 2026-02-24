import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String API_URL = 'http://127.0.0.1:8000/api';
const String WS_URL = 'ws://127.0.0.1:8000/api/ws';

class JobServiceClient {
  final _storage = const FlutterSecureStorage();
  WebSocketChannel? _channel;
  
  // Real-time stream controllers to replace Firestore Stream behavior
  final _customerJobsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _workerJobsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _availableJobsController = StreamController<List<Map<String, dynamic>>>.broadcast();

  // Helper to fetch authorization header
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) throw Exception('No authentication token found');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Connect WebSocket to receive real-time updates for jobs
  Future<void> connectWebSocket() async {
    final userId = await _storage.read(key: 'userId');
    if (userId == null) return;

    _channel = WebSocketChannel.connect(Uri.parse('$WS_URL/$userId'));
    _channel?.stream.listen((message) {
      final decoded = jsonDecode(message);
      // Depending on the signal (new_job, status_update), you could trigger a refetch or patch state directly.
      // For simplicity, we just trigger refetches here mimicking Firestore snapshots loosely.
      fetchCustomerJobs();
      fetchWorkerJobs();
      fetchAvailableJobs();
    });
  }

  // ============================================
  // CREATE JOB (Customer)
  // ============================================
  Future<String> createJob({
    required String serviceType,
    required double price,
    required int workersNeeded,
    required double latitude,
    required double longitude,
    required String address,
    required String description,
  }) async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse('$API_URL/bookings/'),
      headers: headers,
      body: jsonEncode({
        'service_type': serviceType,
        'price': price,
        'workers_needed': workersNeeded,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      fetchCustomerJobs(); // Update stream
      return data['id'].toString();
    } else {
      throw Exception('Failed to create job: ${response.body}');
    }
  }

  // ============================================
  // ACCEPT JOB (Partner)
  // ============================================
  Future<Map<String, dynamic>> acceptJob(String jobId) async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse('$API_URL/bookings/$jobId/accept'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      fetchWorkerJobs(); // Update stream
      return {
        'success': true,
        'jobId': data['id'],
        'otp': data['otp'],
      };
    } else {
      throw Exception('Failed to accept job: ${response.body}');
    }
  }

  // ============================================
  // UPDATE JOB STATUS (Partner)
  // ============================================
  Future<void> updateJobStatus(String jobId, String newStatus) async {
    final headers = await _getAuthHeaders();

    final response = await http.put(
      Uri.parse('$API_URL/bookings/$jobId/status?new_status=$newStatus'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update job status: ${response.body}');
    }
    fetchWorkerJobs(); // Refetch streams
  }

  // ============================================
  // VERIFY OTP
  // ============================================
  Future<bool> verifyOTP(String jobId, String inputOtp) async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse('$API_URL/bookings/$jobId/verify-otp?otp=$inputOtp'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      fetchCustomerJobs();
      fetchWorkerJobs();
      return true;
    }
    return false;
  }

  // ============================================
  // FETCHERS AND STREAMS
  // ============================================

  // These functions populate the streams simulating Firestore .snapshots()
  
  Future<void> fetchCustomerJobs() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$API_URL/bookings/customer'), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _customerJobsController.add(data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint("Error fetching customer jobs: $e");
    }
  }

  Future<void> fetchWorkerJobs() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$API_URL/bookings/worker'), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _workerJobsController.add(data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint("Error fetching worker jobs: $e");
    }
  }

  Future<void> fetchAvailableJobs() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$API_URL/bookings/available'), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _availableJobsController.add(data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint("Error fetching available jobs: $e");
    }
  }

  // Expose Streams for UI
  Stream<List<Map<String, dynamic>>> getCustomerJobs() {
    fetchCustomerJobs(); // Initial fetch
    return _customerJobsController.stream;
  }

  Stream<List<Map<String, dynamic>>> getWorkerJobs() {
    fetchWorkerJobs(); // Initial fetch
    return _workerJobsController.stream;
  }

  Stream<List<Map<String, dynamic>>> getAvailableJobs() {
    fetchAvailableJobs(); // Initial fetch
    return _availableJobsController.stream;
  }

  void dispose() {
    _channel?.sink.close();
    _customerJobsController.close();
    _workerJobsController.close();
    _availableJobsController.close();
  }
}
