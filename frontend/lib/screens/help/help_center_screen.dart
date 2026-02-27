import 'package:flutter/material.dart';

import '../common/safetap_button.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  // Track which FAQ items are expanded
  final Map<int, bool> _expandedItems = {};

  // FAQ data with questions and answers
  final List<Map<String, dynamic>> _faqItems = [
    {
      'icon': Icons.calendar_today_rounded,
      'iconColor': const Color(0xFF3366FF),
      'question': 'Booking Issues',
      'answer': 'Having trouble with your booking? You can reschedule or cancel any booking from the "Bookings" tab. If a worker doesn\'t show up, contact our support immediately and we\'ll find a replacement or issue a full refund.',
    },
    {
      'icon': Icons.account_balance_wallet_rounded,
      'iconColor': const Color(0xFFFF9800),
      'question': 'Payments & Refunds',
      'answer': 'We accept all major payment methods including credit cards, debit cards, and UPI. Refunds are processed within 3-5 business days. If you were charged incorrectly, please contact support with your booking ID.',
    },
    {
      'icon': Icons.verified_user_rounded,
      'iconColor': const Color(0xFF4CAF50),
      'question': 'Safety & Verification',
      'answer': 'All our service partners undergo thorough background checks and ID verification. Each partner is rated by customers like you. We also provide a safety guarantee that covers any damages during service.',
    },
    {
      'icon': Icons.people_rounded,
      'iconColor': const Color(0xFF9C27B0),
      'question': 'Account Settings',
      'answer': 'You can update your profile, change password, manage saved addresses, and update payment methods from the Profile tab. To delete your account, please contact our support team.',
    },
    {
      'icon': Icons.work_rounded,
      'iconColor': const Color(0xFF00BCD4),
      'question': 'Become a Partner',
      'answer': 'Want to offer your services on Clenzy? Switch to Partner Mode from your Profile to register as a service provider. You\'ll need to complete verification and training before you can start accepting jobs.',
    },
    {
      'icon': Icons.star_rounded,
      'iconColor': const Color(0xFFFFC107),
      'question': 'Ratings & Reviews',
      'answer': 'After each completed service, you\'ll be asked to rate your experience. Your feedback helps us maintain quality. You can also view ratings and reviews of service providers before booking.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Help Center',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D26),
                  ),
                ),
                const SizedBox(height: 24),
                // Need Immediate Help Section
                const Text(
                  'Need Immediate Help?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D26),
                  ),
                ),
                const SizedBox(height: 16),
                // Emergency Support & Live Chat Cards
                Row(
                  children: [
                    Expanded(child: _buildEmergencySupportCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLiveChatCard()),
                  ],
                ),
                const SizedBox(height: 16),
                SafeTapButton(
                  onPressed: () async {
                    // This screen is not tied to a specific job,
                    // so for now we only show a confirmation.
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'In an active job, SafeTap will alert nearby centers from the job screen.',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Common Questions Header
                const Text(
                  'Common Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D26),
                  ),
                ),
                const SizedBox(height: 16),
                // FAQ List with expandable answers
                ...List.generate(_faqItems.length, (index) {
                  return _buildFaqItem(index, _faqItems[index]);
                }),
                const SizedBox(height: 40),
                // Still Need Help Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF1F8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Still need help?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1D26),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Our team is here to support you 24/7',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email Support Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.email_rounded, size: 20),
                          label: const Text(
                            'Email Support',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3366FF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Footer
                Center(
                  child: Text(
                    'Clenzy TRUST & SAFETY TEAM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[400],
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencySupportCard() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF7E5F),
            Color(0xFFFF6B6B),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(26),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Emergency\nSupport',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SAFETY FIRST',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withAlpha(179),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveChatCard() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4ECDC4),
            Color(0xFF44A08D),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -10,
            top: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Live Chat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'WAIT: ~2 MINS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withAlpha(179),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(int index, Map<String, dynamic> item) {
    final isExpanded = _expandedItems[index] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: Column(
        children: [
          // Question row (tappable)
          InkWell(
            onTap: () {
              setState(() {
                _expandedItems[index] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (item['iconColor'] as Color).withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['iconColor'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item['question'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1D26),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF3366FF),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Answer section (expandable)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item['answer'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
