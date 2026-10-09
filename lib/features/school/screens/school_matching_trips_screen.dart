import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/school/controllers/school_controller.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_search_request.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_trip_model.dart';
import 'package:ride_sharing_user_app/features/school/screens/school_trip_details_screen.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_empty_matching_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_empty_tip_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_matching_trip_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_search_summary_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_top_bar.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolMatchingTripsScreen extends StatelessWidget {
  final String schoolName;
  final String pickupPoint;
  final bool hasReturnRide;
  final SchoolSearchRequest searchRequest;

  const SchoolMatchingTripsScreen({
    super.key,
    required this.schoolName,
    required this.pickupPoint,
    required this.hasReturnRide,
    required this.searchRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GetBuilder<SchoolController>(
          builder: (schoolCtrl) {
            final matchingTrips = schoolCtrl.matchingTrips;
            final hasMatches = matchingTrips.isNotEmpty;

            return Column(
              children: [
                const SchoolTopBar(showBackButton: true), // Title & Subtitle
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: EdgeInsetsDirectional.only(
                    bottom: 8,
                    start: Dimensions.paddingSizeDefault,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasMatches ? 'school_trips'.tr : 'school_trips'.tr,
                        style: textBold.copyWith(
                          fontSize: 24,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasMatches
                            ? 'trips_matching_school_pickup'.tr
                            : 'search_results_for_your_school_ride'.tr,
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Search Summary Card
                        SchoolSearchSummaryCard(
                          schoolName: schoolName,
                          pickupPoint: pickupPoint,
                          hasReturnRide: hasReturnRide,
                          onEdit: () => Get.back(),
                        ),
                        const SizedBox(height: 20),

                        // State A: Matches Found (Image 1 screens 2 & 3)
                        if (hasMatches) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'matching_trips'.tr,
                                style: textBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '${matchingTrips.length} ${'matches'.tr}',
                                style: textMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: matchingTrips.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final trip = matchingTrips[index];
                              final isSelected =
                                  schoolCtrl.selectedTrip?.id == trip.id;
                              return SchoolMatchingTripCard(
                                trip: trip,
                                isSelected: isSelected,
                                onSelect: () =>
                                    schoolCtrl.setSelectedTrip(trip),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ]
                        // State B: No Matches Found (Image 2)
                        else ...[
                          SchoolEmptyMatchingCard(
                            onChangeSearch: () => Get.back(),
                          ),
                          const SizedBox(height: 20),
                          const SchoolEmptyTipCard(),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Bar with Continue Button (Image 1 screen 2 & 3)
                if (hasMatches)
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
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: schoolCtrl.selectedTrip != null
                              ? () {
                                  Get.to(
                                    () => SchoolTripDetailsScreen(
                                      trip: schoolCtrl.selectedTrip!,
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A0E9),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFF94A3B8).withOpacity(0.4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'continue'.tr,
                            style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
