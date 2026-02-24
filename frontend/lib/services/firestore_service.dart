import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String API_URL = 'http://127.0.0.1:8000/api';

class ApiService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) throw Exception('No authentication token found');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ==================== SERVICES ====================

  Future<List<Map<String, dynamic>>> getServices() async {
    // Implement API call to your fastAPI server for getting services catalogue
    return [];
  }

  // ==================== BOOKINGS (Redirected to Bookings Endpoints) ====================

  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    final headers = await _getAuthHeaders();
    await http.post(
      Uri.parse('$API_URL/bookings/'),
      headers: headers,
      body: jsonEncode(bookingData),
    );
  }

  Future<List<Map<String, dynamic>>> getUserBookings() async {
     final headers = await _getAuthHeaders();
     final response = await http.get(Uri.parse('$API_URL/bookings/customer'), headers: headers);
     if (response.statusCode == 200) {
       return jsonDecode(response.body).cast<Map<String, dynamic>>();
     }
     return [];
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
     final headers = await _getAuthHeaders();
     await http.put(Uri.parse('$API_URL/bookings/$bookingId/status?new_status=$status'), headers: headers);
  }

  // ==================== PARTNER (Provider) MODE ====================

  Future<void> registerAsPartner(Map<String, dynamic> partnerData) async {
     // Usually an endpoint like Put to /api/users/upgrade_to_partner
  }

  Future<List<Map<String, dynamic>>> getPartnerJobs() async {
     final headers = await _getAuthHeaders();
     final response = await http.get(Uri.parse('$API_URL/bookings/worker'), headers: headers);
     if (response.statusCode == 200) {
       return jsonDecode(response.body).cast<Map<String, dynamic>>();
     }
     return [];
  }
}
