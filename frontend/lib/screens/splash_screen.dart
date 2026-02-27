import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/partner_profile_data.dart';
import 'auth/login_screen.dart';
import 'main_navigation.dart';
import 'partner/partner_navigation.dart';
import 'partner/partner_onboarding_screen.dart';
import 'admin/admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Give the splash a short display time
    await Future.delayed(const Duration(seconds: 2));

    // Rehydrate auth state from secure storage
    await _authService.checkAuthStatus();

    if (!mounted) return;

    if (_authService.isLoggedIn) {
      final role = await _authService.getUserRole();

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } else if (role == 'worker' ||
          role == 'individual_partner' ||
          role == 'agency_partner') {
        final partnerData = PartnerProfileData.instance;
        if (partnerData.isProfileComplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PartnerNavigation()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PartnerOnboardingScreen()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo Row
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3366FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                // App Name
                const Text(
                  'Clenzy',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D26),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tagline
            const Text(
              'YOUR HOME, OUR CARE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8E99A4),
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 40),
            // Loading indicator
            const CircularProgressIndicator(
              color: Color(0xFF3366FF),
            ),
          ],
        ),
      ),
    );
  }
}
