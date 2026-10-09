import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/school/controllers/school_controller.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_pickup_point_model.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_trip_model.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_changing_pickup_info_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_current_route_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_map_picker_preview.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_pickup_point_option_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_top_bar.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolChangePickupScreen extends StatefulWidget {
  final SchoolTripModel trip;

  const SchoolChangePickupScreen({
    super.key,
    required this.trip,
  });

  @override
  State<SchoolChangePickupScreen> createState() =>
      _SchoolChangePickupScreenState();
}

class _SchoolChangePickupScreenState extends State<SchoolChangePickupScreen> {
  String _selectedPointName = '';

  @override
  void initState() {
    super.initState();
    final schoolCtrl = Get.find<SchoolController>();
    _selectedPointName = schoolCtrl.selectedPickupPoint.isNotEmpty
        ? schoolCtrl.selectedPickupPoint
        : widget.trip.pickupPoint;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      schoolCtrl.getPickupPointsForTrip(
        widget.trip.id,
        schoolName: widget.trip.toSchool,
      );
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

  void _onSavePickupPoint(SchoolController schoolCtrl) {
    if (_selectedPointName.isNotEmpty) {
      schoolCtrl.setSelectedPickupPoint(_selectedPointName);
      showCustomSnackBar(
        'pickup_point_updated'.tr,
        isError: false,
      );
      Get.back(result: _selectedPointName);
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GetBuilder<SchoolController>(
          builder: (schoolCtrl) {
            final points = schoolCtrl.availablePickupPoints;

            return Column(
              children: [
                const SchoolTopBar(showBackButton: true),
                const SizedBox(height: 8),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Pickup point / Choose from available points
                        Text(
                          'pickup_point_title'.tr,
                          style: textBold.copyWith(
                            fontSize: 24,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'choose_from_available_points'.tr,
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Current Route Card
                        SchoolCurrentRouteCard(
                          routeName: widget.trip.routeName,
                        ),
                        const SizedBox(height: 20),

                        // Quick Pickup Points
                        Text(
                          'quick_pickup_points'.tr,
                          style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (schoolCtrl.isLoadingPickupPoints)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: Color(0xFF00A0E9),
                              ),
                            ),
                          )
                        else if (points.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: Text(
                                'no_pickup_points_for_school'.tr,
                                style: textMedium.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: points.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final point = points[index];
                              final isSelected =
                                  _selectedPointName == point.name;
                              final distText = _calculateDistanceFromUser(
                                  point.latitude, point.longitude);
                              final displayPoint = (point.distanceText.isNotEmpty)
                                  ? point
                                  : SchoolPickupPointModel(
                                      id: point.id,
                                      name: point.name,
                                      pickupTime: point.pickupTime,
                                      distanceText: distText ?? '',
                                      latitude: point.latitude,
                                      longitude: point.longitude,
                                      isCurrent: point.isCurrent,
                                    );
                              return SchoolPickupPointOptionCard(
                                point: displayPoint,
                                isSelected: isSelected,
                                onSelect: () {
                                  setState(() {
                                    _selectedPointName = point.name;
                                  });
                                },
                              );
                            },
                          ),
                        const SizedBox(height: 20),

                        // Choose from map preview
                        SchoolMapPickerPreview(
                          trip: widget.trip,
                          selectedPickupPoint: _selectedPointName,
                          pickupPoints: points,
                          onSelectPoint: (point) {
                            setState(() {
                              _selectedPointName = point;
                            });
                          },
                          onViewMap: () {
                            if (_selectedPointName.isNotEmpty) {
                              showCustomSnackBar(
                                '${'current_pickup_point'.tr}: $_selectedPointName',
                                isError: false,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Changing pickup point info note
                        const SchoolChangingPickupInfoCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Actions: Save & Cancel
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: const Color(0xFFE2E8F0)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => _onSavePickupPoint(schoolCtrl),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A0E9),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'save_pickup_point'.tr,
                              style: textBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                            ),
                            child: Text(
                              'cancel'.tr,
                              style: textMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
