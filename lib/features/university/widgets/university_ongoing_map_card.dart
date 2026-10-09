import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_active_trip_model.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import 'package:ride_sharing_user_app/util/images.dart';

class UniversityOngoingMapCard extends StatefulWidget {
  final UniversityActiveTripModel trip;

  const UniversityOngoingMapCard({
    super.key,
    required this.trip,
  });

  @override
  State<UniversityOngoingMapCard> createState() =>
      _UniversityOngoingMapCardState();
}

class _UniversityOngoingMapCardState extends State<UniversityOngoingMapCard> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _roadRoutePoints = [];
  BitmapDescriptor? _carMarkerIcon;
  bool _userInteractedWithMap = false;

  @override
  void initState() {
    super.initState();
    _loadCustomCarIcon();
    _buildMapData();
    _fetchRoadRoute();
  }

  Future<void> _loadCustomCarIcon() async {
    try {
      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(40, 40)),
        Images.mapLocationIcon,
      );
      if (mounted) {
        setState(() {
          _carMarkerIcon = icon;
          _buildMapData();
        });
      }
    } catch (e) {
      debugPrint('Error loading custom car icon: $e');
    }
  }

  @override
  void didUpdateWidget(covariant UniversityOngoingMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip != widget.trip) {
      _buildMapData();
      _fetchRoadRoute();
      if (!_userInteractedWithMap) {
        _fitMapBounds();
      }
    }
  }

  Future<void> _fetchRoadRoute() async {
    final trip = widget.trip;
    final pickupPos = LatLng(trip.pickupLatitude, trip.pickupLongitude);
    final destPos = LatLng(trip.destinationLatitude, trip.destinationLongitude);
    final driverPos = LatLng(
      trip.driverLatitude ??
          ((trip.pickupLatitude + trip.destinationLatitude) / 2),
      trip.driverLongitude ??
          ((trip.pickupLongitude + trip.destinationLongitude) / 2),
    );

    try {
      final roadPts = await MapBoundHelper.getDrivingRoute(
        pickupPos,
        destPos,
        waypoints: [driverPos],
      );
      if (mounted && roadPts.length >= 2) {
        setState(() {
          _roadRoutePoints = roadPts;
          _buildMapData();
        });
      }
    } catch (e) {
      debugPrint('Error fetching university road route: $e');
    }
  }

  void _buildMapData() {
    _markers.clear();
    _polylines.clear();

    final trip = widget.trip;
    final pickupPos = LatLng(trip.pickupLatitude, trip.pickupLongitude);
    final destPos = LatLng(trip.destinationLatitude, trip.destinationLongitude);
    final driverPos = LatLng(
      trip.driverLatitude ??
          ((trip.pickupLatitude + trip.destinationLatitude) / 2),
      trip.driverLongitude ??
          ((trip.pickupLongitude + trip.destinationLongitude) / 2),
    );

    // 1. Pickup Marker (Green)
    _markers.add(
      Marker(
        markerId: const MarkerId('trip_pickup'),
        position: pickupPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: trip.pickupPoint,
          snippet: trip.pickupAddress,
        ),
      ),
    );

    // 2. Destination Marker (Red)
    _markers.add(
      Marker(
        markerId: const MarkerId('trip_destination'),
        position: destPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: trip.universityName,
          snippet: trip.destinationAddress,
        ),
      ),
    );

    // 3. Driver Marker (Car asset icon)
    _markers.add(
      Marker(
        markerId: const MarkerId('trip_driver'),
        position: driverPos,
        icon: _carMarkerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: trip.driver.name,
          snippet: '${trip.driver.vehicleName} · ${trip.driver.plateNumber}',
        ),
      ),
    );

    // 4. Route Polyline
    final List<LatLng> polyPoints = _roadRoutePoints.length >= 2
        ? _roadRoutePoints
        : [pickupPos, driverPos, destPos];

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('ongoing_trip_route'),
        points: polyPoints,
        color: const Color(0xFF047857),
        width: 4,
        patterns: [
          PatternItem.dash(12),
          PatternItem.gap(6),
        ],
      ),
    );
  }

  void _fitMapBounds({bool force = false}) {
    if (_mapController == null) return;
    if (_userInteractedWithMap && !force) return;

    final trip = widget.trip;
    final points = [
      LatLng(trip.pickupLatitude, trip.pickupLongitude),
      LatLng(
        trip.driverLatitude ??
            ((trip.pickupLatitude + trip.destinationLatitude) / 2),
        trip.driverLongitude ??
            ((trip.pickupLongitude + trip.destinationLongitude) / 2),
      ),
      LatLng(trip.destinationLatitude, trip.destinationLongitude),
    ];

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        48,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final initialCenter = LatLng(
      trip.driverLatitude ??
          ((trip.pickupLatitude + trip.destinationLatitude) / 2),
      trip.driverLongitude ??
          ((trip.pickupLongitude + trip.destinationLongitude) / 2),
    );

    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Google Map View
            GoogleMap(
              key: ValueKey('ongoing_trip_map_${trip.id}'),
              initialCameraPosition: CameraPosition(
                target: initialCenter,
                zoom: 12.5,
              ),
              markers: _markers,
              polylines: _polylines,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              onCameraMoveStarted: () {
                if (!_userInteractedWithMap) {
                  setState(() {
                    _userInteractedWithMap = true;
                  });
                }
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              style: Get.isRegistered<ThemeController>()
                  ? (Get.isDarkMode
                      ? Get.find<ThemeController>().darkMap
                      : Get.find<ThemeController>().lightMap)
                  : null,
              onMapCreated: (controller) {
                _mapController = controller;
                _fitMapBounds();
              },
            ),

            // Live badge overlay (Top-Left)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'live'.tr,
                      style: textSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recenter Map Button (Bottom-Right)
            Positioned(
              bottom: 14,
              right: 14,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _userInteractedWithMap = false;
                  });
                  _fitMapBounds(force: true);
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.my_location_rounded,
                      size: 18,
                      color: Color(0xFF00A0E9),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
================================================================================
ARCHIVED CODE - REPLACED BY GOOGLE MAP IMPLEMENTATION
================================================================================
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0).withOpacity(0.8)
      ..strokeWidth = 1.0;

    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePolylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF047857)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final start = const Offset(55, 45);
    final end = const Offset(310, 190);

    final totalDistance = (end - start).distance;
    const dashLength = 8.0;
    const gapLength = 6.0;
    double currentDistance = 0.0;

    final normalized = (end - start) / totalDistance;

    while (currentDistance < totalDistance) {
      final p1 = start + normalized * currentDistance;
      final p2 = start + normalized * (currentDistance + dashLength).clamp(0.0, totalDistance);
      canvas.drawLine(p1, p2, paint);
      currentDistance += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
================================================================================
*/

/*
Archived Code:
    // 3. Driver Marker (Cyan / Azure)
    _markers.add(
      Marker(
        markerId: const MarkerId('trip_driver'),
        position: driverPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: trip.driver.name,
          snippet: '${trip.driver.vehicleName} · ${trip.driver.plateNumber}',
        ),
      ),
    );
*/

