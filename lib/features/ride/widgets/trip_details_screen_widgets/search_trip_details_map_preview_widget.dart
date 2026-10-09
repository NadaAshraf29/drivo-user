import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';

class SearchTripDetailsMapPreviewWidget extends StatefulWidget {
  final dynamic trip;
  final bool fromSearch;
  final VoidCallback onTap;

  const SearchTripDetailsMapPreviewWidget({
    super.key,
    required this.trip,
    required this.onTap,
    this.fromSearch = false,
  });

  @override
  State<SearchTripDetailsMapPreviewWidget> createState() =>
      _SearchTripDetailsMapPreviewWidgetState();
}

class _SearchTripDetailsMapPreviewWidgetState
    extends State<SearchTripDetailsMapPreviewWidget> {
  GoogleMapController? _mapController;
  List<LatLng> _actualRoutePoints = [];

  @override
  void initState() {
    super.initState();
    MapBoundHelper.getActualDriverRoute(widget.trip).then((route) {
      if (!mounted) return;
      if (route.isNotEmpty) {
        setState(() {
          _actualRoutePoints = route;
        });
      }
    }).catchError((_) {});
  }

  LatLng _toCorrectLatLng(double a, double b) {
    return MapBoundHelper.toCorrectLatLng(a, b);
  }

  @override
  Widget build(BuildContext context) {
    final List<LatLng> decodedRoutePoints = _actualRoutePoints.isNotEmpty
        ? _actualRoutePoints
        : MapBoundHelper.getRoutePolylinePoints(widget.trip);

    final LatLng? startPoint =
        MapBoundHelper.getDriverStart(widget.trip, decodedRoutePoints);
    final LatLng? endPoint =
        MapBoundHelper.getDriverEnd(widget.trip, decodedRoutePoints);

    LatLng? closestPickupPos;
    if (widget.trip.closestPickup?.lat != null &&
        widget.trip.closestPickup?.lng != null &&
        (widget.trip.closestPickup!.lat != 0.0 ||
            widget.trip.closestPickup!.lng != 0.0)) {
      closestPickupPos = _toCorrectLatLng(
          widget.trip.closestPickup!.lat, widget.trip.closestPickup!.lng);
    } else if (widget.trip.boardingPointStart != null &&
        (widget.trip.boardingPointStart!.latitude != 0.0 ||
            widget.trip.boardingPointStart!.longitude != 0.0)) {
      closestPickupPos = _toCorrectLatLng(
          widget.trip.boardingPointStart!.latitude,
          widget.trip.boardingPointStart!.longitude);
    }

    LatLng? closestDropoffPos;
    if (widget.trip.closestDropoff?.lat != null &&
        widget.trip.closestDropoff?.lng != null &&
        (widget.trip.closestDropoff!.lat != 0.0 ||
            widget.trip.closestDropoff!.lng != 0.0)) {
      closestDropoffPos = _toCorrectLatLng(
          widget.trip.closestDropoff!.lat, widget.trip.closestDropoff!.lng);
    } else if (widget.trip.boardingPointEnd != null &&
        (widget.trip.boardingPointEnd!.latitude != 0.0 ||
            widget.trip.boardingPointEnd!.longitude != 0.0)) {
      closestDropoffPos = _toCorrectLatLng(
          widget.trip.boardingPointEnd!.latitude,
          widget.trip.boardingPointEnd!.longitude);
    }

    final List<LatLng> allPoints = [];
    if (startPoint != null) {
      allPoints.add(startPoint);
    }
    if (endPoint != null) {
      allPoints.add(endPoint);
    }
    if (closestPickupPos != null) {
      allPoints.add(closestPickupPos);
    }
    if (closestDropoffPos != null) {
      allPoints.add(closestDropoffPos);
    }
    final List<RouteStop> driverStops = MapBoundHelper.getDriverStops(widget.trip);
    for (final s in driverStops) {
      allPoints.add(s.location);
    }
    allPoints.addAll(decodedRoutePoints);

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
            snippet: widget.trip.pickupAddress ?? widget.trip.boardingPointStart?.name ?? '',
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
            snippet: widget.trip.dropoffAddress ?? widget.trip.boardingPointEnd?.name ?? '',
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
          polylineId: const PolylineId('route'),
          points: decodedRoutePoints,
          color: const Color(0xFF08A9F0),
          width: 4,
        ),
      );
    } else if (startPoint != null && endPoint != null) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [startPoint, endPoint],
          color: const Color(0xFF08A9F0),
          width: 4,
        ),
      );
    }

    return Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
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
