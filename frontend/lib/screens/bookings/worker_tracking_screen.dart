import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/location_service.dart';

class WorkerTrackingScreen extends StatefulWidget {
  final String jobId;
  final bool isWorker;

  const WorkerTrackingScreen({
    super.key,
    required this.jobId,
    this.isWorker = false,
  });

  @override
  State<WorkerTrackingScreen> createState() => _WorkerTrackingScreenState();
}

class _WorkerTrackingScreenState extends State<WorkerTrackingScreen> {
  final LocationService _locationService = LocationService();
  StreamSubscription<Map<String, dynamic>?>? _locationSub;

  Map<String, dynamic>? _latestLocation;
  bool _connecting = true;

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  Future<void> _initTracking() async {
    await _locationService.connectWebSocket();

    // If this screen is opened by a worker, start sending their live location.
    if (widget.isWorker) {
      _locationService.startLiveTracking(widget.jobId);
    }

    _locationSub = _locationService.streamLiveLocation(widget.jobId).listen(
      (location) {
        if (!mounted) return;
        setState(() {
          _latestLocation = location;
        });
      },
    );

    if (mounted) {
      setState(() {
        _connecting = false;
      });
    }
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _locationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Worker Location'),
      ),
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Job #${widget.jobId}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF1A1D26),
                ),
              ),
              const SizedBox(height: 16),
              if (_connecting)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_latestLocation == null)
                _buildWaitingForLocation(isDark)
              else
                _buildLocationDetails(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingForLocation(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Waiting for live location…',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF1A1D26),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Once the worker starts sharing location, you will see their movement here in real time.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDetails(bool isDark) {
    final data = _latestLocation ?? {};
    final latitude = (data['latitude'] as num?)?.toDouble();
    final longitude = (data['longitude'] as num?)?.toDouble();
    final speed = (data['speed'] as num?)?.toDouble();
    final heading = (data['heading'] as num?)?.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              Text(
                'Current coordinates',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF1A1D26),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Latitude: ${latitude?.toStringAsFixed(6) ?? '-'}\n'
                'Longitude: ${longitude?.toStringAsFixed(6) ?? '-'}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.navigation_rounded,
                    size: 18,
                    color: const Color(0xFF3366FF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    heading != null
                        ? 'Heading: ${heading.toStringAsFixed(1)}°'
                        : 'Heading: –',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.speed_rounded,
                    size: 18,
                    color: const Color(0xFF3366FF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    speed != null
                        ? 'Speed: ${speed.toStringAsFixed(1)} m/s'
                        : 'Speed: –',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Tip: In production, you can replace this card with a live map (e.g., Google Maps) and move a marker using these coordinates.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

