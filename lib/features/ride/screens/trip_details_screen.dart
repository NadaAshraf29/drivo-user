import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_details_screen_widgets/trip_details_header_widget.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_details_screen_widgets/trip_details_vehicle_widget.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_details_screen_widgets/trip_details_route_card_widget.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_details_screen_widgets/trip_details_info_list_widget.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_details_screen_widgets/trip_details_map_preview_widget.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_details_screen_widgets/trip_details_location_field_widget.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_details_screen_widgets/trip_details_location_picker_dialog.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/seats_dropdown.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/pool_stop_pickup_controller.dart';

enum _RouteLocationTarget { pickup, dropoff }

class TripDetailsScreen extends StatefulWidget {
  final dynamic trip;
  final bool fromSearch;
  final RideController rideController;

  const TripDetailsScreen({
    super.key,
    required this.trip,
    required this.rideController,
    this.fromSearch = false,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  LatLng? _selectedClosestPickup;
  LatLng? _selectedClosestDropoff;
  LatLng? _searchedPickupPoint;
  LatLng? _searchedDropoffPoint;
  String? _selectedPickupAddress;
  String? _selectedDropoffAddress;
  int _selectedSeats = 1;
  List<LatLng> _actualDriverRoutePoints = [];

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<PoolStopPickupController>()) {
      final seats = Get.find<PoolStopPickupController>().selectedSeats;
      if (seats >= 1) {
        _selectedSeats = seats;
      }
    }
    _initializeSelectedLocations();
    _initActualDriverRoute();
  }

  void _initActualDriverRoute() {
    MapBoundHelper.getActualDriverRoute(widget.trip).then((pts) {
      if (!mounted) return;
      if (pts.isNotEmpty) {
        setState(() {
          _actualDriverRoutePoints = pts;
          if (_searchedPickupPoint != null) {
            _selectedClosestPickup = MapBoundHelper.findClosestPointOnRoute(
                _searchedPickupPoint!, pts);
          }
          if (_searchedDropoffPoint != null) {
            _selectedClosestDropoff = MapBoundHelper.findClosestPointOnRoute(
                _searchedDropoffPoint!, pts);
          }
        });
      }
    }).catchError((_) {});
  }

  void _initializeSelectedLocations() {
    final trip = widget.trip;
    final routePoints = _routePolylinePoints(trip);

    // 1. Searched reference points (Passenger's requested locations)
    final passengerPickup = MapBoundHelper.getPassengerPickup(trip);
    final passengerDropoff = MapBoundHelper.getPassengerDropoff(trip);

    if (passengerPickup != null) {
      _searchedPickupPoint = passengerPickup;
    } else if (trip.pickupMatchPoint != null &&
        (trip.pickupMatchPoint.lat != 0.0 ||
            trip.pickupMatchPoint.lng != 0.0)) {
      _searchedPickupPoint = _mapCoordinateFromTrip(
          trip.pickupMatchPoint.lat, trip.pickupMatchPoint.lng);
    }

    if (passengerDropoff != null) {
      _searchedDropoffPoint = passengerDropoff;
    } else if (trip.dropoffMatchPoint != null &&
        (trip.dropoffMatchPoint.lat != 0.0 ||
            trip.dropoffMatchPoint.lng != 0.0)) {
      _searchedDropoffPoint = _mapCoordinateFromTrip(
          trip.dropoffMatchPoint.lat, trip.dropoffMatchPoint.lng);
    }

    // 2. Closest points on route (Meeting point & Dropoff spot) -> Shortest walk
    if (_searchedPickupPoint != null && routePoints.isNotEmpty) {
      _selectedClosestPickup = MapBoundHelper.findClosestPointOnRoute(
          _searchedPickupPoint!, routePoints);
    } else {
      final pickup = trip.closestPickup;
      if (pickup?.lat != null &&
          pickup?.lng != null &&
          (pickup!.lat != 0.0 || pickup.lng != 0.0)) {
        _selectedClosestPickup = _mapCoordinateFromTrip(pickup.lat, pickup.lng);
      } else if (trip.boardingPointStart != null &&
          (trip.boardingPointStart!.latitude != 0.0 ||
              trip.boardingPointStart!.longitude != 0.0)) {
        _selectedClosestPickup = _mapCoordinateFromTrip(
            trip.boardingPointStart!.latitude,
            trip.boardingPointStart!.longitude);
      } else if (routePoints.isNotEmpty) {
        _selectedClosestPickup = routePoints.first;
      }
    }

    final pickup = trip.closestPickup;
    if (pickup?.placeName != null &&
        pickup!.placeName.trim().isNotEmpty &&
        !_isCoordinateString(pickup.placeName)) {
      _selectedPickupAddress = pickup.placeName.trim();
    } else if (trip.boardingPointStart?.name != null &&
        trip.boardingPointStart!.name.trim().isNotEmpty &&
        !_isCoordinateString(trip.boardingPointStart!.name)) {
      _selectedPickupAddress = trip.boardingPointStart!.name.trim();
    } else if (trip.pickupAddress != null &&
        trip.pickupAddress.toString().trim().isNotEmpty &&
        !_isCoordinateString(trip.pickupAddress.toString())) {
      _selectedPickupAddress = trip.pickupAddress.toString().trim();
    } else if (trip.title != null && trip.title.toString().trim().isNotEmpty) {
      final parts = trip.title.toString().split(RegExp(r'[-➔→to]'));
      if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
        _selectedPickupAddress = parts[0].trim();
      }
    }

    if (_searchedDropoffPoint != null && routePoints.isNotEmpty) {
      _selectedClosestDropoff = MapBoundHelper.findClosestPointOnRoute(
          _searchedDropoffPoint!, routePoints);
    } else {
      final dropoff = trip.closestDropoff;
      if (dropoff?.lat != null &&
          dropoff?.lng != null &&
          (dropoff!.lat != 0.0 || dropoff.lng != 0.0)) {
        _selectedClosestDropoff =
            _mapCoordinateFromTrip(dropoff.lat, dropoff.lng);
      } else if (trip.boardingPointEnd != null &&
          (trip.boardingPointEnd!.latitude != 0.0 ||
              trip.boardingPointEnd!.longitude != 0.0)) {
        _selectedClosestDropoff = _mapCoordinateFromTrip(
            trip.boardingPointEnd!.latitude, trip.boardingPointEnd!.longitude);
      } else if (routePoints.isNotEmpty) {
        _selectedClosestDropoff = routePoints.last;
      }
    }

    final dropoff = trip.closestDropoff;
    if (dropoff?.placeName != null &&
        dropoff!.placeName.trim().isNotEmpty &&
        !_isCoordinateString(dropoff.placeName)) {
      _selectedDropoffAddress = dropoff.placeName.trim();
    } else if (trip.boardingPointEnd?.name != null &&
        trip.boardingPointEnd!.name.trim().isNotEmpty &&
        !_isCoordinateString(trip.boardingPointEnd!.name)) {
      _selectedDropoffAddress = trip.boardingPointEnd!.name.trim();
    } else if (trip.dropoffAddress != null &&
        trip.dropoffAddress.toString().trim().isNotEmpty &&
        !_isCoordinateString(trip.dropoffAddress.toString())) {
      _selectedDropoffAddress = trip.dropoffAddress.toString().trim();
    } else if (trip.title != null && trip.title.toString().trim().isNotEmpty) {
      final parts = trip.title.toString().split(RegExp(r'[-➔→to]'));
      if (parts.length >= 2 && parts[1].trim().isNotEmpty) {
        _selectedDropoffAddress = parts[1].trim();
      }
    }
  }

  bool _isCoordinateString(String s) {
    final trimmed = s.trim();
    final coordRegex = RegExp(r'^-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?$');
    return coordRegex.hasMatch(trimmed);
  }

  bool get _requiresRouteLocationSelection {
    try {
      final trip = widget.trip;
      if (trip != null) {
        String ct = '';
        try {
          if (trip.carpoolType != null &&
              trip.carpoolType.toString().trim().isNotEmpty) {
            ct = trip.carpoolType.toString().toLowerCase().trim();
          }
        } catch (_) {}
        if (ct.isEmpty) {
          try {
            if (trip.type != null &&
                trip.type.toString().trim().isNotEmpty) {
              ct = trip.type.toString().toLowerCase().trim();
            }
          } catch (_) {}
        }
        if (ct == 'travel' || ct == 'north_coast' || ct == 'sahel') {
          return false;
        }
        try {
          if (trip.isTravelOrNorthCoast == true) {
            return false;
          }
        } catch (_) {}
      }
    } catch (_) {}
    return true;
  }

  LatLng _toCorrectLatLng(double a, double b) {
    return MapBoundHelper.toCorrectLatLng(a, b);
  }

  LatLng _mapCoordinateFromTrip(double lat, double lng) {
    return _toCorrectLatLng(lat, lng);
  }

  List<LatLng> _routePolylinePoints(dynamic trip) {
    if (_actualDriverRoutePoints.isNotEmpty) {
      return _actualDriverRoutePoints;
    }
    return MapBoundHelper.getRoutePolylinePoints(trip);
  }

  @override
  Widget build(BuildContext context) {
    final int seatsLeft =
        widget.trip.seatsAvailable ?? (widget.trip.availableSeats ?? 2);
    final num price = widget.trip.price ?? (widget.trip.fare ?? 240);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E2432),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'trip_details'.tr.isNotEmpty &&
                  !'trip_details'.tr.contains('trip_details')
              ? 'trip_details'.tr
              : 'Trip Details',
          style: textBold.copyWith(
            color: const Color(0xFF1E2432),
            fontSize: 17,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Icons.share_outlined,
        //       color: Color(0xFF1E2432),
        //       size: 20,
        //     ),
        //     onPressed: () {
        //       // Share functionality
        //     },
        //   ),
        // ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TripDetailsHeaderWidget(trip: widget.trip),
              const SizedBox(height: 12),
              TripDetailsVehicleWidget(trip: widget.trip),
              const SizedBox(height: 12),
              TripDetailsRouteCardWidget(trip: widget.trip),
              const SizedBox(height: 12),
              TripDetailsInfoListWidget(trip: widget.trip),
              if (_requiresRouteLocationSelection) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.alt_route_rounded,
                      size: 16,
                      color: Color(0xFF00A3EC),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'meeting_points'.tr.isNotEmpty &&
                              !'meeting_points'.tr.contains('meeting_points')
                          ? 'meeting_points'.tr
                          : 'Pickup & Dropoff Spots',
                      style: textBold.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF1E2432),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TripDetailsLocationFieldWidget(
                  label: 'closest_pickup'.tr.isNotEmpty &&
                          !'closest_pickup'.tr.contains('closest_pickup')
                      ? 'closest_pickup'.tr
                      : 'Closest Pickup Point',
                  selectedPoint: _selectedClosestPickup,
                  userReferencePoint: _searchedPickupPoint ??
                      MapBoundHelper.getPassengerPickup(widget.trip),
                  addressName: _selectedPickupAddress,
                  accentColor: const Color(0xFF00A3EC),
                  onTap: () => _showPolylineLocationPicker(
                    context,
                    widget.trip,
                    _RouteLocationTarget.pickup,
                  ),
                ),
                if (MapBoundHelper.getDriverStops(widget.trip).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.alt_route_rounded,
                              size: 15,
                              color: Color(0xFF00A3EC),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'driver_stops'.tr.isNotEmpty &&
                                        !'driver_stops'.tr.contains('driver_stops')
                                    ? 'driver_stops'.tr
                                    : 'Stops along route (Choose as pickup):',
                                style: textSemiBold.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: MapBoundHelper.getDriverStops(widget.trip)
                              .map((stop) {
                            final bool isSelected = _selectedClosestPickup !=
                                    null &&
                                (_selectedClosestPickup!.latitude -
                                            stop.location.latitude)
                                        .abs() <
                                    0.0003 &&
                                (_selectedClosestPickup!.longitude -
                                            stop.location.longitude)
                                        .abs() <
                                    0.0003;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedClosestPickup = stop.location;
                                  _selectedPickupAddress = stop.name;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF00A3EC)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF00A3EC)
                                        : const Color(0xFFCBD5E1),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF00A3EC),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      stop.name,
                                      style: textMedium.copyWith(
                                        fontSize: 12,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF1E293B),
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    if (stop.time != null &&
                                        stop.time!.isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${stop.time})',
                                        style: textRegular.copyWith(
                                          fontSize: 10,
                                          color: isSelected
                                              ? Colors.white70
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                TripDetailsLocationFieldWidget(
                  label: 'closest_dropoff'.tr.isNotEmpty &&
                          !'closest_dropoff'.tr.contains('closest_dropoff')
                      ? 'closest_dropoff'.tr
                      : 'Closest Dropoff Point',
                  selectedPoint: _selectedClosestDropoff,
                  userReferencePoint: _searchedDropoffPoint ??
                      MapBoundHelper.getPassengerDropoff(widget.trip),
                  addressName: _selectedDropoffAddress,
                  accentColor: const Color(0xFFEF5350),
                  onTap: () => _showPolylineLocationPicker(
                    context,
                    widget.trip,
                    _RouteLocationTarget.dropoff,
                  ),
                ),
                if (MapBoundHelper.getDriverStops(widget.trip).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.alt_route_rounded,
                              size: 15,
                              color: Color(0xFFEF5350),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Stops along route (Choose as dropoff):',
                                style: textSemiBold.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: MapBoundHelper.getDriverStops(widget.trip)
                              .map((stop) {
                            final bool isSelected = _selectedClosestDropoff !=
                                    null &&
                                (_selectedClosestDropoff!.latitude -
                                            stop.location.latitude)
                                        .abs() <
                                    0.0003 &&
                                (_selectedClosestDropoff!.longitude -
                                            stop.location.longitude)
                                        .abs() <
                                    0.0003;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedClosestDropoff = stop.location;
                                  _selectedDropoffAddress = stop.name;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFEF5350)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFEF5350)
                                        : const Color(0xFFCBD5E1),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFFEF5350),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      stop.name,
                                      style: textMedium.copyWith(
                                        fontSize: 12,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF1E293B),
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    if (stop.time != null &&
                                        stop.time!.isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${stop.time})',
                                        style: textRegular.copyWith(
                                          fontSize: 10,
                                          color: isSelected
                                              ? Colors.white70
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.event_seat_rounded,
                      size: 16,
                      color: Color(0xFF00A3EC),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'number_of_seats'.tr.isNotEmpty &&
                              !'number_of_seats'.tr.contains('number_of_seats')
                          ? 'number_of_seats'.tr
                          : 'Number of Seats',
                      style: textBold.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF1E2432),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SeatsDropdown(
                  value: _selectedSeats,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedSeats = val;
                      });
                      if (Get.isRegistered<PoolStopPickupController>()) {
                        Get.find<PoolStopPickupController>()
                            .setSearchParameters(seats: val);
                      }
                    }
                  },
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.map_rounded,
                        size: 16,
                        color: Color(0xFF00A3EC),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'route_preview'.tr.isNotEmpty &&
                                !'route_preview'.tr.contains('route_preview')
                            ? 'route_preview'.tr
                            : 'Route Preview',
                        style: textBold.copyWith(
                          fontSize: 14,
                          color: const Color(0xFF1E2432),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => _showRouteMap(widget.trip, context),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Text(
                        'view_full_route'.tr.isNotEmpty &&
                                !'view_full_route'
                                    .tr
                                    .contains('view_full_route')
                            ? 'view_full_route'.tr
                            : 'View Full',
                        style: textBold.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF00A3EC),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TripDetailsMapPreviewWidget(
                trip: widget.trip,
                fromSearch: true,
                selectedPickupPoint: _searchedPickupPoint,
                selectedClosestPickup: _selectedClosestPickup,
                selectedDropoffPoint: _searchedDropoffPoint,
                selectedClosestDropoff: _selectedClosestDropoff,
                onTap: () => _showRouteMap(widget.trip, context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Price & Seats Left Block
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$price',
                          style: textBold.copyWith(
                            fontSize: 22,
                            color: const Color(0xFF1E2432),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${'egp'.tr} / ${'seat'.tr.isNotEmpty && !'seat'.tr.contains('seat') ? 'seat'.tr : 'seat'}',
                          style: textMedium.copyWith(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$seatsLeft ${'seats_left'.tr.isNotEmpty && !'seats_left'.tr.contains('seats_left') ? 'seats_left'.tr : 'seats left'}',
                          style: textMedium.copyWith(
                            fontSize: 11,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // CTA Button
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _selectTrip(widget.trip, widget.rideController),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    'join_a_ride'.tr.isNotEmpty &&
                            !'join_a_ride'.tr.contains('join_a_ride')
                        ? 'join_a_ride'.tr
                        : 'Join a Ride',
                    style: textBold.copyWith(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF211F20),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPolylineLocationPicker(
    BuildContext context,
    dynamic trip,
    _RouteLocationTarget target,
  ) {
    final routePolylinePoints = _routePolylinePoints(trip);
    if (routePolylinePoints.isEmpty) {
      Get.snackbar(
        'Error',
        'tap_on_route_to_select_location'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final LatLng? driverStart =
        MapBoundHelper.getDriverStart(trip, routePolylinePoints);
    final LatLng? driverEnd =
        MapBoundHelper.getDriverEnd(trip, routePolylinePoints);
    final LatLng? passengerPickup = MapBoundHelper.getPassengerPickup(trip);
    final LatLng? passengerDropoff = MapBoundHelper.getPassengerDropoff(trip);

    final isPickup = target == _RouteLocationTarget.pickup;
    final List<RouteStop> driverStops = MapBoundHelper.getDriverStops(trip);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return TripDetailsLocationPickerDialog(
          target: isPickup
              ? LocationPickerTarget.pickup
              : LocationPickerTarget.dropoff,
          routePolylinePoints: routePolylinePoints,
          routeStartPoint: driverStart,
          routeEndPoint: driverEnd,
          routeStartAddress: trip.pickupAddress ?? 'Start of driver route',
          routeEndAddress: trip.dropoffAddress ?? 'End of driver route',
          initialRoutePoint:
              isPickup ? _selectedClosestPickup : _selectedClosestDropoff,
          initialSearchedPoint: isPickup
              ? (_searchedPickupPoint ?? passengerPickup)
              : (_searchedDropoffPoint ?? passengerDropoff),
          initialAddress:
              isPickup ? _selectedPickupAddress : _selectedDropoffAddress,
          pickupPoint: passengerPickup,
          dropoffPoint: passengerDropoff,
          driverStops: driverStops,
          accentColor: isPickup ? Colors.cyan : Colors.orange,
          onLocationSelected: (routePoint, searchedPoint, addressName) {
            setState(() {
              if (isPickup) {
                _selectedClosestPickup = routePoint;
                _searchedPickupPoint = searchedPoint;
                _selectedPickupAddress = addressName;
              } else {
                _selectedClosestDropoff = routePoint;
                _searchedDropoffPoint = searchedPoint;
                _selectedDropoffAddress = addressName;
              }
            });
          },
        );
      },
    );
  }

  void _showRouteMap(dynamic trip, BuildContext context) {
    final List<LatLng> routePolylinePoints = _routePolylinePoints(trip);
    final LatLng? startPoint =
        MapBoundHelper.getDriverStart(trip, routePolylinePoints);
    final LatLng? endPoint =
        MapBoundHelper.getDriverEnd(trip, routePolylinePoints);

    LatLng? userPickupPos;
    if (_searchedPickupPoint != null) {
      userPickupPos = _toCorrectLatLng(
          _searchedPickupPoint!.latitude, _searchedPickupPoint!.longitude);
    } else if (trip.pickupMatchPoint != null &&
        (trip.pickupMatchPoint.lat != 0.0 ||
            trip.pickupMatchPoint.lng != 0.0)) {
      userPickupPos = _toCorrectLatLng(
          trip.pickupMatchPoint.lat, trip.pickupMatchPoint.lng);
    }

    LatLng? closestPickupPos;
    if (_selectedClosestPickup != null) {
      closestPickupPos = _toCorrectLatLng(
          _selectedClosestPickup!.latitude, _selectedClosestPickup!.longitude);
    } else if (trip.closestPickup?.lat != null &&
        trip.closestPickup?.lng != null &&
        (trip.closestPickup!.lat != 0.0 || trip.closestPickup!.lng != 0.0)) {
      closestPickupPos =
          _toCorrectLatLng(trip.closestPickup!.lat, trip.closestPickup!.lng);
    } else if (trip.boardingPointStart != null &&
        (trip.boardingPointStart!.latitude != 0.0 ||
            trip.boardingPointStart!.longitude != 0.0)) {
      closestPickupPos = _toCorrectLatLng(trip.boardingPointStart!.latitude,
          trip.boardingPointStart!.longitude);
    }

    LatLng? userDropoffPos;
    if (_searchedDropoffPoint != null) {
      userDropoffPos = _toCorrectLatLng(
          _searchedDropoffPoint!.latitude, _searchedDropoffPoint!.longitude);
    } else if (trip.dropoffMatchPoint != null &&
        (trip.dropoffMatchPoint.lat != 0.0 ||
            trip.dropoffMatchPoint.lng != 0.0)) {
      userDropoffPos = _toCorrectLatLng(
          trip.dropoffMatchPoint.lat, trip.dropoffMatchPoint.lng);
    }

    LatLng? closestDropoffPos;
    if (_selectedClosestDropoff != null) {
      closestDropoffPos = _toCorrectLatLng(_selectedClosestDropoff!.latitude,
          _selectedClosestDropoff!.longitude);
    } else if (trip.closestDropoff?.lat != null &&
        trip.closestDropoff?.lng != null &&
        (trip.closestDropoff!.lat != 0.0 || trip.closestDropoff!.lng != 0.0)) {
      closestDropoffPos =
          _toCorrectLatLng(trip.closestDropoff!.lat, trip.closestDropoff!.lng);
    } else if (trip.boardingPointEnd != null &&
        (trip.boardingPointEnd!.latitude != 0.0 ||
            trip.boardingPointEnd!.longitude != 0.0)) {
      closestDropoffPos = _toCorrectLatLng(
          trip.boardingPointEnd!.latitude, trip.boardingPointEnd!.longitude);
    }

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
            snippet: trip.pickupAddress ?? trip.boardingPointStart?.name ?? '',
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
            snippet: trip.dropoffAddress ?? trip.boardingPointEnd?.name ?? '',
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
            snippet: trip.closestPickup?.placeName ??
                _selectedPickupAddress ??
                'Meeting Point on Route',
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
            snippet:
                _selectedDropoffAddress ?? trip.closestDropoff?.placeName ?? '',
          ),
        ),
      );
    }

    final List<RouteStop> driverStops = MapBoundHelper.getDriverStops(trip);
    for (int i = 0; i < driverStops.length; i++) {
      final stop = driverStops[i];
      markers.add(
        Marker(
          markerId: MarkerId('route_stop_${stop.id ?? i}'),
          position: stop.location,
          zIndex: 5,
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

    final List<LatLng> allPoints = [];
    if (startPoint != null) {
      allPoints.add(startPoint);
    }
    if (endPoint != null) {
      allPoints.add(endPoint);
    }
    if (userPickupPos != null) {
      allPoints.add(userPickupPos);
    }
    if (closestPickupPos != null) {
      allPoints.add(closestPickupPos);
    }
    if (userDropoffPos != null) {
      allPoints.add(userDropoffPos);
    }
    if (closestDropoffPos != null) {
      allPoints.add(closestDropoffPos);
    }
    for (final s in driverStops) {
      allPoints.add(s.location);
    }
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        final Set<Polyline> polylines = {};
        if (routePolylinePoints.isNotEmpty) {
          polylines.add(
            Polyline(
              polylineId: const PolylineId('driver_actual_route'),
              points: routePolylinePoints,
              color: Theme.of(context).primaryColor,
              width: 4,
            ),
          );
        } else if (startPoint != null && endPoint != null) {
          polylines.add(
            Polyline(
              polylineId: const PolylineId('driver_actual_route'),
              points: [startPoint, endPoint],
              color: Theme.of(context).primaryColor,
              width: 4,
            ),
          );
        }

        if (closestPickupPos != null &&
            closestDropoffPos != null &&
            routePolylinePoints.length >= 2) {
          int idxPickup = 0;
          double minD1 = double.infinity;
          int idxDropoff = routePolylinePoints.length - 1;
          double minD2 = double.infinity;

          for (int i = 0; i < routePolylinePoints.length; i++) {
            final d1 = Geolocator.distanceBetween(
              closestPickupPos.latitude,
              closestPickupPos.longitude,
              routePolylinePoints[i].latitude,
              routePolylinePoints[i].longitude,
            );
            if (d1 < minD1) {
              minD1 = d1;
              idxPickup = i;
            }

            final d2 = Geolocator.distanceBetween(
              closestDropoffPos.latitude,
              closestDropoffPos.longitude,
              routePolylinePoints[i].latitude,
              routePolylinePoints[i].longitude,
            );
            if (d2 < minD2) {
              minD2 = d2;
              idxDropoff = i;
            }
          }

          if (idxPickup < idxDropoff) {
            polylines.add(
              Polyline(
                polylineId: const PolylineId('passenger_active_segment'),
                points: [
                  closestPickupPos,
                  ...routePolylinePoints.sublist(idxPickup, idxDropoff + 1),
                  closestDropoffPos,
                ],
                color: const Color(0xFF0284C7),
                width: 6,
                zIndex: 2,
              ),
            );
          }
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 0.95,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'view_full_route'.tr,
                          style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: allPoints.isNotEmpty
                            ? allPoints.first
                            : (startPoint ?? const LatLng(30.1181, 31.6089)),
                        zoom: 13,
                      ),
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: true,
                      compassEnabled: true,
                      markers: markers,
                      polylines: polylines,
                      onMapCreated: (controller) {
                        Future.delayed(const Duration(milliseconds: 200), () {
                          _fitMapBounds(
                            controller,
                            [
                              ...allPoints,
                              ...routePolylinePoints,
                            ],
                          );
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (closestPickupPos != null) ...[
                        ElevatedButton.icon(
                          onPressed: () {
                            final pos = closestPickupPos;
                            if (pos != null) {
                              _openInGoogleMaps(pos.latitude, pos.longitude);
                            }
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Navigate to Meeting Point'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (!(trip is PoolRide &&
                          (trip.carpoolType == 'travel' ||
                              trip.carpoolType == 'north_coast')))
                        ...[],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    try {
      final point = _toCorrectLatLng(lat, lng);
      final cLat = point.latitude;
      final cLng = point.longitude;
      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$cLat,$cLng&travelmode=driving';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        final fallbackUrl = 'https://maps.google.com/maps?q=$cLat,$cLng';
        if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
          await launchUrl(Uri.parse(fallbackUrl),
              mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar(
            'Error',
            'Could not open Google Maps. Please install Google Maps app.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
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

  void _fitMapBounds(GoogleMapController controller, List<LatLng> points) {
    if (points.isEmpty) return;

    if (points.length == 1) {
      controller.animateCamera(
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

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _selectTrip(dynamic trip, RideController rideController) {
    if (_requiresRouteLocationSelection &&
        (_selectedClosestPickup == null || _selectedClosestDropoff == null)) {
      Get.snackbar(
        'Error',
        'please_select_pickup_and_dropoff_on_route'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final pPoint = _selectedClosestPickup != null
        ? _toCorrectLatLng(
            _selectedClosestPickup!.latitude, _selectedClosestPickup!.longitude)
        : null;
    final dPoint = _selectedClosestDropoff != null
        ? _toCorrectLatLng(_selectedClosestDropoff!.latitude,
            _selectedClosestDropoff!.longitude)
        : null;

    if (Get.isRegistered<PoolStopPickupController>()) {
      Get.find<PoolStopPickupController>()
          .setSearchParameters(seats: _selectedSeats);
    }

    rideController.selectCarpoolTrip(
      trip,
      bookingType: 'all',
      selectedDates: const [],
      selectedPickupLat: pPoint?.latitude,
      selectedPickupLng: pPoint?.longitude,
      selectedDropoffLat: dPoint?.latitude,
      selectedDropoffLng: dPoint?.longitude,
    );
  }
}
