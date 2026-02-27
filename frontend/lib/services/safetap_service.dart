import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const String _apiBaseUrl = 'http://127.0.0.1:8000/api/safetap';

class SafetapService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> triggerPanic({
    required int jobId,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse('$_apiBaseUrl/panic');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'job_id': jobId,
          'latitude': latitude,
          'longitude': longitude,
          'notes': notes,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to trigger panic (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('SafeTap panic error: $e');
      rethrow;
    }
  }
}

