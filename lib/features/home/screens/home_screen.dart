import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/banner_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_view.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_map_view.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_screen_widgets/home_carpool_section.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_screen_widgets/home_header_widget.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/my_offer/controller/offer_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/home_screen_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/available_trips/controllers/available_trips_controller.dart';
import 'package:ride_sharing_user_app/features/walkthrough/controllers/walkthrough_controller.dart';
import 'package:ride_sharing_user_app/features/walkthrough/domain/models/walkthrough_model.dart';
import 'package:ride_sharing_user_app/features/walkthrough/helpers/walkthrough_helper.dart';
import '../widgets/home_screen_widgets/home_search_widget.dart';
import '../widgets/home_screen_widgets/home_trips_header_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _searchWidgetKey = GlobalKey();
  final GlobalKey _carpoolSectionKey = GlobalKey();

  String greetingMessage() {
    var timeNow = DateTime.now().hour;
    if (timeNow <= 12) {
      return 'good_morning'.tr;
    } else if ((timeNow > 12) && (timeNow <= 16)) {
      return 'good_afternoon'.tr;
    } else if ((timeNow > 16) && (timeNow < 20)) {
      return 'good_evening'.tr;
    } else {
      return 'good_night'.tr;
    }
  }

  bool clickedMenu = false;
  bool carpoolClickedMenu = false;
  bool parcelClickedMenu = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // Button position tracking for animation
  double _buttonTopPosition = 0.0;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<WalkthroughController>()) {
      final walkthroughCtrl = Get.find<WalkthroughController>();
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetHomeSearch, _searchWidgetKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetHomeCategories, _carpoolSectionKey);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!walkthroughCtrl.hasSeenFlow(WalkthroughFlowType.home)) {
          Future.delayed(const Duration(milliseconds: 700), () {
            if (mounted && !walkthroughCtrl.hasSeenFlow(WalkthroughFlowType.home)) {
              walkthroughCtrl.startFlow(
                WalkthroughFlowType.home,
                WalkthroughHelper.getHomeSteps(),
              );
            }
          });
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });

    // Set initial button position
    _buttonTopPosition = Get.height * 0.5;

    // Add listener to track sheet position changes after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize scroll tracking after build is complete to avoid setState during build
      Get.find<LocationController>().initializeScrollTracking();

      // Set up sheet listener for bottom nav visibility control
      Get.find<LocationController>().setupSheetListener(_sheetController);

      // Listen to sheet changes and update button position
      _sheetController.addListener(() {
        if (_sheetController.isAttached && mounted) {
          _updateButtonPosition();
        }
      });
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  // Simple button position update based on sheet size
  void _updateButtonPosition() {
    if (!mounted) return;

    // Use postFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Add small delay to ensure build is complete
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;

        double sheetSize = _sheetController.size;
        double screenHeight = Get.height;

        // Simple calculation: move button up as sheet expands
        // Sheet at 0.2 (collapsed) → button at 40% from top
        // Sheet at 0.9 (expanded) → button at 20% from top
        double newTop = screenHeight * (0.68 - sheetSize * 0.3);

        if (_buttonTopPosition != newTop) {
          setState(() {
            _buttonTopPosition = newTop;
          });
        }
      });
    });
  }

  Future<void> loadData({bool isReload = false}) async {
    if (isReload) {
      Get.find<ConfigController>().getConfigData();
    }

    Get.find<ParcelController>().getUnpaidParcelList();
    Get.find<BannerController>().getBannerList();
    Get.find<CategoryController>().getCategoryList();
    Get.find<AddressController>().getAddressList(1);
    Get.find<CouponController>().getCouponList(1, isUpdate: false);
    Get.find<OfferController>().getOfferList(1);
    if (Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfileInfo();
    }
    await Get.find<RideController>().getCurrentRideCarpool(type: "carpool");

    Get.find<AvailableTripsController>().getAvailableTrips();

    await Get.find<RideController>().getCurrentRide();

    if (Get.find<RideController>().currentTripDetails != null) {
      Get.find<RideController>().getBiddingList(
          Get.find<RideController>().currentTripDetails!.id!, 1);
      PusherHelper().pusherDriverStatus(
          Get.find<RideController>().currentTripDetails!.id!);
      if (Get.find<RideController>().currentTripDetails!.currentStatus ==
              'accepted' ||
          Get.find<RideController>().currentTripDetails!.currentStatus ==
              'ongoing') {
        Get.find<RideController>().startLocationRecord();
      }
    } else {
      Get.find<RideController>().clearBiddingList();
    }
    await Get.find<ParcelController>().getOngoingParcelList();
    if (Get.find<ParcelController>().parcelListModel!.data!.isNotEmpty) {
      for (var element in Get.find<ParcelController>().parcelListModel!.data!) {
        PusherHelper().pusherDriverStatus(element.id!);
      }
    }

    // Get current location first to ensure we have accurate coordinates
    await Get.find<LocationController>().getCurrentLocation(
      isAnimate: false,
      type: LocationType.from,
    );

    // Use current position for nearest drivers, fallback to saved address if current location fails
    double latitude = Get.find<LocationController>().position.latitude;
    double longitude = Get.find<LocationController>().position.longitude;

    // If current position is invalid, use saved address as fallback
    if (latitude == 0 && longitude == 0) {
      final savedAddress = Get.find<LocationController>().getUserAddress();
      latitude = savedAddress?.latitude ?? 0;
      longitude = savedAddress?.longitude ?? 0;
    }

    if (latitude != 0 && longitude != 0) {
      await Get.find<RideController>().getNearestDriverList(
        latitude.toString(),
        longitude.toString(),
      );
    }

    HomeScreenHelper().checkMaintanceMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await loadData(isReload: true);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
              ),
              child: Column(
                children: [
                  const HomeHeaderWidget(),
                  const SizedBox(height: 14),
                  KeyedSubtree(
                    key: _searchWidgetKey,
                    child: const HomeSearchWidget(),
                  ),
                  const SizedBox(height: 16),
                  const BannerView(),
                  const SizedBox(height: 16),
                  // const HomeActiveTripsSection(),
                  KeyedSubtree(
                    key: _carpoolSectionKey,
                    child: const HomeCarpoolSection(),
                  ),
                  // const HomeParcelCard(),
                  const SizedBox(height: 20),
                  const HomeTripsHeaderWidget(),
                  const SizedBox(height: 12),
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: const HomeMapView(title: 'rider_around_you'),
                    ),
                  ),
                  const SizedBox(height: 100),
                  // const HomeAvailableCarpoolSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// ARCHIVED FLOATING SIDE BADGES & OVERLAYS
// ==========================================
/*
// The 3 floating side tab badges (parcel, regular ride, carpool) and their 
// sliding popup menus (clickedMenu, carpoolClickedMenu, parcelClickedMenu) 
// have been removed and replaced with inline HomeActiveTripsSection cards 
// positioned under the carpool section on the home page.
*/
