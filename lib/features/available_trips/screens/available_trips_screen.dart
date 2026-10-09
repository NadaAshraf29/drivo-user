import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/available_trips/controllers/available_trips_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/pool_stop_pickup_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/ride_card_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class AvailableTripsScreen extends StatefulWidget {
  const AvailableTripsScreen({super.key});

  @override
  State<AvailableTripsScreen> createState() => _AvailableTripsScreenState();
}

class _AvailableTripsScreenState extends State<AvailableTripsScreen> {
  int _selectedTabIndex = 0; // Tracks the selected carpool filter index

  @override
  void initState() {
    super.initState();
    // Fetch available trips on screen load after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AvailableTripsController>().getAvailableTrips(reload: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final poolController = Get.find<PoolStopPickupController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        title: Text(
          'Available Trips'.tr,
          style: textBold.copyWith(
            color: Colors.white,
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<AvailableTripsController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          bool isArabic = Get.locale?.languageCode == 'ar';
          List<String> carpoolTypes = [];

          for (var ride in controller.availableTrips) {
            String label = isArabic
                ? ride.carpoolTypeLabelAr ?? 'رحلة واحدة'
                : ride.carpoolTypeLabel ?? 'One Trip';
            if (label.isNotEmpty && !carpoolTypes.contains(label)) {
              carpoolTypes.add(label);
            }
          }

          List<String> tabs = ['all'.tr, ...carpoolTypes];

          if (_selectedTabIndex >= tabs.length) {
            _selectedTabIndex = 0;
          }

          List<dynamic> filteredTrips = _selectedTabIndex == 0
              ? controller.availableTrips
              : controller.availableTrips.where((ride) {
                  String label = isArabic
                      ? ride.carpoolTypeLabelAr ?? 'رحلة واحدة'
                      : ride.carpoolTypeLabel ?? 'One Trip';
                  return label == tabs[_selectedTabIndex];
                }).toList();

          return Column(
            children: [
              if (controller.availableTrips.isNotEmpty)
                Container(
                  height: 60,
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    itemCount: tabs.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedTabIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              right: Dimensions.paddingSizeSmall),
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeLarge),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[100],
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusLarge),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            tabs[index],
                            style: textMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Filtered List View Container Area
              Expanded(
                child: filteredTrips.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () =>
                            controller.getAvailableTrips(reload: true),
                        child: ListView(
                          children: [
                            SizedBox(height: Get.height * 0.15),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    Images.noDataFound,
                                    height: 120,
                                    width: 120,
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeDefault),
                                  Text(
                                    'No Trips Available'.tr,
                                    style: textBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeSmall),
                                  Text(
                                    'There are no rides matching this filter at the moment.'
                                        .tr,
                                    style: textRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            controller.getAvailableTrips(reload: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          itemCount: filteredTrips.length,
                          itemBuilder: (context, index) {
                            final ride = filteredTrips[index];
                            return RideCardWidget(
                              fromSearch: false,
                              ride: ride,
                              index: index,
                              controller: poolController,
                              fromAvailable: true,
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
