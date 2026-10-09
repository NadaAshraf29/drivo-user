import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/university/controllers/university_controller.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_empty_matching_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_empty_tip_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_matching_trip_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_search_summary_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_top_bar.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'university_trip_details_screen.dart';

class UniversityMatchingTripsScreen extends StatelessWidget {
  final String university;
  final String pickupPoint;
  final bool hasReturnRide;

  const UniversityMatchingTripsScreen({
    super.key,
    required this.university,
    required this.pickupPoint,
    required this.hasReturnRide,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GetBuilder<UniversityController>(
          builder: (uniController) {
            final matchingTrips = uniController.matchingTrips;
            final hasMatches = matchingTrips.isNotEmpty;

            return Column(
              children: [
                const UniversityTopBar(showBackButton: true), // Title & Subtitle
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
                        hasMatches ? 'university_trips'.tr : 'university_trips'.tr,
                        style: textBold.copyWith(
                          fontSize: 24,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasMatches
                            ? 'trips_matching_university_and_pickup'.tr
                            : 'search_results_for_your_university_ride'.tr,
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
                        UniversitySearchSummaryCard(
                          university: university,
                          pickupPoint: pickupPoint,
                          hasReturnRide: hasReturnRide,
                          onEdit: () => Get.back(),
                        ),
                        const SizedBox(height: 20),

                        // State A: Matches Found
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
                                  uniController.selectedTrip?.id == trip.id;
                              return UniversityMatchingTripCard(
                                trip: trip,
                                isSelected: isSelected,
                                onSelect: () =>
                                    uniController.setSelectedTrip(trip),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ]
                        // State B: No Matches Found
                        else ...[
                          UniversityEmptyMatchingCard(
                            university: university,
                            pickupPoint: pickupPoint,
                            hasReturnRide: hasReturnRide,
                            onChangeSearch: () => Get.back(),
                          ),
                          const SizedBox(height: 20),
                          const UniversityEmptyTipCard(),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Bar with Continue Button
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
                          color: Colors.black.withValues(alpha: 0.04),
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
                          onPressed: uniController.selectedTrip != null
                              ? () {
                                  Get.to(
                                    () => UniversityTripDetailsScreen(
                                      trip: uniController.selectedTrip!,
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A0E9),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFF94A3B8).withValues(alpha: 0.4),
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

