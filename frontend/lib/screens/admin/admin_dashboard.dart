import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import 'admin_users_screen.dart';
import 'admin_approvals_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _AdminOverviewScreen(),
      const AdminUsersScreen(),
      const AdminApprovalsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard_rounded, 'Overview', 0),
              _buildNavItem(Icons.people_alt, 'Users', 1),
              _buildNavItem(Icons.verified_user, 'Approvals', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF3366FF) : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF3366FF) : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOverviewScreen extends StatefulWidget {
  const _AdminOverviewScreen();

  @override
  State<_AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<_AdminOverviewScreen> {
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();
  
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final stats = await _adminService.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = stats;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Color(0xFF1A1D26), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF3366FF)),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _fetchStats();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await _authService.signOut();
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null 
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D26),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard('Total Users', _stats?['total_users']?.toString() ?? '0', Icons.people, Colors.blue),
                  _buildStatCard('Total Partners', _stats?['total_partners']?.toString() ?? '0', Icons.handshake, Colors.green),
                  _buildStatCard('Total Jobs', _stats?['total_jobs']?.toString() ?? '0', Icons.work, Colors.orange),
                  _buildStatCard('Revenue', '\$${_stats?['total_revenue']?.toStringAsFixed(2) ?? '0.00'}', Icons.attach_money, Colors.purple),
                  if ((_stats?['pending_partners'] ?? 0) > 0)
                    _buildStatCard('Pending Approvals', _stats?['pending_partners']?.toString() ?? '0', Icons.pending_actions, Colors.red),
                ],
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D26),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8E99A4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
