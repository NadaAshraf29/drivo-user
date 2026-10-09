import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/pool_stop_pickup_controller.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import '../widgets/nearby_rides_widgets/nearby_ride_card_widget.dart';
import '../widgets/nearby_rides_widgets/nearby_rides_header_widget.dart';
import '../widgets/nearby_rides_widgets/nearby_rides_location_card_widget.dart';

class NearbyRidesScreen extends StatefulWidget {
  const NearbyRidesScreen({super.key});

  @override
  State<NearbyRidesScreen> createState() => _NearbyRidesScreenState();
}

class _NearbyRidesScreenState extends State<NearbyRidesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<PoolStopPickupController>().fetchNearMeTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<PoolStopPickupController>(
        builder: (poolController) {
          if (poolController.isLoadingNearMe && poolController.nearMeTrips.isEmpty) {
            return const Center(child: LoaderWidget());
          }

          final trips = poolController.nearMeTrips;

          return RefreshIndicator(
            onRefresh: () async {
              await poolController.fetchNearMeTrips();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Top Header Title & Subtitle
                Text(
                  'nearby_rides'.tr.isNotEmpty
                      ? 'nearby_rides'.tr
                      : 'Nearby Rides',
                  style: textBold.copyWith(
                    fontSize: 28,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'available_rides_close_to_location'.tr.isNotEmpty
                      ? 'available_rides_close_to_location'.tr
                      : 'Available rides close to your current location.',
                  style: textRegular.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),

                // Location Card
                const NearbyRidesLocationCardWidget(),
                const SizedBox(height: 28),

                // Available Rides Section Header
                NearbyRidesHeaderWidget(totalNearby: trips.length),
                const SizedBox(height: 16),

                // Rides List or Empty State
                if (trips.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'no_nearby_rides_found'.tr.isNotEmpty
                            ? 'no_nearby_rides_found'.tr
                            : 'No nearby rides found near your location.',
                        style: textMedium.copyWith(
                          fontSize: 15,
                          color: const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...trips.map((ride) => NearbyRideCardWidget(ride: ride)),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
