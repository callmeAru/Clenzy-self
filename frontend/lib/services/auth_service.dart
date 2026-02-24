import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Adjust this depending on emulator or physical device testing
// Android emulator uses 10.0.2.2. Web/iOS uses 127.0.0.1
const String API_URL = 'http://127.0.0.1:8000/api'; 

class User {
  final int id;
  final String email;
  final String role;
  
  User({required this.id, required this.email, required this.role});
}

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Initialize Auth State from Local Storage
  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'jwt');
    final userId = await _storage.read(key: 'userId');
    final email = await _storage.read(key: 'email');
    final role = await _storage.read(key: 'role');
    
    if (token != null && userId != null) {
      _currentUser = User(id: int.parse(userId), email: email ?? '', role: role ?? 'user');
      notifyListeners();
    }
  }

  // Sign up with REST API
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String role = 'user',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$API_URL/users/signup'),
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
        throw jsonDecode(response.body)['detail'] ?? 'Signup failed';
      }
      
      // Auto-login after signup
      await signInWithEmail(email: email, password: password);
    } catch (e) {
      throw 'Signup failed: ${e.toString()}';
    }
  }

  // Sign in with REST API
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$API_URL/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        await _storage.write(key: 'jwt', value: data['access_token']);
        await _storage.write(key: 'userId', value: data['user_id'].toString());
        await _storage.write(key: 'role', value: data['role']);
        await _storage.write(key: 'email', value: email);
        
        _currentUser = User(id: data['user_id'], email: email, role: data['role']);
        notifyListeners();
      } else {
        throw jsonDecode(response.body)['detail'] ?? 'Login failed';
      }
    } catch (e) {
      throw 'Login failed: ${e.toString()}';
    }
  }

  // Get current user role (from local storage)
  Future<String?> getUserRole() async {
    return _currentUser?.role ?? await _storage.read(key: 'role');
  }

  // Get current JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  // Sign out
  Future<void> signOut() async {
    await _storage.deleteAll();
    _currentUser = null;
    notifyListeners();
  }
}
