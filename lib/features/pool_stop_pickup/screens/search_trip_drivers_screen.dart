import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/pool_stop_pickup_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/matching_trip_card.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import 'package:ride_sharing_user_app/features/walkthrough/controllers/walkthrough_controller.dart';
import 'package:ride_sharing_user_app/features/walkthrough/domain/models/walkthrough_model.dart';
import 'package:ride_sharing_user_app/features/walkthrough/helpers/walkthrough_helper.dart';
import 'package:ride_sharing_user_app/features/walkthrough/widgets/how_it_works_button.dart';

class SearchTripDriversScreen extends StatefulWidget {
  const SearchTripDriversScreen({super.key});

  @override
  State<SearchTripDriversScreen> createState() =>
      _SearchTripDriversScreenState();
}

class _SearchTripDriversScreenState extends State<SearchTripDriversScreen> {
  final GlobalKey _firstCardKey = GlobalKey();
  final GlobalKey _continueBtnKey = GlobalKey();
  int? _selectedTripIndex;

  void _startWalkthrough({bool isManual = false}) {
    if (!Get.isRegistered<WalkthroughController>()) return;
    final walkthroughCtrl = Get.find<WalkthroughController>();
    walkthroughCtrl.startFlow(
      WalkthroughFlowType.searchResults,
      WalkthroughHelper.getSearchResultsSteps(),
      isManual: isManual,
    );
  }

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<WalkthroughController>()) {
      final walkthroughCtrl = Get.find<WalkthroughController>();
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetResultsFirstCard, _firstCardKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetResultsContinue, _continueBtnKey);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!walkthroughCtrl.hasSeenFlow(WalkthroughFlowType.searchResults)) {
          final poolCtrl = Get.find<PoolStopPickupController>();
          if (poolCtrl.availableTrips.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 650), () {
              if (mounted &&
                  !walkthroughCtrl
                      .hasSeenFlow(WalkthroughFlowType.searchResults)) {
                _startWalkthrough(isManual: false);
              }
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1E293B), size: 19),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: HowItWorksButton(
              onTap: () => _startWalkthrough(isManual: true),
            ),
          ),
        ],
      ),
      body: GetBuilder<PoolStopPickupController>(
        builder: (poolController) {
          if (poolController.isSearchingTrips) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF08A9F0)),
            );
          }

          final trips = poolController.availableTrips;
          final type = poolController.selectedCarpoolType;
          final startCity = _shortLocation(_startLocation(poolController));
          final endCity = _shortLocation(_endLocation(poolController));

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    _buildHeader(type),
                    const SizedBox(height: 22),
                    _buildSearchSummary(
                      type: type,
                      startCity: startCity,
                      endCity: endCity,
                    ),
                    const SizedBox(height: 24),
                    if (trips.isEmpty)
                      _buildEmptyState(type)
                    else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Matching trips'.tr,
                            style: textBold.copyWith(
                              fontSize: 20,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          _buildCountBadge(trips.length),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...trips.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final card = MatchingTripCard(
                          ride: entry.value,
                          index: idx,
                          isSelected: _selectedTripIndex == idx,
                          onSelect: () => setState(() {
                            _selectedTripIndex = idx;
                          }),
                          onViewDetails: () {
                            setState(() {
                              _selectedTripIndex = idx;
                            });
                            Get.to(() => TripDetailsScreen(
                                  trip: entry.value,
                                  rideController: Get.find<RideController>(),
                                  fromSearch: true,
                                ));
                          },
                        );
                        if (idx == 0) {
                          return KeyedSubtree(
                            key: _firstCardKey,
                            child: card,
                          );
                        }
                        return card;
                      }),
                    ],
                  ],
                ),
              ),
              if (trips.isNotEmpty) _buildContinueButton(trips),
            ],
          );
        },
      ),
    );
  }

  String _tripTypeLabel(String type) {
    switch (type) {
      case 'routine':
        return 'routine'.tr;
      case 'north_coast':
        return 'north_coast'.tr;
      case 'travel':
        return 'travel'.tr;
      default:
        return 'one_trip'.tr;
    }
  }

  Widget _buildHeader(String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_tripTypeLabel(type)} ${'trips'.tr}',
          style: textBold.copyWith(
            fontSize: 28,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'trips_matching_route_preferences'.tr,
          style: textRegular.copyWith(
            fontSize: 13,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSummary({
    required String type,
    required String startCity,
    required String endCity,
  }) {
    final route =
        type == 'routine' ? '$startCity · $endCity' : '$startCity · $endCity';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F8FB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_outlined,
                color: Color(0xFF079CD7), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'searched_for'.tr,
                  style: textBold.copyWith(
                    fontSize: 9,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  route,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textBold.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _tripTypeLabel(type),
                  style: textRegular.copyWith(
                    fontSize: 10,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Edit'.tr,
              style: textSemiBold.copyWith(
                fontSize: 12,
                color: const Color(0xFF08A9F0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  color: Color(0xFFE4F6FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_car_filled_rounded,
                    size: 38, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 18),
              Text(
                _emptyTitle(type),
                textAlign: TextAlign.center,
                style: textBold.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'no_matching_carpool_trips_desc'.tr,
                textAlign: TextAlign.center,
                style: textRegular.copyWith(
                  fontSize: 11,
                  height: 1.45,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 22),
              _buildChangeSearchButton(),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF8FC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  size: 16, color: Color(0xFF079CD7)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'try_another_pickup_point'.tr,
                      style: textBold.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'try_another_pickup_point_desc'.tr,
                      style: textRegular.copyWith(
                        fontSize: 9,
                        height: 1.35,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChangeSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF08A9F0),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'change_search'.tr,
          style: textBold.copyWith(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$count ${'matches'.tr}',
        style: textMedium.copyWith(
          fontSize: 12,
          color: const Color(0xFF08A9F0),
        ),
      ),
    );
  }

  Widget _buildContinueButton(List<PoolRide> trips) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: KeyedSubtree(
            key: _continueBtnKey,
            child: ElevatedButton(
              onPressed: () {
                final selectedTrip = trips[_selectedTripIndex ?? 0];
                Get.to(() => TripDetailsScreen(
                      trip: selectedTrip,
                      rideController: Get.find<RideController>(),
                      fromSearch: true,
                    ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF08A9F0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Continue'.tr,
                style: textBold.copyWith(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _emptyTitle(String type) {
    switch (type) {
      case 'routine':
        return 'no_matching_routine_trips'.tr;
      case 'north_coast':
        return 'no_matching_north_coast_trips'.tr;
      case 'travel':
        return 'no_matching_travel_trips'.tr;
      default:
        return 'no_matching_one_trip_trips'.tr;
    }
  }

  String _startLocation(PoolStopPickupController controller) {
    return controller.selectedStartCity ??
        controller.selectedBoardingPointStart?.name ??
        controller.pickupAddress?.address ??
        'Cairo';
  }

  String _endLocation(PoolStopPickupController controller) {
    return controller.selectedEndCity ??
        controller.selectedBoardingPointEnd?.name ??
        controller.destinationAddress?.address ??
        'Alexandria';
  }

  String _shortLocation(String value) {
    return value.contains(',') ? value.split(',').first.trim() : value.trim();
  }
}
