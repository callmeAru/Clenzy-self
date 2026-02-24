import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String API_URL = 'http://127.0.0.1:8000/api';
const String WS_URL = 'ws://127.0.0.1:8000/api/ws';

class JobService {
  final _storage = const FlutterSecureStorage();
  WebSocketChannel? _channel;
  
  final _customerJobsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _workerJobsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _availableJobsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _jobStreamController = StreamController<Map<String, dynamic>?>.broadcast();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) throw Exception('No authentication token found');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================
  // CREATE JOB
  // ============================================
  Future<String> createJob({
    required String customerId, // Kept for compatibility
    required String serviceType,
    required double price,
    required int workersNeeded,
    dynamic location, // Can be GeoPoint or Lat/Lng map
    required String address,
    required String description,
  }) async {
    final headers = await _getAuthHeaders();
    
    double lat = 0;
    double lng = 0;
    if (location is Map) {
      lat = location['latitude'] ?? 0;
      lng = location['longitude'] ?? 0;
    }

    final response = await http.post(
      Uri.parse('$API_URL/bookings/'),
      headers: headers,
      body: jsonEncode({
        'service_type': serviceType,
        'price': price,
        'workers_needed': workersNeeded,
        'latitude': lat,
        'longitude': lng,
        'address': address,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'].toString();
    } else {
      throw Exception('Failed to create job: ${response.body}');
    }
  }

  // ============================================
  // ACCEPT JOB
  // ============================================
  Future<Map<String, dynamic>> acceptJob(String jobId) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$API_URL/bookings/$jobId/accept'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
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
  // UPDATE JOB STATUS
  // ============================================
  Future<void> updateJobStatus(String jobId, String status) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse('$API_URL/bookings/$jobId/status?new_status=$status'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update job status: ${response.body}');
    }
  }

  // ============================================
  // VERIFY OTP
  // ============================================
  Future<bool> verifyOTP(String jobId, String otp) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$API_URL/bookings/$jobId/verify-otp?otp=$otp'),
      headers: headers,
    );

    return response.statusCode == 200;
  }

  // ============================================
  // STREAMS
  // ============================================

  Stream<List<Map<String, dynamic>>> getCustomerJobs(String customerId) {
    _fetchAndAdd(Uri.parse('$API_URL/bookings/customer'), _customerJobsController);
    return _customerJobsController.stream;
  }

  Stream<List<Map<String, dynamic>>> getWorkerJobs(String workerId) {
    _fetchAndAdd(Uri.parse('$API_URL/bookings/worker'), _workerJobsController);
    return _workerJobsController.stream;
  }

  Stream<List<Map<String, dynamic>>> getAvailableJobs() {
    _fetchAndAdd(Uri.parse('$API_URL/bookings/available'), _availableJobsController);
    return _availableJobsController.stream;
  }

  Stream<Map<String, dynamic>?> getJobStream(String jobId) {
    // Basic implementation: fetch once then return stream
    _fetchJob(jobId);
    return _jobStreamController.stream;
  }

  Future<void> _fetchAndAdd(Uri url, StreamController<List<Map<String, dynamic>>> controller) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        controller.add(data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint("Error fetching jobs: $e");
    }
  }

  Future<void> _fetchJob(String jobId) async {
     // Implement if needed for single job tracking
  }

  Future<void> cancelJob(String jobId) async {
    final headers = await _getAuthHeaders();
    await http.put(
      Uri.parse('$API_URL/bookings/$jobId/status?new_status=cancelled'),
      headers: headers,
    );
  }

  void dispose() {
    _customerJobsController.close();
    _workerJobsController.close();
    _availableJobsController.close();
    _jobStreamController.close();
  }
}
