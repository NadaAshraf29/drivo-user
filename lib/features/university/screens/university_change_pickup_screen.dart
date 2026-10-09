import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/university/controllers/university_controller.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_pickup_point_model.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_trip_model.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_changing_pickup_info_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_current_route_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_map_picker_preview.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_pickup_point_option_card.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class UniversityChangePickupScreen extends StatefulWidget {
  final UniversityTripModel trip;
  final String currentPickupPoint;

  const UniversityChangePickupScreen({
    super.key,
    required this.trip,
    required this.currentPickupPoint,
  });

  @override
  State<UniversityChangePickupScreen> createState() =>
      _UniversityChangePickupScreenState();
}

class _UniversityChangePickupScreenState
    extends State<UniversityChangePickupScreen> {
  late String _selectedPickupPoint;

  @override
  void initState() {
    super.initState();
    _selectedPickupPoint = widget.currentPickupPoint.isNotEmpty
        ? widget.currentPickupPoint
        : 'Abbas El Akkad';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<UniversityController>()) {
        Get.find<UniversityController>().getPickupPointsForTrip(widget.trip.id);
      }
    });
  }

  String? _calculateDistanceFromUser(double? pLat, double? pLng) {
    if (pLat == null || pLng == null || (pLat == 0 && pLng == 0)) return null;
    if (!Get.isRegistered<LocationController>()) return null;
    final userPos = Get.find<LocationController>().position;
    if (userPos.latitude == 0 && userPos.longitude == 0) return null;

    final corrected = MapBoundHelper.toCorrectLatLng(pLat, pLng);
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

  Future<void> _openInGoogleMaps(double? lat, double? lng, [String? name]) async {
    if (lat == null || lng == null || (lat == 0 && lng == 0)) {
      Get.snackbar(
        'Location Unavailable',
        'Coordinates for this pickup point are not available.',
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0F172A),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final point = MapBoundHelper.toCorrectLatLng(lat, lng);
      final cLat = point.latitude;
      final cLng = point.longitude;
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
          'Could not open Google Maps. Please install Google Maps app.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Title Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F7FA),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'pickup_point_title'.tr,
                        style: textBold.copyWith(
                          fontSize: 20,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'choose_from_available_points'.tr,
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Route Card
                    UniversityCurrentRouteCard(
                      routeName: widget.trip.routeName,
                      university: widget.trip.toUniversity,
                    ),
                    const SizedBox(height: 20),

                    // Quick Pickup Points
                    Text(
                      'quick_pickup_points'.tr,
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    GetBuilder<UniversityController>(
                      builder: (uniController) {
                        final points = uniController.availablePickupPoints;

                        if (points.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'no_pickup_points_for_university'.tr,
                                style: textRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            ...points.map((point) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: UniversityPickupPointOptionCard(
                                  title: point.name,
                                  subtitle: point.timing,
                                  distanceText: _calculateDistanceFromUser(
                                      point.latitude, point.longitude),
                                  tag: point.tag != null && point.tag!.isNotEmpty
                                      ? point.tag
                                      : null,
                                  isSelected: _selectedPickupPoint == point.name,
                                  onTap: () {
                                    setState(() {
                                      _selectedPickupPoint = point.name;
                                    });
                                    uniController
                                        .setSelectedPickupPoint(point.name);
                                  },
                                  onNavigate: () => _openInGoogleMaps(
                                    point.latitude,
                                    point.longitude,
                                    point.name,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 6),
                            // Map View Preview with points from uniController
                            UniversityMapPickerPreview(
                              trip: widget.trip,
                              selectedPickupPoint: _selectedPickupPoint,
                              pickupPoints: points,
                              onNavigate: (lat, lng, name) =>
                                  _openInGoogleMaps(lat, lng, name),
                              onSelectPoint: (point) {
                                setState(() {
                                  _selectedPickupPoint = point;
                                });
                                uniController.setSelectedPickupPoint(point);
                              },
                              onViewMap: () {
                                Get.snackbar(
                                  'choose_from_map'.tr,
                                  _selectedPickupPoint,
                                  backgroundColor: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Info Card
                    const UniversityChangingPickupInfoCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Save Button
                    InkWell(
                      onTap: () {
                        Get.back(result: _selectedPickupPoint);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A0E9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'save_pickup_point'.tr,
                            style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Cancel Button
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'cancel'.tr,
                            style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
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
    );
  }
}
