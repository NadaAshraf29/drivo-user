import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/special_trip_model.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/trip_location_point.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';

class SpecialTripMapWidget extends StatefulWidget {
  final List<TripLocationPoint> pickupPoints;
  final List<TripLocationPoint> destinationPoints;
  final SpecialTripDriverModel? driver;
  final double height;
  final bool isInteractive;

  const SpecialTripMapWidget({
    super.key,
    required this.pickupPoints,
    required this.destinationPoints,
    this.driver,
    this.height = 200,
    this.isInteractive = true,
  });

  @override
  State<SpecialTripMapWidget> createState() => _SpecialTripMapWidgetState();
}

class _SpecialTripMapWidgetState extends State<SpecialTripMapWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _currentRoutePoints = [];
  bool _isFetchingRoute = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _buildMarkersAndPolylines();
  }

  @override
  void didUpdateWidget(covariant SpecialTripMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _buildMarkersAndPolylines();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _buildMarkersAndPolylines() {
    _markers.clear();
    _polylines.clear();

    final List<LatLng> waypointList = [];

    // Valid Pickups
    final validPickups = widget.pickupPoints.where((p) => p.isValid).toList();
    for (int i = 0; i < validPickups.length; i++) {
      final p = validPickups[i];
      final latLng = MapBoundHelper.toCorrectLatLng(p.latitude, p.longitude);
      waypointList.add(latLng);

      _markers.add(
        Marker(
          markerId: MarkerId('pickup_${p.id}'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: InfoWindow(
            title: 'P${i + 1}: ${p.name}',
            snippet: p.address,
          ),
        ),
      );
    }

    // Valid Destinations
    final validDestinations =
        widget.destinationPoints.where((d) => d.isValid).toList();
    for (int i = 0; i < validDestinations.length; i++) {
      final d = validDestinations[i];
      final latLng = MapBoundHelper.toCorrectLatLng(d.latitude, d.longitude);
      waypointList.add(latLng);

      _markers.add(
        Marker(
          markerId: MarkerId('destination_${d.id}'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'D${i + 1}: ${d.name}',
            snippet: d.address,
          ),
        ),
      );
    }

    // Driver Marker if available
    if (widget.driver != null &&
        widget.driver!.latitude != null &&
        widget.driver!.longitude != null) {
      final driverLatLng = MapBoundHelper.toCorrectLatLng(
          widget.driver!.latitude!, widget.driver!.longitude!);
      _markers.add(
        Marker(
          markerId: const MarkerId('driver_location'),
          position: driverLatLng,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: widget.driver!.name,
            snippet: widget.driver!.vehicleName,
          ),
        ),
      );
    }

    // Initial polyline (use cached road points or straight-line fallback)
    if (_currentRoutePoints.isNotEmpty) {
      _applyPolylines(_currentRoutePoints);
    } else if (waypointList.length >= 2) {
      _applyPolylines(waypointList);
    }

    if (mounted) {
      setState(() {});
    }

    // Asynchronously fetch real turn-by-turn road navigation route
    if (waypointList.length >= 2) {
      _fetchRoadRoute(waypointList);
    } else {
      _fitBounds();
    }
  }

  void _applyPolylines(List<LatLng> points) {
    _polylines.clear();
    // Route border / glow casing
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('special_trip_route_casing'),
        points: points,
        color: const Color(0xFF0284C7).withValues(alpha: 0.35),
        width: 7,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    );
    // Core road navigation line
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('special_trip_route'),
        points: points,
        color: const Color(0xFF00A0E9),
        width: 4,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    );
  }

  Future<void> _fetchRoadRoute(List<LatLng> waypoints) async {
    if (_isFetchingRoute) return;

    _isFetchingRoute = true;
    if (mounted) {
      setState(() {});
    }

    try {
      final origin = waypoints.first;
      final destination = waypoints.last;
      final midPoints = waypoints.length > 2
          ? waypoints.sublist(1, waypoints.length - 1)
          : null;

      final roadPoints = await MapBoundHelper.getDrivingRoute(
        origin,
        destination,
        waypoints: midPoints,
      );

      if (!mounted) return;
      if (roadPoints.length >= 2) {
        _currentRoutePoints = roadPoints;
        setState(() {
          _applyPolylines(roadPoints);
        });
        _fitBounds(routePoints: roadPoints);
      } else {
        _fitBounds();
      }
    } catch (e) {
      debugPrint('Error fetching driving route for special trip: $e');
      if (mounted) {
        _fitBounds();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingRoute = false;
        });
      }
    }
  }

  void _fitBounds({List<LatLng>? routePoints}) {
    if (_mapController == null) return;

    final List<LatLng> allCoords = [];
    if (routePoints != null && routePoints.isNotEmpty) {
      allCoords.addAll(routePoints);
    } else {
      for (final p in widget.pickupPoints.where((p) => p.isValid)) {
        allCoords.add(MapBoundHelper.toCorrectLatLng(p.latitude, p.longitude));
      }
      for (final d in widget.destinationPoints.where((d) => d.isValid)) {
        allCoords.add(MapBoundHelper.toCorrectLatLng(d.latitude, d.longitude));
      }
      if (widget.driver != null &&
          widget.driver!.latitude != null &&
          widget.driver!.longitude != null) {
        allCoords.add(MapBoundHelper.toCorrectLatLng(
            widget.driver!.latitude!, widget.driver!.longitude!));
      }
    }

    if (allCoords.isEmpty) return;

    if (allCoords.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(allCoords.first, 14),
      );
      return;
    }

    double minLat = allCoords.first.latitude;
    double maxLat = allCoords.first.latitude;
    double minLng = allCoords.first.longitude;
    double maxLng = allCoords.first.longitude;

    for (final point in allCoords) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _recenter() {
    _fitBounds(
      routePoints: _currentRoutePoints.isNotEmpty ? _currentRoutePoints : null,
    );
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _recenter();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Default initial location: first valid pickup or Cairo center
    LatLng initialPosition = const LatLng(30.0444, 31.2357);
    TripLocationPoint? firstValidPickup;
    for (final p in widget.pickupPoints) {
      if (p.isValid) {
        firstValidPickup = p;
        break;
      }
    }
    if (firstValidPickup != null) {
      initialPosition = MapBoundHelper.toCorrectLatLng(
          firstValidPickup.latitude, firstValidPickup.longitude);
    }

    final currentHeight =
        _isExpanded ? (widget.height * 1.7).clamp(340.0, 480.0) : widget.height;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: currentHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: 12,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _fitBounds(
                  routePoints: _currentRoutePoints.isNotEmpty
                      ? _currentRoutePoints
                      : null,
                );
              },
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              scrollGesturesEnabled: widget.isInteractive,
              zoomGesturesEnabled: widget.isInteractive,
              rotateGesturesEnabled: widget.isInteractive,
              tiltGesturesEnabled: widget.isInteractive,
              gestureRecognizers: widget.isInteractive
                  ? <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    }
                  : const <Factory<OneSequenceGestureRecognizer>>{},
            ),

            // Controls Overlay (Expand, Recenter, Zoom In, Zoom Out)
            if (widget.isInteractive)
              Positioned(
                top: 10,
                right: 10,
                child: Column(
                  children: [
                    // Expand/Collapse Map
                    _MapActionButton(
                      icon: _isExpanded
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      tooltip: _isExpanded ? 'Collapse' : 'Expand',
                      onTap: _toggleExpand,
                    ),
                    const SizedBox(height: 6),

                    // Recenter / Fit Route
                    _MapActionButton(
                      icon: Icons.my_location_rounded,
                      tooltip: 'Fit Route',
                      iconColor: const Color(0xFF00A0E9),
                      onTap: _recenter,
                    ),
                    const SizedBox(height: 10),

                    // Zoom In
                    _MapActionButton(
                      icon: Icons.add_rounded,
                      tooltip: 'Zoom In',
                      onTap: _zoomIn,
                    ),
                    const SizedBox(height: 6),

                    // Zoom Out
                    _MapActionButton(
                      icon: Icons.remove_rounded,
                      tooltip: 'Zoom Out',
                      onTap: _zoomOut,
                    ),
                  ],
                ),
              ),

            // Loading Route Indicator
            if (_isFetchingRoute)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF00A0E9),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'loading_route'.tr.isNotEmpty &&
                                'loading_route'.tr != 'loading_route'
                            ? 'loading_route'.tr
                            : 'Loading route...',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? iconColor;

  const _MapActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }
}
