import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_details_screen_widgets/trip_details_header_widget.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_details_screen_widgets/trip_details_vehicle_widget.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_details_screen_widgets/trip_details_route_card_widget.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_details_screen_widgets/trip_details_info_list_widget.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_details_screen_widgets/trip_details_action_buttons_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import '../../../helper/price_converter.dart';
import '../../pool_stop_pickup/domain/models/pool_ride_model.dart';
import '../widgets/trip_details_screen_widgets/search_trip_details_map_preview_widget.dart';

class SearchTripDetailsScreen extends StatefulWidget {
  final dynamic trip;
  final bool fromSearch;
  final RideController rideController;

  const SearchTripDetailsScreen({
    super.key,
    required this.trip,
    required this.rideController,
    this.fromSearch = false,
  });

  @override
  State<SearchTripDetailsScreen> createState() =>
      _SearchTripDetailsScreenState();
}

class _SearchTripDetailsScreenState extends State<SearchTripDetailsScreen> {
  LatLng _toCorrectLatLng(double a, double b) {
    return MapBoundHelper.toCorrectLatLng(a, b);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'trip_details'.tr,
          style: textBold.copyWith(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {
              dev.log('search details');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TripDetailsHeaderWidget(trip: widget.trip),
            const SizedBox(height: 24),
            TripDetailsVehicleWidget(trip: widget.trip),
            const SizedBox(height: 18),
            TripDetailsRouteCardWidget(trip: widget.trip),
            const SizedBox(height: 20),
            TripDetailsInfoListWidget(trip: widget.trip),
            const SizedBox(height: 24),
            SearchTripDetailsMapPreviewWidget(
              trip: widget.trip,
              fromSearch: true,
              onTap: () => _showRouteMap(widget.trip, context),
            ),
            const SizedBox(height: 28),
            TripDetailsActionButtonsWidget(
              onJoinTrip: () => _selectTrip(widget.trip, widget.rideController),
              onViewFullRoute: () => _showRouteMap(widget.trip, context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRouteMap(dynamic trip, BuildContext context) {
    final List<LatLng> routePolylinePoints =
        MapBoundHelper.getRoutePolylinePoints(trip);

    final LatLng? startPoint =
        MapBoundHelper.getDriverStart(trip, routePolylinePoints);
    final LatLng? endPoint =
        MapBoundHelper.getDriverEnd(trip, routePolylinePoints);

    LatLng? closestPickupPos;
    if (trip.closestPickup?.lat != null &&
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

    LatLng? closestDropoffPos;
    if (trip.closestDropoff?.lat != null &&
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
            snippet: trip.closestPickup?.placeName ?? '',
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
            snippet: trip.closestDropoff?.placeName ?? '',
          ),
        ),
      );
    }

    final List<RouteStop> driverStops = MapBoundHelper.getDriverStops(trip);
    for (int i = 0; i < driverStops.length; i++) {
      final stop = driverStops[i];
      markers.add(
        Marker(
          markerId: MarkerId('driver_stop_${stop.id ?? i}'),
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
    for (final s in driverStops) {
      allPoints.add(s.location);
    }
    allPoints.addAll(routePolylinePoints);

    final Set<Polyline> polylines = {};
    if (routePolylinePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: routePolylinePoints,
          color: Theme.of(context).primaryColor,
          width: 4,
        ),
      );
    } else if (startPoint != null && endPoint != null) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [startPoint, endPoint],
          color: Theme.of(context).primaryColor,
          width: 4,
        ),
      );
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
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
                            [...allPoints, ...routePolylinePoints],
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
                              _openInGoogleMaps(
                                pos.latitude,
                                pos.longitude,
                              );
                            }
                          },
                          icon: const Icon(Icons.directions),
                          label: Text('Navigate to Meeting Point'.tr),
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
                              trip.carpoolType == 'north_coast'))) ...[
                        Text(
                          '${'Walking distance to pickup:'.tr} ${PriceConverter.formatDistance(PriceConverter.calculateDistance(
                            trip.pickupMatchPoint.lat,
                            trip.pickupMatchPoint.lng,
                            trip.closestPickup?.lat ??
                                trip.pickupMatchPoint.lat,
                            trip.closestPickup?.lng ??
                                trip.pickupMatchPoint.lng,
                          ))}',
                          style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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
    rideController.selectCarpoolTrip(
      trip,
      bookingType: 'all',
      selectedDates: const [],
    );
  }
}
