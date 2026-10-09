import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_active_trip_model.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolOngoingMapCard extends StatefulWidget {
  final SchoolActiveTripModel trip;
  final bool isOtpGiven;

  const SchoolOngoingMapCard({
    super.key,
    required this.trip,
    this.isOtpGiven = false,
  });

  @override
  State<SchoolOngoingMapCard> createState() => _SchoolOngoingMapCardState();
}

class _SchoolOngoingMapCardState extends State<SchoolOngoingMapCard> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  String _distanceDisplay = '';
  bool _userInteractedWithMap = false;

  @override
  void initState() {
    super.initState();
    _buildMapData();
    _fetchRoadRoutes();
  }

  @override
  void didUpdateWidget(covariant SchoolOngoingMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip != widget.trip ||
        oldWidget.isOtpGiven != widget.isOtpGiven) {
      _buildMapData();
      _fetchRoadRoutes();
      if (!_userInteractedWithMap) {
        _fitMapBounds();
      }
    }
  }

  LatLng _resolveUserLocation() {
    if (Get.isRegistered<LocationController>()) {
      final loc = Get.find<LocationController>();
      final lat = loc.position.latitude != 0
          ? loc.position.latitude
          : (loc.getUserAddress()?.latitude != null
              ? loc.getUserAddress()!.latitude!
              : null);
      final lng = loc.position.longitude != 0
          ? loc.position.longitude
          : (loc.getUserAddress()?.longitude != null
              ? loc.getUserAddress()!.longitude!
              : null);
      if (lat != null && lng != null && lat != 0 && lng != 0) {
        return LatLng(lat, lng);
      }
    }
    return LatLng(
      widget.trip.pickupLatitude - 0.005,
      widget.trip.pickupLongitude - 0.004,
    );
  }

  void _buildMapData() {
    _markers.clear();
    _polylines.clear();

    final trip = widget.trip;
    final userPos = _resolveUserLocation();
    final pickupPos = LatLng(trip.pickupLatitude, trip.pickupLongitude);
    final destPos = LatLng(trip.destinationLatitude, trip.destinationLongitude);
    final driverPos = LatLng(
      trip.driverLatitude ??
          ((trip.pickupLatitude + trip.destinationLatitude) / 2),
      trip.driverLongitude ??
          ((trip.pickupLongitude + trip.destinationLongitude) / 2),
    );

    // 1. User Marker (Violet)
    _markers.add(
      Marker(
        markerId: const MarkerId('school_trip_user'),
        position: userPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(title: 'your_location'.tr),
      ),
    );

    if (!widget.isOtpGiven) {
      // User hasn't given OTP -> Show distance from user to pickup point
      final distMeters = Geolocator.distanceBetween(
        userPos.latitude,
        userPos.longitude,
        pickupPos.latitude,
        pickupPos.longitude,
      );
      _distanceDisplay = distMeters < 1000
          ? '${distMeters.round()} m'
          : '${(distMeters / 1000).toStringAsFixed(1)} km';

      // Pickup Marker (Green)
      _markers.add(
        Marker(
          markerId: const MarkerId('school_trip_pickup'),
          position: pickupPos,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: trip.pickupPoint,
            snippet: trip.pickupAddress,
          ),
        ),
      );

      // Driver Marker (Azure)
      _markers.add(
        Marker(
          markerId: const MarkerId('school_trip_driver'),
          position: driverPos,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: trip.driver.name,
            snippet: '${trip.driver.vehicleModel} · ${trip.driver.plateNumber}',
          ),
        ),
      );

      // Initial straight line polyline between User and Pickup (will be upgraded by _fetchRoadRoutes)
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('user_to_pickup_route'),
          points: [userPos, pickupPos],
          color: const Color(0xFF059669),
          width: 4,
          patterns: [
            PatternItem.dash(12),
            PatternItem.gap(6),
          ],
        ),
      );

      // Initial straight line polyline between Driver and Pickup
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_to_pickup_route'),
          points: [driverPos, pickupPos],
          color: const Color(0xFF00A0E9).withOpacity(0.7),
          width: 3,
        ),
      );
    } else {
      // User gave OTP to driver -> Show distance from user to drop-off point
      final distMeters = Geolocator.distanceBetween(
        userPos.latitude,
        userPos.longitude,
        destPos.latitude,
        destPos.longitude,
      );
      _distanceDisplay = distMeters < 1000
          ? '${distMeters.round()} m'
          : '${(distMeters / 1000).toStringAsFixed(1)} km';

      // Destination / Drop-off Marker (Red)
      _markers.add(
        Marker(
          markerId: const MarkerId('school_trip_destination'),
          position: destPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: trip.schoolName,
            snippet: trip.destinationAddress,
          ),
        ),
      );

      // Driver transit marker (Azure)
      _markers.add(
        Marker(
          markerId: const MarkerId('school_trip_driver_transit'),
          position: driverPos,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: trip.driver.name,
            snippet: '${trip.driver.vehicleModel} · ${trip.driver.plateNumber}',
          ),
        ),
      );

      // Initial straight polyline between User/Driver and Drop-off
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('user_to_dropoff_route'),
          points: [userPos, driverPos, destPos],
          color: const Color(0xFF00A0E9),
          width: 4,
          patterns: [
            PatternItem.dash(12),
            PatternItem.gap(6),
          ],
        ),
      );
    }
  }

  Future<void> _fetchRoadRoutes() async {
    final trip = widget.trip;
    final userPos = _resolveUserLocation();
    final pickupPos = LatLng(trip.pickupLatitude, trip.pickupLongitude);
    final destPos = LatLng(trip.destinationLatitude, trip.destinationLongitude);
    final driverPos = LatLng(
      trip.driverLatitude ??
          ((trip.pickupLatitude + trip.destinationLatitude) / 2),
      trip.driverLongitude ??
          ((trip.pickupLongitude + trip.destinationLongitude) / 2),
    );

    try {
      if (!widget.isOtpGiven) {
        final userToPickupPts = await MapBoundHelper.getDrivingRoute(userPos, pickupPos);
        final driverToPickupPts = await MapBoundHelper.getDrivingRoute(driverPos, pickupPos);

        if (!mounted) return;
        setState(() {
          if (userToPickupPts.length >= 2) {
            _polylines.removeWhere((p) => p.polylineId.value == 'user_to_pickup_route');
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('user_to_pickup_route'),
                points: userToPickupPts,
                color: const Color(0xFF059669),
                width: 4,
                patterns: [
                  PatternItem.dash(12),
                  PatternItem.gap(6),
                ],
              ),
            );
          }
          if (driverToPickupPts.length >= 2) {
            _polylines.removeWhere((p) => p.polylineId.value == 'driver_to_pickup_route');
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('driver_to_pickup_route'),
                points: driverToPickupPts,
                color: const Color(0xFF00A0E9).withOpacity(0.85),
                width: 4,
              ),
            );
          }
        });
        if (!_userInteractedWithMap) {
          _fitMapBounds();
        }
      } else {
        final driverToDestPts = await MapBoundHelper.getDrivingRoute(driverPos, destPos);
        if (!mounted) return;
        setState(() {
          if (driverToDestPts.length >= 2) {
            _polylines.removeWhere((p) => p.polylineId.value == 'user_to_dropoff_route');
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('user_to_dropoff_route'),
                points: driverToDestPts,
                color: const Color(0xFF00A0E9),
                width: 4,
                patterns: [
                  PatternItem.dash(12),
                  PatternItem.gap(6),
                ],
              ),
            );
          }
        });
        if (!_userInteractedWithMap) {
          _fitMapBounds();
        }
      }
    } catch (e) {
      debugPrint('Error fetching road routes for school map card: $e');
    }
  }

  void _fitMapBounds({bool force = false}) {
    if (_mapController == null) return;
    if (_userInteractedWithMap && !force) return;

    final trip = widget.trip;
    final userPos = _resolveUserLocation();
    final targetPos = widget.isOtpGiven
        ? LatLng(trip.destinationLatitude, trip.destinationLongitude)
        : LatLng(trip.pickupLatitude, trip.pickupLongitude);

    final List<LatLng> points = [
      userPos,
      targetPos,
      LatLng(
        trip.driverLatitude ??
            ((trip.pickupLatitude + trip.destinationLatitude) / 2),
        trip.driverLongitude ??
            ((trip.pickupLongitude + trip.destinationLongitude) / 2),
      ),
    ];

    for (var p in _polylines) {
      points.addAll(p.points);
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    if ((maxLat - minLat).abs() < 0.001) {
      minLat -= 0.003;
      maxLat += 0.003;
    }
    if ((maxLng - minLng).abs() < 0.001) {
      minLng -= 0.003;
      maxLng += 0.003;
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
    final initialCenter = _resolveUserLocation();

    return Container(
      width: double.infinity,
      height: 220,
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
              key: ValueKey(
                  'school_ongoing_map_${trip.id}_${widget.isOtpGiven}'),
              initialCameraPosition: CameraPosition(
                target: initialCenter,
                zoom: 13.0,
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
              top: 14,
              left: 14,
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

            // Dynamic Distance Indicator Badge (Top-Right)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isOtpGiven
                        ? const Color(0xFF00A0E9).withOpacity(0.3)
                        : const Color(0xFF10B981).withOpacity(0.3),
                  ),
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
                    Icon(
                      widget.isOtpGiven
                          ? Icons.school_rounded
                          : Icons.directions_walk_rounded,
                      size: 16,
                      color: widget.isOtpGiven
                          ? const Color(0xFF00A0E9)
                          : const Color(0xFF059669),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.isOtpGiven
                              ? 'distance_to_dropoff'.tr
                              : 'distance_to_pickup'.tr,
                          style: textRegular.copyWith(
                            fontSize: 10,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          _distanceDisplay,
                          style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: widget.isOtpGiven
                                ? const Color(0xFF00A0E9)
                                : const Color(0xFF059669),
                          ),
                        ),
                      ],
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
