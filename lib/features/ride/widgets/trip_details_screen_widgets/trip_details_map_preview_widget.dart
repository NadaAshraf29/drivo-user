import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripDetailsMapPreviewWidget extends StatefulWidget {
  final dynamic trip;
  final bool fromSearch;
  final LatLng? selectedPickupPoint;
  final LatLng? selectedClosestPickup;
  final LatLng? selectedDropoffPoint;
  final LatLng? selectedClosestDropoff;
  final VoidCallback onTap;

  const TripDetailsMapPreviewWidget({
    super.key,
    required this.trip,
    required this.onTap,
    this.selectedPickupPoint,
    this.selectedClosestPickup,
    this.selectedDropoffPoint,
    this.selectedClosestDropoff,
    this.fromSearch = false,
  });

  @override
  State<TripDetailsMapPreviewWidget> createState() =>
      _TripDetailsMapPreviewWidgetState();
}

class _TripDetailsMapPreviewWidgetState
    extends State<TripDetailsMapPreviewWidget> {
  GoogleMapController? _mapController;
  List<LatLng> _pickupWalkingPoints = [];
  List<LatLng> _dropoffWalkingPoints = [];
  List<LatLng> _drivingRoutePoints = [];

  LatLng _toCorrectLatLng(double a, double b) {
    return MapBoundHelper.toCorrectLatLng(a, b);
  }

  @override
  void initState() {
    super.initState();
    _fetchWalkingRoutes();
    _fetchDrivingRouteIfNeeded();
  }

  void _fetchDrivingRouteIfNeeded() {
    MapBoundHelper.getActualDriverRoute(widget.trip).then((route) {
      if (!mounted) return;
      if (route.isNotEmpty) {
        setState(() {
          _drivingRoutePoints = route;
        });
        _fitBounds(_collectAllPoints());
      }
    }).catchError((_) {});
  }

  void _fetchWalkingRoutes() {
    final userPickupPos = _getUserPickupPos();
    final closestPickupPos = _getClosestPickupPos();
    if (userPickupPos != null &&
        closestPickupPos != null &&
        userPickupPos != closestPickupPos) {
      MapBoundHelper.getWalkingRoute(userPickupPos, closestPickupPos)
          .then((result) {
        if (!mounted) return;
        setState(() {
          _pickupWalkingPoints = result.points;
        });
      }).catchError((_) {});
    } else {
      setState(() {
        _pickupWalkingPoints = [];
      });
    }

    final userDropoffPos = _getUserDropoffPos();
    final closestDropoffPos = _getClosestDropoffPos();
    if (userDropoffPos != null &&
        closestDropoffPos != null &&
        userDropoffPos != closestDropoffPos) {
      MapBoundHelper.getWalkingRoute(userDropoffPos, closestDropoffPos)
          .then((result) {
        if (!mounted) return;
        setState(() {
          _dropoffWalkingPoints = result.points;
        });
      }).catchError((_) {});
    } else {
      setState(() {
        _dropoffWalkingPoints = [];
      });
    }
  }

  List<LatLng> _collectAllPoints() {
    final List<LatLng> decodedRoutePoints = _drivingRoutePoints.isNotEmpty
        ? _drivingRoutePoints
        : MapBoundHelper.getRoutePolylinePoints(widget.trip);

    final LatLng? startPoint =
        MapBoundHelper.getDriverStart(widget.trip, decodedRoutePoints);
    final LatLng? endPoint =
        MapBoundHelper.getDriverEnd(widget.trip, decodedRoutePoints);

    final LatLng? userPickupPos = _getUserPickupPos();
    final LatLng? closestPickupPos = _getClosestPickupPos();
    final LatLng? userDropoffPos = _getUserDropoffPos();
    final LatLng? closestDropoffPos = _getClosestDropoffPos();

    final List<LatLng> allPoints = [];
    if (startPoint != null) allPoints.add(startPoint);
    if (endPoint != null) allPoints.add(endPoint);
    if (userPickupPos != null) allPoints.add(userPickupPos);
    if (closestPickupPos != null) allPoints.add(closestPickupPos);
    if (userDropoffPos != null) allPoints.add(userDropoffPos);
    if (closestDropoffPos != null) allPoints.add(closestDropoffPos);
    allPoints.addAll(decodedRoutePoints);
    if (_pickupWalkingPoints.isNotEmpty) {
      allPoints.addAll(_pickupWalkingPoints);
    }
    if (_dropoffWalkingPoints.isNotEmpty) {
      allPoints.addAll(_dropoffWalkingPoints);
    }
    final List<RouteStop> driverStops = MapBoundHelper.getDriverStops(widget.trip);
    for (final s in driverStops) {
      allPoints.add(s.location);
    }
    return allPoints;
  }

  LatLng? _getUserPickupPos() {
    if (widget.selectedPickupPoint != null) {
      return _toCorrectLatLng(
        widget.selectedPickupPoint!.latitude,
        widget.selectedPickupPoint!.longitude,
      );
    } else if (widget.trip.pickupMatchPoint != null &&
        (widget.trip.pickupMatchPoint.lat != 0.0 ||
            widget.trip.pickupMatchPoint.lng != 0.0)) {
      return _toCorrectLatLng(
        widget.trip.pickupMatchPoint.lat,
        widget.trip.pickupMatchPoint.lng,
      );
    }
    return null;
  }

  LatLng? _getClosestPickupPos() {
    if (widget.selectedClosestPickup != null) {
      return _toCorrectLatLng(
        widget.selectedClosestPickup!.latitude,
        widget.selectedClosestPickup!.longitude,
      );
    } else if (widget.trip.closestPickup?.lat != null &&
        widget.trip.closestPickup?.lng != null &&
        (widget.trip.closestPickup!.lat != 0.0 ||
            widget.trip.closestPickup!.lng != 0.0)) {
      return _toCorrectLatLng(
        widget.trip.closestPickup!.lat,
        widget.trip.closestPickup!.lng,
      );
    } else if (widget.trip.boardingPointStart != null &&
        (widget.trip.boardingPointStart!.latitude != 0.0 ||
            widget.trip.boardingPointStart!.longitude != 0.0)) {
      return _toCorrectLatLng(
        widget.trip.boardingPointStart!.latitude,
        widget.trip.boardingPointStart!.longitude,
      );
    }
    return null;
  }

  LatLng? _getUserDropoffPos() {
    if (widget.selectedDropoffPoint != null) {
      return _toCorrectLatLng(
        widget.selectedDropoffPoint!.latitude,
        widget.selectedDropoffPoint!.longitude,
      );
    } else if (widget.trip.dropoffMatchPoint != null &&
        (widget.trip.dropoffMatchPoint.lat != 0.0 ||
            widget.trip.dropoffMatchPoint.lng != 0.0)) {
      return _toCorrectLatLng(
        widget.trip.dropoffMatchPoint.lat,
        widget.trip.dropoffMatchPoint.lng,
      );
    }
    return null;
  }

  LatLng? _getClosestDropoffPos() {
    if (widget.selectedClosestDropoff != null) {
      return _toCorrectLatLng(
        widget.selectedClosestDropoff!.latitude,
        widget.selectedClosestDropoff!.longitude,
      );
    } else if (widget.trip.closestDropoff?.lat != null &&
        widget.trip.closestDropoff?.lng != null &&
        (widget.trip.closestDropoff!.lat != 0.0 ||
            widget.trip.closestDropoff!.lng != 0.0)) {
      return _toCorrectLatLng(
        widget.trip.closestDropoff!.lat,
        widget.trip.closestDropoff!.lng,
      );
    } else if (widget.trip.boardingPointEnd != null &&
        (widget.trip.boardingPointEnd!.latitude != 0.0 ||
            widget.trip.boardingPointEnd!.longitude != 0.0)) {
      return _toCorrectLatLng(
        widget.trip.boardingPointEnd!.latitude,
        widget.trip.boardingPointEnd!.longitude,
      );
    }
    return null;
  }

  @override
  void didUpdateWidget(covariant TripDetailsMapPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedClosestPickup != oldWidget.selectedClosestPickup ||
        widget.selectedPickupPoint != oldWidget.selectedPickupPoint ||
        widget.selectedClosestDropoff != oldWidget.selectedClosestDropoff ||
        widget.selectedDropoffPoint != oldWidget.selectedDropoffPoint ||
        widget.trip != oldWidget.trip) {
      _fetchWalkingRoutes();
      _fetchDrivingRouteIfNeeded();
      final points = _collectAllPoints();
      _fitBounds(points);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<LatLng> decodedRoutePoints = _drivingRoutePoints.isNotEmpty
        ? _drivingRoutePoints
        : MapBoundHelper.getRoutePolylinePoints(widget.trip);

    final LatLng? startPoint =
        MapBoundHelper.getDriverStart(widget.trip, decodedRoutePoints);
    final LatLng? endPoint =
        MapBoundHelper.getDriverEnd(widget.trip, decodedRoutePoints);

    final LatLng? closestPickupPos = _getClosestPickupPos();
    final LatLng? closestDropoffPos = _getClosestDropoffPos();

    final List<LatLng> allPoints = _collectAllPoints();

    final LatLng center = allPoints.isNotEmpty
        ? LatLng(
            allPoints.map((p) => p.latitude).reduce((a, b) => a + b) /
                allPoints.length,
            allPoints.map((p) => p.longitude).reduce((a, b) => a + b) /
                allPoints.length,
          )
        : (startPoint ?? const LatLng(30.0444, 31.2357));

    final Set<Marker> markers = {};

    if (startPoint != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: startPoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: 'start_point'.tr.isNotEmpty &&
                    !'start_point'.tr.contains('start_point')
                ? 'start_point'.tr
                : 'Start Point (Driver)',
            snippet: widget.trip.pickupAddress ??
                widget.trip.boardingPointStart?.name ??
                '',
          ),
        ),
      );
    }

    if (endPoint != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: endPoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: 'end_point'.tr.isNotEmpty &&
                    !'end_point'.tr.contains('end_point')
                ? 'end_point'.tr
                : 'End Point (Driver)',
            snippet: widget.trip.dropoffAddress ??
                widget.trip.boardingPointEnd?.name ??
                '',
          ),
        ),
      );
    }

    if (closestPickupPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('closest_pickup'),
          position: closestPickupPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueCyan,
          ),
          infoWindow: InfoWindow(
            title: 'closest_pickup'.tr.isNotEmpty &&
                    !'closest_pickup'.tr.contains('closest_pickup')
                ? 'closest_pickup'.tr
                : 'Closest Pickup',
            snippet: widget.trip.closestPickup?.placeName ?? '',
          ),
        ),
      );
    }

    if (closestDropoffPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('closest_dropoff'),
          position: closestDropoffPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: 'closest_dropoff'.tr.isNotEmpty &&
                    !'closest_dropoff'.tr.contains('closest_dropoff')
                ? 'closest_dropoff'.tr
                : 'Closest Dropoff',
            snippet: widget.trip.closestDropoff?.placeName ?? '',
          ),
        ),
      );
    }

    final List<RouteStop> driverStops = MapBoundHelper.getDriverStops(widget.trip);
    for (int i = 0; i < driverStops.length; i++) {
      final stop = driverStops[i];
      markers.add(
        Marker(
          markerId: MarkerId('preview_stop_${stop.id ?? i}'),
          position: stop.location,
          zIndex: 4,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow,
          ),
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: stop.address ?? 'Driver Stop',
          ),
        ),
      );
    }

    final Set<Polyline> polylines = {};
    if (decodedRoutePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_actual_route'),
          points: decodedRoutePoints,
          color: const Color(0xFF08A9F0),
          width: 4,
          zIndex: 1,
        ),
      );
    } else if (startPoint != null && endPoint != null) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_actual_route'),
          points: [
            startPoint,
            endPoint,
          ],
          color: const Color(0xFF08A9F0),
          width: 3,
          zIndex: 1,
        ),
      );
    }

    if (closestPickupPos != null &&
        closestDropoffPos != null &&
        decodedRoutePoints.length >= 2) {
      int idxPickup = 0;
      double minD1 = double.infinity;
      int idxDropoff = decodedRoutePoints.length - 1;
      double minD2 = double.infinity;

      for (int i = 0; i < decodedRoutePoints.length; i++) {
        final d1 = Geolocator.distanceBetween(
          closestPickupPos.latitude,
          closestPickupPos.longitude,
          decodedRoutePoints[i].latitude,
          decodedRoutePoints[i].longitude,
        );
        if (d1 < minD1) {
          minD1 = d1;
          idxPickup = i;
        }

        final d2 = Geolocator.distanceBetween(
          closestDropoffPos.latitude,
          closestDropoffPos.longitude,
          decodedRoutePoints[i].latitude,
          decodedRoutePoints[i].longitude,
        );
        if (d2 < minD2) {
          minD2 = d2;
          idxDropoff = i;
        }
      }

      if (idxPickup < idxDropoff) {
        final passengerSegment = [
          closestPickupPos,
          ...decodedRoutePoints.sublist(idxPickup, idxDropoff + 1),
          closestDropoffPos,
        ];
        polylines.add(
          Polyline(
            polylineId: const PolylineId('passenger_active_segment'),
            points: passengerSegment,
            color: const Color(0xFF0284C7),
            width: 5,
            zIndex: 2,
          ),
        );
      }
    }

    if (_pickupWalkingPoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('pickup_walk'),
          points: _pickupWalkingPoints,
          color: const Color(0xFF00A3EC),
          width: 3,
          patterns: [PatternItem.dash(8), PatternItem.gap(4)],
          zIndex: 3,
        ),
      );
    }

    if (_dropoffWalkingPoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('dropoff_walk'),
          points: _dropoffWalkingPoints,
          color: const Color(0xFFEF5350),
          width: 3,
          patterns: [PatternItem.dash(8), PatternItem.gap(4)],
          zIndex: 3,
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              GoogleMap(
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                initialCameraPosition: CameraPosition(
                  target: center,
                  zoom: 8.5,
                ),
                zoomControlsEnabled: false,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                myLocationButtonEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                  _fitBounds(allPoints);
                },
                markers: markers,
                polylines: polylines,
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fullscreen_rounded,
                        size: 16,
                        color: Color(0xFF00A3EC),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'view_full_route'.tr.isNotEmpty &&
                                !'view_full_route'.tr.contains('view_full_route')
                            ? 'view_full_route'.tr
                            : 'Full Route',
                        style: textBold.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF1E2432),
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
    );
  }

  void _fitBounds(List<LatLng> points) {
    if (_mapController == null || points.isEmpty) return;

    if (points.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 14),
      );
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 40));
  }
}
