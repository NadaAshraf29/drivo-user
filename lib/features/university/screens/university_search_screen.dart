import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/seats_dropdown.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/trip_field_tile.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_picker_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/university/controllers/university_controller.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_search_request.dart';
import 'package:ride_sharing_user_app/features/university/screens/university_matching_trips_screen.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_dropdown_field.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_gender_selector.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_return_checkbox_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_top_bar.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import 'package:ride_sharing_user_app/features/walkthrough/controllers/walkthrough_controller.dart';
import 'package:ride_sharing_user_app/features/walkthrough/domain/models/walkthrough_model.dart';
import 'package:ride_sharing_user_app/features/walkthrough/helpers/walkthrough_helper.dart';
import 'package:ride_sharing_user_app/features/walkthrough/widgets/how_it_works_button.dart';

class UniversitySearchScreen extends StatefulWidget {
  const UniversitySearchScreen({super.key});

  @override
  State<UniversitySearchScreen> createState() => _UniversitySearchScreenState();
}

class _UniversitySearchScreenState extends State<UniversitySearchScreen> {
  final GlobalKey _uniPickerKey = GlobalKey();
  final GlobalKey _uniPickupKey = GlobalKey();
  final GlobalKey _uniDateKey = GlobalKey();
  final GlobalKey _uniOptionsKey = GlobalKey();
  final GlobalKey _uniSubmitKey = GlobalKey();

  String _selectedUniversity = '';
  String _selectedPickupPoint = '';
  DateTime _selectedDate = DateTime.now();
  int _selectedSeats = 1;
  String _selectedGender = 'both';
  bool _needReturnRide = true;

  void _startWalkthrough({bool isManual = false}) {
    if (!Get.isRegistered<WalkthroughController>()) return;
    final walkthroughCtrl = Get.find<WalkthroughController>();
    walkthroughCtrl.startFlow(
      WalkthroughFlowType.universitySearch,
      WalkthroughHelper.getUniversitySteps(),
      isManual: isManual,
    );
  }

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<WalkthroughController>()) {
      final walkthroughCtrl = Get.find<WalkthroughController>();
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetUniPicker, _uniPickerKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetUniPickup, _uniPickupKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetUniDate, _uniDateKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetUniOptions, _uniOptionsKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetUniSubmit, _uniSubmitKey);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!walkthroughCtrl.hasSeenFlow(WalkthroughFlowType.universitySearch)) {
          Future.delayed(const Duration(milliseconds: 650), () {
            if (mounted &&
                !walkthroughCtrl
                    .hasSeenFlow(WalkthroughFlowType.universitySearch)) {
              _startWalkthrough(isManual: false);
            }
          });
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<UniversityController>()) {
        final uniController = Get.find<UniversityController>();
        uniController.getUniversityConfig().then((_) {
          if (!mounted) return;
          _syncSelectionWithController(uniController);
        });
      }
    });
  }

  void _syncSelectionWithController(UniversityController uniController) {
    final unis = uniController.getAvailableUniversities();
    if (unis.isNotEmpty) {
      setState(() {
        if (_selectedUniversity.isEmpty ||
            !unis.contains(_selectedUniversity)) {
          _selectedUniversity = unis.first;
        }
        final points =
            uniController.getPickupPointsForUniversity(_selectedUniversity);
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

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final dayStr = isToday ? 'Today' : DateFormat('EEE').format(date);
    final monthDayStr = DateFormat('MMM d').format(date);
    return '$dayStr · $monthDayStr';
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
            .autoAdvanceIfCurrentStep('uni_step_date');
      }
    }
  }

  void _showUniversityPicker(
      List<String> unis, UniversityController uniController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SchoolPickerBottomSheet(
        title: 'university_label'.tr,
        items: unis,
        selectedItem: _selectedUniversity,
        onSelected: (val) {
          setState(() {
            _selectedUniversity = val;
            final points = uniController.getPickupPointsForUniversity(val);
            _selectedPickupPoint = points.isNotEmpty ? points.first : '';
          });
          if (Get.isRegistered<WalkthroughController>()) {
            Get.find<WalkthroughController>()
                .autoAdvanceIfCurrentStep('uni_step_picker');
          }
        },
      ),
    );
  }

  void _showPickupPicker(List<String> points, List<String> availableUnis,
      UniversityController uniController) {
    if (_selectedUniversity.isEmpty && availableUnis.isNotEmpty) {
      showCustomSnackBar('select_university'.tr);
      _showUniversityPicker(availableUnis, uniController);
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SchoolPickerBottomSheet(
        title: 'pickup_point_label'.tr,
        items: points,
        selectedItem: _selectedPickupPoint,
        onSelected: (val) {
          setState(() {
            _selectedPickupPoint = val;
          });
          if (Get.isRegistered<WalkthroughController>()) {
            Get.find<WalkthroughController>()
                .autoAdvanceIfCurrentStep('uni_step_pickup');
          }
        },
      ),
    );
  }

  void _onSearchPressed(UniversityController uniController) async {
    if (_selectedUniversity.isEmpty) {
      showCustomSnackBar('select_university'.tr);
      return;
    }

    final formattedDate =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final request = UniversitySearchRequest(
      universityName: _selectedUniversity,
      pickupPointName: _selectedPickupPoint,
      date: formattedDate,
      seats: _selectedSeats,
      gender: _selectedGender,
      needReturnRide: _needReturnRide,
    );

    await uniController.searchUniversityTrips(request);
    if (!mounted) return;
    Get.to(
      () => UniversityMatchingTripsScreen(
        university: _selectedUniversity,
        pickupPoint: _selectedPickupPoint,
        hasReturnRide: _needReturnRide,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GetBuilder<UniversityController>(
          builder: (uniController) {
            final availableUnis = uniController.getAvailableUniversities();
            if (_selectedUniversity.isEmpty && availableUnis.isNotEmpty) {
              _selectedUniversity = availableUnis.first;
              final points = uniController
                  .getPickupPointsForUniversity(_selectedUniversity);
              _selectedPickupPoint = points.isNotEmpty ? points.first : '';
            }

            final currentPickupPoints = uniController
                .getPickupPointsForUniversity(_selectedUniversity);

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const UniversityTopBar(showBackButton: false),
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
                                'universities'.tr,
                                style: textBold.copyWith(
                                  fontSize: 20,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'find_a_trip_matches_university_route'.tr,
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
                            'search_university_trips'.tr,
                            style: textBold.copyWith(
                              fontSize: 15,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'choose_university_and_pickup_point'.tr,
                            style: textRegular.copyWith(
                              fontSize: 10.5,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // University Dropdown
                          KeyedSubtree(
                            key: _uniPickerKey,
                            child: UniversityDropdownField(
                              label: 'choose_the_university'.tr.isNotEmpty &&
                                      'choose_the_university'.tr !=
                                          'choose_the_university'
                                  ? 'choose_the_university'.tr
                                  : 'CHOOSE THE UNIVERSITY',
                              value: _selectedUniversity.isNotEmpty
                                  ? _selectedUniversity
                                  : 'select_university'.tr,
                              prefix: const Icon(
                                Icons.school_rounded,
                                color: Color(0xFF00A0E9),
                                size: 18,
                              ),
                              onTap: () => _showUniversityPicker(
                                availableUnis,
                                uniController,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Pickup Point Dropdown (FROM)
                          KeyedSubtree(
                            key: _uniPickupKey,
                            child: UniversityDropdownField(
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
                                availableUnis,
                                uniController,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Row: Date & Seats
                          Row(
                            children: [
                              Expanded(
                                child: KeyedSubtree(
                                  key: _uniDateKey,
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
                                      if (Get.isRegistered<WalkthroughController>()) {
                                        Get.find<WalkthroughController>()
                                            .autoAdvanceIfCurrentStep('uni_step_options');
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          KeyedSubtree(
                            key: _uniOptionsKey,
                            child: Column(
                              children: [
                                // Gender Selector
                                UniversityGenderSelector(
                                  selectedGender: _selectedGender,
                                  onGenderChanged: (gender) {
                                    setState(() {
                                      _selectedGender = gender;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),

                                // Return Ride Checkbox
                                UniversityReturnCheckboxCard(
                                  isChecked: _needReturnRide,
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

                          // Search Button
                          KeyedSubtree(
                            key: _uniSubmitKey,
                            child: SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton(
                                onPressed: uniController.isSearching
                                    ? null
                                    : () => _onSearchPressed(uniController),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A0E9),
                                  disabledBackgroundColor: Colors.black54,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(23),
                                  ),
                                  elevation: 0,
                                ),
                                child: uniController.isSearching
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
                                            color: Colors.white,
                                            size: 19,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Find university rides'.tr.isNotEmpty &&
                                                    'Find university rides'.tr !=
                                                        'Find university rides'
                                                ? 'Find university rides'.tr
                                                : 'Find university rides',
                                            style: textBold.copyWith(
                                              color: Colors.white,
                                              fontSize: 14,
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
