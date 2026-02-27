import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/location_service.dart';
import '../../services/safetap_service.dart';
import '../common/safetap_button.dart';

class ActiveJobSafetapSheet extends StatefulWidget {
  final int jobId;

  const ActiveJobSafetapSheet({
    super.key,
    required this.jobId,
  });

  @override
  State<ActiveJobSafetapSheet> createState() => _ActiveJobSafetapSheetState();
}

class _ActiveJobSafetapSheetState extends State<ActiveJobSafetapSheet> {
  final TextEditingController _notesController = TextEditingController();
  final SafetapService _safetapService = SafetapService();
  final LocationService _locationService = LocationService();

  bool _sending = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _sendPanic() async {
    setState(() {
      _sending = true;
    });

    try {
      Position? position = await _locationService.getCurrentLocation();

      await _safetapService.triggerPanic(
        jobId: widget.jobId,
        latitude: position?.latitude,
        longitude: position?.longitude,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency alert sent to the nearest center.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send emergency alert. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              'SafeTap Emergency',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This will immediately alert nearby emergency partners and our safety team for Job #${widget.jobId}.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add any details that help responders (optional)…',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 20),
            SafeTapButton(
              isBusy: _sending,
              onPressed: _sendPanic,
            ),
            const SizedBox(height: 12),
            Text(
              'Use only when you or your worker feel unsafe during an active job.',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

