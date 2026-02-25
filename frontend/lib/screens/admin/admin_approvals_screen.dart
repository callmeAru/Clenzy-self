import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminApprovalsScreen extends StatefulWidget {
  const AdminApprovalsScreen({super.key});

  @override
  State<AdminApprovalsScreen> createState() => _AdminApprovalsScreenState();
}

class _AdminApprovalsScreenState extends State<AdminApprovalsScreen> {
  final AdminService _adminService = AdminService();
  
  List<dynamic> _profiles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchApprovals();
  }

  Future<void> _fetchApprovals() async {
    try {
      final profiles = await _adminService.getPendingApprovals();
      if (mounted) {
        setState(() {
          _profiles = profiles;
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

  Future<void> _reviewProfile(int profileId, bool approve) async {
    try {
      await _adminService.reviewPartner(profileId, approve);
      
      // Remove from list
      setState(() {
        _profiles.removeWhere((p) => p['id'] == profileId);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'Partner Approved' : 'Partner Rejected'),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Pending Approvals', style: TextStyle(color: Color(0xFF1A1D26), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1A1D26)),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null 
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _buildList(),
    );
  }

  Widget _buildList() {
    if (_profiles.isEmpty) {
      return const Center(
        child: Text(
          'No pending approvals.',
          style: TextStyle(fontSize: 16, color: Color(0xFF8E99A4)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _profiles.length,
      itemBuilder: (context, index) {
        final profile = _profiles[index];
        final user = profile['user'] ?? {};
        
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF3366FF).withAlpha(26),
                      child: Text(
                        (user['full_name'] ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF3366FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['full_name'] ?? 'Unknown User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D26),
                            ),
                          ),
                          Text(
                            profile['business_type'] ?? 'Individual',
                            style: const TextStyle(
                              color: Color(0xFF3366FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.email, user['email'] ?? 'No email'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone, user['phone'] ?? 'No phone'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_city, profile['city'] ?? 'No city'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.info_outline, profile['bio'] ?? 'No bio provided'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _reviewProfile(profile['id'], false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _reviewProfile(profile['id'], true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF1A1D26)),
          ),
        ),
      ],
    );
  }
}
