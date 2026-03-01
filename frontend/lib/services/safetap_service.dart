import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:clenzy/config/api_config.dart';


class SafetapService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> triggerPanic({
    required int jobId,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    try {
      final token = await _storage.read(key: 'jwt');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse('$apiBaseUrl/safetap/panic');
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

