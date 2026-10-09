import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

/// Self-contained map card that handles live 2-second map updates
/// and smooth driver animation without triggering whole-page rebuilds.
class CarpoolActiveRideMapCard extends StatefulWidget {
  final TripDetails trip;

  const CarpoolActiveRideMapCard({
    super.key,
    required this.trip,
  });

  @override
  State<CarpoolActiveRideMapCard> createState() =>
      _CarpoolActiveRideMapCardState();
}

class _CarpoolActiveRideMapCardState extends State<CarpoolActiveRideMapCard> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _driverCarIcon;
  double _driverBearing = 0.0;
  List<LatLng> _currentActiveRoute = [];
  bool _isFollowingDriver = false;
  bool _userInteractedWithMap = false;
  LatLng? _currentDriverPos;
  Timer? _liveTrackingTimer;

  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);

  @override
  void initState() {
    super.initState();
    _loadCustomCarIcon();
    _initRouteAndDriver();
    _startLiveTrackingTimer();
  }

  void _startLiveTrackingTimer() {
    _liveTrackingTimer?.cancel();
    _liveTrackingTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      final tripId = widget.trip.id;
      if (tripId == null || tripId.isEmpty || !mounted) return;

      final rideController = Get.find<RideController>();
      final response =
          await rideController.getRideDetails(tripId, isUpdate: false);
      if (!mounted) return;

      if (response?.statusCode == 200 && rideController.tripDetails != null) {
        final updatedTrip = rideController.tripDetails!;
        final newDriverPos = _resolveDriverLatLng(
            updatedTrip, _resolveUserPickupLatLng(updatedTrip));
        if (newDriverPos != null) {
          final isDifferent = _currentDriverPos == null ||
              (_currentDriverPos!.latitude - newDriverPos.latitude).abs() >
                  0.00001 ||
              (_currentDriverPos!.longitude - newDriverPos.longitude).abs() >
                  0.00001;
          if (isDifferent) {
            final double newBearing = _currentDriverPos != null
                ? _calculateBearing(_currentDriverPos!, newDriverPos)
                : _driverBearing;
            setState(() {
              if (newBearing != 0.0) {
                _driverBearing = newBearing;
              }
              _currentDriverPos = newDriverPos;
            });
            if (_isFollowingDriver && !_userInteractedWithMap) {
              _centerOnDriver(newDriverPos);
            }
          }
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant CarpoolActiveRideMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip.id != widget.trip.id ||
        oldWidget.trip.currentStatus != widget.trip.currentStatus ||
        oldWidget.trip.encodedPolyline != widget.trip.encodedPolyline ||
        oldWidget.trip.passengerPolyline != widget.trip.passengerPolyline ||
        oldWidget.trip.lastLocation?.latitude !=
            widget.trip.lastLocation?.latitude ||
        oldWidget.trip.lastLocation?.longitude !=
            widget.trip.lastLocation?.longitude ||
        oldWidget.trip.carpoolRideLocation?.latitude !=
            widget.trip.carpoolRideLocation?.latitude ||
        oldWidget.trip.carpoolRideLocation?.longitude !=
            widget.trip.carpoolRideLocation?.longitude ||
        oldWidget.trip.driver?.lastLocations?.latitude !=
            widget.trip.driver?.lastLocations?.latitude ||
        oldWidget.trip.driver?.lastLocations?.longitude !=
            widget.trip.driver?.lastLocations?.longitude) {
      _initRouteAndDriver();
      final LatLng? routeStartPos = _resolveRouteStartLatLng(widget.trip);
      final LatLng? pickupPos = _resolveUserPickupLatLng(widget.trip);
      final LatLng? driverPos = _currentDriverPos ??
          _resolveDriverLatLng(widget.trip, pickupPos) ??
          routeStartPos ??
          (_currentActiveRoute.isNotEmpty
              ? _currentActiveRoute.first
              : null);
      if (!_userInteractedWithMap) {
        if (_isFollowingDriver && driverPos != null) {
          _centerOnDriver(driverPos);
        } else if (!_isFollowingDriver) {
          _fitMapBounds();
        }
      }
    }
  }

  @override
  void dispose() {
    _liveTrackingTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _centerOnDriver(LatLng driverPos, {bool force = false}) {
    if (_mapController == null) return;
    if (_userInteractedWithMap && !force) return;
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: driverPos,
          zoom: 16.5,
          bearing: _driverBearing,
          tilt: 25.0,
        ),
      ),
    );
  }

  Future<void> _loadCustomCarIcon() async {
    try {
      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(44, 44)),
        Images.carIcon,
      );
      if (mounted) {
        setState(() {
          _driverCarIcon = icon;
        });
      }
    } catch (e) {
      debugPrint('Error loading custom car icon: $e');
    }
  }

  bool _isReturn(TripDetails trip) {
    if (trip.isReturnLeg) return true;
    final leg = (trip.effectiveTripLeg ?? trip.currentTripLeg ?? '').toLowerCase().trim();
    if (leg == 'return' || leg == 'evening' || leg == 'night') return true;
    final rName = (trip.routeName ?? '').toLowerCase();
    final ttl = (trip.title ?? '').toLowerCase();
    if (rName.contains('return_trip') || rName.contains('night_trip') || ttl.contains('return_trip') || ttl.contains('night_trip')) {
      return true;
    }
    return false;
  }

  List<LatLng> _alignRoutePointsForLeg(
    List<LatLng> points,
    LatLng? startPos,
    LatLng? endPos,
  ) {
    if (points.length < 2 || !_isReturn(widget.trip)) {
      return points;
    }
    final targetStart = startPos ?? _resolveRouteStartLatLng(widget.trip);
    if (targetStart == null) return points;

    final double distToFirst = _computeSquaredDistance(points.first, targetStart);
    final double distToLast = _computeSquaredDistance(points.last, targetStart);
    if (distToLast < distToFirst) {
      return points.reversed.toList();
    }
    return points;
  }

  double _computeSquaredDistance(LatLng p1, LatLng p2) {
    final double dLat = p1.latitude - p2.latitude;
    final double dLng = p1.longitude - p2.longitude;
    return dLat * dLat + dLng * dLng;
  }

  void _initRouteAndDriver() {
    final LatLng? routeStartPos = _resolveRouteStartLatLng(widget.trip);
    final LatLng? routeEndPos = _resolveRouteEndLatLng(widget.trip);
    final LatLng? pickupPos = _resolveUserPickupLatLng(widget.trip);
    final LatLng? destinationPos = _resolveUserDropoffLatLng(widget.trip);
    final bool isTripStarted =
        (widget.trip.currentStatus ?? '').toLowerCase() == 'ongoing' ||
        (widget.trip.currentStatus ?? '').toLowerCase() == 'on_going';
    final LatLng? rawDriverPos =
        isTripStarted ? _resolveDriverLatLng(widget.trip, pickupPos) : null;

    List<LatLng> decodedRoute =
        MapBoundHelper.getRoutePolylinePoints(widget.trip);

    if (decodedRoute.length >= 2) {
      decodedRoute = _alignRoutePointsForLeg(
        decodedRoute,
        routeStartPos ?? pickupPos,
        destinationPos ?? routeEndPos,
      );
      _currentActiveRoute = decodedRoute;
      if (decodedRoute.length >= 2) {
        _driverBearing =
            _calculateBearing(decodedRoute[0], decodedRoute[1]);
      }
    } else {
      final List<LatLng> fallback = _buildFullRoutePoints(
        widget.trip,
        routeStartPos,
        pickupPos,
        destinationPos,
        routeEndPos,
        rawDriverPos,
      );
      if (fallback.isNotEmpty) {
        _currentActiveRoute = fallback;
        if (fallback.length >= 2) {
          _driverBearing =
              _calculateBearing(fallback[0], fallback[1]);
        }
      }
    }

    // Always fetch actual turn-by-turn road route asynchronously for maximum accuracy
    _fetchActualRoadRoute();
  }

  Future<void> _fetchActualRoadRoute() async {
    final LatLng? routeStartPos = _resolveRouteStartLatLng(widget.trip);
    final LatLng? routeEndPos = _resolveRouteEndLatLng(widget.trip);
    final LatLng? pickupPos = _resolveUserPickupLatLng(widget.trip);
    final LatLng? destinationPos = _resolveUserDropoffLatLng(widget.trip);
    final bool isTripStarted =
        (widget.trip.currentStatus ?? '').toLowerCase() == 'ongoing' ||
        (widget.trip.currentStatus ?? '').toLowerCase() == 'on_going';
    final LatLng? driverPos = isTripStarted
        ? (_currentDriverPos ?? _resolveDriverLatLng(widget.trip, pickupPos))
        : null;

    LatLng? origin = driverPos ?? routeStartPos ?? pickupPos;
    LatLng? destination = destinationPos ?? routeEndPos;

    if (destination == null && origin != pickupPos) {
      destination = pickupPos;
    }
    if (origin == null && destination != pickupPos) {
      origin = pickupPos;
    }
    if (destination == null && origin != routeStartPos) {
      destination = routeStartPos;
    }

    if (origin == null || destination == null) return;
    if (_computeSquaredDistance(origin, destination) < 0.0000001) return;

    List<LatLng> waypoints = [];
    if (pickupPos != null &&
        _computeSquaredDistance(pickupPos, origin) > 0.00005 &&
        _computeSquaredDistance(pickupPos, destination) > 0.00005) {
      waypoints.add(pickupPos);
    }
    if (destinationPos != null &&
        destination != destinationPos &&
        _computeSquaredDistance(destinationPos, origin) > 0.00005 &&
        _computeSquaredDistance(destinationPos, destination) > 0.00005 &&
        (waypoints.isEmpty || _computeSquaredDistance(destinationPos, waypoints.last) > 0.00005)) {
      waypoints.add(destinationPos);
    }

    try {
      final List<LatLng> roadPoints = await MapBoundHelper.getDrivingRoute(
        origin,
        destination,
        waypoints: waypoints,
      );

      if (!mounted) return;

      if (roadPoints.length >= 2) {
        final aligned = _alignRoutePointsForLeg(roadPoints, origin, destination);
        setState(() {
          _currentActiveRoute = aligned;
          if (aligned.length >= 2) {
            _driverBearing =
                _calculateBearing(aligned[0], aligned[1]);
          }
        });
        _fitMapBounds();
      }
    } catch (e) {
      debugPrint('Error fetching driving road route: $e');
    }
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final double lat1 = start.latitude * (math.pi / 180.0);
    final double lon1 = start.longitude * (math.pi / 180.0);
    final double lat2 = end.latitude * (math.pi / 180.0);
    final double lon2 = end.longitude * (math.pi / 180.0);

    final double dLon = lon2 - lon1;

    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final double radians = math.atan2(y, x);
    return (radians * (180.0 / math.pi) + 360.0) % 360.0;
  }

  List<LatLng> _buildFullRoutePoints(
    TripDetails trip,
    LatLng? routeStartPos,
    LatLng? pickupPos,
    LatLng? destinationPos,
    LatLng? routeEndPos,
    LatLng? rawDriverPos,
  ) {
    List<LatLng> decoded = MapBoundHelper.getRoutePolylinePoints(trip);

    if (decoded.isNotEmpty && decoded.length >= 2) {
      return _alignRoutePointsForLeg(
        decoded,
        routeStartPos ?? pickupPos,
        destinationPos ?? routeEndPos,
      );
    }

    List<LatLng> fallback = [];
    final bool isTripStarted =
        (trip.currentStatus ?? '').toLowerCase() == 'ongoing' ||
        (trip.currentStatus ?? '').toLowerCase() == 'on_going';
    final LatLng? startPt =
        (isTripStarted ? rawDriverPos : null) ?? routeStartPos ?? pickupPos;
    final LatLng? endPt =
        destinationPos ?? routeEndPos ?? (startPt != pickupPos ? pickupPos : null);

    if (startPt != null) fallback.add(startPt);
    if (pickupPos != null && !fallback.contains(pickupPos)) {
      fallback.add(pickupPos);
    }
    if (destinationPos != null && !fallback.contains(destinationPos)) {
      fallback.add(destinationPos);
    }
    if (endPt != null && !fallback.contains(endPt)) {
      fallback.add(endPt);
    }

    return fallback;
  }

  LatLng _toCorrectLatLng(double a, double b) {
    return MapBoundHelper.toCorrectLatLng(a, b);
  }

  LatLng? _resolveRouteStartLatLng(TripDetails trip) {
    final bool isReturn = _isReturn(trip);
    if (isReturn) {
      if (trip.endCoordinates?.coordinates != null &&
          trip.endCoordinates!.coordinates!.length >= 2) {
        return _toCorrectLatLng(
          trip.endCoordinates!.coordinates![1],
          trip.endCoordinates!.coordinates![0],
        );
      }
      if (trip.destinationCoordinates?.coordinates != null &&
          trip.destinationCoordinates!.coordinates!.length >= 2) {
        return _toCorrectLatLng(
          trip.destinationCoordinates!.coordinates![1],
          trip.destinationCoordinates!.coordinates![0],
        );
      }
      final driverEnd = MapBoundHelper.getDriverEnd(trip);
      if (driverEnd != null) return driverEnd;
      final passengerDropoff = MapBoundHelper.getPassengerDropoff(trip);
      if (passengerDropoff != null) return passengerDropoff;
    }

    if (trip.startCoordinates?.coordinates != null &&
        trip.startCoordinates!.coordinates!.length >= 2) {
      // Backend sends lat and long wrong (swapped) for the start route:
      // Destination and pickup work right with [1], [0], so swap lat and long here only: [0], [1]
      return _toCorrectLatLng(
        trip.startCoordinates!.coordinates![0],
        trip.startCoordinates!.coordinates![1],
      );
    }
    if (trip.pickupCoordinates?.coordinates != null &&
        trip.pickupCoordinates!.coordinates!.length >= 2) {
      return _toCorrectLatLng(
        trip.pickupCoordinates!.coordinates![0],
        trip.pickupCoordinates!.coordinates![1],
      );
    }
    final driverStart = MapBoundHelper.getDriverStart(trip);
    if (driverStart != null) return driverStart;

    final passengerPickup = MapBoundHelper.getPassengerPickup(trip);
    if (passengerPickup != null) return passengerPickup;

    final routePoly = MapBoundHelper.getRoutePolylinePoints(trip);
    if (routePoly.isNotEmpty) {
      return isReturn ? routePoly.last : routePoly.first;
    }

    return isReturn
        ? MapBoundHelper.getDriverEnd(trip) ?? MapBoundHelper.getDriverStart(trip)
        : MapBoundHelper.getDriverStart(trip) ?? MapBoundHelper.getDriverEnd(trip);
  }

  LatLng? _resolveRouteEndLatLng(TripDetails trip) {
    final bool isReturn = _isReturn(trip);
    if (isReturn) {
      if (trip.startCoordinates?.coordinates != null &&
          trip.startCoordinates!.coordinates!.length >= 2) {
        return _toCorrectLatLng(
          trip.startCoordinates!.coordinates![0],
          trip.startCoordinates!.coordinates![1],
        );
      }
      if (trip.pickupCoordinates?.coordinates != null &&
          trip.pickupCoordinates!.coordinates!.length >= 2) {
        return _toCorrectLatLng(
          trip.pickupCoordinates!.coordinates![0],
          trip.pickupCoordinates!.coordinates![1],
        );
      }
      final driverStart = MapBoundHelper.getDriverStart(trip);
      if (driverStart != null) return driverStart;
      final passengerPickup = MapBoundHelper.getPassengerPickup(trip);
      if (passengerPickup != null) return passengerPickup;
    }

    if (trip.endCoordinates?.coordinates != null &&
        trip.endCoordinates!.coordinates!.length >= 2) {
      return _toCorrectLatLng(
        trip.endCoordinates!.coordinates![1],
        trip.endCoordinates!.coordinates![0],
      );
    }
    if (trip.destinationCoordinates?.coordinates != null &&
        trip.destinationCoordinates!.coordinates!.length >= 2) {
      return _toCorrectLatLng(
        trip.destinationCoordinates!.coordinates![1],
        trip.destinationCoordinates!.coordinates![0],
      );
    }
    final driverEnd = MapBoundHelper.getDriverEnd(trip);
    if (driverEnd != null) return driverEnd;

    final passengerDropoff = MapBoundHelper.getPassengerDropoff(trip);
    if (passengerDropoff != null) return passengerDropoff;

    final routePoly = MapBoundHelper.getRoutePolylinePoints(trip);
    if (routePoly.isNotEmpty) {
      return isReturn ? routePoly.first : routePoly.last;
    }

    return isReturn
        ? MapBoundHelper.getDriverStart(trip) ?? MapBoundHelper.getDriverEnd(trip)
        : MapBoundHelper.getDriverEnd(trip) ?? MapBoundHelper.getDriverStart(trip);
  }

  LatLng? _resolveUserPickupLatLng(TripDetails trip) {
    if (trip.isTravelOrNorthCoast) {
      return _resolveRouteStartLatLng(trip);
    }
    final bool isReturn = _isReturn(trip);
    if (isReturn) {
      if (trip.destinationCoordinates?.coordinates != null &&
          trip.destinationCoordinates!.coordinates!.length >= 2) {
        return _toCorrectLatLng(
          trip.destinationCoordinates!.coordinates![1],
          trip.destinationCoordinates!.coordinates![0],
        );
      }
      if (trip.endCoordinates?.coordinates != null &&
          trip.endCoordinates!.coordinates!.length >= 2) {
        return _toCorrectLatLng(
          trip.endCoordinates!.coordinates![1],
          trip.endCoordinates!.coordinates![0],
        );
      }
    }
    if (trip.carpoolRideLocation?.latitude != null &&
        trip.carpoolRideLocation?.longitude != null &&
        (trip.carpoolRideLocation!.latitude != 0.0 ||
            trip.carpoolRideLocation!.longitude != 0.0)) {
      return _toCorrectLatLng(
        trip.carpoolRideLocation!.latitude!,
        trip.carpoolRideLocation!.longitude!,
      );
    }
    if (trip.closestPcikupPoint != null &&
        trip.closestPcikupPoint!.length >= 2) {
      return _toCorrectLatLng(
        trip.closestPcikupPoint![0],
        trip.closestPcikupPoint![1],
      );
    }
    if (trip.customerRequestCoordinates?.coordinates != null &&
        trip.customerRequestCoordinates!.coordinates!.length >= 2) {
      return _toCorrectLatLng(
        trip.customerRequestCoordinates!.coordinates![0],
        trip.customerRequestCoordinates!.coordinates![1],
      );
    }
    if (trip.pickupCoordinates?.coordinates != null &&
        trip.pickupCoordinates!.coordinates!.length >= 2) {
      return _toCorrectLatLng(
        trip.pickupCoordinates!.coordinates![0],
        trip.pickupCoordinates!.coordinates![1],
      );
    }
    if (trip.startCoordinates?.coordinates != null &&
        trip.startCoordinates!.coordinates!.length >= 2) {
      return _toCorrectLatLng(
        trip.startCoordinates!.coordinates![0],
        trip.startCoordinates!.coordinates![1],
      );
    }
    final passengerPickup = MapBoundHelper.getPassengerPickup(trip);
    if (passengerPickup != null) return passengerPickup;

    final driverStart = MapBoundHelper.getDriverStart(trip);
    if (driverStart != null) return driverStart;

    if (isReturn) {
      return _resolveRouteStartLatLng(trip);
    }
    return null;
  }

  LatLng? _resolveUserDropoffLatLng(TripDetails trip) {
    if (trip.isTravelOrNorthCoast) {
      return _resolveRouteEndLatLng(trip);
    }
    final bool isReturn = _isReturn(trip);
    if (isReturn) {
      if (trip.closestPcikupPoint != null &&
          trip.closestPcikupPoint!.length >= 2) {
        return _toCorrectLatLng(
          trip.closestPcikupPoint![0],
          trip.closestPcikupPoint![1],
        );
      }
      if (trip.customerRequestCoordinates?.coordinates != null &&
          trip.customerRequestCoordinates!.coordinates!.length >= 2) {
        return _toCorrectLatLng(
          trip.customerRequestCoordinates!.coordinates![0],
          trip.customerRequestCoordinates!.coordinates![1],
        );
      }
      if (trip.pickupCoordinates?.coordinates != null &&
          trip.pickupCoordinates!.coordinates!.length >= 2) {
        return _toCorrectLatLng(
          trip.pickupCoordinates!.coordinates![0],
          trip.pickupCoordinates!.coordinates![1],
        );
      }
      if (trip.startCoordinates?.coordinates != null &&
          trip.startCoordinates!.coordinates!.length >= 2) {
        return _toCorrectLatLng(
          trip.startCoordinates!.coordinates![0],
          trip.startCoordinates!.coordinates![1],
        );
      }
    }
    if (trip.carpoolDropoffLocation?.latitude != null &&
        trip.carpoolDropoffLocation?.longitude != null &&
        (trip.carpoolDropoffLocation!.latitude != 0.0 ||
            trip.carpoolDropoffLocation!.longitude != 0.0)) {
      return _toCorrectLatLng(
        trip.carpoolDropoffLocation!.latitude!,
        trip.carpoolDropoffLocation!.longitude!,
      );
    }
    if (trip.destinationCoordinates?.coordinates != null &&
        trip.destinationCoordinates!.coordinates!.length >= 2) {
      return _toCorrectLatLng(
        trip.destinationCoordinates!.coordinates![1],
        trip.destinationCoordinates!.coordinates![0],
      );
    }
    if (trip.endCoordinates?.coordinates != null &&
        trip.endCoordinates!.coordinates!.length >= 2) {
      return _toCorrectLatLng(
        trip.endCoordinates!.coordinates![1],
        trip.endCoordinates!.coordinates![0],
      );
    }
    final passengerDropoff = MapBoundHelper.getPassengerDropoff(trip);
    if (passengerDropoff != null) return passengerDropoff;

    final driverEnd = MapBoundHelper.getDriverEnd(trip);
    if (driverEnd != null) return driverEnd;

    if (isReturn) {
      return _resolveRouteEndLatLng(trip);
    }
    return null;
  }

  LatLng? _resolveDriverLatLng(TripDetails trip, LatLng? pickupPos) {
    if (trip.lastLocation?.latitude != null &&
        trip.lastLocation?.longitude != null) {
      return _toCorrectLatLng(
        trip.lastLocation!.latitude!,
        trip.lastLocation!.longitude!,
      );
    }
    if (trip.driver?.lastLocations?.latitude != null &&
        trip.driver?.lastLocations?.longitude != null) {
      return _toCorrectLatLng(
        trip.driver!.lastLocations!.latitude!,
        trip.driver!.lastLocations!.longitude!,
      );
    }
    return null;
  }



  bool _isValidLatLng(LatLng? pt) {
    if (pt == null) return false;
    if (pt.latitude.isNaN || pt.longitude.isNaN) return false;
    if (pt.latitude < -90.0 || pt.latitude > 90.0) return false;
    if (pt.longitude < -180.0 || pt.longitude > 180.0) return false;
    if (pt.latitude == 0.0 && pt.longitude == 0.0) return false;
    return true;
  }

  void _fitMapBounds({bool force = false}) {
    if (_mapController == null || !mounted) return;
    if (_userInteractedWithMap && !force) return;

    try {
      final bool isTripStarted =
          (widget.trip.currentStatus ?? '').toLowerCase() == 'ongoing' ||
          (widget.trip.currentStatus ?? '').toLowerCase() == 'on_going';

      if (_isFollowingDriver && isTripStarted) {
        final LatLng? pickupPos = _resolveUserPickupLatLng(widget.trip);
        final LatLng? driverPos =
            _resolveDriverLatLng(widget.trip, pickupPos) ??
                _currentDriverPos;
        if (driverPos != null && _isValidLatLng(driverPos)) {
          _centerOnDriver(driverPos, force: force);
          return;
        }
      }

      final LatLng? routeStartPos = _resolveRouteStartLatLng(widget.trip);
      final LatLng? routeEndPos = _resolveRouteEndLatLng(widget.trip);
      final LatLng? pickupPos = _resolveUserPickupLatLng(widget.trip);
      final LatLng? destinationPos = _resolveUserDropoffLatLng(widget.trip);
      final LatLng? activeDriverPos = isTripStarted
          ? (_currentDriverPos ?? _resolveDriverLatLng(widget.trip, pickupPos))
          : null;

      List<LatLng> pointsToFit = [];
      for (final pt in _currentActiveRoute) {
        if (_isValidLatLng(pt) && !pointsToFit.contains(pt)) {
          pointsToFit.add(pt);
        }
      }
      if (routeStartPos != null &&
          _isValidLatLng(routeStartPos) &&
          !pointsToFit.contains(routeStartPos)) {
        pointsToFit.add(routeStartPos);
      }
      if (pickupPos != null &&
          _isValidLatLng(pickupPos) &&
          !pointsToFit.contains(pickupPos)) {
        pointsToFit.add(pickupPos);
      }
      if (destinationPos != null &&
          _isValidLatLng(destinationPos) &&
          !pointsToFit.contains(destinationPos)) {
        pointsToFit.add(destinationPos);
      }
      if (routeEndPos != null &&
          _isValidLatLng(routeEndPos) &&
          !pointsToFit.contains(routeEndPos)) {
        pointsToFit.add(routeEndPos);
      }
      if (activeDriverPos != null &&
          _isValidLatLng(activeDriverPos) &&
          !pointsToFit.contains(activeDriverPos)) {
        pointsToFit.add(activeDriverPos);
      }
      final List<RouteStop> driverStops = MapBoundHelper.getDriverStops(widget.trip);
      for (final s in driverStops) {
        if (_isValidLatLng(s.location) && !pointsToFit.contains(s.location)) {
          pointsToFit.add(s.location);
        }
      }

      if (pointsToFit.isEmpty) return;

      if (pointsToFit.length == 1) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(pointsToFit.first, 15),
        );
        return;
      }

      double minLat = pointsToFit.first.latitude;
      double maxLat = pointsToFit.first.latitude;
      double minLng = pointsToFit.first.longitude;
      double maxLng = pointsToFit.first.longitude;

      for (final pt in pointsToFit) {
        if (pt.latitude < minLat) minLat = pt.latitude;
        if (pt.latitude > maxLat) maxLat = pt.latitude;
        if (pt.longitude < minLng) minLng = pt.longitude;
        if (pt.longitude > maxLng) maxLng = pt.longitude;
      }

      if ((maxLat - minLat).abs() < 0.0005 &&
          (maxLng - minLng).abs() < 0.0005) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 15),
        );
        return;
      }

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 35),
      );
    } catch (e) {
      debugPrint('Error fitting map bounds: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    final bool isTripStarted =
        (widget.trip.currentStatus ?? '').toLowerCase() == 'ongoing' ||
        (widget.trip.currentStatus ?? '').toLowerCase() == 'on_going';

    final LatLng? routeStartPos = _resolveRouteStartLatLng(widget.trip);
    final LatLng? routeEndPos = _resolveRouteEndLatLng(widget.trip);
    final LatLng? pickupPos = _resolveUserPickupLatLng(widget.trip);
    final LatLng? destinationPos = _resolveUserDropoffLatLng(widget.trip);
    final LatLng? rawDriverPos =
        isTripStarted ? _resolveDriverLatLng(widget.trip, pickupPos) : null;

    final List<LatLng> activeRoute = _currentActiveRoute.isNotEmpty
        ? _currentActiveRoute
        : _buildFullRoutePoints(
            widget.trip,
            routeStartPos,
            pickupPos,
            destinationPos,
            routeEndPos,
            rawDriverPos,
          );

    final LatLng? activeDriverPos =
        isTripStarted ? (_currentDriverPos ?? rawDriverPos) : null;

    LatLng initialLatLng = (isTripStarted ? activeDriverPos : null) ??
        routeStartPos ??
        pickupPos ??
        destinationPos ??
        (activeRoute.isNotEmpty ? activeRoute.first : null) ??
        Get.find<LocationController>().initialPosition;

    if (!_isValidLatLng(initialLatLng)) {
      initialLatLng = const LatLng(30.0444, 31.2357);
    }

    Set<Marker> markers = {};
    List<LatLng> mapPointsForBounds = [];

    // 1. Driver Start Route Marker (Cyan)
    if (routeStartPos != null && _isValidLatLng(routeStartPos)) {
      markers.add(
        Marker(
          markerId: const MarkerId('route_start'),
          position: routeStartPos,
          zIndex: 3,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueCyan),
          infoWindow: InfoWindow(
            title: 'start_location'.tr == 'start_location'
                ? 'Start Route'
                : 'start_location'.tr,
            snippet: widget.trip.startAddress ?? '',
          ),
        ),
      );
      mapPointsForBounds.add(routeStartPos);
    }

    // 2. Passenger Pickup Marker (Azure / Blue)
    if (pickupPos != null && _isValidLatLng(pickupPos)) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_pickup'),
          position: pickupPos,
          zIndex: 4,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: 'pickup_location'.tr == 'pickup_location'
                ? 'Pickup Location'
                : 'pickup_location'.tr,
            snippet: widget.trip.pickupAddress ?? '',
          ),
        ),
      );
      mapPointsForBounds.add(pickupPos);
    }

    // 3. Passenger Destination Marker (Red)
    if (destinationPos != null && _isValidLatLng(destinationPos)) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_dropoff'),
          position: destinationPos,
          zIndex: 4,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'destination'.tr == 'destination'
                ? 'Drop-off Location'
                : 'destination'.tr,
            snippet: widget.trip.destinationAddress ?? '',
          ),
        ),
      );
      mapPointsForBounds.add(destinationPos);
    } else if (routeEndPos != null && _isValidLatLng(routeEndPos)) {
      markers.add(
        Marker(
          markerId: const MarkerId('route_end'),
          position: routeEndPos,
          zIndex: 4,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'destination'.tr == 'destination'
                ? 'Drop-off Location'
                : 'destination'.tr,
            snippet: widget.trip.endAddressDisplay.isNotEmpty
                ? widget.trip.endAddressDisplay
                : (widget.trip.endAddress ?? ''),
          ),
        ),
      );
      mapPointsForBounds.add(routeEndPos);
    }

    // 4. Driver Car Marker (Appears ONLY when the trip starts)
    if (isTripStarted && activeDriverPos != null && _isValidLatLng(activeDriverPos)) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: activeDriverPos,
          zIndex: 5,
          rotation: _driverBearing,
          anchor: const Offset(0.5, 0.5),
          icon: _driverCarIcon ??
              BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: 'driver_location'.tr == 'driver_location'
                ? 'Driver Location'
                : 'driver_location'.tr,
            snippet: widget.trip.driver?.displayName ?? '',
          ),
        ),
      );
      mapPointsForBounds.add(activeDriverPos);
    }

    // 5. Driver Stops along Route
    final List<RouteStop> driverStops = MapBoundHelper.getDriverStops(widget.trip);
    for (int i = 0; i < driverStops.length; i++) {
      final stop = driverStops[i];
      if (_isValidLatLng(stop.location)) {
        markers.add(
          Marker(
            markerId: MarkerId('active_driver_stop_${stop.id ?? i}'),
            position: stop.location,
            zIndex: 3,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow,
            ),
            infoWindow: InfoWindow(
              title: stop.name,
              snippet: stop.address ?? 'Driver Stop',
            ),
          ),
        );
        mapPointsForBounds.add(stop.location);
      }
    }

    Set<Polyline> polylines = {};
    if (activeRoute.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('full_carpool_route_casing'),
          points: activeRoute,
          color: _primaryBlue.withValues(alpha: 0.28),
          width: 7,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
      polylines.add(
        Polyline(
          polylineId: const PolylineId('full_carpool_route'),
          points: activeRoute,
          color: _primaryBlue,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
      mapPointsForBounds.addAll(activeRoute);
    }

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEFF5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            GoogleMap(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              style: Get.isDarkMode
                  ? Get.find<ThemeController>().darkMap
                  : Get.find<ThemeController>().lightMap,
              initialCameraPosition: CameraPosition(
                target: initialLatLng,
                zoom: 14,
              ),
              markers: markers,
              polylines: polylines,
              onCameraMoveStarted: () {
                if (!_userInteractedWithMap) {
                  setState(() {
                    _userInteractedWithMap = true;
                  });
                }
              },
              onMapCreated: (controller) {
                _mapController = controller;
                if (mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _mapController != null) {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          _fitMapBounds();
                        }
                      });
                    }
                  });
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
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
                      decoration: BoxDecoration(
                        color: isTripStarted
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF0284C7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isTripStarted ? 'Live' : 'Route',
                      style: textSemiBold.copyWith(
                        color: _textDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_userInteractedWithMap) ...[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _userInteractedWithMap = false;
                        });
                        _fitMapBounds(force: true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFEBEFF5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.center_focus_strong_rounded,
                              size: 14,
                              color: _primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Recenter',
                              style: textSemiBold.copyWith(
                                color: _primaryBlue,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (_isFollowingDriver && isTripStarted) ...[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isFollowingDriver = false;
                          _userInteractedWithMap = false;
                        });
                        _fitMapBounds(force: true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFEBEFF5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.fullscreen_rounded,
                              size: 14,
                              color: _textDark,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'full_route'.tr == 'full_route'
                                  ? 'Full Route'
                                  : 'full_route'.tr,
                              style: textSemiBold.copyWith(
                                color: _textDark,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (isTripStarted && activeDriverPos != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isFollowingDriver = !_isFollowingDriver;
                          _userInteractedWithMap = false;
                        });
                        if (_isFollowingDriver) {
                          _centerOnDriver(activeDriverPos, force: true);
                        } else {
                          _fitMapBounds(force: true);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isFollowingDriver
                              ? _primaryBlue
                              : Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _isFollowingDriver
                                  ? _primaryBlue.withValues(alpha: 0.35)
                                  : Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: _isFollowingDriver
                                ? _primaryBlue
                                : const Color(0xFFEBEFF5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isFollowingDriver
                                  ? Icons.navigation_rounded
                                  : Icons.near_me_outlined,
                              size: 14,
                              color: _isFollowingDriver
                                  ? Colors.white
                                  : _primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isFollowingDriver
                                  ? ('following_driver'.tr == 'following_driver'
                                      ? 'Following'
                                      : 'following_driver'.tr)
                                  : ('follow_driver'.tr == 'follow_driver'
                                      ? 'Follow Driver'
                                      : 'follow_driver'.tr),
                              style: textBold.copyWith(
                                color: _isFollowingDriver
                                    ? Colors.white
                                    : _textDark,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
