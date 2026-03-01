import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


import 'package:clenzy/config/api_config.dart';

/// User model
class User {
  final int id;
  final String email;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.role,
  });
}

/// Auth service with state management
class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Restore auth state from secure storage
  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'jwt');
    final userId = await _storage.read(key: 'userId');
    final email = await _storage.read(key: 'email');
    final role = await _storage.read(key: 'role');

    if (token != null && userId != null) {
      _currentUser = User(
        id: int.parse(userId),
        email: email ?? '',
        role: role ?? 'user',
      );
      notifyListeners();
    }
  }

  /// SIGN UP
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String role = 'user',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
          'role': role,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw error['detail'] ?? 'Signup failed';
      }

      // Auto login after successful signup
      await signInWithEmail(email: email, password: password);
    } catch (e) {
      throw 'Signup failed: $e';
    }
  }

  /// SIGN IN
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw error['detail'] ?? 'Login failed';
      }

      final data = jsonDecode(response.body);

      await _storage.write(key: 'jwt', value: data['access_token']);
      await _storage.write(key: 'userId', value: data['user_id'].toString());
      await _storage.write(key: 'role', value: data['role']);
      await _storage.write(key: 'email', value: email);

      _currentUser = User(
        id: data['user_id'],
        email: email,
        role: data['role'],
      );

      notifyListeners();
    } catch (e) {
      throw 'Login failed: $e';
    }
  }

  /// Get stored JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  /// Get user role
  Future<String?> getUserRole() async {
    return _currentUser?.role ?? await _storage.read(key: 'role');
  }

  /// SIGN OUT
  Future<void> signOut() async {
    await _storage.deleteAll();
    _currentUser = null;
    notifyListeners();
  }
}