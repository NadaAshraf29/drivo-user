import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/domain/models/place_details_model.dart';
import 'package:ride_sharing_user_app/features/location/domain/models/prediction_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';

enum LocationPickerTarget { pickup, dropoff }

class TripDetailsLocationPickerDialog extends StatefulWidget {
  final LocationPickerTarget target;
  final List<LatLng> routePolylinePoints;
  final LatLng? routeStartPoint;
  final LatLng? routeEndPoint;
  final String? routeStartAddress;
  final String? routeEndAddress;
  final LatLng? initialRoutePoint;
  final LatLng? initialSearchedPoint;
  final String? initialAddress;
  final LatLng? pickupPoint;
  final LatLng? dropoffPoint;
  final Color accentColor;
  final List<RouteStop> driverStops;
  final Function(LatLng routePoint, LatLng? searchedPoint, String? addressName)
      onLocationSelected;

  const TripDetailsLocationPickerDialog({
    super.key,
    required this.target,
    required this.routePolylinePoints,
    this.routeStartPoint,
    this.routeEndPoint,
    this.routeStartAddress,
    this.routeEndAddress,
    this.initialRoutePoint,
    this.initialSearchedPoint,
    this.initialAddress,
    this.pickupPoint,
    this.dropoffPoint,
    required this.accentColor,
    this.driverStops = const [],
    required this.onLocationSelected,
  });

  @override
  State<TripDetailsLocationPickerDialog> createState() =>
      _TripDetailsLocationPickerDialogState();
}

class _TripDetailsLocationPickerDialogState
    extends State<TripDetailsLocationPickerDialog> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  LatLng? _selectedRoutePoint;
  LatLng? _searchedPoint;
  String? _searchedAddress;
  double? _distanceInMeters;
  double? _walkingDurationSeconds;
  List<LatLng> _walkingRoutePoints = [];
  int _walkingRequestId = 0;
  bool _isLoadingPlace = false;

  LatLng? get _effectiveReferencePoint {
    if (_searchedPoint != null) return _searchedPoint;
    final p = widget.target == LocationPickerTarget.pickup
        ? widget.pickupPoint
        : widget.dropoffPoint;
    if (p != null) {
      return MapBoundHelper.toCorrectLatLng(p.latitude, p.longitude);
    }
    return null;
  }

  void _recomputeDistance() {
    final ref = _effectiveReferencePoint;
    if (ref != null && _selectedRoutePoint != null) {
      _distanceInMeters = Geolocator.distanceBetween(
        ref.latitude,
        ref.longitude,
        _selectedRoutePoint!.latitude,
        _selectedRoutePoint!.longitude,
      );
      _fetchWalkingRoute(ref, _selectedRoutePoint!);
    } else {
      _distanceInMeters = null;
      _walkingDurationSeconds = null;
      _walkingRoutePoints = [];
    }
  }

  void _fetchWalkingRoute(LatLng origin, LatLng destination) {
    final currentId = ++_walkingRequestId;
    MapBoundHelper.getWalkingRoute(origin, destination).then((result) {
      if (!mounted || currentId != _walkingRequestId) return;
      setState(() {
        _walkingRoutePoints = result.points;
        if (result.distanceMeters != null && result.distanceMeters! > 0) {
          _distanceInMeters = result.distanceMeters;
        }
        if (result.durationSeconds != null && result.durationSeconds! > 0) {
          _walkingDurationSeconds = result.durationSeconds;
        }
      });
    }).catchError((_) {});
  }

  @override
  void initState() {
    super.initState();
    _selectedRoutePoint = widget.initialRoutePoint != null
        ? MapBoundHelper.toCorrectLatLng(
            widget.initialRoutePoint!.latitude,
            widget.initialRoutePoint!.longitude,
          )
        : null;
    _searchedPoint = widget.initialSearchedPoint != null
        ? MapBoundHelper.toCorrectLatLng(
            widget.initialSearchedPoint!.latitude,
            widget.initialSearchedPoint!.longitude,
          )
        : null;
    _searchedAddress = widget.initialAddress;

    if (_searchedAddress != null && _searchedAddress!.isNotEmpty) {
      _searchController.text = _searchedAddress!;
    }

    final ref = _effectiveReferencePoint;
    if (widget.routePolylinePoints.isNotEmpty) {
      if (ref != null) {
        _selectedRoutePoint =
            MapBoundHelper.findClosestPointOnRoute(ref, widget.routePolylinePoints);
      } else if (_selectedRoutePoint != null) {
        _selectedRoutePoint = MapBoundHelper.findClosestPointOnRoute(
            _selectedRoutePoint!, widget.routePolylinePoints);
      } else {
        _selectedRoutePoint = widget.target == LocationPickerTarget.pickup
            ? widget.routePolylinePoints.first
            : widget.routePolylinePoints.last;
      }
    }

    _recomputeDistance();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onLocationSearched(LatLng point, {String? addressName}) {
    if (widget.routePolylinePoints.isEmpty) return;

    final correctedPoint =
        MapBoundHelper.toCorrectLatLng(point.latitude, point.longitude);
    final nearest =
        MapBoundHelper.findClosestPointOnRoute(correctedPoint, widget.routePolylinePoints);

    setState(() {
      _searchedPoint = correctedPoint;
      _selectedRoutePoint = nearest;
      if (addressName != null) {
        _searchedAddress = addressName;
        _searchController.text = addressName;
      }
      _recomputeDistance();
    });

    _fitPointsOnMap([correctedPoint, nearest]);
  }

  void _onMapTapped(LatLng tapPoint) {
    if (widget.routePolylinePoints.isEmpty) return;
    _searchFocusNode.unfocus();

    final correctedTap =
        MapBoundHelper.toCorrectLatLng(tapPoint.latitude, tapPoint.longitude);
    final nearest =
        MapBoundHelper.findClosestPointOnRoute(correctedTap, widget.routePolylinePoints);

    setState(() {
      _searchedPoint = correctedTap;
      _selectedRoutePoint = nearest;
      _recomputeDistance();
    });
  }

  void _onMeetingPointDragged(LatLng dragPoint) {
    if (widget.routePolylinePoints.isEmpty) return;

    final corrected =
        MapBoundHelper.toCorrectLatLng(dragPoint.latitude, dragPoint.longitude);
    final nearest =
        MapBoundHelper.findClosestPointOnRoute(corrected, widget.routePolylinePoints);

    setState(() {
      _selectedRoutePoint = nearest;
      _recomputeDistance();
    });
  }

  void _onUserSpotDragged(LatLng dragPoint) {
    final corrected =
        MapBoundHelper.toCorrectLatLng(dragPoint.latitude, dragPoint.longitude);

    setState(() {
      _searchedPoint = corrected;
      if (widget.routePolylinePoints.isNotEmpty) {
        _selectedRoutePoint =
            MapBoundHelper.findClosestPointOnRoute(corrected, widget.routePolylinePoints);
      }
      _recomputeDistance();
    });
  }

  void _onSelectStop(RouteStop stop) {
    _searchFocusNode.unfocus();
    final nearest = widget.routePolylinePoints.isNotEmpty
        ? MapBoundHelper.findClosestPointOnRoute(
            stop.location, widget.routePolylinePoints)
        : stop.location;

    setState(() {
      _selectedRoutePoint = nearest;
      _searchedAddress = stop.name;
      _searchController.text = stop.name;
      _recomputeDistance();
    });

    final targetList = <LatLng>[
      stop.location,
      if (_effectiveReferencePoint != null) _effectiveReferencePoint!,
    ];
    _fitPointsOnMap(targetList);
  }

  void _fitPointsOnMap(List<LatLng> points) {
    if (_mapController == null || points.isEmpty) return;

    if (points.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15.5),
      );
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    if ((maxLat - minLat).abs() < 0.003 && (maxLng - minLng).abs() < 0.003) {
      final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(center, 16));
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 65));
  }

  String _formatDistance(double? meters) {
    if (meters == null) return '';
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _formatWalkingDuration(double? meters) {
    if (_walkingDurationSeconds != null && _walkingDurationSeconds! > 0) {
      final minutes = (_walkingDurationSeconds! / 60).round();
      if (minutes <= 1) return '1 min walk';
      return '$minutes min walk';
    }
    if (meters == null || meters <= 15) return '1 min walk';
    final int minutes = (meters / 80).round();
    if (minutes <= 1) return '1 min walk';
    return '$minutes min walk';
  }

  String _formatDistanceAndWalkTime(double? meters) {
    if (meters == null) return '';
    final distanceStr = _formatDistance(meters);
    final walkTime = _formatWalkingDuration(meters);
    if (walkTime.isEmpty) return distanceStr;
    return '$distanceStr • $walkTime';
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    try {
      final point = MapBoundHelper.toCorrectLatLng(lat, lng);
      final cLat = point.latitude;
      final cLng = point.longitude;
      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$cLat,$cLng&travelmode=driving';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        final fallbackUrl = 'https://maps.google.com/maps?q=$cLat,$cLng';
        if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
          await launchUrl(
            Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          Get.snackbar(
            'Error',
            'Could not open Google Maps. Please try again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open Google Maps. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPickup = widget.target == LocationPickerTarget.pickup;
    final title = isPickup
        ? ('select_closest_pickup'.tr.isNotEmpty &&
                !('select_closest_pickup'.tr.contains('select_closest_pickup'))
            ? 'select_closest_pickup'.tr
            : 'Select Closest Pickup Point')
        : ('select_closest_dropoff'.tr.isNotEmpty &&
                !('select_closest_dropoff'.tr.contains('select_closest_dropoff'))
            ? 'select_closest_dropoff'.tr
            : 'Select Closest Dropoff Point');

    final Set<Marker> markers = {};

    // 1. Driver's Trip Start & End points (starts from driver route origin to destination)
    final LatLng? startPos = widget.routeStartPoint != null
        ? MapBoundHelper.toCorrectLatLng(
            widget.routeStartPoint!.latitude, widget.routeStartPoint!.longitude)
        : (widget.routePolylinePoints.isNotEmpty
            ? widget.routePolylinePoints.first
            : null);

    final LatLng? endPos = widget.routeEndPoint != null
        ? MapBoundHelper.toCorrectLatLng(
            widget.routeEndPoint!.latitude, widget.routeEndPoint!.longitude)
        : (widget.routePolylinePoints.isNotEmpty
            ? widget.routePolylinePoints.last
            : null);

    if (startPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('trip_start'),
          position: startPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'start_point'.tr.isNotEmpty &&
                    !'start_point'.tr.contains('start_point')
                ? 'start_point'.tr
                : 'Start Point (Driver)',
            snippet: widget.routeStartAddress ?? 'Driver trip start',
          ),
        ),
      );
    }
    if (endPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('trip_end'),
          position: endPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'end_point'.tr.isNotEmpty &&
                    !'end_point'.tr.contains('end_point')
                ? 'end_point'.tr
                : 'End Point (Driver)',
            snippet: widget.routeEndAddress ?? 'Driver trip end',
          ),
        ),
      );
    }

    // 2. User Reference Spot (Passenger's requested location)
    final ref = _effectiveReferencePoint;
    if (ref != null && (ref != _selectedRoutePoint)) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_search_spot'),
          position: ref,
          draggable: true,
          onDrag: (newPos) => _onUserSpotDragged(newPos),
          onDragEnd: (newPos) => _onUserSpotDragged(newPos),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: InfoWindow(
            title: isPickup ? 'Your Pickup Spot' : 'Your Dropoff Spot',
            snippet: _distanceInMeters != null
                ? '${_formatDistanceAndWalkTime(_distanceInMeters)} to route meeting point (Drag to move)'
                : 'Drag to move your spot',
          ),
        ),
      );
    }

    // 3. Meeting Point on Driver's Route
    if (_selectedRoutePoint != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('route_meeting_point'),
          position: _selectedRoutePoint!,
          draggable: true,
          onDrag: (newPos) => _onMeetingPointDragged(newPos),
          onDragEnd: (newPos) => _onMeetingPointDragged(newPos),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isPickup ? BitmapDescriptor.hueCyan : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: isPickup ? 'Pickup Meeting Point' : 'Dropoff Meeting Point',
            snippet: _distanceInMeters != null
                ? '${_formatDistanceAndWalkTime(_distanceInMeters)} (Drag along route)'
                : 'Drag along driver\'s route',
          ),
        ),
      );
    }

    // 4. Driver Stops along Route (Selectable as meeting point)
    for (int i = 0; i < widget.driverStops.length; i++) {
      final stop = widget.driverStops[i];
      final isSelected = _selectedRoutePoint != null &&
          (_selectedRoutePoint!.latitude - stop.location.latitude).abs() < 0.0003 &&
          (_selectedRoutePoint!.longitude - stop.location.longitude).abs() < 0.0003;

      markers.add(
        Marker(
          markerId: MarkerId('driver_stop_${stop.id ?? i}'),
          position: stop.location,
          zIndex: 5,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueCyan : BitmapDescriptor.hueYellow,
          ),
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: isPickup
                ? 'Driver Stop • Tap to choose as Pickup'
                : 'Driver Stop • Tap to choose as Dropoff',
            onTap: () => _onSelectStop(stop),
          ),
          onTap: () => _onSelectStop(stop),
        ),
      );
    }

    // Polylines: Main route + connecting dynamic walking hint line
    final Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId('driver_route'),
        points: widget.routePolylinePoints,
        color: Theme.of(context).primaryColor,
        width: 5,
      ),
    };

    if (ref != null &&
        _selectedRoutePoint != null &&
        ref != _selectedRoutePoint) {
      final walkingPoints = _walkingRoutePoints.isNotEmpty
          ? _walkingRoutePoints
          : [ref, _selectedRoutePoint!];
      polylines.add(
        Polyline(
          polylineId: const PolylineId('hint_line'),
          points: walkingPoints,
          color: widget.accentColor,
          width: 4,
          patterns: [
            PatternItem.dash(14),
            PatternItem.gap(8),
          ],
        ),
      );
    }

    final initialCenter = _selectedRoutePoint ??
        ref ??
        startPos ??
        const LatLng(30.0444, 31.2357);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.85,
          color: Colors.white,
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPickup ? Icons.directions_walk : Icons.place,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Search a place or tap anywhere to set meeting point'
                                .tr,
                            style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Search Bar Overlay
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: TypeAheadField<PredictionModel>(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'search_location'.tr.isNotEmpty &&
                                !'search_location'.tr.contains('search_location')
                            ? 'search_location'.tr
                            : 'Search street, landmark, address...',
                        hintStyle: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.grey.shade500,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: widget.accentColor,
                          size: 20,
                        ),
                        suffixIcon: _isLoadingPlace
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : controller.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      controller.clear();
                                      setState(() {
                                        _searchedAddress = null;
                                      });
                                    },
                                  )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.accentColor,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    );
                  },
                  suggestionsCallback: (pattern) async {
                    if (pattern.trim().isEmpty) return [];
                    try {
                      return await Get.find<LocationController>()
                          .searchLocation(context, pattern, fromMap: true);
                    } catch (e) {
                      return [];
                    }
                  },
                  itemBuilder: (context, PredictionModel suggestion) {
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: widget.accentColor,
                        size: 20,
                      ),
                      title: Text(
                        suggestion.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    );
                  },
                  onSelected: (PredictionModel suggestion) async {
                    if (suggestion.placeId == null) return;
                    _searchFocusNode.unfocus();
                    setState(() {
                      _isLoadingPlace = true;
                    });
                    try {
                      final locationCtrl = Get.find<LocationController>();
                      final response = await locationCtrl.locationServiceInterface
                          .getPlaceDetails(suggestion.placeId!);
                      if (response.statusCode == 200 &&
                          response.body['data'] != null) {
                        final placeDetails =
                            PlaceDetailsModel.fromJson(response.body);
                        final lat = placeDetails
                            .data?.result?.geometry?.location?.lat;
                        final lng = placeDetails
                            .data?.result?.geometry?.location?.lng;
                        if (lat != null && lng != null) {
                          final point =
                              MapBoundHelper.toCorrectLatLng(lat, lng);
                          final placeName =
                              placeDetails.data?.result?.name ??
                                  suggestion.description ??
                                  '';
                          _onLocationSearched(point, addressName: placeName);
                        }
                      }
                    } catch (e) {
                      debugPrint('Error getting place details: $e');
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoadingPlace = false;
                        });
                      }
                    }
                  },
                  emptyBuilder: (context) => const SizedBox(),
                ),
              ),

              // Driver Stops Bar (Instant selection chips)
              if (widget.driverStops.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.alt_route_rounded,
                            size: 14,
                            color: widget.accentColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isPickup
                                ? ('driver_stops'.tr.isNotEmpty &&
                                        !'driver_stops'.tr.contains('driver_stops')
                                    ? 'driver_stops'.tr
                                    : 'Driver Stops (Tap to choose as Pickup):')
                                : 'Driver Stops (Tap to choose as Dropoff):',
                            style: textSemiBold.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: widget.driverStops.map((stop) {
                            final isSelected = _selectedRoutePoint != null &&
                                (_selectedRoutePoint!.latitude - stop.location.latitude).abs() < 0.0003 &&
                                (_selectedRoutePoint!.longitude - stop.location.longitude).abs() < 0.0003;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => _onSelectStop(stop),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? widget.accentColor : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? widget.accentColor
                                          : const Color(0xFFCBD5E1),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.pin_drop_rounded,
                                        size: 13,
                                        color: isSelected ? Colors.white : widget.accentColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        stop.name,
                                        style: textMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF1E293B),
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (stop.time != null && stop.time!.isNotEmpty) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          '(${stop.time})',
                                          style: textRegular.copyWith(
                                            fontSize: Dimensions.fontSizeExtraSmall,
                                            color: isSelected
                                                ? Colors.white.withValues(alpha: 0.9)
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

              // Map Area
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: initialCenter,
                        zoom: 13,
                      ),
                      markers: markers,
                      polylines: polylines,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: false,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        final focusPoints = <LatLng>[
                          if (ref != null) ref,
                          if (_selectedRoutePoint != null) _selectedRoutePoint!,
                          if (startPos != null) startPos,
                          if (endPos != null) endPos,
                          ...widget.driverStops.map((s) => s.location),
                        ];
                        Future.delayed(
                          const Duration(milliseconds: 300),
                          () {
                            if (focusPoints.isNotEmpty) {
                              _fitPointsOnMap(focusPoints);
                            } else if (widget.routePolylinePoints.isNotEmpty) {
                              _fitPointsOnMap(widget.routePolylinePoints);
                            }
                          },
                        );
                      },
                      onTap: (position) => _onMapTapped(position),
                    ),

                    // Map Hint Badge Overlay
                    Positioned(
                      top: 10,
                      left: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.touch_app_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Tap or drag markers to adjust meeting point'
                                    .tr,
                                style: textRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
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

              // Bottom Info and Confirmation Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedRoutePoint != null) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.alt_route_rounded,
                              color: widget.accentColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        isPickup
                                            ? 'Meeting Point (Pickup)'
                                            : 'Meeting Point (Dropoff)',
                                        style: textBold.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (_distanceInMeters != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.orange.shade300,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.directions_walk,
                                              size: 13,
                                              color: Colors.orange.shade800,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              _formatDistanceAndWalkTime(
                                                  _distanceInMeters),
                                              style: textBold.copyWith(
                                                fontSize: 10,
                                                color: Colors.orange.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _searchedAddress != null &&
                                          _searchedAddress!.trim().isNotEmpty
                                      ? 'From: ${_searchedAddress!.trim()}'
                                      : 'Meeting point selected on driver route'
                                          .tr,
                                  style: textRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (ref != null &&
                                    ref != _selectedRoutePoint)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      'Dashed line links your location to the driver\'s route'
                                          .tr,
                                      style: textRegular.copyWith(
                                        fontSize: 10,
                                        color: widget.accentColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _openInGoogleMaps(
                                _selectedRoutePoint!.latitude,
                                _selectedRoutePoint!.longitude,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.accentColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: widget.accentColor
                                        .withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.navigation_rounded,
                                      color: widget.accentColor,
                                      size: 18,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Navigate'.tr,
                                      style: textBold.copyWith(
                                        fontSize: 9,
                                        color: widget.accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedRoutePoint != null
                            ? () {
                                widget.onLocationSelected(
                                  _selectedRoutePoint!,
                                  _searchedPoint,
                                  _searchedAddress,
                                );
                                Navigator.of(context).pop();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _selectedRoutePoint != null
                              ? ('confirm_location'.tr.isNotEmpty &&
                                      !'confirm_location'.tr
                                          .contains('confirm_location')
                                  ? 'confirm_location'.tr
                                  : 'Confirm Meeting Point')
                              : 'Tap on map or search to choose',
                          style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
