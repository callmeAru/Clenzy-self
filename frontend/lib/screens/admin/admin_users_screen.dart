import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService();
  
  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await _adminService.getUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleUserStatus(int userId, bool currentStatus) async {
    try {
      await _adminService.toggleUserStatus(userId, !currentStatus);
      // Refresh list
      _fetchUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User status updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Manage Users', style: TextStyle(color: Color(0xFF1A1D26), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1A1D26)),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null 
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _buildUserList(),
    );
  }

  Widget _buildUserList() {
    if (_users.isEmpty) {
      return const Center(child: Text('No users found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final bool isActive = user['is_active'] ?? false;
        final String role = user['role'] ?? 'user';
        
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF3366FF).withAlpha(26),
              child: Text(
                (user['full_name'] ?? '?')[0].toUpperCase(),
                style: const TextStyle(color: Color(0xFF3366FF), fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              user['full_name'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1D26)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email'] ?? ''),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            trailing: Switch(
              value: isActive,
              activeColor: Colors.green,
              onChanged: (role == 'admin') ? null : (value) => _toggleUserStatus(user['id'], isActive),
            ),
          ),
        );
      },
    );
  }
}
