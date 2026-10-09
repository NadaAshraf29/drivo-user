import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/seats_dropdown.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/trip_field_tile.dart';
import 'package:ride_sharing_user_app/features/school/controllers/school_controller.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_search_request.dart';
import 'package:ride_sharing_user_app/features/school/screens/school_matching_trips_screen.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_dropdown_field.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_gender_selector.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_picker_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_return_checkbox_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_top_bar.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import 'package:ride_sharing_user_app/features/walkthrough/controllers/walkthrough_controller.dart';
import 'package:ride_sharing_user_app/features/walkthrough/domain/models/walkthrough_model.dart';
import 'package:ride_sharing_user_app/features/walkthrough/helpers/walkthrough_helper.dart';
import 'package:ride_sharing_user_app/features/walkthrough/widgets/how_it_works_button.dart';

class SchoolSearchScreen extends StatefulWidget {
  const SchoolSearchScreen({super.key});

  @override
  State<SchoolSearchScreen> createState() => _SchoolSearchScreenState();
}

class _SchoolSearchScreenState extends State<SchoolSearchScreen> {
  final GlobalKey _schoolPickerKey = GlobalKey();
  final GlobalKey _schoolPickupKey = GlobalKey();
  final GlobalKey _schoolDateKey = GlobalKey();
  final GlobalKey _schoolOptionsKey = GlobalKey();
  final GlobalKey _schoolSubmitKey = GlobalKey();

  String _selectedSchool = '';
  String _selectedPickupPoint = '';
  DateTime _selectedDate = DateTime.now();
  int _selectedSeats = 1;
  String _selectedGender = 'male';
  bool _needReturnRide = true;

  void _startWalkthrough({bool isManual = false}) {
    if (!Get.isRegistered<WalkthroughController>()) return;
    final walkthroughCtrl = Get.find<WalkthroughController>();
    walkthroughCtrl.startFlow(
      WalkthroughFlowType.schoolSearch,
      WalkthroughHelper.getSchoolSteps(),
      isManual: isManual,
    );
  }

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<WalkthroughController>()) {
      final walkthroughCtrl = Get.find<WalkthroughController>();
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetSchoolPicker, _schoolPickerKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetSchoolPickup, _schoolPickupKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetSchoolDate, _schoolDateKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetSchoolOptions, _schoolOptionsKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetSchoolSubmit, _schoolSubmitKey);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!walkthroughCtrl.hasSeenFlow(WalkthroughFlowType.schoolSearch)) {
          Future.delayed(const Duration(milliseconds: 650), () {
            if (mounted &&
                !walkthroughCtrl
                    .hasSeenFlow(WalkthroughFlowType.schoolSearch)) {
              _startWalkthrough(isManual: false);
            }
          });
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<SchoolController>()) {
        final schoolCtrl = Get.find<SchoolController>();
        schoolCtrl.getSchoolConfig().then((_) {
          if (!mounted) return;
          _syncSelectionWithController(schoolCtrl);
        });
      }
    });
  }

  void _syncSelectionWithController(SchoolController schoolCtrl) {
    final schools = schoolCtrl.getAvailableSchools();
    if (schools.isNotEmpty) {
      setState(() {
        if (_selectedSchool.isEmpty || !schools.contains(_selectedSchool)) {
          _selectedSchool = schools.first;
        }
        final points = schoolCtrl.getPickupPointsForSchool(_selectedSchool);
        if (points.isNotEmpty) {
          if (_selectedPickupPoint.isEmpty ||
              !points.contains(_selectedPickupPoint)) {
            _selectedPickupPoint = points.first;
          }
        } else {
          _selectedPickupPoint = '';
        }
      });
    }
  }

  void _showSchoolPicker(List<String> schools, SchoolController schoolCtrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SchoolPickerBottomSheet(
        title: 'select_school'.tr,
        items: schools,
        selectedItem: _selectedSchool,
        onSelected: (val) {
          setState(() {
            _selectedSchool = val;
            final points = schoolCtrl.getPickupPointsForSchool(val);
            _selectedPickupPoint = points.isNotEmpty ? points.first : '';
          });
          if (Get.isRegistered<WalkthroughController>()) {
            Get.find<WalkthroughController>()
                .autoAdvanceIfCurrentStep('school_step_picker');
          }
        },
      ),
    );
  }

  void _showPickupPicker(List<String> points, List<String> availableSchools,
      SchoolController schoolCtrl) {
    if (_selectedSchool.isEmpty && availableSchools.isNotEmpty) {
      showCustomSnackBar('select_school'.tr);
      _showSchoolPicker(availableSchools, schoolCtrl);
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SchoolPickerBottomSheet(
        title: 'select_pickup_point'.tr,
        items: points,
        selectedItem: _selectedPickupPoint,
        onSelected: (val) {
          setState(() {
            _selectedPickupPoint = val;
          });
          if (Get.isRegistered<WalkthroughController>()) {
            Get.find<WalkthroughController>()
                .autoAdvanceIfCurrentStep('school_step_pickup');
          }
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00A0E9),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
      if (Get.isRegistered<WalkthroughController>()) {
        Get.find<WalkthroughController>()
            .autoAdvanceIfCurrentStep('school_step_date');
      }
    }
  }

  void _onSearchPressed(SchoolController schoolCtrl) async {
    if (_selectedSchool.isEmpty) {
      showCustomSnackBar('select_school'.tr);
      return;
    }

    final request = SchoolSearchRequest(
      schoolName: _selectedSchool,
      pickupPointName: _selectedPickupPoint,
      date: _selectedDate,
      seats: _selectedSeats,
      gender: _selectedGender,
      needReturnRide: _needReturnRide,
    );

    await schoolCtrl.searchSchoolTrips(request);
    if (!mounted) return;
    Get.to(
      () => SchoolMatchingTripsScreen(
        schoolName: _selectedSchool,
        pickupPoint: _selectedPickupPoint,
        hasReturnRide: _needReturnRide,
        searchRequest: request,
      ),
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GetBuilder<SchoolController>(
          builder: (schoolCtrl) {
            final availableSchools = schoolCtrl.getAvailableSchools();
            if (_selectedSchool.isEmpty && availableSchools.isNotEmpty) {
              _selectedSchool = availableSchools.first;
              final points =
                  schoolCtrl.getPickupPointsForSchool(_selectedSchool);
              _selectedPickupPoint = points.isNotEmpty ? points.first : '';
            }

            final currentPickupPoints =
                schoolCtrl.getPickupPointsForSchool(_selectedSchool);

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SchoolTopBar(showBackButton: false),
                  const SizedBox(height: 4),

                  // Header Title & Subtitle + How it works
                  Padding(
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
                                'schools'.tr,
                                style: textBold.copyWith(
                                  fontSize: 20,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'find_a_trip_matches_school_route'.tr,
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
                  ),
                  const SizedBox(height: 8),

                  // Main Search Card
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'search_school_trips'.tr,
                            style: textBold.copyWith(
                              fontSize: 15,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'choose_school_and_pickup_point'.tr,
                            style: textRegular.copyWith(
                              fontSize: 10.5,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // School Dropdown
                          KeyedSubtree(
                            key: _schoolPickerKey,
                            child: SchoolDropdownField(
                              label: 'choose_the_school'.tr.isNotEmpty &&
                                      'choose_the_school'.tr !=
                                          'choose_the_school'
                                  ? 'choose_the_school'.tr
                                  : 'CHOOSE THE SCHOOL',
                              value: _selectedSchool.isNotEmpty
                                  ? _selectedSchool
                                  : 'select_school'.tr,
                              prefix: const Icon(
                                Icons.school_rounded,
                                color: Color(0xFF00A0E9),
                                size: 18,
                              ),
                              onTap: () => _showSchoolPicker(
                                availableSchools,
                                schoolCtrl,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Pickup Point Dropdown (FROM)
                          KeyedSubtree(
                            key: _schoolPickupKey,
                            child: SchoolDropdownField(
                              label: 'from'.tr.isNotEmpty && 'from'.tr != 'from'
                                  ? 'from'.tr
                                  : 'FROM',
                              value: _selectedPickupPoint.isNotEmpty
                                  ? _selectedPickupPoint
                                  : 'select_pickup_point'.tr,
                              prefix: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00A0E9),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              onTap: () => _showPickupPicker(
                                currentPickupPoints,
                                availableSchools,
                                schoolCtrl,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Row: Date & Seats
                          Row(
                            children: [
                              Expanded(
                                child: KeyedSubtree(
                                  key: _schoolDateKey,
                                  child: TripFieldTile(
                                    icon: Icons.calendar_today_outlined,
                                    label: 'date'.tr,
                                    value: _formatSelectedDate(_selectedDate),
                                    onTap: _pickDate,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SeatsDropdown(
                                  value: _selectedSeats,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedSeats = val);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          KeyedSubtree(
                            key: _schoolOptionsKey,
                            child: Column(
                              children: [
                                // Gender Selector
                                SchoolGenderSelector(
                                  selectedGender: _selectedGender,
                                  onGenderSelected: (g) {
                                    setState(() {
                                      _selectedGender = g;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),

                                // Return Ride Checkbox
                                SchoolReturnCheckboxCard(
                                  value: _needReturnRide,
                                  onChanged: (val) {
                                    setState(() {
                                      _needReturnRide = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Search Trips Button
                          KeyedSubtree(
                            key: _schoolSubmitKey,
                            child: SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton(
                                onPressed: schoolCtrl.isSearching
                                    ? null
                                    : () => _onSearchPressed(schoolCtrl),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A0E9),
                                  disabledBackgroundColor: Colors.black54,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(23),
                                  ),
                                  elevation: 0,
                                ),
                                child: schoolCtrl.isSearching
                                    ? const SpinKitThreeBounce(
                                        color: Colors.white,
                                        size: 22,
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.search_rounded,
                                            size: 19,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Find trips'.tr.isNotEmpty &&
                                                    'Find trips'.tr !=
                                                        'Find trips'
                                                ? 'Find trips'.tr
                                                : 'Find trips',
                                            style: textBold.copyWith(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
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
            );
          },
        ),
      ),
    );
  }
}
