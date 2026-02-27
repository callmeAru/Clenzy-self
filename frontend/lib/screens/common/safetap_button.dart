import 'package:flutter/material.dart';

typedef SafeTapCallback = Future<void> Function();

class SafeTapButton extends StatelessWidget {
  final SafeTapCallback onPressed;
  final bool isBusy;

  const SafeTapButton({
    super.key,
    required this.onPressed,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isBusy ? null : () async => onPressed(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF3B30),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.emergency_share_rounded),
        label: Text(
          'SafeTap Emergency',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.white,
          ),
        ),
      ),
    );
  }
}

