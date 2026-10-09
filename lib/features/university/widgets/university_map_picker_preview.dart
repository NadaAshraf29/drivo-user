import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/university/controllers/university_controller.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_pickup_point_model.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_trip_model.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class UniversityMapPickerPreview extends StatefulWidget {
  final VoidCallback onViewMap;
  final ValueChanged<String>? onSelectPoint;
  final UniversityTripModel? trip;
  final String? selectedPickupPoint;
  final List<UniversityPickupPointModel>? pickupPoints;
  final Function(double lat, double lng, String name)? onNavigate;

  const UniversityMapPickerPreview({
    super.key,
    required this.onViewMap,
    this.onSelectPoint,
    this.trip,
    this.selectedPickupPoint,
    this.pickupPoints,
    this.onNavigate,
  });

  @override
  State<UniversityMapPickerPreview> createState() =>
      _UniversityMapPickerPreviewState();
}

class _UniversityMapPickerPreviewState
    extends State<UniversityMapPickerPreview> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _buildMapData();
    _fetchRealRoadRoute();
  }

  @override
  void didUpdateWidget(covariant UniversityMapPickerPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip != widget.trip ||
        oldWidget.selectedPickupPoint != widget.selectedPickupPoint ||
        oldWidget.pickupPoints != widget.pickupPoints) {
      _buildMapData();
      _fetchRealRoadRoute();
      _fitMapBounds();
    }
  }

  Future<void> _fetchRealRoadRoute() async {
    final startPos = _resolveStartLatLng();
    final dropoffPos = _resolveDropoffLatLng();

    List<UniversityPickupPointModel> points = widget.pickupPoints ??
        (Get.isRegistered<UniversityController>()
            ? Get.find<UniversityController>().availablePickupPoints
            : []);

    final List<LatLng> waypoints = [];
    for (var p in points) {
      if (p.latitude != null &&
          p.longitude != null &&
          p.latitude != 0 &&
          p.longitude != 0) {
        waypoints.add(MapBoundHelper.toCorrectLatLng(p.latitude!, p.longitude!));
      }
    }

    List<LatLng> realRoute = [];
    if (startPos != null && dropoffPos != null) {
      realRoute = await MapBoundHelper.getDrivingRoute(
        startPos,
        dropoffPos,
        waypoints: waypoints,
      );
    }

    if (realRoute.length < 2 && _routePoints.length >= 2) {
      realRoute = List<LatLng>.from(_routePoints);
    } else if (realRoute.length < 2 && startPos != null && dropoffPos != null) {
      realRoute = [startPos, ...waypoints, dropoffPos];
    }

    if (realRoute.length >= 2 && mounted) {
      setState(() {
        _routePoints = realRoute;
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('driver_route_casing'),
            points: _routePoints,
            color: const Color(0xFF00A0E9).withValues(alpha: 0.28),
            width: 7,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        );
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('driver_route_core'),
            points: _routePoints,
            color: const Color(0xFF00A0E9),
            width: 4,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        );
      });
      _fitMapBounds();
    }
  }

  void _buildMapData() {
    _markers.clear();
    _polylines.clear();
    _routePoints.clear();

    // 1. Gather all pickup points
    List<UniversityPickupPointModel> points = [];
    if (widget.pickupPoints != null && widget.pickupPoints!.isNotEmpty) {
      points = widget.pickupPoints!;
    } else if (Get.isRegistered<UniversityController>()) {
      points = Get.find<UniversityController>().availablePickupPoints;
    }

    final selectedName = widget.selectedPickupPoint?.trim().toLowerCase() ?? '';

    // 2. Decode or construct Driver Route polyline points
    if (widget.trip != null) {
      _routePoints = MapBoundHelper.getRoutePolylinePoints(widget.trip);
    }

    // 3. Fallback: Connect available points in sequence to university dropoff
    if (_routePoints.isEmpty) {
      final List<LatLng> collected = [];

      final startPos = _resolveStartLatLng();
      if (startPos != null && startPos.latitude != 0 && startPos.longitude != 0) {
        collected.add(startPos);
      }

      for (var p in points) {
        if (p.latitude != null &&
            p.longitude != null &&
            p.latitude != 0 &&
            p.longitude != 0) {
          final latLng = MapBoundHelper.toCorrectLatLng(p.latitude!, p.longitude!);
          if (!collected.any((existing) =>
              (existing.latitude - latLng.latitude).abs() < 0.0001 &&
              (existing.longitude - latLng.longitude).abs() < 0.0001)) {
            collected.add(latLng);
          }
        }
      }

      final dropoffPos = _resolveDropoffLatLng();
      if (dropoffPos != null && dropoffPos.latitude != 0 && dropoffPos.longitude != 0) {
        if (!collected.any((existing) =>
            (existing.latitude - dropoffPos.latitude).abs() < 0.0001 &&
            (existing.longitude - dropoffPos.longitude).abs() < 0.0001)) {
          collected.add(dropoffPos);
        }
      }

      _routePoints = collected;
    }

    // 4. Build Route Polylines
    if (_routePoints.length >= 2) {
      // Glow/Casing polyline
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_route_casing'),
          points: _routePoints,
          color: const Color(0xFF00A0E9).withValues(alpha: 0.28),
          width: 7,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );

      // Core Driver Route Polyline
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_route_core'),
          points: _routePoints,
          color: const Color(0xFF00A0E9),
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    }

    // 5. Pickup Points Markers
    for (var p in points) {
      if (p.latitude != null &&
          p.longitude != null &&
          p.latitude != 0 &&
          p.longitude != 0) {
        final pos = MapBoundHelper.toCorrectLatLng(p.latitude!, p.longitude!);
        final isSelected = selectedName.isNotEmpty &&
            (p.name.trim().toLowerCase() == selectedName ||
                selectedName.contains(p.name.trim().toLowerCase()) ||
                p.name.trim().toLowerCase().contains(selectedName));

        _markers.add(
          Marker(
            markerId: MarkerId('pickup_${p.id.isNotEmpty ? p.id : p.name}'),
            position: pos,
            zIndex: isSelected ? 10.0 : 2.0,
            infoWindow: InfoWindow(
              title: isSelected ? '★ ${p.name} (Selected Pickup)' : p.name,
              snippet: p.timing.isNotEmpty ? p.timing : 'Pickup Stop',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isSelected ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRose,
            ),
            onTap: () => widget.onSelectPoint?.call(p.name),
          ),
        );
      }
    }

    // 6. Driver Start Marker (if available)
    final startPos = _resolveStartLatLng();
    if (startPos != null && startPos.latitude != 0 && startPos.longitude != 0) {
      _markers.add(
        Marker(
          markerId: const MarkerId('driver_route_start'),
          position: startPos,
          zIndex: 3.0,
          infoWindow: InfoWindow(
            title: widget.trip?.fromArea.isNotEmpty == true
                ? widget.trip!.fromArea
                : 'Start Point',
            snippet: 'Driver Route Start',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    // 7. Drop-off / University Destination Marker (Always included)
    final destPos = _resolveDropoffLatLng();
    if (destPos != null && destPos.latitude != 0 && destPos.longitude != 0) {
      final destName = _resolveDropoffName();
      _markers.add(
        Marker(
          markerId: const MarkerId('driver_route_destination'),
          position: destPos,
          zIndex: 9.0,
          infoWindow: InfoWindow(
            title: '🏁 $destName (Drop-off)',
            snippet: 'drop_off_point'.tr.isNotEmpty &&
                    !'drop_off_point'.tr.contains('drop_off_point')
                ? 'drop_off_point'.tr
                : 'Drop-off University Point',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      );
    }
  }

  LatLng? _resolveStartLatLng() {
    if (widget.trip != null) {
      if (widget.trip!.startLatitude != null &&
          widget.trip!.startLongitude != null &&
          widget.trip!.startLatitude! != 0 &&
          widget.trip!.startLongitude! != 0) {
        return MapBoundHelper.toCorrectLatLng(
          widget.trip!.startLatitude!,
          widget.trip!.startLongitude!,
        );
      }
      final driverStart =
          MapBoundHelper.getDriverStart(widget.trip, _routePoints);
      if (driverStart != null &&
          driverStart.latitude != 0 &&
          driverStart.longitude != 0) {
        return driverStart;
      }
    }
    if (_routePoints.length >= 2) {
      return _routePoints.first;
    }
    return null;
  }

  LatLng? _resolveDropoffLatLng() {
    if (widget.trip != null) {
      if (widget.trip!.destinationLatitude != null &&
          widget.trip!.destinationLongitude != null &&
          widget.trip!.destinationLatitude! != 0 &&
          widget.trip!.destinationLongitude! != 0) {
        return MapBoundHelper.toCorrectLatLng(
          widget.trip!.destinationLatitude!,
          widget.trip!.destinationLongitude!,
        );
      }
      if (widget.trip!.endLatitude != null &&
          widget.trip!.endLongitude != null &&
          widget.trip!.endLatitude! != 0 &&
          widget.trip!.endLongitude! != 0) {
        return MapBoundHelper.toCorrectLatLng(
          widget.trip!.endLatitude!,
          widget.trip!.endLongitude!,
        );
      }
      final driverEnd = MapBoundHelper.getDriverEnd(widget.trip, _routePoints);
      if (driverEnd != null &&
          driverEnd.latitude != 0 &&
          driverEnd.longitude != 0) {
        return driverEnd;
      }
      final passengerDropoff = MapBoundHelper.getPassengerDropoff(widget.trip);
      if (passengerDropoff != null &&
          passengerDropoff.latitude != 0 &&
          passengerDropoff.longitude != 0) {
        return passengerDropoff;
      }
    }

    if (Get.isRegistered<UniversityController>()) {
      final uniCtrl = Get.find<UniversityController>();
      final String uniName =
          widget.trip?.toUniversity.trim().toLowerCase() ?? '';
      if (uniName.isNotEmpty) {
        for (var u in uniCtrl.universities) {
          if ((u.name.trim().toLowerCase() == uniName ||
                  (u.nameAr != null &&
                      u.nameAr!.trim().toLowerCase() == uniName) ||
                  uniName.contains(u.name.trim().toLowerCase()) ||
                  u.name.trim().toLowerCase().contains(uniName)) &&
              u.latitude != null &&
              u.longitude != null &&
              u.latitude != 0 &&
              u.longitude != 0) {
            return MapBoundHelper.toCorrectLatLng(u.latitude!, u.longitude!);
          }
        }
      }
    }

    if (_routePoints.length >= 2) {
      return _routePoints.last;
    }

    return null;
  }

  String _resolveDropoffName() {
    if (widget.trip != null) {
      if (widget.trip!.toUniversity.trim().isNotEmpty) {
        return widget.trip!.toUniversity.trim();
      }
      if (widget.trip!.destinationPoint.trim().isNotEmpty) {
        return widget.trip!.destinationPoint.trim();
      }
    }
    return 'University Drop-off';
  }

  void _fitMapBounds() {
    if (_mapController == null) return;

    final List<LatLng> allBoundsPoints = [];
    allBoundsPoints.addAll(_routePoints);
    for (var m in _markers) {
      allBoundsPoints.add(m.position);
    }

    if (allBoundsPoints.isEmpty) return;

    if (allBoundsPoints.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(allBoundsPoints.first, 14.5),
      );
      return;
    }

    double minLat = allBoundsPoints.first.latitude;
    double maxLat = allBoundsPoints.first.latitude;
    double minLng = allBoundsPoints.first.longitude;
    double maxLng = allBoundsPoints.first.longitude;

    for (var p in allBoundsPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        36,
      ),
    );
  }

  Future<void> _openGoogleMaps(double lat, double lng, [String? destinationName]) async {
    if (lat == 0 && lng == 0) {
      Get.snackbar(
        'Location Unavailable',
        'Coordinates for this pickup point are not set.',
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0F172A),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final corrected = MapBoundHelper.toCorrectLatLng(lat, lng);
      final cLat = corrected.latitude;
      final cLng = corrected.longitude;

      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$cLat,$cLng&travelmode=driving';
      final fallbackUrl = 'https://maps.google.com/maps?q=$cLat,$cLng';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
        await launchUrl(Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open Google Maps app.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error opening Google Maps: $e');
      Get.snackbar(
        'Error',
        'Could not open Google Maps. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  UniversityPickupPointModel? _getActiveSelectedModel() {
    List<UniversityPickupPointModel> points = [];
    if (widget.pickupPoints != null && widget.pickupPoints!.isNotEmpty) {
      points = widget.pickupPoints!;
    } else if (Get.isRegistered<UniversityController>()) {
      points = Get.find<UniversityController>().availablePickupPoints;
    }

    final selectedName = widget.selectedPickupPoint?.trim().toLowerCase() ?? '';
    if (selectedName.isEmpty) {
      return points.isNotEmpty ? points.first : null;
    }

    for (var p in points) {
      if (p.name.trim().toLowerCase() == selectedName ||
          selectedName.contains(p.name.trim().toLowerCase()) ||
          p.name.trim().toLowerCase().contains(selectedName)) {
        return p;
      }
    }
    return points.isNotEmpty ? points.first : null;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  String? _calculateDistanceFromUser(double activeLat, double activeLng) {
    if (activeLat == 0 && activeLng == 0) return null;
    if (!Get.isRegistered<LocationController>()) return null;
    final userPos = Get.find<LocationController>().position;
    if (userPos.latitude == 0 && userPos.longitude == 0) return null;

    final corrected = MapBoundHelper.toCorrectLatLng(activeLat, activeLng);
    final meters = Geolocator.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      corrected.latitude,
      corrected.longitude,
    );

    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m ${'from_your_location'.tr}';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km ${'from_your_location'.tr}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationController = Get.isRegistered<LocationController>()
        ? Get.find<LocationController>()
        : null;
    final userLat = locationController?.position.latitude ?? 0.0;
    final userLng = locationController?.position.longitude ?? 0.0;

    LatLng targetPos;
    if (_routePoints.isNotEmpty) {
      targetPos = _routePoints.first;
    } else if (userLat != 0 && userLng != 0) {
      targetPos = MapBoundHelper.toCorrectLatLng(userLat, userLng);
    } else {
      targetPos = const LatLng(30.0588, 31.3411);
    }

    final activePoint = _getActiveSelectedModel();
    final activeLat = activePoint?.latitude ?? widget.trip?.pickupLatitude ?? 0.0;
    final activeLng = activePoint?.longitude ?? widget.trip?.pickupLongitude ?? 0.0;
    final activeName = activePoint?.name ?? widget.selectedPickupPoint ?? 'Pickup Point';
    final activeDistText = _calculateDistanceFromUser(activeLat, activeLng);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'choose_from_map'.tr,
              style: textBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: const Color(0xFF0F172A),
              ),
            ),
            InkWell(
              onTap: () {
                _fitMapBounds();
                widget.onViewMap();
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.crop_free_rounded,
                    size: 14,
                    color: Color(0xFF00A0E9),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'view_map'.tr,
                    style: textSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xFF00A0E9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Google Map
                GoogleMap(
                  key: const ValueKey('university_map_picker_preview'),
                  initialCameraPosition: CameraPosition(
                    target: targetPos,
                    zoom: 13.5,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
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
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _fitMapBounds();
                  },
                ),

                // Top-Left Route Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
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
                            color: Color(0xFF00A0E9),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'driver_route'.tr.isNotEmpty
                              ? 'driver_route'.tr
                              : 'Driver Route',
                          style: textSemiBold.copyWith(
                            fontSize: 11,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top-Right Recenter Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: InkWell(
                    onTap: _fitMapBounds,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.my_location_rounded,
                          size: 16,
                          color: Color(0xFF00A0E9),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Floating Navigation Action Bar for Selected Pickup Point
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0F2FE),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: Color(0xFF00A0E9),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                activeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textBold.copyWith(
                                  fontSize: 13,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                activeDistText != null
                                    ? '$activeDistText · ${'pickup_point_label'.tr}'
                                    : ('navigate_to_pickup'.tr.isNotEmpty
                                        ? 'navigate_to_pickup'.tr
                                        : 'Navigate to pickup point'),
                                style: textRegular.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            if (widget.onNavigate != null) {
                              widget.onNavigate!(activeLat, activeLng, activeName);
                            } else {
                              _openGoogleMaps(activeLat, activeLng, activeName);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A0E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.directions_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'directions'.tr.isNotEmpty
                                      ? 'directions'.tr
                                      : 'Navigate',
                                  style: textBold.copyWith(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
