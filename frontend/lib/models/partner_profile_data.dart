// Partner Profile Data Model
// This stores the partner's profile information

import '../services/auth_service.dart';

class PartnerProfileData {
  String bio;
  String businessType;
  String businessName;
  bool useSameAsProfileName;
  List<Map<String, String>> teamMembers;
  List<String> selectedServices;
  List<String> customSkills;
  String city;
  double serviceRadius;
  String paymentMethod;
  String paymentId;
  bool nationalIdUploaded;
  bool certificateUploaded;
  String? nationalIdFileName;
  String? certificateFileName;
  bool isProfileComplete;
  String approvalStatus; // 'pending', 'approved', 'rejected'

  PartnerProfileData({
    this.bio = '',
    this.businessType = 'Individual',
    this.businessName = '',
    this.useSameAsProfileName = true,
    List<Map<String, String>>? teamMembers,
    List<String>? selectedServices,
    List<String>? customSkills,
    this.city = 'New York',
    this.serviceRadius = 15,
    this.paymentMethod = '',
    this.paymentId = '',
    this.nationalIdUploaded = false,
    this.certificateUploaded = false,
    this.nationalIdFileName,
    this.certificateFileName,
    this.isProfileComplete = false,
    this.approvalStatus = 'pending',
  })  : teamMembers = teamMembers ?? [],
        selectedServices = selectedServices ?? [],
        customSkills = customSkills ?? [];

  // Singleton instance
  static PartnerProfileData? _instance;

  static PartnerProfileData get instance {
    _instance ??= PartnerProfileData();
    return _instance!;
  }

  static void updateInstance(PartnerProfileData data) {
    _instance = data;
  }

  // Mark profile as complete
  void markAsComplete() {
    isProfileComplete = true;
    approvalStatus = 'pending';
  }

  // Get all services (selected + custom)
  List<String> get allServices => [...selectedServices, ...customSkills];

  // Get the current user's name from AuthService
  String get _currentUserName {
    final user = AuthService().currentUser;
    if (user?.email != null) {
      return user!.email.split('@').first;
    }
    return 'Partner';
  }

  // Get display name
  String get displayName {
    if (businessType == 'Individual' && useSameAsProfileName) {
      return _currentUserName;
    }
    return businessName.isNotEmpty ? businessName : 'Partner';
  }
}
