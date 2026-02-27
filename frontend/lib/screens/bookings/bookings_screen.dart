import 'package:flutter/material.dart';

import 'active_job_safetap_sheet.dart';
import 'worker_tracking_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _selectedTab = 0; // 0 = Upcoming, 1 = Past

  // Sample active/upcoming jobs
  final List<Map<String, dynamic>> _upcomingJobs = [
    {
      'title': 'Main Stack Clog Repair',
      'address': '742 Evergreen Ter.',
      'worker': 'David Smith',
      'status': 'EN ROUTE',
      'statusColor': 0xFF4CAF50,
      'icon': Icons.plumbing,
      'dateTime': null,
    },
    {
      'title': 'Electrical Panel Upgrade',
      'address': '124 Conch St.',
      'worker': 'Sarah Jenkins',
      'status': 'CONFIRMED',
      'statusColor': 0xFFFF9800,
      'icon': Icons.bolt,
      'dateTime': 'TODAY 2:30 PM',
    },
    {
      'title': 'Deep Move-out Cleaning',
      'address': 'Ocean Ave Apt 4B',
      'worker': 'Elena Rodriguez',
      'status': 'CONFIRMED',
      'statusColor': 0xFF4CAF50,
      'icon': Icons.cleaning_services,
      'dateTime': 'OCT 30, 9:00 AM',
    },
    {
      'title': 'Exterior Repainting',
      'address': '742 Evergreen Ter.',
      'worker': 'Mike Ross',
      'status': 'CONFIRMED',
      'statusColor': 0xFF9C27B0,
      'icon': Icons.format_paint,
      'dateTime': 'NOV 2, 10:00 AM',
    },
  ];

  // Sample past jobs
  final List<Map<String, dynamic>> _pastJobs = [
    {
      'title': 'Kitchen Plumbing Fix',
      'address': '456 Oak Street',
      'worker': 'John Miller',
      'status': 'COMPLETED',
      'statusColor': 0xFF8E99A4,
      'icon': Icons.plumbing,
      'dateTime': 'OCT 15, 2024',
      'rating': 5.0,
    },
    {
      'title': 'AC Installation',
      'address': '789 Pine Ave',
      'worker': 'Tom Wilson',
      'status': 'COMPLETED',
      'statusColor': 0xFF8E99A4,
      'icon': Icons.ac_unit,
      'dateTime': 'OCT 10, 2024',
      'rating': 4.5,
    },
    {
      'title': 'Bathroom Renovation',
      'address': '321 Elm Road',
      'worker': 'Lisa Chen',
      'status': 'COMPLETED',
      'statusColor': 0xFF8E99A4,
      'icon': Icons.bathroom,
      'dateTime': 'OCT 5, 2024',
      'rating': 4.8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(isDark),
            const SizedBox(height: 16),
            // Tab Bar
            _buildTabBar(isDark),
            const SizedBox(height: 8),
            // Jobs count
            _buildJobsCount(isDark),
            // Jobs List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                itemCount: _selectedTab == 0 ? _upcomingJobs.length : _pastJobs.length,
                itemBuilder: (context, index) {
                  final jobs = _selectedTab == 0 ? _upcomingJobs : _pastJobs;
                  return _buildJobCard(jobs[index], isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Bookings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1D26),
            ),
          ),
          Icon(
            Icons.tune_rounded,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8ECF4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _selectedTab == 0 
                        ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _selectedTab == 0
                        ? [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Upcoming',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedTab == 0
                          ? const Color(0xFF3366FF)
                          : (isDark ? Colors.grey[500] : const Color(0xFF8E99A4)),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _selectedTab == 1 
                        ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _selectedTab == 1
                        ? [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Past',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedTab == 1
                          ? const Color(0xFF3366FF)
                          : (isDark ? Colors.grey[500] : const Color(0xFF8E99A4)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsCount(bool isDark) {
    final count = _selectedTab == 0 ? _upcomingJobs.length : _pastJobs.length;
    final label = _selectedTab == 0 ? 'ACTIVE JOBS' : 'PAST JOBS';
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '($count)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, bool isDark) {
    final bool isEnRoute = job['status'] == 'EN ROUTE';
    final bool isCompleted = job['status'] == 'COMPLETED';
    
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const WorkerTrackingScreen(
              jobId: '1',
              isWorker: false,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8ECF4),
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon - same style as All Services screen
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  job['icon'],
                  color: const Color(0xFF3366FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Row(
                      children: [
                        if (isEnRoute)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          isEnRoute
                              ? job['status']
                              : (isCompleted
                                  ? '${job['status']} • ${job['dateTime']}'
                                  : '${job['status']} • ${job['dateTime']}'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isEnRoute
                                ? const Color(0xFF4CAF50)
                                : Color(job['statusColor']),
                          ),
                        ),
                        if (isCompleted && job['rating'] != null) ...[
                          const Spacer(),
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job['rating'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1D26),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Title
                    Text(
                      job['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1D26),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Address and Worker
                  Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            job['address'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          job['worker'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const ActiveJobSafetapSheet(
                              jobId: 1,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFF3B30),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(
                          Icons.emergency_share_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'SafeTap Emergency',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // More options
              Icon(
                Icons.more_vert,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
