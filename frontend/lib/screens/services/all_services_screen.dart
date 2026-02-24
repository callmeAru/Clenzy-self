import 'package:flutter/material.dart';
import 'service_providers_screen.dart';

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.cleaning_services, 'label': 'Cleaning'},
    {'icon': Icons.build, 'label': 'Repair'},
    {'icon': Icons.plumbing, 'label': 'Plumbing'},
    {'icon': Icons.bolt, 'label': 'Electrical'},
    {'icon': Icons.format_paint, 'label': 'Painting'},
    {'icon': Icons.local_shipping, 'label': 'Moving'},
    {'icon': Icons.pest_control, 'label': 'Pest Control'},
  ];

  final Map<int, List<Map<String, dynamic>>> _servicesByCategory = {
    0: [ // Cleaning
      {'icon': Icons.home, 'name': 'Deep Cleaning', 'price': 49},
      {'icon': Icons.kitchen, 'name': 'Kitchen Cleaning', 'price': 29},
      {'icon': Icons.weekend, 'name': 'Sofa Shampooing', 'price': 39},
      {'icon': Icons.ac_unit, 'name': 'AC Service', 'price': 59},
      {'icon': Icons.window, 'name': 'Window Cleaning', 'price': 19},
      {'icon': Icons.sanitizer, 'name': 'Sanitization', 'price': 35},
    ],
    1: [ // Repair
      {'icon': Icons.handyman, 'name': 'General Repair', 'price': 45},
      {'icon': Icons.door_front_door, 'name': 'Door Repair', 'price': 35},
      {'icon': Icons.chair, 'name': 'Furniture Repair', 'price': 55},
      {'icon': Icons.roofing, 'name': 'Roof Repair', 'price': 99},
    ],
    2: [ // Plumbing
      {'icon': Icons.water_drop, 'name': 'Tap Leak Fix', 'price': 25},
      {'icon': Icons.plumbing, 'name': 'Pipe Repair', 'price': 45},
      {'icon': Icons.bathtub, 'name': 'Bathroom Fix', 'price': 55},
      {'icon': Icons.hot_tub, 'name': 'Geyser Repair', 'price': 65},
    ],
    3: [ // Electrical
      {'icon': Icons.lightbulb, 'name': 'Wiring Setup', 'price': 40},
      {'icon': Icons.power, 'name': 'Short Circuit', 'price': 35},
      {'icon': Icons.electrical_services, 'name': 'Switch Repair', 'price': 20},
      {'icon': Icons.settings_input_hdmi, 'name': 'MCB Repair', 'price': 30},
    ],
    4: [ // Painting
      {'icon': Icons.format_paint, 'name': 'Wall Painting', 'price': 199},
      {'icon': Icons.door_sliding, 'name': 'Door Painting', 'price': 49},
      {'icon': Icons.texture, 'name': 'Texture Paint', 'price': 299},
      {'icon': Icons.imagesearch_roller, 'name': 'Touch Up', 'price': 29},
    ],
    5: [ // Moving
      {'icon': Icons.local_shipping, 'name': 'Home Shifting', 'price': 299},
      {'icon': Icons.inventory_2, 'name': 'Packing', 'price': 99},
      {'icon': Icons.chair_alt, 'name': 'Furniture Move', 'price': 149},
    ],
    6: [ // Pest Control
      {'icon': Icons.pest_control, 'name': 'General Pest', 'price': 79},
      {'icon': Icons.bug_report, 'name': 'Cockroach', 'price': 49},
      {'icon': Icons.coronavirus, 'name': 'Termite', 'price': 149},
      {'icon': Icons.bedtime, 'name': 'Bed Bugs', 'price': 99},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1A1D26),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D26),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          const SizedBox(height: 16),
          // Main Content
          Expanded(
            child: Row(
              children: [
                // Left Sidebar - Categories
                _buildCategorySidebar(),
                // Right Content - Services Grid
                Expanded(
                  child: _buildServicesContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.grey[500],
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for a service...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySidebar() {
    return Container(
      width: 80,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE8ECF4), width: 1),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isSelected ? const Color(0xFF3366FF) : Colors.transparent,
                    width: 3,
                  ),
                ),
                color: isSelected ? const Color(0xFFF0F4FF) : Colors.transparent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _categories[index]['icon'] as IconData,
                    color: isSelected ? const Color(0xFF3366FF) : Colors.grey[400],
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _categories[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF3366FF) : Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicesContent() {
    final services = _servicesByCategory[_selectedCategoryIndex] ?? [];
    final categoryName = _categories[_selectedCategoryIndex]['label'] as String;

    return Container(
      color: const Color(0xFFF8F9FC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              '$categoryName Services',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
          ),
          // Services Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(services[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceProvidersScreen(
              categoryName: service['name'] as String,
              categoryIcon: service['icon'] as IconData,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon - same style as home screen
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                service['icon'] as IconData,
                color: const Color(0xFF3366FF),
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            // Name
            Text(
              service['name'] as String,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D26),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Price
            Text(
              'From \$${service['price']}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3366FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

