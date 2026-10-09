import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/passenger_model.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/paymob_intent_response.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/special_trip_fare_model.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/special_trip_model.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/trip_location_point.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/services/special_trip_service_interface.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/features/payment/domain/services/paymob_service.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_success_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:flutter_paymob_sdk/flutter_paymob_sdk.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';

class CreateYourOwnTripController extends GetxController {
  final SpecialTripServiceInterface specialTripService;

  CreateYourOwnTripController({required this.specialTripService});

  // Location Points
  List<TripLocationPoint> _pickupPoints = [];
  List<TripLocationPoint> _destinationPoints = [];

  List<TripLocationPoint> get pickupPoints => _pickupPoints;
  List<TripLocationPoint> get destinationPoints => _destinationPoints;

  // Dates & Schedule
  late DateTime _startDate;
  late DateTime _endDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  bool _hasReturnRide = false;
  TimeOfDay? _returnTime = const TimeOfDay(hour: 17, minute: 0);

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  TimeOfDay get startTime => _startTime;
  bool get hasReturnRide => _hasReturnRide;
  TimeOfDay? get returnTime => _returnTime;

  // Operating Weekdays (1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun)
  // Default: Sunday(7), Monday(1), Tuesday(2), Wednesday(3), Thursday(4)
  Set<int> _selectedWeekdays = {7, 1, 2, 3, 4};
  Set<int> get selectedWeekdays => _selectedWeekdays;

  // Seats & Passengers
  int _seatsCount = 1;
  int get seatsCount => _seatsCount;

  List<SpecialTripPassengerModel> _passengers = [];
  List<SpecialTripPassengerModel> get passengers => _passengers;

  // Payment Responsibility
  PaymentResponsibility _paymentResponsibility =
      PaymentResponsibility.creatorPays;
  PaymentResponsibility get paymentResponsibility => _paymentResponsibility;

  // Pricing & Requests
  SpecialTripFareModel? _fareModel;
  SpecialTripFareModel? get fareModel => _fareModel;

  SpecialTripRequestModel? _currentTrip;
  SpecialTripRequestModel? get currentTrip => _currentTrip;

  // UI States
  bool _isLoadingFare = false;
  bool get isLoadingFare => _isLoadingFare;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _isSearchingPassenger = false;
  bool get isSearchingPassenger => _isSearchingPassenger;

  SpecialTripPassengerModel? _searchedPassenger;
  SpecialTripPassengerModel? get searchedPassenger => _searchedPassenger;

  String? _searchPassengerError;
  String? get searchPassengerError => _searchPassengerError;

  // 30-Minute Payment Countdown
  Timer? _countdownTimer;
  Duration _remainingPaymentDuration = Duration.zero;
  Duration get remainingPaymentDuration => _remainingPaymentDuration;

  bool _isProcessingPayment = false;
  bool get isProcessingPayment => _isProcessingPayment;

  @override
  void onInit() {
    super.onInit();
    _resetForm();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  void _resetForm() {
    // Tomorrow is the minimum allowed start date
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _startDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    _endDate = _startDate.add(const Duration(days: 30));

    _pickupPoints = [
      TripLocationPoint(
        id: 'p_1',
        name: '${'pickup_point'.tr} 1',
        type: TripLocationType.pickup,
        order: 1,
      ),
    ];

    _destinationPoints = [
      TripLocationPoint(
        id: 'd_1',
        name: '${'destination_point'.tr} 1',
        type: TripLocationType.destination,
        order: 1,
      ),
    ];

    _selectedWeekdays = {7, 1, 2, 3, 4};
    _seatsCount = 1;
    _hasReturnRide = false;
    _paymentResponsibility = PaymentResponsibility.creatorPays;
    _fareModel = null;

    _initCurrentUserPassenger();
  }

  void _initCurrentUserPassenger() {
    String currentUserName = 'You';
    String currentUserPhone = '';
    String? avatar;

    if (Get.isRegistered<ProfileController>()) {
      final profile = Get.find<ProfileController>().profileModel?.data;
      if (profile != null) {
        currentUserName =
            '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
        if (currentUserName.isEmpty) currentUserName = 'You';
        currentUserPhone =
            SpecialTripPassengerModel.formatPhoneNumber(profile.phone ?? '');
        avatar = profile.profileImage;
      }
    }

    _passengers = [
      SpecialTripPassengerModel(
        id: 'current_user',
        name: currentUserName,
        phone: currentUserPhone,
        avatar: avatar,
        isCurrentUser: true,
        paymentStatus: PassengerPaymentStatus.unpaid,
      ),
    ];
  }

  // --- Pickup Points Management ---
  void addPickupPoint() {
    final nextOrder = _pickupPoints.length + 1;
    _pickupPoints.add(
      TripLocationPoint(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        name: '${'pickup_point'.tr} $nextOrder',
        type: TripLocationType.pickup,
        order: nextOrder,
      ),
    );
    update();
  }

  void removePickupPoint(int index) {
    if (_pickupPoints.length <= 1) {
      showCustomSnackBar('at_least_one_pickup_point_required'.tr);
      return;
    }
    _pickupPoints.removeAt(index);
    for (int i = 0; i < _pickupPoints.length; i++) {
      _pickupPoints[i].order = i + 1;
      _pickupPoints[i].name = '${'pickup_point'.tr} ${i + 1}';
    }
    update();
  }

  void updatePickupPoint(int index, String address, double lat, double lng) {
    if (index >= 0 && index < _pickupPoints.length) {
      final corrected = MapBoundHelper.toCorrectLatLng(lat, lng);
      _pickupPoints[index] = _pickupPoints[index].copyWith(
        address: address,
        latitude: corrected.latitude != 0.0 ? corrected.latitude : lat,
        longitude: corrected.longitude != 0.0 ? corrected.longitude : lng,
      );
      update();
    }
  }

  // --- Destination Points Management ---
  void addDestinationPoint() {
    final nextOrder = _destinationPoints.length + 1;
    _destinationPoints.add(
      TripLocationPoint(
        id: 'd_${DateTime.now().millisecondsSinceEpoch}',
        name: '${'destination_point'.tr} $nextOrder',
        type: TripLocationType.destination,
        order: nextOrder,
      ),
    );
    update();
  }

  void removeDestinationPoint(int index) {
    if (_destinationPoints.length <= 1) {
      showCustomSnackBar('at_least_one_destination_point_required'.tr);
      return;
    }
    _destinationPoints.removeAt(index);
    for (int i = 0; i < _destinationPoints.length; i++) {
      _destinationPoints[i].order = i + 1;
      _destinationPoints[i].name = '${'destination_point'.tr} ${i + 1}';
    }
    update();
  }

  void updateDestinationPoint(
      int index, String address, double lat, double lng) {
    if (index >= 0 && index < _destinationPoints.length) {
      final corrected = MapBoundHelper.toCorrectLatLng(lat, lng);
      _destinationPoints[index] = _destinationPoints[index].copyWith(
        address: address,
        latitude: corrected.latitude != 0.0 ? corrected.latitude : lat,
        longitude: corrected.longitude != 0.0 ? corrected.longitude : lng,
      );
      update();
    }
  }

  // --- Dates & Schedule ---
  bool isStartDateValid(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isAfter(today);
  }

  void setStartDate(DateTime date) {
    if (!isStartDateValid(date)) {
      showCustomSnackBar('start_date_cannot_be_today'.tr, isError: true);
      return;
    }
    _startDate = DateTime(date.year, date.month, date.day);
    if (_endDate.isBefore(_startDate)) {
      _endDate = _startDate.add(const Duration(days: 30));
    }
    update();
  }

  void setEndDate(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    if (target.isBefore(_startDate)) {
      showCustomSnackBar('end_date_must_be_after_start_date'.tr, isError: true);
      return;
    }
    _endDate = target;
    update();
  }

  void setStartTime(TimeOfDay time) {
    _startTime = time;
    update();
  }

  void setReturnRide(bool value) {
    _hasReturnRide = value;
    if (_hasReturnRide && _returnTime == null) {
      _returnTime = const TimeOfDay(hour: 17, minute: 0);
    }
    update();
  }

  void setReturnTime(TimeOfDay time) {
    _returnTime = time;
    update();
  }

  void toggleWeekday(int day) {
    if (_selectedWeekdays.contains(day)) {
      if (_selectedWeekdays.length > 1) {
        _selectedWeekdays.remove(day);
      } else {
        showCustomSnackBar('select_at_least_one_day'.tr);
      }
    } else {
      _selectedWeekdays.add(day);
    }
    update();
  }

  void setExcludeWeekends(bool exclude) {
    if (exclude) {
      // Exclude Friday(5) and Saturday(6)
      _selectedWeekdays.remove(5);
      _selectedWeekdays.remove(6);
      if (_selectedWeekdays.isEmpty) {
        _selectedWeekdays.addAll({7, 1, 2, 3, 4});
      }
    } else {
      _selectedWeekdays.addAll({5, 6});
    }
    update();
  }

  bool get isWeekendsExcluded =>
      !_selectedWeekdays.contains(5) && !_selectedWeekdays.contains(6);

  int calculateOperatingDaysCount() {
    int count = 0;
    DateTime current = _startDate;
    final end = _endDate;

    while (!current.isAfter(end)) {
      if (_selectedWeekdays.contains(current.weekday)) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }
    return count > 0 ? count : 1;
  }

  List<String> get activeOperatingDates {
    if (_fareModel != null && _fareModel!.activeDates.isNotEmpty) {
      return _fareModel!.activeDates;
    }
    final List<String> dates = [];
    DateTime current = _startDate;
    while (!current.isAfter(_endDate)) {
      if (_selectedWeekdays.contains(current.weekday)) {
        dates.add(DateFormat('yyyy-MM-dd').format(current));
      }
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  // --- Seats & Passengers ---
  void setSeatsCount(int count) {
    if (count < 1) return;
    _seatsCount = count;
    // Trim passengers if exceeds seats
    if (_passengers.length > _seatsCount) {
      _passengers = _passengers.sublist(0, _seatsCount);
    }
    update();
  }

  void clearPassengerSearch() {
    _searchedPassenger = null;
    _searchPassengerError = null;
    _isSearchingPassenger = false;
    update();
  }

  Future<void> searchPassengerByPhone(String phone) async {
    final cleanPhone = SpecialTripPassengerModel.formatPhoneNumber(phone);
    if (cleanPhone.isEmpty || cleanPhone == '+20' || cleanPhone == '+200') {
      _searchPassengerError = 'enter_mobile_number'.tr;
      update();
      return;
    }

    // Check if phone matches current user
    if (_passengers.isNotEmpty &&
        SpecialTripPassengerModel.formatPhoneNumber(_passengers.first.phone) ==
            cleanPhone) {
      _searchPassengerError = 'cannot_add_yourself'.tr;
      update();
      return;
    }

    // Check if already added
    if (_passengers.any((p) =>
        SpecialTripPassengerModel.formatPhoneNumber(p.phone) == cleanPhone)) {
      _searchPassengerError = 'passenger_already_added'.tr;
      update();
      return;
    }

    _isSearchingPassenger = true;
    _searchPassengerError = null;
    _searchedPassenger = null;
    update();

    final response = await specialTripService.searchUserByPhone(cleanPhone);
    _isSearchingPassenger = false;

    if (response.statusCode == 200 && response.body?['data'] != null) {
      final passenger =
          SpecialTripPassengerModel.fromJson(response.body['data']);
      _searchedPassenger = passenger.copyWith(phone: cleanPhone);
      _searchPassengerError = null;
    } else {
      _searchedPassenger = null;
      _searchPassengerError = response.body?['message'] ??
          response.statusText ??
          'user_not_found'.tr;
    }
    update();
  }

  void confirmAddPassenger(SpecialTripPassengerModel passenger) {
    if (_passengers.length >= _seatsCount) {
      showCustomSnackBar('maximum_seats_reached'.tr);
      return;
    }
    final formattedPhone =
        SpecialTripPassengerModel.formatPhoneNumber(passenger.phone);
    if (_passengers.any((p) =>
        SpecialTripPassengerModel.formatPhoneNumber(p.phone) ==
        formattedPhone)) {
      showCustomSnackBar('passenger_already_added'.tr);
      return;
    }
    _passengers.add(passenger.copyWith(phone: formattedPhone));
    clearPassengerSearch();
    update();
  }

  void removePassenger(int index) {
    if (index >= 0 && index < _passengers.length) {
      if (_passengers[index].isCurrentUser) {
        showCustomSnackBar('cannot_remove_trip_creator'.tr);
        return;
      }
      _passengers.removeAt(index);
      update();
    }
  }

  // --- Payment Responsibility ---
  void setPaymentResponsibility(PaymentResponsibility value) {
    _paymentResponsibility = value;
    update();
  }

  // --- Validation & Fare Calculation ---
  bool validateTripForm() {
    if (_pickupPoints.isEmpty || !_pickupPoints.any((p) => p.isValid)) {
      showCustomSnackBar('pickup_location_is_required'.tr);
      return false;
    }
    if (_destinationPoints.isEmpty ||
        !_destinationPoints.any((d) => d.isValid)) {
      showCustomSnackBar('destination_location_is_required'.tr);
      return false;
    }
    if (!isStartDateValid(_startDate)) {
      showCustomSnackBar('start_date_cannot_be_today'.tr, isError: true);
      return false;
    }
    if (_endDate.isBefore(_startDate)) {
      showCustomSnackBar('end_date_must_be_after_start_date'.tr, isError: true);
      return false;
    }
    if (_selectedWeekdays.isEmpty) {
      showCustomSnackBar('select_at_least_one_day'.tr);
      return false;
    }
    return true;
  }

  Map<String, dynamic> buildEstimatePayload() {
    final excludedWeekdays = [1, 2, 3, 4, 5, 6, 7]
        .where((d) => !_selectedWeekdays.contains(d))
        .toList()
      ..sort();

    final pickupLocations = _pickupPoints
        .where((p) => p.isValid)
        .map((p) => p.toLocationApiJson())
        .toList();

    final destinationLocations = _destinationPoints
        .where((d) => d.isValid)
        .map((d) => d.toLocationApiJson())
        .toList();

    final returnTimeOfDay = _returnTime ?? const TimeOfDay(hour: 17, minute: 0);
    final returnTimeFormatted =
        '${DateFormat('yyyy-MM-dd').format(_startDate)} ${returnTimeOfDay.hour.toString().padLeft(2, '0')}:${returnTimeOfDay.minute.toString().padLeft(2, '0')}:00';

    return {
      'start_date': DateFormat('yyyy-MM-dd').format(_startDate),
      'end_date': DateFormat('yyyy-MM-dd').format(_endDate),
      'excluded_weekdays': excludedWeekdays,
      'pickup_locations': pickupLocations,
      'destination_locations': destinationLocations,
      'is_return_trip': _hasReturnRide,
      if (_hasReturnRide) 'return_time': returnTimeFormatted,
      'seats_count': _seatsCount,
    };
  }

  Map<String, dynamic> buildCreatePayload() {
    final excludedWeekdays = [1, 2, 3, 4, 5, 6, 7]
        .where((d) => !_selectedWeekdays.contains(d))
        .toList()
      ..sort();

    final pickupLocations = _pickupPoints
        .where((p) => p.isValid)
        .map((p) => p.toLocationApiJson())
        .toList();

    final destinationLocations = _destinationPoints
        .where((d) => d.isValid)
        .map((d) => d.toLocationApiJson())
        .toList();

    final startTimeFormatted =
        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}:00';

    final additionalPassengers = _passengers
        .where((p) => !p.isCurrentUser)
        .map((p) => p.toApiPassengerJson())
        .toList();

    final Map<String, dynamic> payload = {
      'start_date': DateFormat('yyyy-MM-dd').format(_startDate),
      'end_date': DateFormat('yyyy-MM-dd').format(_endDate),
      'start_time': startTimeFormatted,
      'excluded_weekdays': excludedWeekdays,
      'pickup_locations': pickupLocations,
      'destination_locations': destinationLocations,
      'is_return_trip': _hasReturnRide,
      if (_hasReturnRide && _returnTime != null)
        'return_time':
            '${_returnTime!.hour.toString().padLeft(2, '0')}:${_returnTime!.minute.toString().padLeft(2, '0')}:00',
      'seats_count': _seatsCount,
      'payment_responsibility':
          _paymentResponsibility == PaymentResponsibility.creatorPays
              ? 'creator_only'
              : 'split',
      'additional_passengers': additionalPassengers,
    };

    return payload;
  }

  Map<String, dynamic> buildTripDataPayload() => buildCreatePayload();

  Future<bool> requestFare() async {
    if (!validateTripForm()) return false;
    if (_isLoadingFare) return false;

    _isLoadingFare = true;
    update();

    final payload = buildEstimatePayload();
    if (kDebugMode) {
      log('====> [ScheduledRide] Estimate Request: $payload');
    }

    final response = await specialTripService.estimateScheduledRide(payload);
    _isLoadingFare = false;

    if (response.statusCode == 200 && response.body?['data'] != null) {
      if (kDebugMode) {
        log('====> [ScheduledRide] Estimate Response: ${response.body['data']}');
      }
      _fareModel = SpecialTripFareModel.fromJson(response.body['data']);
      update();
      return true;
    } else {
      if (kDebugMode) {
        log('====> [ScheduledRide] Estimate Error [${response.statusCode}]: ${response.statusText} / ${response.body}');
      }
      ApiChecker.checkApi(response);
      update();
      return false;
    }
  }

  Future<bool> confirmAndCreateRequest() async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    update();

    final payload = buildCreatePayload();
    if (kDebugMode) {
      log('====> [ScheduledRide] Create Request: $payload');
    }

    final response = await specialTripService.createScheduledRide(payload);
    _isSubmitting = false;

    if (response.statusCode == 200 && response.body?['data'] != null) {
      if (kDebugMode) {
        log('====> [ScheduledRide] Create Response: ${response.body['data']}');
      }

      // Build local fallback trip containing all validated user choices
      final localTrip = SpecialTripRequestModel(
        id: '',
        pickupPoints: _pickupPoints,
        destinationPoints: _destinationPoints,
        startDate: _startDate,
        endDate: _endDate,
        operatingWeekdays: _selectedWeekdays.toList(),
        outboundTime: _startTime,
        hasReturnRide: _hasReturnRide,
        returnTime: _hasReturnRide ? _returnTime : null,
        seatsCount: _seatsCount,
        passengers: _passengers,
        paymentResponsibility: _paymentResponsibility,
        fare: _fareModel,
        activeDates: activeOperatingDates,
      );

      final Map<String, dynamic> responseData =
          (response.body['data'] is Map<String, dynamic>)
              ? response.body['data']
              : <String, dynamic>{};

      final createdTrip = SpecialTripRequestModel.fromJson(
        responseData,
        fallback: localTrip,
      );

      // Preserve passenger names from local list if backend returns empty names
      final mergedPassengers = <SpecialTripPassengerModel>[];
      for (var p in createdTrip.passengers) {
        final localMatch = _passengers.firstWhereOrNull((lp) =>
            SpecialTripPassengerModel.formatPhoneNumber(lp.phone) ==
            SpecialTripPassengerModel.formatPhoneNumber(p.phone));
        if (localMatch != null &&
            (p.name.isEmpty || p.name.startsWith('Passenger '))) {
          mergedPassengers.add(p.copyWith(
              name: localMatch.name, isCurrentUser: localMatch.isCurrentUser));
        } else {
          mergedPassengers.add(p);
        }
      }

      _currentTrip = createdTrip.copyWith(
        startDate: createdTrip.startDate,
        endDate: createdTrip.endDate,
        seatsCount:
            createdTrip.seatsCount > 0 ? createdTrip.seatsCount : _seatsCount,
        operatingWeekdays: createdTrip.operatingWeekdays.isNotEmpty
            ? createdTrip.operatingWeekdays
            : _selectedWeekdays.toList(),
        activeDates: createdTrip.activeDates.isNotEmpty
            ? createdTrip.activeDates
            : activeOperatingDates,
        outboundTime: createdTrip.outboundTime,
        hasReturnRide: _hasReturnRide || createdTrip.hasReturnRide,
        returnTime:
            createdTrip.returnTime ?? (_hasReturnRide ? _returnTime : null),
        paymentResponsibility: createdTrip.paymentResponsibility,
        passengers:
            mergedPassengers.isNotEmpty ? mergedPassengers : _passengers,
        fare: createdTrip.fare ?? _fareModel,
        pickupPoints: createdTrip.pickupPoints.isNotEmpty
            ? createdTrip.pickupPoints
            : _pickupPoints,
        destinationPoints: createdTrip.destinationPoints.isNotEmpty
            ? createdTrip.destinationPoints
            : _destinationPoints,
      );

      if (_currentTrip?.status == SpecialTripStatus.waitingForPayment ||
          _currentTrip?.status == SpecialTripStatus.accepted) {
        if (_currentTrip?.paymentExpiresAt != null) {
          startPaymentCountdown(_currentTrip!.paymentExpiresAt!);
        }
      }

      update();
      return true;
    } else {
      if (kDebugMode) {
        log('====> [ScheduledRide] Create Error [${response.statusCode}]: ${response.statusText} / ${response.body}');
      }
      ApiChecker.checkApi(response);
      update();
      return false;
    }
  }

  // --- Request Details & Lifecycle Management ---
  void setTrip(SpecialTripRequestModel trip) {
    if (_currentTrip != null) {
      _currentTrip = trip.copyWith(
        startDate: trip.startDate,
        endDate: trip.endDate,
        seatsCount:
            trip.seatsCount > 0 ? trip.seatsCount : _currentTrip!.seatsCount,
        operatingWeekdays: trip.operatingWeekdays.isNotEmpty
            ? trip.operatingWeekdays
            : _currentTrip!.operatingWeekdays,
        activeDates: trip.activeDates.isNotEmpty
            ? trip.activeDates
            : _currentTrip!.activeDates,
        passengers: trip.passengers.isNotEmpty
            ? trip.passengers
            : _currentTrip!.passengers,
        pickupPoints: trip.pickupPoints.isNotEmpty
            ? trip.pickupPoints
            : _currentTrip!.pickupPoints,
        destinationPoints: trip.destinationPoints.isNotEmpty
            ? trip.destinationPoints
            : _currentTrip!.destinationPoints,
        fare: trip.fare ?? _currentTrip!.fare,
      );
    } else {
      _currentTrip = trip;
    }
    if (_currentTrip?.status == SpecialTripStatus.waitingForPayment ||
        _currentTrip?.status == SpecialTripStatus.accepted) {
      if (_currentTrip?.paymentExpiresAt != null) {
        startPaymentCountdown(_currentTrip!.paymentExpiresAt!);
      }
    }
    update();
  }

  void simulateDriverAcceptance() {
    if (_currentTrip == null) return;
    _currentTrip!.status = SpecialTripStatus.accepted;
    _currentTrip!.driver = SpecialTripDriverModel(
      id: 'drv_101',
      name: 'Captain Ahmed Mostafa',
      phone: '+20 100 234 5678',
      rating: 4.95,
      vehicleName: 'Hyundai Elantra - Silver',
      licensePlate: 'ABC 5678',
      latitude: (_currentTrip!.pickupPoints.isNotEmpty)
          ? _currentTrip!.pickupPoints.first.latitude
          : 30.0444,
      longitude: (_currentTrip!.pickupPoints.isNotEmpty)
          ? _currentTrip!.pickupPoints.first.longitude
          : 31.2357,
    );
    // 30-minute countdown starts from driver acceptance
    final expiresAt = DateTime.now().add(const Duration(minutes: 30));
    _currentTrip!.paymentExpiresAt = expiresAt;
    _currentTrip!.status = SpecialTripStatus.waitingForPayment;
    startPaymentCountdown(expiresAt);
    update();
    showCustomSnackBar(
        'Driver accepted your trip! Complete payment within 30 minutes.',
        isError: false);
  }

  void startPaymentCountdown(DateTime expiresAt) {
    _countdownTimer?.cancel();
    _updateRemainingTime(expiresAt);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime(expiresAt);
    });
  }

  void _updateRemainingTime(DateTime expiresAt) {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) {
      _remainingPaymentDuration = Duration.zero;
      _countdownTimer?.cancel();
      if (_currentTrip != null &&
          (_currentTrip!.status == SpecialTripStatus.waitingForPayment ||
              _currentTrip!.status == SpecialTripStatus.accepted)) {
        _currentTrip!.status = SpecialTripStatus.expired;
      }
      update();
    } else {
      _remainingPaymentDuration = expiresAt.difference(now);
      update();
    }
  }

  String get formattedCountdown {
    final minutes = _remainingPaymentDuration.inMinutes;
    final seconds = _remainingPaymentDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- Paymob Flow ---
  Future<void> initiatePayment({BuildContext? context}) async {
    if (_currentTrip == null || _isProcessingPayment) return;

    if (_remainingPaymentDuration <= Duration.zero &&
        _currentTrip!.paymentExpiresAt != null &&
        DateTime.now().isAfter(_currentTrip!.paymentExpiresAt!)) {
      showCustomSnackBar('payment_window_expired'.tr.isNotEmpty &&
              'payment_window_expired'.tr != 'payment_window_expired'
          ? 'payment_window_expired'.tr
          : 'Payment window has expired.');
      return;
    }

    _isProcessingPayment = true;
    update();

    try {
      final tripId = _currentTrip!.id;
      final double fareAmount =
          (_currentTrip!.fare?.totalFare ?? _currentTrip!.estimatedFare ?? 0.0)
              .toDouble();

      if (kDebugMode) {
        log('====> [ScheduledRide] Paymob Intent Request (University Carpool endpoint): tripId = $tripId, amount = $fareAmount');
      }

      PaymobSDKIntentModel? sdkIntent;
      if (Get.isRegistered<RideController>()) {
        try {
          sdkIntent = await Get.find<RideController>().getPaymobIntent(
            tripRequestId: tripId,
            amount: fareAmount > 0 ? fareAmount : 100.0,
            selectedDuration: '1_month',
          );
        } catch (e) {
          if (kDebugMode) {
            log('====> [ScheduledRide] getPaymobIntent error: $e');
          }
        }
      }

      if (sdkIntent == null ||
          (sdkIntent.clientSecret == null && sdkIntent.secretKey == null)) {
        final response =
            await specialTripService.createScheduledRidePaymobIntent(
          tripId,
          amount: fareAmount > 0 ? fareAmount : null,
        );
        if (response.statusCode == 200 && response.body?['data'] != null) {
          final intentData = response.body['data'];
          final intentModel = PaymobIntentResponse.fromJson(
            intentData is Map
                ? Map<String, dynamic>.from(intentData)
                : response.body,
          );
          sdkIntent = PaymobSDKIntentModel(
            clientSecret: intentModel.clientSecret ?? intentModel.secretKey,
            publicKey: intentModel.publicKey ?? '',
            secretKey: intentModel.secretKey,
            currency: intentModel.currency ?? 'EGP',
            amount: intentModel.amountCents != null
                ? (intentModel.amountCents! / 100.0)
                : fareAmount,
          );
        }
      }

      if (sdkIntent == null ||
          (sdkIntent.clientSecret == null && sdkIntent.secretKey == null)) {
        showCustomSnackBar('failed_to_retrieve_payment_intent'.tr.isNotEmpty &&
                'failed_to_retrieve_payment_intent'.tr !=
                    'failed_to_retrieve_payment_intent'
            ? 'failed_to_retrieve_payment_intent'.tr
            : 'Failed to retrieve payment intent from backend.');
        return;
      }

      bool paymentLaunched = true;
      dynamic paymentResult;

      if (context != null && !context.mounted) return;
      final effectiveContext = (context != null && context.mounted)
          ? context
          : (Get.context ?? Get.key.currentContext);

      if (effectiveContext != null) {
        if (kDebugMode) {
          log('====> [ScheduledRide] Launching Native Paymob SDK for trip $tripId');
        }
        paymentResult = await PaymobSdkService.startPayment(
          context: effectiveContext,
          intent: sdkIntent,
        );
        if (kDebugMode) {
          log('====> [ScheduledRide] Paymob Native Result: $paymentResult');
        }
      }

      if (paymentLaunched) {
        bool isPaymentSuccess = false;
        String? paymentErrorMsg;

        if (paymentResult != null) {
          try {
            if (paymentResult is PaymobPaymentResult) {
              if (paymentResult.status == PaymentStatus.successful) {
                isPaymentSuccess = true;
              } else if (paymentResult.status == PaymentStatus.rejected) {
                paymentErrorMsg = paymentResult.errorMessage ??
                    'Payment was declined or rejected.';
              } else if (paymentResult.status == PaymentStatus.unknown &&
                  paymentResult.errorMessage != null &&
                  paymentResult.errorMessage!
                      .toLowerCase()
                      .contains('cancel')) {
                paymentErrorMsg =
                    paymentResult.errorMessage ?? 'Payment was cancelled.';
              }
            }
          } catch (_) {}

          if (!isPaymentSuccess) {
            try {
              final String statusStr =
                  paymentResult.status?.toString().toLowerCase() ?? '';
              if (statusStr.contains('success') ||
                  statusStr == 'true' ||
                  paymentResult.status == true) {
                isPaymentSuccess = true;
              }
            } catch (_) {}
          }

          if (!isPaymentSuccess && paymentResult is Map) {
            if (paymentResult['status'] == true ||
                paymentResult['success'] == true ||
                paymentResult['hmac_valid'] == true) {
              isPaymentSuccess = true;
            }
          }

          if (paymentErrorMsg == null) {
            try {
              if (paymentResult.errorMessage != null &&
                  paymentResult.errorMessage.toString().trim().isNotEmpty) {
                paymentErrorMsg = paymentResult.errorMessage.toString();
              } else if (paymentResult is Map &&
                  paymentResult['message'] != null) {
                paymentErrorMsg = paymentResult['message'].toString();
              }
            } catch (_) {}
          }
        }

        if (kDebugMode) {
          log('====> [ScheduledRide] Verifying payment status from backend for trip: $tripId (with retry polling)');
        }
        final pollResult = await _pollVerifyPaymentStatus(
          tripId,
          initialConfirmed: isPaymentSuccess,
        );
        final bool isConfirmedPaid = pollResult.isConfirmed;
        final String? backendRouteTitle = pollResult.routeTitle;
        final int? backendAmount = pollResult.amount;

        if (isPaymentSuccess || isConfirmedPaid) {
          _countdownTimer?.cancel();
          _currentTrip!.status = SpecialTripStatus.confirmed;
          for (int i = 0; i < _currentTrip!.passengers.length; i++) {
            _currentTrip!.passengers[i] = _currentTrip!.passengers[i].copyWith(
              paymentStatus: PassengerPaymentStatus.paid,
            );
          }
          showCustomSnackBar('payment_successful_trip_confirmed'.tr,
              isError: false);
          update();

          if (Get.isRegistered<RideController>()) {
            Get.find<RideController>().getRideDetails(tripId);
          }
          if (Get.isRegistered<TripController>()) {
            Get.find<TripController>().getTripList(1, reload: true);
          }

          String effectiveRouteTitle = backendRouteTitle ?? '';
          if (effectiveRouteTitle.isEmpty && _currentTrip != null) {
            final from = _currentTrip!.pickupPoints.isNotEmpty
                ? (_currentTrip!.pickupPoints.first.address.isNotEmpty
                    ? _currentTrip!.pickupPoints.first.address
                    : _currentTrip!.pickupPoints.first.name)
                : '';
            final to = _currentTrip!.destinationPoints.isNotEmpty
                ? (_currentTrip!.destinationPoints.first.address.isNotEmpty
                    ? _currentTrip!.destinationPoints.first.address
                    : _currentTrip!.destinationPoints.first.name)
                : '';
            if (from.isNotEmpty && to.isNotEmpty) {
              effectiveRouteTitle = '$from → $to';
            } else if (from.isNotEmpty) {
              effectiveRouteTitle = from;
            } else if (to.isNotEmpty) {
              effectiveRouteTitle = to;
            }
          }
          if (effectiveRouteTitle.isEmpty) {
            effectiveRouteTitle = 'Carpool Trip';
          }

          final int effectiveAmount = (_currentTrip?.fare?.totalFare ??
                  _currentTrip?.estimatedFare ??
                  backendAmount ??
                  0)
              .round();

          if (context != null && !context.mounted) return;
          final sheetContext = (context != null && context.mounted)
              ? context
              : (Get.context ?? Get.key.currentContext);

          if (sheetContext != null && sheetContext.mounted) {
            CarpoolPaymentSuccessBottomSheet.show(
              context: sheetContext,
              tripId: tripId,
              routeTitle: effectiveRouteTitle,
              amount: effectiveAmount,
              paymentMethod: 'VISA / MasterCard',
            );
          }
        } else if (paymentErrorMsg != null) {
          showCustomSnackBar(paymentErrorMsg);
        } else {
          showCustomSnackBar(
              'payment_verification_pending'.tr.isNotEmpty &&
                      'payment_verification_pending'.tr !=
                          'payment_verification_pending'
                  ? 'payment_verification_pending'.tr
                  : 'Payment submitted. Updating status...',
              isError: false);
          if (Get.isRegistered<RideController>()) {
            Get.find<RideController>().getRideDetails(tripId);
          }
          if (Get.isRegistered<TripController>()) {
            Get.find<TripController>().getTripList(1, reload: true);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        log('====> [ScheduledRide] Paymob Exception: $e');
      }
      showCustomSnackBar('Payment error: $e');
    } finally {
      _isProcessingPayment = false;
      update();
    }
  }

  Future<void> payForTrip(
    String tripId, {
    BuildContext? context,
    String? routeTitle,
    int? amount,
    String paymentMethod = 'VISA / MasterCard',
  }) async {
    if (_isProcessingPayment) return;
    _isProcessingPayment = true;
    update();

    try {
      if (kDebugMode) {
        log('====> [ScheduledRide] Paymob Intent Request (University Carpool endpoint) for tripId: $tripId, amount: $amount');
      }

      final double effectiveAmount = (amount != null && amount > 0)
          ? amount.toDouble()
          : (_currentTrip?.fare?.totalFare ??
                  _currentTrip?.estimatedFare ??
                  100.0)
              .toDouble();

      PaymobSDKIntentModel? sdkIntent;
      if (Get.isRegistered<RideController>()) {
        try {
          sdkIntent = await Get.find<RideController>().getPaymobIntent(
            tripRequestId: tripId,
            amount: effectiveAmount,
            selectedDuration: '1_month',
          );
        } catch (e) {
          if (kDebugMode) {
            log('====> [ScheduledRide] getPaymobIntent error: $e');
          }
        }
      }

      if (sdkIntent == null ||
          (sdkIntent.clientSecret == null && sdkIntent.secretKey == null)) {
        final response =
            await specialTripService.createScheduledRidePaymobIntent(
          tripId,
          amount: effectiveAmount > 0 ? effectiveAmount : null,
        );
        if (response.statusCode == 200 && response.body?['data'] != null) {
          final intentData = response.body['data'];
          final intentModel = PaymobIntentResponse.fromJson(
            intentData is Map
                ? Map<String, dynamic>.from(intentData)
                : response.body,
          );
          sdkIntent = PaymobSDKIntentModel(
            clientSecret: intentModel.clientSecret ?? intentModel.secretKey,
            publicKey: intentModel.publicKey ?? '',
            secretKey: intentModel.secretKey,
            currency: intentModel.currency ?? 'EGP',
            amount: intentModel.amountCents != null
                ? (intentModel.amountCents! / 100.0)
                : effectiveAmount,
          );
        }
      }

      if (sdkIntent == null ||
          (sdkIntent.clientSecret == null && sdkIntent.secretKey == null)) {
        showCustomSnackBar('failed_to_retrieve_payment_intent'.tr.isNotEmpty &&
                'failed_to_retrieve_payment_intent'.tr !=
                    'failed_to_retrieve_payment_intent'
            ? 'failed_to_retrieve_payment_intent'.tr
            : 'Failed to retrieve payment intent from backend.');
        return;
      }

      bool paymentLaunched = true;
      dynamic paymentResult;

      if (context != null && !context.mounted) return;
      final effectiveContext = (context != null && context.mounted)
          ? context
          : (Get.context ?? Get.key.currentContext);

      if (effectiveContext != null) {
        if (kDebugMode) {
          log('====> [ScheduledRide] Launching Native Paymob SDK for trip $tripId');
        }
        paymentResult = await PaymobSdkService.startPayment(
          context: effectiveContext,
          intent: sdkIntent,
        );
        if (kDebugMode) {
          log('====> [ScheduledRide] Paymob Native Result: $paymentResult');
        }
      }

      if (paymentLaunched) {
        bool isPaymentSuccess = false;
        String? paymentErrorMsg;

        if (paymentResult != null) {
          try {
            if (paymentResult is PaymobPaymentResult) {
              if (paymentResult.status == PaymentStatus.successful) {
                isPaymentSuccess = true;
              } else if (paymentResult.status == PaymentStatus.rejected) {
                paymentErrorMsg = paymentResult.errorMessage ??
                    'Payment was declined or rejected.';
              } else if (paymentResult.status == PaymentStatus.unknown &&
                  paymentResult.errorMessage != null &&
                  paymentResult.errorMessage!
                      .toLowerCase()
                      .contains('cancel')) {
                paymentErrorMsg =
                    paymentResult.errorMessage ?? 'Payment was cancelled.';
              }
            }
          } catch (_) {}

          if (!isPaymentSuccess) {
            try {
              final String statusStr =
                  paymentResult.status?.toString().toLowerCase() ?? '';
              if (statusStr.contains('success') ||
                  statusStr == 'true' ||
                  paymentResult.status == true) {
                isPaymentSuccess = true;
              }
            } catch (_) {}
          }

          if (!isPaymentSuccess && paymentResult is Map) {
            if (paymentResult['status'] == true ||
                paymentResult['success'] == true ||
                paymentResult['hmac_valid'] == true) {
              isPaymentSuccess = true;
            }
          }

          if (paymentErrorMsg == null) {
            try {
              if (paymentResult.errorMessage != null &&
                  paymentResult.errorMessage.toString().trim().isNotEmpty) {
                paymentErrorMsg = paymentResult.errorMessage.toString();
              } else if (paymentResult is Map &&
                  paymentResult['message'] != null) {
                paymentErrorMsg = paymentResult['message'].toString();
              }
            } catch (_) {}
          }
        }

        if (kDebugMode) {
          log('====> [ScheduledRide] Verifying payment status from backend for trip: $tripId (with retry polling)');
        }
        final pollResult = await _pollVerifyPaymentStatus(
          tripId,
          initialConfirmed: isPaymentSuccess,
        );
        final bool isConfirmed = pollResult.isConfirmed;
        final String? backendRouteTitle = pollResult.routeTitle;
        final int? backendAmount = pollResult.amount;

        if (isPaymentSuccess || isConfirmed) {
          showCustomSnackBar('payment_successful_trip_confirmed'.tr,
              isError: false);
          update();

          if (Get.isRegistered<RideController>()) {
            Get.find<RideController>().getRideDetails(tripId);
          }
          if (Get.isRegistered<TripController>()) {
            Get.find<TripController>().getTripList(1, reload: true);
          }

          final String effectiveRouteTitle = (routeTitle != null &&
                  routeTitle.trim().isNotEmpty)
              ? routeTitle.trim()
              : (backendRouteTitle != null &&
                      backendRouteTitle.trim().isNotEmpty)
                  ? backendRouteTitle.trim()
                  : (_currentTrip != null
                      ? (_currentTrip!.pickupPoints.isNotEmpty &&
                              _currentTrip!.destinationPoints.isNotEmpty
                          ? '${_currentTrip!.pickupPoints.first.address} → ${_currentTrip!.destinationPoints.first.address}'
                          : 'Carpool Trip')
                      : 'Carpool Trip');

          final int effectiveAmount = (amount != null && amount > 0)
              ? amount
              : (backendAmount != null && backendAmount > 0)
                  ? backendAmount
                  : (_currentTrip?.fare?.totalFare ??
                          _currentTrip?.estimatedFare ??
                          0)
                      .round();

          if (context != null && !context.mounted) return;
          final sheetContext = (context != null && context.mounted)
              ? context
              : (Get.context ?? Get.key.currentContext);

          if (sheetContext != null && sheetContext.mounted) {
            CarpoolPaymentSuccessBottomSheet.show(
              context: sheetContext,
              tripId: tripId,
              routeTitle: effectiveRouteTitle,
              amount: effectiveAmount,
              paymentMethod: paymentMethod,
            );
          }
        } else if (paymentErrorMsg != null) {
          showCustomSnackBar(paymentErrorMsg);
        } else {
          showCustomSnackBar(
              'payment_verification_pending'.tr.isNotEmpty &&
                      'payment_verification_pending'.tr !=
                          'payment_verification_pending'
                  ? 'payment_verification_pending'.tr
                  : 'Payment submitted. Updating status...',
              isError: false);
          if (Get.isRegistered<RideController>()) {
            Get.find<RideController>().getRideDetails(tripId);
          }
          if (Get.isRegistered<TripController>()) {
            Get.find<TripController>().getTripList(1, reload: true);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        log('====> [ScheduledRide] payForTrip Exception: $e');
      }
      showCustomSnackBar('Payment error: $e');
    } finally {
      _isProcessingPayment = false;
      update();
    }
  }

  /// Public poll verify payment method for external callers (e.g. CarpoolTripDetailsCard)
  Future<({bool isConfirmed, String? routeTitle, int? amount})>
      pollVerifyPayment(String tripId, {bool initialConfirmed = false}) async {
    return await _pollVerifyPaymentStatus(tripId,
        initialConfirmed: initialConfirmed);
  }

  /// Fetches trip details from the backend and updates _currentTrip
  Future<void> fetchTripDetails(String tripId) async {
    try {
      final response = await specialTripService.getSpecialTripDetails(tripId);
      if (response.statusCode == 200 && response.body != null) {
        if (response.body is Map) {
          final tripModel = SpecialTripRequestModel.fromJson(
            Map<String, dynamic>.from(response.body),
            fallback: _currentTrip,
          );
          _currentTrip = tripModel;
          update();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        log('====> [ScheduledRide] fetchTripDetails error: $e');
      }
    }
  }

  /// Helper to poll and verify payment status from backend across 5 retry attempts.
  /// Allows the Paymob asynchronous webhook to reach the server and set payment_status to 'paid'.
  Future<({bool isConfirmed, String? routeTitle, int? amount})>
      _pollVerifyPaymentStatus(String tripId,
          {bool initialConfirmed = false}) async {
    bool isConfirmed = initialConfirmed;
    String? backendRouteTitle;
    int? backendAmount;

    for (int attempt = 0; attempt < 5; attempt++) {
      if (attempt > 0) {
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      try {
        final verifyResponse =
            await specialTripService.verifyPaymentStatus(tripId);

        if (kDebugMode) {
          log('====> [ScheduledRide] Verify Attempt ${attempt + 1}: status=${verifyResponse.statusCode}, body=${verifyResponse.body}');
        }

        if (verifyResponse.statusCode == 200 && verifyResponse.body != null) {
          final dynamic rawData = verifyResponse.body['content'] ??
              verifyResponse.body['data'] ??
              verifyResponse.body;
          if (rawData is Map) {
            final data = Map<String, dynamic>.from(rawData);
            final pStatus = (data['payment_status'] ?? data['status'])
                ?.toString()
                .toLowerCase();
            final isPaid = data['is_paid'] == true ||
                data['is_paid'] == 1 ||
                data['is_paid'] == '1';
            final paidFare = (data['paid_fare'] as num?)?.toDouble() ?? 0.0;
            if (pStatus == 'paid' ||
                pStatus == 'confirmed' ||
                pStatus == 'completed' ||
                pStatus == 'approved' ||
                pStatus == 'success' ||
                data['payment_status'] == 'paid' ||
                isPaid ||
                paidFare > 0) {
              isConfirmed = true;
            }

            if (data['route_name'] != null &&
                data['route_name'].toString().trim().isNotEmpty) {
              backendRouteTitle = data['route_name'].toString().trim();
            } else if (data['title'] != null &&
                data['title'].toString().trim().isNotEmpty) {
              backendRouteTitle = data['title'].toString().trim();
            }

            final fareVal = data['paid_fare'] ??
                data['actual_fare'] ??
                data['estimated_fare'] ??
                data['fare'] ??
                data['total_fare'];
            if (fareVal is num && fareVal > 0) {
              backendAmount = fareVal.round();
            }
          }

          try {
            if (verifyResponse.body is Map) {
              final tripModel = TripDetailsModel.fromJson(
                      Map<String, dynamic>.from(verifyResponse.body))
                  .data;
              if (tripModel != null) {
                final statusStr = tripModel.paymentStatus?.toLowerCase() ?? '';
                if (statusStr == 'paid' ||
                    statusStr == 'confirmed' ||
                    statusStr == 'completed' ||
                    statusStr == 'approved' ||
                    statusStr == 'success' ||
                    (tripModel.paidFare != null && tripModel.paidFare! > 0)) {
                  isConfirmed = true;
                }
                if (backendRouteTitle == null &&
                    tripModel.routeNameDisplay.isNotEmpty) {
                  backendRouteTitle = tripModel.routeNameDisplay;
                }
                if (backendAmount == null &&
                    tripModel.paidFare != null &&
                    tripModel.paidFare! > 0) {
                  backendAmount = tripModel.paidFare!.round();
                }
              }
            }
          } catch (_) {}
        }
      } catch (e) {
        if (kDebugMode) {
          log('====> [ScheduledRide] Verify Attempt ${attempt + 1} exception: $e');
        }
      }

      if (isConfirmed) {
        if (kDebugMode) {
          log('====> [ScheduledRide] Payment successfully verified as PAID on attempt ${attempt + 1}!');
        }
        break;
      }
    }

    return (
      isConfirmed: isConfirmed,
      routeTitle: backendRouteTitle,
      amount: backendAmount,
    );
  }
}
