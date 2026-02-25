import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class AdminService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$API_URL/admin/stats'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body)['detail'] ?? 'Failed to fetch stats';
      }
    } catch (e) {
      throw 'Failed to fetch stats: ${e.toString()}';
    }
  }

  Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$API_URL/admin/users'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body)['detail'] ?? 'Failed to fetch users';
      }
    } catch (e) {
      throw 'Failed to fetch users: ${e.toString()}';
    }
  }
  
  Future<void> toggleUserStatus(int userId, bool isActive) async {
    try {
      final response = await http.put(
        Uri.parse('$API_URL/admin/users/$userId/status?is_active=$isActive'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)['detail'] ?? 'Failed to update status';
      }
    } catch (e) {
      throw 'Failed to update status: ${e.toString()}';
    }
  }

  Future<List<dynamic>> getPendingApprovals() async {
    try {
      final response = await http.get(
        Uri.parse('$API_URL/admin/partner-approvals'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body)['detail'] ?? 'Failed to fetch approvals';
      }
    } catch (e) {
      throw 'Failed to fetch approvals: ${e.toString()}';
    }
  }

  Future<void> reviewPartner(int profileId, bool approve) async {
    try {
      final response = await http.put(
        Uri.parse('$API_URL/admin/partner-approvals/$profileId?approve=$approve'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)['detail'] ?? 'Failed to review partner';
      }
    } catch (e) {
      throw 'Failed to review partner: ${e.toString()}';
    }
  }
}
