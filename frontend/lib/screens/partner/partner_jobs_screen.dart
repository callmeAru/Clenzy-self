import 'package:flutter/material.dart';

class PartnerJobsScreen extends StatefulWidget {
  const PartnerJobsScreen({super.key});

  @override
  State<PartnerJobsScreen> createState() => _PartnerJobsScreenState();
}

class _PartnerJobsScreenState extends State<PartnerJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _activeJobs = [
    {
      'title': 'Plumbing Repair',
      'ticketId': 'FX-9021',
      'earnings': '\$85.00',
      'date': 'Today',
      'time': '10:00 AM - 11:30 AM',
      'customer': 'John Doe',
      'address': '123 Market St, Apt 4B, SF',
      'status': 'ON MY WAY',
      'statusColor': 0xFF4CAF50,
      'image': 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=400',
    },
    {
      'title': 'Electrical Maintenance',
      'ticketId': 'FX-8842',
      'earnings': '\$120.00',
      'date': 'Today',
      'time': '02:30 PM - 04:00 PM',
      'customer': 'Sarah Smith',
      'address': '455 Mission St, San Francisco',
      'status': 'SCHEDULED',
      'statusColor': 0xFF3366FF,
      'image': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400',
    },
    {
      'title': 'AC Cleaning',
      'ticketId': 'FX-7731',
      'earnings': '\$60.00',
      'date': 'Tomorrow',
      'time': '09:00 AM',
      'customer': 'Michael Chen',
      'address': '789 Oak Ave, Oakland',
      'status': 'UPCOMING',
      'statusColor': 0xFFFF9800,
      'image': 'https://images.unsplash.com/photo-1631545806609-35d4ae440431?w=400',
    },
  ];

  final List<Map<String, dynamic>> _pendingJobs = [
    {
      'title': 'Water Heater Install',
      'ticketId': 'FX-7655',
      'earnings': '\$150.00',
      'date': 'Jan 15',
      'time': '11:00 AM - 02:00 PM',
      'customer': 'David Wilson',
      'address': '321 Pine St, Berkeley',
      'status': 'PENDING',
      'statusColor': 0xFFFF9800,
      'image': 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400',
    },
  ];

  final List<Map<String, dynamic>> _completedJobs = [
    {
      'title': 'Kitchen Sink Repair',
      'ticketId': 'FX-6543',
      'earnings': '\$75.00',
      'date': 'Jan 8',
      'time': '03:00 PM - 04:30 PM',
      'customer': 'Emma Thompson',
      'address': '567 Elm St, San Jose',
      'status': 'COMPLETED',
      'statusColor': 0xFF4CAF50,
      'image': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400',
    },
    {
      'title': 'Bathroom Pipe Fix',
      'ticketId': 'FX-6210',
      'earnings': '\$95.00',
      'date': 'Jan 7',
      'time': '10:00 AM - 12:00 PM',
      'customer': 'Robert Brown',
      'address': '890 Cedar Rd, Palo Alto',
      'status': 'COMPLETED',
      'statusColor': 0xFF4CAF50,
      'image': 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=400',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJobsList(_activeJobs, showImage: true),
          _buildJobsList(_pendingJobs, showImage: true),
          _buildJobsList(_completedJobs, showImage: true),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FC),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFF1A1D26)),
        onPressed: () {},
      ),
      title: const Text(
        'My Jobs',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1D26),
        ),
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
              onPressed: () {},
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF3366FF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE8ECF4), width: 1),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF3366FF),
            unselectedLabelColor: Colors.grey[500],
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: Color(0xFF3366FF), width: 2),
            ),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobsList(List<Map<String, dynamic>> jobs, {bool showImage = false}) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No jobs found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildJobCard(jobs[index], showImage: showImage),
        );
      },
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, {bool showImage = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with status badge
          if (showImage)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.network(
                      job['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.build_rounded,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(job['statusColor']),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      job['status'],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Earnings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D26),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ticket #${job['ticketId']}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3366FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Earn Potential',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          job['earnings'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1D26),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Details
                _buildDetailRow(
                  Icons.access_time_rounded,
                  '${job['date']}, ${job['time']}',
                  isHighlight: job['date'] == 'Tomorrow',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.person_outline_rounded,
                  'Customer: ${job['customer']}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.location_on_outlined,
                  job['address'],
                ),
                const SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3366FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3366FF).withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.navigation_rounded,
                          color: Color(0xFF3366FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isHighlight ? const Color(0xFFFF9800) : Colors.grey[400],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isHighlight ? const Color(0xFFFF9800) : Colors.grey[600],
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
