import 'package:flutter/material.dart';
import 'booking_page.dart';

class ServiceProvidersScreen extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;

  const ServiceProvidersScreen({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
  });

  @override
  State<ServiceProvidersScreen> createState() => _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState extends State<ServiceProvidersScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Individuals', 'Agencies', 'Top Rated'];
  
  // Location filter values
  double _selectedDistance = 10.0;
  final List<double> _distanceOptions = [5, 10, 15, 25, 50];

  // Sample providers data matching the design
  final List<Map<String, dynamic>> _providers = [
    {
      'name': "John's Pro Plumbing",
      'type': 'individual',
      'rating': 4.9,
      'reviews': '120+',
      'price': 45,
      'isVerified': true,
      'badge': null,
      'distance': 2.5,
      'imageUrl': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
    },
    {
      'name': 'Rapid Response',
      'type': 'individual',
      'rating': 4.8,
      'reviews': '350',
      'price': 65,
      'isVerified': true,
      'badge': null,
      'distance': 4.2,
      'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    },
    {
      'name': 'Elite Pipe Fixers',
      'type': 'agency',
      'rating': 5.0,
      'reviews': '85',
      'price': 70,
      'isVerified': false,
      'badge': 'ELITE',
      'distance': 8.0,
      'imageUrl': 'https://images.unsplash.com/photo-1581092921461-eab10ce8e6f3?w=150',
    },
    {
      'name': "Sam's Quick Repairs",
      'type': 'individual',
      'rating': null,
      'reviews': null,
      'price': 38,
      'isVerified': false,
      'badge': 'NEW PROVIDER',
      'distance': 1.2,
      'imageUrl': null,
    },
    {
      'name': 'Metro Plumbing Co.',
      'type': 'agency',
      'rating': 4.7,
      'reviews': '1.2k',
      'price': 55,
      'isVerified': true,
      'badge': null,
      'distance': 12.0,
      'imageUrl': null,
    },
    {
      'name': 'Quick Fix Pro',
      'type': 'individual',
      'rating': 4.6,
      'reviews': '89',
      'price': 42,
      'isVerified': true,
      'badge': null,
      'distance': 18.0,
      'imageUrl': null,
    },
    {
      'name': 'City Plumbers',
      'type': 'agency',
      'rating': 4.9,
      'reviews': '520',
      'price': 60,
      'isVerified': true,
      'badge': null,
      'distance': 6.5,
      'imageUrl': null,
    },
  ];

  List<Map<String, dynamic>> get _filteredProviders {
    var filtered = _providers.where((p) {
      // Filter by distance
      if ((p['distance'] as double) > _selectedDistance) {
        return false;
      }
      
      // Filter by type
      switch (_selectedFilter) {
        case 1: // Individuals
          return p['type'] == 'individual';
        case 2: // Agencies
          return p['type'] == 'agency';
        case 3: // Top Rated
          return (p['rating'] ?? 0) >= 4.8;
        default:
          return true;
      }
    }).toList();
    
    // Sort by distance
    filtered.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1D26)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D26),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Color(0xFF1A1D26)),
            onPressed: _showLocationFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs - Fixed (not scrollable)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: List.generate(_filters.length, (index) {
                final isSelected = _selectedFilter == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3366FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3366FF)
                              : const Color(0xFFE8ECF4),
                        ),
                      ),
                      child: Text(
                        _filters[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1A1D26),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Location indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  'Showing providers within ${_selectedDistance.toInt()} km',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  '${_filteredProviders.length} found',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3366FF),
                  ),
                ),
              ],
            ),
          ),
          // Provider List
          Expanded(
            child: _filteredProviders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredProviders.length,
                    itemBuilder: (context, index) {
                      return _buildProviderCard(_filteredProviders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showLocationFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter by Location',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1D26),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find professionals near your location',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Current location display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3366FF).withAlpha(26),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: Color(0xFF3366FF),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Location',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1D26),
                                ),
                              ),
                              Text(
                                'Using your GPS location',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8E99A4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Distance Range',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D26),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Distance options
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _distanceOptions.map((distance) {
                      final isSelected = _selectedDistance == distance;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _selectedDistance = distance;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF3366FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF3366FF)
                                  : const Color(0xFFE8ECF4),
                            ),
                          ),
                          child: Text(
                            '${distance.toInt()} km',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1A1D26),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {}); // Refresh main screen
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3366FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Filter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No providers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try increasing the distance range',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: _showLocationFilter,
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Change Filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    final hasImage = provider['imageUrl'] != null;
    final hasRating = provider['rating'] != null;
    final badge = provider['badge'] as String?;
    final isNewProvider = badge == 'NEW PROVIDER';
    final isElite = badge == 'ELITE';
    final distance = provider['distance'] as double;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: Row(
        children: [
          // Profile Image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8ECF4),
              border: Border.all(
                color: const Color(0xFFE8ECF4),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: hasImage
                  ? Image.network(
                      provider['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderAvatar(provider);
                      },
                    )
                  : _buildPlaceholderAvatar(provider),
            ),
          ),
          const SizedBox(width: 14),
          // Provider Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name with verified badge
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        provider['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D26),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (provider['isVerified'] == true) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF3366FF),
                        size: 18,
                      ),
                    ],
                    if (isElite) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3366FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ELITE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Rating or New Provider badge
                if (isNewProvider)
                  const Text(
                    'NEW PROVIDER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3366FF),
                    ),
                  )
                else if (hasRating)
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFC107),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider['rating'].toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D26),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${provider['reviews']} reviews',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                // Distance
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${distance.toStringAsFixed(1)} km away',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Price and Book Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '\$${provider['price']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1D26),
                      ),
                    ),
                    TextSpan(
                      text: '/h',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Show booking confirmation
                  _showBookingDialog(provider);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3366FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'BOOK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar(Map<String, dynamic> provider) {
    final isAgency = provider['type'] == 'agency';
    return Container(
      color: const Color(0xFFE8ECF4),
      child: Center(
        child: Icon(
          isAgency ? Icons.business : Icons.person,
          color: Colors.grey[400],
          size: 28,
        ),
      ),
    );
  }

  void _showBookingDialog(Map<String, dynamic> provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage(
          provider: provider,
          categoryName: widget.categoryName,
        ),
      ),
    );
  }
}

