import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/notification/screens/notification_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/pool_stop_pickup_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/screens/create_your_own_trip_screen.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/screens/search_trip_drivers_screen.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/boarding_points_card.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/routine_route_card.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/location_card.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/seats_dropdown.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/trip_field_tile.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/gender_selector.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/matching_trip_card.dart';
import 'package:ride_sharing_user_app/features/ride/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/available_trips/controllers/available_trips_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/walkthrough/controllers/walkthrough_controller.dart';
import 'package:ride_sharing_user_app/features/walkthrough/domain/models/walkthrough_model.dart';
import 'package:ride_sharing_user_app/features/walkthrough/helpers/walkthrough_helper.dart';
import 'package:ride_sharing_user_app/features/walkthrough/widgets/how_it_works_button.dart';

class SetDestinationCarPoolScreen extends StatefulWidget {
  final Address? address;
  final String? searchText;
  final bool fromDashboard;
  final VoidCallback? onBackToWelcome;
  final String? carpoolType;

  const SetDestinationCarPoolScreen({
    super.key,
    this.address,
    this.searchText,
    this.fromDashboard = false,
    this.onBackToWelcome,
    this.carpoolType,
  });

  @override
  State<SetDestinationCarPoolScreen> createState() =>
      _SetDestinationCarPoolScreenState();
}

class _SetDestinationCarPoolScreenState
    extends State<SetDestinationCarPoolScreen> {
  static const Color _pickerBlue = Color.fromARGB(255, 184, 212, 240);
  final FocusNode _pickLocationFocus = FocusNode();
  final FocusNode _destinationLocationFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _pickupKey = GlobalKey();
  final GlobalKey _destinationKey = GlobalKey();
  final GlobalKey _dateKey = GlobalKey();
  final GlobalKey _timeKey = GlobalKey();
  final GlobalKey _seatsKey = GlobalKey();
  final GlobalKey _genderKey = GlobalKey();
  final GlobalKey _submitKey = GlobalKey();

  late DateTime _selectedDate;
  TimeOfDay _selectedDepartureTime = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _selectedReturnTime = const TimeOfDay(hour: 17, minute: 0);
  int _selectedSeats = 1;
  String _selectedGender = 'both';
  String? _selectedRoutineStartAddress;
  String? _selectedRoutineEndAddress;

  String _getRideStartAddress(PoolRide ride) {
    if (ride.pickupAddress.trim().isNotEmpty) return ride.pickupAddress.trim();
    if (ride.boardingPointStart != null &&
        ride.boardingPointStart!.name.trim().isNotEmpty) {
      return ride.boardingPointStart!.name.trim();
    }
    if (ride.closestPickup != null &&
        ride.closestPickup!.placeName.trim().isNotEmpty) {
      return ride.closestPickup!.placeName.trim();
    }
    return '';
  }

  String _getRideEndAddress(PoolRide ride) {
    if (ride.dropoffAddress.trim().isNotEmpty) return ride.dropoffAddress.trim();
    if (ride.boardingPointEnd != null &&
        ride.boardingPointEnd!.name.trim().isNotEmpty) {
      return ride.boardingPointEnd!.name.trim();
    }
    if (ride.closestDropoff != null &&
        ride.closestDropoff!.placeName.trim().isNotEmpty) {
      return ride.closestDropoff!.placeName.trim();
    }
    return '';
  }

  bool _isRoutineRide(PoolRide ride) {
    final cType = (ride.carpoolType ?? '').toLowerCase();
    final label = (ride.carpoolTypeLabel ?? '').toLowerCase();
    final labelAr = ride.carpoolTypeLabelAr ?? '';

    // Strictly exclude school and university / uni
    if (cType == 'school' ||
        cType == 'university' ||
        cType == 'uni' ||
        cType == 'travel' ||
        cType == 'north_coast' ||
        cType == 'sahel' ||
        label.contains('school') ||
        label.contains('university') ||
        label.contains('uni') ||
        labelAr.contains('مدرسة') ||
        labelAr.contains('جامعة')) {
      return false;
    }

    return cType == 'routine' ||
        cType == 'work' ||
        cType == 'daily' ||
        cType == 'commute' ||
        cType.contains('routine') ||
        cType.contains('work') ||
        label.contains('routine') ||
        label.contains('work') ||
        labelAr.contains('روتين') ||
        labelAr.contains('عمل') ||
        labelAr.contains('يومي') ||
        ride.isRecurring == true;
  }

  WalkthroughFlowType _getFlowType() {
    final type = widget.carpoolType ?? 'trip';
    if (type == 'routine') return WalkthroughFlowType.workRideSearch;
    if (type == 'travel') return WalkthroughFlowType.travelSearch;
    if (type == 'north_coast') return WalkthroughFlowType.northCoastSearch;
    return WalkthroughFlowType.regularRideSearch;
  }

  void _startWalkthrough({bool isManual = false}) {
    if (!Get.isRegistered<WalkthroughController>()) return;
    final flowType = _getFlowType();
    final type = widget.carpoolType ?? 'trip';
    final walkthroughCtrl = Get.find<WalkthroughController>();
    walkthroughCtrl.startFlow(
      flowType,
      WalkthroughHelper.getSearchSteps(carpoolType: type),
      isManual: isManual,
    );
  }

  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  String _profileImageUrl(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) return '';
    if (profileImage.startsWith('http://') ||
        profileImage.startsWith('https://')) {
      return profileImage;
    }
    return '${Get.find<ConfigController>().config?.imageBaseUrl?.profileImage ?? ''}/$profileImage';
  }

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final dayStr = isToday ? 'Today' : DateFormat('EEE').format(date);
    final monthDayStr = DateFormat('MMM d').format(date);
    return '$dayStr · $monthDayStr';
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;

    // Set the selected carpool type
    final type = widget.carpoolType ?? 'trip';
    final poolController = Get.find<PoolStopPickupController>();
    poolController.setSelectedCarpoolType(type, notify: false);

    if (Get.isRegistered<WalkthroughController>()) {
      final walkthroughCtrl = Get.find<WalkthroughController>();
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetSearchPickup, _pickupKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetSearchDestination, _destinationKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetSearchDate, _dateKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetSearchTime, _timeKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetSearchSeats, _seatsKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetSearchGender, _genderKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetSearchSubmit, _submitKey);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final flowType = _getFlowType();
        if (!walkthroughCtrl.hasSeenFlow(flowType)) {
          Future.delayed(const Duration(milliseconds: 650), () {
            if (mounted && !walkthroughCtrl.hasSeenFlow(flowType)) {
              _startWalkthrough(isManual: false);
            }
          });
        }
      });
    }

    Get.find<LocationController>().initAddLocationData();
    Get.find<LocationController>().initTextControllers();
    Get.find<RideController>().clearExtraRoute();
    Get.find<MapController>().initializeData();
    Get.find<RideController>().initData();
    Get.find<ParcelController>().updatePaymentPerson(false, notify: false);

    if (Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfileInfo();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LocationController>()
          .getCurrentLocation(isAnimate: false, type: LocationType.from)
          .then((currentAddress) {
        if (currentAddress != null) {
          Get.find<LocationController>().setPickUp(currentAddress);
        } else {
          Get.find<LocationController>()
              .setPickUp(Get.find<LocationController>().getUserAddress());
        }
      });

      // If travel or north_coast type is selected, fetch boarding points
      if (type == 'travel' || type == 'north_coast') {
        poolController.getBoardingPoints();
      }

      // Fetch available trips for the bottom section
      Get.find<AvailableTripsController>().getAvailableTrips(reload: true);
    });

    if (widget.address != null) {
      Get.find<LocationController>().setDestination(widget.address);
    }
    if (widget.searchText != null) {
      Get.find<LocationController>()
          .setDestination(Address(address: widget.searchText));
      Future.delayed(const Duration(seconds: 1)).then((_) {
        if (!mounted) return;
        Get.find<LocationController>().searchLocation(
          context,
          widget.searchText ?? '',
          type: LocationType.to,
        );
      });
    }

    // Set initial date & times in the controller
    poolController.setSearchParameters(
      date: _apiDateFormat.format(_selectedDate),
    );
    if (type == 'routine') {
      poolController.setTimes(
        departure:
            '${_selectedDepartureTime.hour.toString().padLeft(2, '0')}:${_selectedDepartureTime.minute.toString().padLeft(2, '0')}',
        returnTime:
            '${_selectedReturnTime.hour.toString().padLeft(2, '0')}:${_selectedReturnTime.minute.toString().padLeft(2, '0')}',
      );
    } else if (type == 'trip') {
      poolController.setTimes(
        departure:
            '${_selectedDepartureTime.hour.toString().padLeft(2, '0')}:${_selectedDepartureTime.minute.toString().padLeft(2, '0')}',
        returnTime: '',
      );
    } else {
      poolController.setTimes(departure: '', returnTime: '');
    }
  }

  @override
  void dispose() {
    _pickLocationFocus.dispose();
    _destinationLocationFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  ThemeData _pickerTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color.fromARGB(255, 84, 161, 239),
            onPrimary: Colors.white,
          ),
      datePickerTheme: DatePickerThemeData(
        headerBackgroundColor: _pickerBlue,
        headerForegroundColor: Colors.white,
        todayForegroundColor: WidgetStateProperty.all(_pickerBlue),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.black;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _pickerBlue;
          }
          return null;
        }),
      ),
      timePickerTheme: TimePickerThemeData(
        dialHandColor: const Color.fromARGB(255, 0, 0, 0),
        dialBackgroundColor: _pickerBlue.withValues(alpha: 0.12),
        hourMinuteColor: _pickerBlue.withValues(alpha: 0.15),
        hourMinuteTextColor: const Color.fromARGB(255, 0, 0, 0),
        dayPeriodColor:
            const Color.fromARGB(255, 173, 202, 232).withValues(alpha: 0.15),
        dayPeriodTextColor: const Color.fromARGB(255, 0, 0, 0),
        entryModeIconColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: _pickerTheme(context),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      Get.find<PoolStopPickupController>().setSearchParameters(
        date: _apiDateFormat.format(picked),
      );
      if (Get.isRegistered<WalkthroughController>()) {
        Get.find<WalkthroughController>()
            .autoAdvanceIfCurrentStep('search_step_date');
      }
    }
  }

  Future<void> _pickDepartureTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDepartureTime,
      builder: (context, child) {
        return Theme(
          data: _pickerTheme(context),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDepartureTime = picked);
      Get.find<PoolStopPickupController>().setTimes(
        departure:
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
      );
      if (Get.isRegistered<WalkthroughController>()) {
        Get.find<WalkthroughController>()
            .autoAdvanceIfCurrentStep('search_step_time');
      }
    }
  }

  Future<void> _pickReturnTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedReturnTime,
      builder: (context, child) {
        return Theme(
          data: _pickerTheme(context),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedReturnTime = picked);
      Get.find<PoolStopPickupController>().setTimes(
        returnTime:
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
      );
      if (Get.isRegistered<WalkthroughController>()) {
        Get.find<WalkthroughController>()
            .autoAdvanceIfCurrentStep('search_step_time');
      }
    }
  }

  bool _isMaintenanceMode() {
    final maintenance = Get.find<ConfigController>().config?.maintenanceMode;
    return maintenance != null &&
        maintenance.maintenanceStatus == 1 &&
        maintenance.selectedMaintenanceSystem?.userApp == 1;
  }

  Future<void> _searchForRides() async {
    final locationController = Get.find<LocationController>();
    final type = widget.carpoolType ?? 'trip';

    if (_isMaintenanceMode()) {
      showCustomSnackBar('maintenance_mode_on_for_ride'.tr, isError: true);
      return;
    }

    final poolController = Get.find<PoolStopPickupController>();
    final availableTripsCtrl = Get.find<AvailableTripsController>();

    if (type == 'routine') {
      if (_selectedRoutineStartAddress == null ||
          _selectedRoutineStartAddress!.trim().isEmpty) {
        showCustomSnackBar('Please select routine pickup start location'.tr);
        return;
      }
      if (_selectedRoutineEndAddress == null ||
          _selectedRoutineEndAddress!.trim().isEmpty) {
        showCustomSnackBar('Please select routine destination location'.tr);
        return;
      }

      poolController.setPickupAddress(
        Address(address: _selectedRoutineStartAddress),
      );
      poolController.setDestinationAddress(
        Address(address: _selectedRoutineEndAddress),
      );
      poolController.setSearchParameters(
        gender: _selectedGender,
        seats: _selectedSeats,
        date: _apiDateFormat.format(_selectedDate),
      );
      poolController.setTimes(
        departure:
            '${_selectedDepartureTime.hour.toString().padLeft(2, '0')}:${_selectedDepartureTime.minute.toString().padLeft(2, '0')}',
        returnTime:
            '${_selectedReturnTime.hour.toString().padLeft(2, '0')}:${_selectedReturnTime.minute.toString().padLeft(2, '0')}',
      );

      List<PoolRide> routineSourceRides = availableTripsCtrl.availableTrips
          .where((ride) => _isRoutineRide(ride))
          .toList();

      if (routineSourceRides.isEmpty &&
          availableTripsCtrl.availableTrips.isNotEmpty) {
        routineSourceRides = availableTripsCtrl.availableTrips.where((ride) {
          final cType = (ride.carpoolType ?? '').toLowerCase();
          final label = (ride.carpoolTypeLabel ?? '').toLowerCase();
          return cType != 'travel' &&
              cType != 'north_coast' &&
              cType != 'school' &&
              cType != 'university' &&
              cType != 'uni' &&
              !label.contains('school') &&
              !label.contains('university') &&
              !label.contains('uni');
        }).toList();
      }

      final matchingRoutineTrips = routineSourceRides.where((ride) {
        if (_selectedRoutineStartAddress != null &&
            _selectedRoutineStartAddress!.isNotEmpty) {
          final start = _getRideStartAddress(ride).toLowerCase();
          final sel = _selectedRoutineStartAddress!.toLowerCase();
          if (start != sel && !start.contains(sel) && !sel.contains(start)) {
            return false;
          }
        }

        if (_selectedRoutineEndAddress != null &&
            _selectedRoutineEndAddress!.isNotEmpty) {
          final end = _getRideEndAddress(ride).toLowerCase();
          final sel = _selectedRoutineEndAddress!.toLowerCase();
          if (end != sel && !end.contains(sel) && !sel.contains(end)) {
            return false;
          }
        }

        if (_selectedGender.isNotEmpty && _selectedGender != 'both') {
          if (ride.allowedGender.isNotEmpty &&
              ride.allowedGender.toLowerCase() != 'both' &&
              ride.allowedGender.toLowerCase() !=
                  _selectedGender.toLowerCase()) {
            return false;
          }
        }

        return true;
      }).toList();

      poolController.availableTrips.clear();
      poolController.availableTrips.addAll(matchingRoutineTrips);
      poolController.update();

      Get.to(() => const SearchTripDriversScreen());
      return;
    }

    if (type != 'travel' && type != 'north_coast') {
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
    }

    if (type != 'travel' && type != 'north_coast') {
      poolController.setPickupAddress(locationController.fromAddress!);
      poolController.setDestinationAddress(locationController.toAddress!);
    }
    poolController.setSearchParameters(
      gender: _selectedGender,
      seats: _selectedSeats,
      date: _apiDateFormat.format(_selectedDate),
    );
    if (type == 'trip') {
      poolController.setTimes(
        departure:
            '${_selectedDepartureTime.hour.toString().padLeft(2, '0')}:${_selectedDepartureTime.minute.toString().padLeft(2, '0')}',
        returnTime: '',
      );
    } else {
      poolController.setTimes(departure: '', returnTime: '');
    }

    await poolController.searchAvailableTrips();
    if (!mounted) return;
    Get.to(() => const SearchTripDriversScreen());
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Notification icon in soft circular container
          InkWell(
            onTap: () => Get.to(() => const NotificationScreen()),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 38,
              height: 38,
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

          // Center: Location Pill (● Madinat Al-Amal, Nasr City ⌵)
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
                        horizontal: 12,
                        vertical: 6,
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

          // Right: User Profile Avatar with cyan ring
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
                  width: 36,
                  height: 36,
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
                              style: textBold.copyWith(
                                fontSize: 13,
                                color: const Color(0xFF0284C7),
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

  Widget _buildHeaderTitle(String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(type),
                  style: textBold.copyWith(
                    fontSize: 20,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getSubtitle(type),
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          HowItWorksButton(
            onTap: () => _startWalkthrough(isManual: true),
          ),
        ],
      ),
    );
  }

  String _getTitle(String type) {
    if (type == 'routine') return 'Routine'.tr;
    if (type == 'travel') return 'Travel'.tr;
    if (type == 'north_coast') return 'North Coast'.tr;
    return 'one trip'.tr.isNotEmpty && 'one trip'.tr != 'one trip'
        ? 'one trip'.tr
        : 'one trip';
  }

  String _getSubtitle(String type) {
    if (type == 'routine') return 'Set up your work route'.tr;
    if (type == 'travel') return 'Plan Your Next Trip'.tr;
    if (type == 'north_coast') return 'Choose Your Coastal Getaway'.tr;
    return 'Find a trip that matches your route today.'.tr.isNotEmpty &&
            'Find a trip that matches your route today.'.tr !=
                'Find a trip that matches your route today.'
        ? 'Find a trip that matches your route today.'.tr
        : 'Find a trip that matches your route today.';
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.carpoolType ?? 'trip';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GetBuilder<LocationController>(
          builder: (locationController) {
            return GetBuilder<RideController>(
              builder: (rideController) {
                return GetBuilder<PoolStopPickupController>(
                  builder: (poolController) {
                    return GetBuilder<AvailableTripsController>(
                      builder: (availableTripsController) {
                        List<String> routineStartAddresses = [];
                        List<String> routineEndAddresses = [];

                        if (type == 'routine') {
                          List<PoolRide> routineRides = availableTripsController
                              .availableTrips
                              .where((ride) => _isRoutineRide(ride))
                              .toList();

                          if (routineRides.isEmpty &&
                              availableTripsController.availableTrips.isNotEmpty) {
                            routineRides = availableTripsController.availableTrips.where((ride) {
                              final cType = (ride.carpoolType ?? '').toLowerCase();
                              final label = (ride.carpoolTypeLabel ?? '').toLowerCase();
                              return cType != 'travel' &&
                                  cType != 'north_coast' &&
                                  cType != 'school' &&
                                  cType != 'university' &&
                                  cType != 'uni' &&
                                  !label.contains('school') &&
                                  !label.contains('university') &&
                                  !label.contains('uni');
                            }).toList();
                          }

                          routineStartAddresses = routineRides
                              .map((r) => _getRideStartAddress(r))
                              .where((s) => s.isNotEmpty)
                              .toSet()
                              .toList()
                            ..sort((a, b) => a
                                .toLowerCase()
                                .compareTo(b.toLowerCase()));

                          if (_selectedRoutineStartAddress != null &&
                              _selectedRoutineStartAddress!.isNotEmpty) {
                            routineEndAddresses = routineRides
                                .where((r) =>
                                    _getRideStartAddress(r).toLowerCase() ==
                                    _selectedRoutineStartAddress!.toLowerCase())
                                .map((r) => _getRideEndAddress(r))
                                .where((s) => s.isNotEmpty)
                                .toSet()
                                .toList()
                              ..sort((a, b) => a
                                  .toLowerCase()
                                  .compareTo(b.toLowerCase()));
                          } else {
                            routineEndAddresses = routineRides
                                .map((r) => _getRideEndAddress(r))
                                .where((s) => s.isNotEmpty)
                                .toSet()
                                .toList()
                              ..sort((a, b) => a
                                  .toLowerCase()
                                  .compareTo(b.toLowerCase()));
                          }
                        }

                        return SingleChildScrollView(
                          controller: _scrollController,
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.only(
                            bottom: widget.fromDashboard
                                ? 80
                                : 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTopBar(),
                              const SizedBox(height: 4),
                              _buildHeaderTitle(type),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. Search your trip Card
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.02),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Search your trip'.tr.isNotEmpty &&
                                                    'Search your trip'.tr !=
                                                        'Search your trip'
                                                ? 'Search your trip'.tr
                                                : 'Search your trip',
                                            style: textBold.copyWith(
                                              fontSize: 15,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Enter your route first to see matching daily trips.'
                                                        .tr
                                                        .isNotEmpty &&
                                                    'Enter your route first to see matching daily trips.'
                                                            .tr !=
                                                        'Enter your route first to see matching daily trips.'
                                                ? 'Enter your route first to see matching daily trips.'
                                                    .tr
                                                : 'Enter your route first to see matching daily trips.',
                                            style: textRegular.copyWith(
                                              fontSize: 10.5,
                                              color: const Color(0xFF94A3B8),
                                            ),
                                          ),
                                          const SizedBox(height: 8),

                                          // Dynamic Location Selection
                                          if (type == 'travel' ||
                                              type == 'north_coast')
                                            BoardingPointsCard(
                                              poolController: poolController,
                                              pickupKey: _pickupKey,
                                              destinationKey: _destinationKey,
                                            )
                                          else if (type == 'routine')
                                            RoutineRouteCard(
                                              startAddresses:
                                                  routineStartAddresses,
                                              endAddresses:
                                                  routineEndAddresses,
                                              selectedStartAddress:
                                                  _selectedRoutineStartAddress,
                                              selectedEndAddress:
                                                  _selectedRoutineEndAddress,
                                              onStartAddressChanged: (value) {
                                                setState(() {
                                                  _selectedRoutineStartAddress =
                                                      value;
                                                  if (value != null &&
                                                      _selectedRoutineEndAddress !=
                                                          null &&
                                                      !routineEndAddresses.contains(
                                                          _selectedRoutineEndAddress)) {
                                                    _selectedRoutineEndAddress =
                                                        null;
                                                  }
                                                });
                                                if (Get.isRegistered<
                                                    WalkthroughController>()) {
                                                  Get.find<
                                                          WalkthroughController>()
                                                      .autoAdvanceIfCurrentStep(
                                                          'search_step_pickup');
                                                }
                                              },
                                              onEndAddressChanged: (value) {
                                                setState(() {
                                                  _selectedRoutineEndAddress =
                                                      value;
                                                });
                                                if (Get.isRegistered<
                                                    WalkthroughController>()) {
                                                  Get.find<
                                                          WalkthroughController>()
                                                      .autoAdvanceIfCurrentStep(
                                                          'search_step_destination');
                                                }
                                              },
                                              pickupKey: _pickupKey,
                                              destinationKey: _destinationKey,
                                              isLoading: availableTripsController
                                                  .isLoading,
                                            )
                                          else
                                            LocationCard(
                                              rideController: rideController,
                                              locationController:
                                                  locationController,
                                              pickFocus: _pickLocationFocus,
                                              destinationFocus:
                                                  _destinationLocationFocus,
                                              onOpenMap: _openMapPicker,
                                              pickupKey: _pickupKey,
                                              destinationKey: _destinationKey,
                                            ),

                                          const SizedBox(height: 8),

                                          // Date & Seats selector row
                                          Row(
                                            children: [
                                              Expanded(
                                                child: KeyedSubtree(
                                                  key: _dateKey,
                                                  child: TripFieldTile(
                                                    icon: Icons
                                                        .calendar_today_outlined,
                                                    label: 'date'.tr,
                                                    value: _formatSelectedDate(
                                                        _selectedDate),
                                                    onTap: _pickDate,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: KeyedSubtree(
                                                  key: _seatsKey,
                                                  child: SeatsDropdown(
                                                    value: _selectedSeats,
                                                    onChanged: (value) {
                                                      if (value != null) {
                                                        setState(() =>
                                                            _selectedSeats =
                                                                value);
                                                        if (Get.isRegistered<WalkthroughController>()) {
                                                          Get.find<WalkthroughController>()
                                                              .autoAdvanceIfCurrentStep('search_step_seats');
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Departure Time (and Return Time ONLY for routine; NO time for travel/north_coast)
                                          if (type == 'routine') ...[
                                            const SizedBox(height: 8),
                                            KeyedSubtree(
                                              key: _timeKey,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: TripFieldTile(
                                                      icon: Icons
                                                          .access_time_rounded,
                                                      label: 'departure_time'
                                                                  .tr
                                                                  .isNotEmpty &&
                                                              'departure_time'
                                                                      .tr !=
                                                                  'departure_time'
                                                          ? 'departure_time'.tr
                                                          : 'Departure',
                                                      value:
                                                          _selectedDepartureTime
                                                              .format(context),
                                                      onTap: _pickDepartureTime,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: TripFieldTile(
                                                      icon: Icons.update_rounded,
                                                      label: 'return_time'
                                                                  .tr
                                                                  .isNotEmpty &&
                                                              'return_time'.tr !=
                                                                  'return_time'
                                                          ? 'return_time'.tr
                                                          : 'Return',
                                                      value: _selectedReturnTime
                                                          .format(context),
                                                      onTap: _pickReturnTime,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ] else if (type == 'trip') ...[
                                            const SizedBox(height: 8),
                                            KeyedSubtree(
                                              key: _timeKey,
                                              child: TripFieldTile(
                                                icon: Icons.access_time_rounded,
                                                label: 'departure_time'
                                                            .tr
                                                            .isNotEmpty &&
                                                        'departure_time'.tr !=
                                                            'departure_time'
                                                    ? 'departure_time'.tr
                                                    : 'Departure',
                                                value: _selectedDepartureTime
                                                    .format(context),
                                                onTap: _pickDepartureTime,
                                              ),
                                            ),
                                          ],

                                          // Gender selector for non-'trip' types
                                          if (type != 'trip') ...[
                                            const SizedBox(height: 8),
                                            KeyedSubtree(
                                              key: _genderKey,
                                              child: GenderSelector(
                                                value: _selectedGender,
                                                onChanged: (value) {
                                                  setState(() =>
                                                      _selectedGender = value);
                                                  Get.find<
                                                          PoolStopPickupController>()
                                                      .setSearchParameters(
                                                          gender: value);
                                                  if (Get.isRegistered<WalkthroughController>()) {
                                                    Get.find<WalkthroughController>()
                                                        .autoAdvanceIfCurrentStep('search_step_gender');
                                                  }
                                                },
                                              ),
                                            ),
                                          ],

                                          const SizedBox(height: 10),

                                          // Find trips Button
                                          KeyedSubtree(
                                            key: _submitKey,
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: 46,
                                              child: ElevatedButton(
                                                onPressed: poolController
                                                        .isSearchingTrips
                                                    ? null
                                                    : _searchForRides,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF00A0E9),
                                                  disabledBackgroundColor:
                                                      Colors.black54,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            23),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: poolController
                                                        .isSearchingTrips
                                                    ? const SpinKitThreeBounce(
                                                        color: Colors.white,
                                                        size: 22,
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .search_rounded,
                                                            color: Colors.white,
                                                            size: 19,
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            'Find trips'
                                                                        .tr
                                                                        .isNotEmpty &&
                                                                    'Find trips'
                                                                            .tr !=
                                                                        'Find trips'
                                                                ? 'Find trips'
                                                                    .tr
                                                                : 'Find trips',
                                                            style: textBold
                                                                .copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ),
                                          if (type == 'trip') ...[
                                            const SizedBox(height: 10),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 46,
                                              child: OutlinedButton.icon(
                                                onPressed: () => Get.to(
                                                  () => const CreateYourOwnTripScreen(),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(
                                                    color: Color(0xFF00A0E9),
                                                    width: 1.5,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(23),
                                                  ),
                                                  foregroundColor:
                                                      const Color(0xFF00A0E9),
                                                ),
                                                icon: const Icon(
                                                  Icons.add_circle_outline_rounded,
                                                  size: 19,
                                                  color: Color(0xFF00A0E9),
                                                ),
                                                label: Text(
                                                  'Create your own trip'.tr.isNotEmpty &&
                                                          'Create your own trip'.tr !=
                                                              'Create your own trip'
                                                      ? 'Create your own trip'.tr
                                                      : 'Create your own trip',
                                                  style: textBold.copyWith(
                                                    color: const Color(0xFF00A0E9),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    if (type == 'routine')
                                      _buildRoutineTripsList(
                                        availableTripsController,
                                        rideController,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoutineTripsList(
    AvailableTripsController availableTripsController,
    RideController rideController,
  ) {
    List<PoolRide> routineSourceRides = availableTripsController.availableTrips
        .where((ride) => _isRoutineRide(ride))
        .toList();

    final matchingRoutineTrips = routineSourceRides.where((ride) {
      if (_selectedRoutineStartAddress != null &&
          _selectedRoutineStartAddress!.isNotEmpty) {
        final start = _getRideStartAddress(ride).toLowerCase();
        final sel = _selectedRoutineStartAddress!.toLowerCase();
        if (start != sel && !start.contains(sel) && !sel.contains(start)) {
          return false;
        }
      }

      if (_selectedRoutineEndAddress != null &&
          _selectedRoutineEndAddress!.isNotEmpty) {
        final end = _getRideEndAddress(ride).toLowerCase();
        final sel = _selectedRoutineEndAddress!.toLowerCase();
        if (end != sel && !end.contains(sel) && !sel.contains(end)) {
          return false;
        }
      }

      if (_selectedGender.isNotEmpty && _selectedGender != 'both') {
        if (ride.allowedGender.isNotEmpty &&
            ride.allowedGender.toLowerCase() != 'both' &&
            ride.allowedGender.toLowerCase() !=
                _selectedGender.toLowerCase()) {
          return false;
        }
      }

      if (ride.seatsAvailable < _selectedSeats) {
        return false;
      }

      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Routine Trips'.tr,
              style: textBold.copyWith(
                fontSize: 18,
                color: const Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${matchingRoutineTrips.length} ${'trips'.tr}',
                style: textBold.copyWith(
                  fontSize: 12,
                  color: const Color(0xFF0284C7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (availableTripsController.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: Color(0xFF00A0E9)),
            ),
          )
        else if (matchingRoutineTrips.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.directions_bus_outlined,
                  size: 44,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(height: 10),
                Text(
                  'No routine trips found'.tr,
                  style: textBold.copyWith(
                    fontSize: 15,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Try adjusting your city filters, time, or gender preferences.'.tr,
                  textAlign: TextAlign.center,
                  style: textRegular.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: matchingRoutineTrips.length,
            itemBuilder: (context, index) {
              final ride = matchingRoutineTrips[index];
              return MatchingTripCard(
                ride: ride,
                index: index,
                isSelected: false,
                onSelect: () {
                  Get.to(() => TripDetailsScreen(
                        trip: ride,
                        rideController: rideController,
                        fromSearch: true,
                      ));
                },
                onViewDetails: () {
                  Get.to(() => TripDetailsScreen(
                        trip: ride,
                        rideController: rideController,
                        fromSearch: true,
                      ));
                },
              );
            },
          ),
      ],
    );
  }
}
