import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/notification/screens/notification_screen.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/screens/trip_fare_calculation_screen.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/one_trip_widgets/one_trip_fare_info_card.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/one_trip_widgets/one_trip_location_card.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/one_trip_widgets/one_trip_schedule_card.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CreateYourOwnTripScreen extends StatefulWidget {
  const CreateYourOwnTripScreen({super.key});

  @override
  State<CreateYourOwnTripScreen> createState() => _CreateYourOwnTripScreenState();
}

class _CreateYourOwnTripScreenState extends State<CreateYourOwnTripScreen> {
  final FocusNode _pickLocationFocus = FocusNode();
  final FocusNode _destinationLocationFocus = FocusNode();

  late DateTime _selectedDate;
  TimeOfDay _selectedDepartureTime = const TimeOfDay(hour: 7, minute: 30);
  int _selectedSeats = 1;

  DateFormat _getSafeDateFormat(String pattern) {
    try {
      final locale = Get.locale?.languageCode ?? 'en';
      return DateFormat(pattern, locale);
    } catch (_) {
      return DateFormat(pattern);
    }
  }

  DateFormat get _displayDateFormat => _getSafeDateFormat('EEE, MMM d');
  DateFormat get _fullDisplayDateFormat => _getSafeDateFormat('EEE, MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String _profileImageUrl(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) return '';
    if (profileImage.startsWith('http://') ||
        profileImage.startsWith('https://')) {
      return profileImage;
    }
    return '${Get.find<ConfigController>().config!.imageBaseUrl!.profileImage}/$profileImage';
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Notification icon in soft circular container
          InkWell(
            onTap: () => Get.to(() => const NotificationScreen()),
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
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: Color(0xFF4A5568),
                ),
              ),
            ),
          ),

          // Center: Location Pill (● Current Location ⌵)
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GetBuilder<LocationController>(
                builder: (locationController) {
                  final address = locationController.getUserAddress();
                  final locationText = address?.address ??
                      (locationController.address.isNotEmpty
                          ? locationController.address
                          : 'select_your_location'.tr);
                  return InkWell(
                    onTap: () => Get.to(() => const PickMapScreen(
                          type: LocationType.accessLocation,
                        )),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00A0E9),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              locationText,
                              style: textMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: const Color(0xFF4A5568),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFF4A5568),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Right: User Profile Avatar
          InkWell(
            onTap: () => Get.to(() => const ProfileScreen()),
            borderRadius: BorderRadius.circular(20),
            child: GetBuilder<ProfileController>(
              builder: (profileController) {
                final profileImg =
                    profileController.profileModel?.data?.profileImage;
                final fName =
                    profileController.profileModel?.data?.firstName ?? '';
                final initial =
                    fName.isNotEmpty ? fName[0].toUpperCase() : 'Z';

                return SizedBox(
                  width: 38,
                  height: 38,
                  child: ClipOval(
                    child: profileImg != null && profileImg.isNotEmpty
                        ? ImageWidget(
                            image: _profileImageUrl(profileImg),
                            placeholder: Images.personPlaceholder,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: const Color(0xFFE0F2FE),
                            alignment: Alignment.center,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Color(0xFF00A0E9),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickDepartureTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDepartureTime,
    );
    if (picked != null) {
      setState(() => _selectedDepartureTime = picked);
    }
  }

  void _openMapPicker(
      LocationType type, LocationController locationController) {
    if (Get.find<RideController>().rideDetails != null) {
      showCustomSnackBar('your_ride_is_ongoing_complete'.tr, isError: true);
      return;
    }
    RouteHelper.goPageAndHideTextField(
      context,
      PickMapScreen(
        type: type,
        oldLocationExist: locationController.pickPosition.latitude > 0,
      ),
    );
  }

  Future<void> _calculateFare() async {
    final locationController = Get.find<LocationController>();
    final rideController = Get.find<RideController>();

    if (locationController.fromAddress == null ||
        locationController.fromAddress!.address == null ||
        locationController.fromAddress!.address!.isEmpty ||
        locationController.pickupLocationController.text.isEmpty) {
      showCustomSnackBar('pickup_location_is_required'.tr);
      _pickLocationFocus.requestFocus();
      return;
    }

    if (locationController.toAddress == null ||
        locationController.toAddress!.address == null ||
        locationController.toAddress!.address!.isEmpty ||
        locationController.destinationLocationController.text.isEmpty) {
      showCustomSnackBar('destination_location_is_required'.tr);
      _destinationLocationFocus.requestFocus();
      return;
    }

    await rideController.getEstimatedFare(false);
    if (!mounted) return;

    final double fare = (rideController.estimatedFare > 0)
        ? rideController.estimatedFare
        : 85.0;

    Get.to(() => TripFareCalculationScreen(
          pickupAddress: locationController.pickupLocationController.text,
          destinationAddress:
              locationController.destinationLocationController.text,
          dateText: _fullDisplayDateFormat.format(_selectedDate),
          timeText: _selectedDepartureTime.format(context),
          seatsCount: _selectedSeats,
          estimatedFare: fare,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GetBuilder<LocationController>(
          builder: (locationController) {
            return GetBuilder<RideController>(
              builder: (rideController) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar with Notification, Location, and Profile
                      _buildTopBar(),
                      const SizedBox(height: 10),

                      // Header Title & Subtitle
                      Text(
                        'create_your_own_trip'.tr,
                        style: textBold.copyWith(
                          fontSize: 24,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'set_up_your_work_route'.tr,
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location Input Card
                      OneTripLocationCard(
                        rideController: rideController,
                        locationController: locationController,
                        pickFocus: _pickLocationFocus,
                        destinationFocus: _destinationLocationFocus,
                        onOpenMap: _openMapPicker,
                      ),
                      const SizedBox(height: 14),

                      // Schedule Card
                      OneTripScheduleCard(
                        dateText: _displayDateFormat.format(_selectedDate),
                        departureTimeText:
                            _selectedDepartureTime.format(context),
                        selectedSeats: _selectedSeats,
                        onPickDate: _pickDate,
                        onPickDepartureTime: _pickDepartureTime,
                        onSeatsChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedSeats = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // Fare Info Banner
                      const OneTripFareInfoCard(),
                      const SizedBox(height: 24),

                      // Calculate Fare Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              rideController.loading ? null : _calculateFare,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A0E9),
                            disabledBackgroundColor: Colors.black54,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: rideController.loading
                              ? const SpinKitThreeBounce(
                                  color: Colors.white,
                                  size: 22,
                                )
                              : Text(
                                  'calculate_fare'.tr,
                                  style: textBold.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
// ponytail: extracted widget class — follow single class per file rule
