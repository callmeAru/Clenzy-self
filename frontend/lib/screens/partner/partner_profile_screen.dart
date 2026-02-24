import 'package:flutter/material.dart';
import '../../models/partner_profile_data.dart';
import '../main_navigation.dart';

class PartnerProfileScreen extends StatefulWidget {
  final bool isEditMode;
  
  const PartnerProfileScreen({
    super.key, 
    this.isEditMode = true, // Default is edit mode for approved partners
  });

  @override
  State<PartnerProfileScreen> createState() => _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends State<PartnerProfileScreen> {
  late String _businessType;
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final bool _isPartnerMode = true;
  bool _hasChanges = false;

  // Load from singleton
  late List<String> _selectedServices;
  late List<String> _customSkills;
  late String _selectedCity;
  late double _serviceRadius;
  late String _selectedPaymentMethod;
  late bool _nationalIdUploaded;
  late bool _certificateUploaded;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final data = PartnerProfileData.instance;
    _businessType = data.businessType;
    _bioController.text = data.bio;
    _upiController.text = data.paymentId;
    _selectedServices = List.from(data.selectedServices);
    _customSkills = List.from(data.customSkills);
    _selectedCity = data.city;
    _serviceRadius = data.serviceRadius;
    _selectedPaymentMethod = data.paymentMethod;
    _nationalIdUploaded = data.nationalIdUploaded;
    _certificateUploaded = data.certificateUploaded;
  }

  @override
  void dispose() {
    _upiController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void _submitChanges() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Color(0xFFFF9800),
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Changes Submitted',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D26),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your profile changes have been submitted for re-approval. You can continue using the app while we review.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3366FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1A1D26),
            size: 20,
          ),
          onPressed: () {
            if (_hasChanges) {
              _showDiscardChangesDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D26),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 20),
            // Partner Mode Switch
            _buildPartnerModeCard(),
            const SizedBox(height: 20),
            // Professional Bio Section
            _buildProfessionalBioSection(),
            const SizedBox(height: 20),
            // Business Type Section
            _buildBusinessTypeSection(),
            const SizedBox(height: 20),
            // Service Expertise Section
            _buildServiceExpertiseSection(),
            const SizedBox(height: 20),
            // Service Area Section
            _buildServiceAreaSection(),
            const SizedBox(height: 20),
            // UPI Details Section
            _buildUpiDetailsSection(),
            const SizedBox(height: 20),
            // Identity & Certifications Section
            _buildIdentityCertificationsSection(),
            const SizedBox(height: 24),
            // Security Note
            _buildSecurityNote(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _hasChanges ? _buildSaveChangesButton() : null,
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade300,
                  Colors.blue.shade500,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alex Johnson',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D26),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Verified Partner',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerModeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8ECF4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Partner Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D26),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withAlpha(26),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Switch to user mode to book services',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isPartnerMode,
              onChanged: (value) {
                if (!value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainNavigation()),
                  );
                }
              },
              activeThumbColor: const Color(0xFF3366FF),
              activeTrackColor: const Color(0xFF3366FF).withAlpha(77),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String status,
    required Color statusColor,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8ECF4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1D26),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        status == 'VERIFIED' ? Icons.check_circle : Icons.warning_rounded,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalBioSection() {
    return _buildSectionCard(
      title: 'Professional Bio',
      status: 'VERIFIED',
      statusColor: const Color(0xFF4CAF50),
      child: TextField(
        controller: _bioController,
        maxLines: 4,
        onChanged: (_) => _markAsChanged(),
        decoration: InputDecoration(
          hintText: 'Describe your experience...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          filled: true,
          fillColor: const Color(0xFFF8F9FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessTypeSection() {
    return _buildSectionCard(
      title: 'Business Type',
      status: 'VERIFIED',
      statusColor: const Color(0xFF4CAF50),
      child: Row(
        children: [
          _buildBusinessTypeChip('Individual', _businessType == 'Individual'),
          const SizedBox(width: 12),
          _buildBusinessTypeChip('Team / Company', _businessType == 'Team / Company'),
        ],
      ),
    );
  }

  Widget _buildBusinessTypeChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _businessType = label);
        _markAsChanged();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3366FF).withAlpha(26) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF3366FF) : const Color(0xFFE8ECF4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFF3366FF) : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceExpertiseSection() {
    return _buildSectionCard(
      title: 'Service Expertise',
      status: 'VERIFIED',
      statusColor: const Color(0xFF4CAF50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._selectedServices.map((s) => _buildSkillChip(s, const Color(0xFF3366FF))),
              ..._customSkills.map((s) => _buildSkillChip(s, const Color(0xFF4CAF50))),
              _buildAddSkillChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedServices.remove(label);
                _customSkills.remove(label);
              });
              _markAsChanged();
            },
            child: Icon(Icons.close, size: 14, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSkillChip() {
    return GestureDetector(
      onTap: () => _showAddSkillDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE8ECF4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text('Add Skill', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  void _showAddSkillDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Skill'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter skill name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _customSkills.add(controller.text));
                _markAsChanged();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceAreaSection() {
    return _buildSectionCard(
      title: 'Service Area',
      status: 'VERIFIED',
      statusColor: const Color(0xFF4CAF50),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LOCATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey[400])),
                  const SizedBox(height: 4),
                  Text(_selectedCity, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1D26))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('RADIUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey[400])),
                  const SizedBox(height: 4),
                  Text('${_serviceRadius.toInt()} miles', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3366FF))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _serviceRadius,
            min: 5,
            max: 50,
            onChanged: (value) {
              setState(() => _serviceRadius = value);
              _markAsChanged();
            },
            activeColor: const Color(0xFF3366FF),
            inactiveColor: const Color(0xFFE8ECF4),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiDetailsSection() {
    return _buildSectionCard(
      title: 'Payment Details',
      status: 'VERIFIED',
      statusColor: const Color(0xFF4CAF50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.g_mobiledata, color: Color(0xFF4285F4)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedPaymentMethod, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1D26))),
                    Text(_upiController.text, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Show edit payment dialog
                  _markAsChanged();
                },
                child: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCertificationsSection() {
    return _buildSectionCard(
      title: 'Identity & Certifications',
      status: _certificateUploaded ? 'VERIFIED' : '1 LEFT',
      statusColor: _certificateUploaded ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
      child: Row(
        children: [
          Expanded(child: _buildDocumentCard('National ID', Icons.badge_outlined, _nationalIdUploaded, 'Verified')),
          const SizedBox(width: 12),
          Expanded(child: _buildDocumentCard('Certificate', Icons.workspace_premium_outlined, _certificateUploaded, _certificateUploaded ? 'Verified' : 'Optional')),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(String title, IconData icon, bool isVerified, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isVerified ? const Color(0xFF4CAF50).withAlpha(77) : const Color(0xFFE8ECF4)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isVerified ? const Color(0xFF4CAF50).withAlpha(26) : const Color(0xFFE8ECF4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: isVerified ? const Color(0xFF4CAF50) : Colors.grey[400], size: 22),
              ),
              if (isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1A1D26))),
          const SizedBox(height: 2),
          Text(status, style: TextStyle(fontSize: 10, color: isVerified ? const Color(0xFF4CAF50) : Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 6),
          Text('Your data is securely processed', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildSaveChangesButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submitChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3366FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
