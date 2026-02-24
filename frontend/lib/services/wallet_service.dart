import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String API_URL = 'http://127.0.0.1:8000/api';

class WalletService {
  final _storage = const FlutterSecureStorage();
  
  final _walletController = StreamController<Map<String, dynamic>?>.broadcast();
  final _transactionsController = StreamController<List<Map<String, dynamic>>>.broadcast();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) throw Exception('No authentication token found');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================
  // GET WALLET
  // ============================================

  Future<void> fetchWallet() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$API_URL/wallet/balance'), headers: headers);
      if (response.statusCode == 200) {
        _walletController.add(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error fetching wallet: $e');
    }
  }

  Stream<Map<String, dynamic>?> getWalletStream(String userId) {
    fetchWallet();
    return _walletController.stream;
  }

  Future<Map<String, dynamic>?> getWallet(String userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$API_URL/wallet/balance'), headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting wallet: $e');
      return null;
    }
  }

  // ============================================
  // GET TRANSACTIONS
  // ============================================

  Future<void> fetchTransactions() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$API_URL/wallet/transactions'), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _transactionsController.add(data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getTransactions(String userId) {
    fetchTransactions();
    return _transactionsController.stream;
  }
  
  void dispose() {
    _walletController.close();
    _transactionsController.close();
  }
}
