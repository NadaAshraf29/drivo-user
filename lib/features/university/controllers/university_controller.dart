import 'dart:io';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/available_trips/controllers/available_trips_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import '../domain/models/university_active_trip_model.dart';
import '../domain/models/university_config_model.dart';
import '../domain/models/university_pickup_point_model.dart';
import '../domain/models/university_search_request.dart';
import '../domain/models/university_subscribe_request.dart';
import '../domain/models/university_subscription_model.dart';
import '../domain/models/university_trip_model.dart';
import '../domain/services/university_service_interface.dart';

class UniversityController extends GetxController implements GetxService {
  final UniversityServiceInterface universityService;

  UniversityController({required this.universityService});

  @override
  void onInit() {
    super.onInit();
    getUniversityConfig();
    getActiveTrip();
  }

  bool _isLoading = false;
  bool _isSearching = false;
  bool _isSubscribing = false;
  bool _isLoadingPickupPoints = false;
  bool _isLoadingActiveTrip = false;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isSubscribing => _isSubscribing;
  bool get isLoadingPickupPoints => _isLoadingPickupPoints;
  bool get isLoadingActiveTrip => _isLoadingActiveTrip;

  List<UniversityItem> _universities = [];
  List<UniversityPickupPointItem> _configPickupPoints = [];
  List<UniversityTripModel> _matchingTrips = [];
  List<UniversityTripModel> _availableRides = [];
  List<UniversityPickupPointModel> _availablePickupPoints = [];
  List<UniversitySubscriptionModel> _mySubscriptions = [];
  UniversityActiveTripModel? _activeTrip;

  List<UniversityItem> get universities => _universities;
  List<UniversityPickupPointItem> get configPickupPoints => _configPickupPoints;
  List<UniversityTripModel> get matchingTrips => _matchingTrips;
  List<UniversityTripModel> get availableRides => _availableRides;
  List<UniversityPickupPointModel> get availablePickupPoints =>
      _availablePickupPoints;
  List<UniversitySubscriptionModel> get mySubscriptions => _mySubscriptions;
  UniversityActiveTripModel? get activeTrip => _activeTrip;

  UniversityTripModel? _selectedTrip;
  UniversityTripModel? get selectedTrip => _selectedTrip;

  UniversitySearchRequest? _lastSearchRequest;
  UniversitySearchRequest? get lastSearchRequest => _lastSearchRequest;

  String _selectedPickupPoint = '';
  String get selectedPickupPoint => _selectedPickupPoint;

  String _selectedDuration = 'monthly';
  String get selectedDuration => _selectedDuration;

  String _selectedPaymentMethod = 'instapay';
  String get selectedPaymentMethod => _selectedPaymentMethod;

  File? _receiptImage;
  File? get receiptImage => _receiptImage;

  void setSelectedTrip(UniversityTripModel trip) {
    _selectedTrip = trip;
    _selectedPickupPoint = trip.pickupPoint;
    update();
  }

  void setSelectedPickupPoint(String point) {
    _selectedPickupPoint = point;
    update();
  }

  void setSelectedDuration(String duration) {
    _selectedDuration = duration;
    update();
  }

  void setSelectedPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    update();
  }

  void setReceiptImage(File? image) {
    _receiptImage = image;
    update();
  }

  Future<void> getUniversityConfig({bool reload = false}) async {
    // if (_universities.isNotEmpty && !reload) return;

    _isLoading = true;
    update();

    try {
      Response response = await universityService.getUniversityConfig();
      if (response.statusCode == 200 && response.body != null) {
        final content =
            response.body['content'] ?? response.body['data'] ?? response.body;
        if (content is Map<String, dynamic> &&
            ((content['universities'] is List &&
                    (content['universities'] as List).isNotEmpty) ||
                (content['pickup_points'] is List &&
                    (content['pickup_points'] as List).isNotEmpty))) {
          final config = UniversityConfigModel.fromJson(content);
          _universities = config.universities;
          _configPickupPoints = config.pickupPoints;
        }
      }
    } catch (e) {
      customPrint('getUniversityConfig error: $e');
    }

    try {
      List<PoolRide> rides = [];
      if (Get.isRegistered<AvailableTripsController>()) {
        final availableTripsCtrl = Get.find<AvailableTripsController>();
        if (availableTripsCtrl.availableTrips.isEmpty) {
          await availableTripsCtrl.getAvailableTrips();
        }
        rides = availableTripsCtrl.availableTrips;
      }

      final universityRides = rides.where((ride) {
        final type = (ride.carpoolType ?? '').toLowerCase();
        final label = (ride.carpoolTypeLabel ?? '').toLowerCase();
        final labelAr = ride.carpoolTypeLabelAr ?? '';
        return type == 'university' ||
            label.contains('university') ||
            labelAr.contains('جامعة');
      }).toList();

      if (universityRides.isNotEmpty) {
        _extractUniversitiesFromRides(universityRides);
        _availableRides = universityRides
            .map((r) => UniversityTripModel.fromPoolRide(r))
            .toList();
      } else {
        _availableRides = [];
      }
    } catch (e) {
      customPrint('Error extracting university trips: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  void _extractUniversitiesFromRides(List<PoolRide> rides) {
    final Map<String, Set<String>> uniPickupMap = {};

    for (var ride in rides) {
      String uni = ride.dropoffAddress.trim();
      if (uni.isEmpty && ride.title != null) {
        uni = ride.title!.trim();
      }
      if (uni.isEmpty) continue;

      if (!uniPickupMap.containsKey(uni)) {
        uniPickupMap[uni] = {};
      }

      final pickup = (ride.boardingPointStart != null &&
              ride.boardingPointStart!.name.trim().isNotEmpty)
          ? ride.boardingPointStart!.name.trim()
          : ride.pickupAddress.trim();
      if (pickup.isNotEmpty) {
        uniPickupMap[uni]!.add(pickup);
      }
    }

    uniPickupMap.forEach((uniName, pickups) {
      final existingIndex = _universities.indexWhere((u) =>
          u.name.toLowerCase() == uniName.toLowerCase() ||
          (u.nameAr != null &&
              u.nameAr!.toLowerCase() == uniName.toLowerCase()));

      if (existingIndex >= 0) {
        final existing = _universities[existingIndex];
        final existingPoints = existing.pickupPoints.map((p) => p.name).toSet();
        List<UniversityPickupPointItem> updatedList =
            List.from(existing.pickupPoints);

        for (var p in pickups) {
          if (!existingPoints.contains(p)) {
            updatedList.add(UniversityPickupPointItem(
              id: 'p_${updatedList.length + 1}_${p.hashCode}',
              name: p,
              nameAr: p,
              universityId: existing.id,
            ));
          }
        }

        _universities[existingIndex] = UniversityItem(
          id: existing.id,
          name: existing.name,
          nameAr: existing.nameAr,
          pickupPoints: updatedList,
        );
      } else {
        _universities.add(UniversityItem(
          id: 'uni_${_universities.length + 1}_${uniName.hashCode}',
          name: uniName,
          nameAr: uniName,
          pickupPoints: pickups
              .map((p) => UniversityPickupPointItem(
                    id: 'p_${p.hashCode}',
                    name: p,
                    nameAr: p,
                    universityId: 'uni_${_universities.length + 1}',
                  ))
              .toList(),
        ));
      }
    });

    _configPickupPoints = _universities.expand((u) => u.pickupPoints).toList();
  }

  List<String> getAvailableUniversities() {
    final isArabic = Get.locale?.languageCode == 'ar';
    return _universities
        .map((u) => (isArabic && u.nameAr != null && u.nameAr!.isNotEmpty)
            ? u.nameAr!
            : u.name)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> getPickupPointsForUniversity(String universityName) {
    if (universityName.isEmpty) return [];

    final normalizedSearch = universityName.trim().toLowerCase();

    // 1. Try matching with configured universities
    for (var u in _universities) {
      final nameLower = u.name.toLowerCase();
      final nameAr = (u.nameAr ?? '').toLowerCase();

      bool isMatch = nameLower == normalizedSearch ||
          nameAr == normalizedSearch ||
          normalizedSearch.contains(nameLower) ||
          nameLower.contains(normalizedSearch) ||
          (nameAr.isNotEmpty && normalizedSearch.contains(nameAr)) ||
          (nameAr.isNotEmpty && nameAr.contains(normalizedSearch));

      if (isMatch && u.pickupPoints.isNotEmpty) {
        final isArabic = Get.locale?.languageCode == 'ar';
        return u.pickupPoints
            .map((p) => (isArabic && p.nameAr != null && p.nameAr!.isNotEmpty)
                ? p.nameAr!
                : p.name)
            .where((name) => name.trim().isNotEmpty)
            .toSet()
            .toList();
      }
    }

    // 2. Check config pickup points by universityId or universityName
    final matchedPoints = _configPickupPoints.where((p) {
      if (p.universityName != null &&
          (p.universityName!.toLowerCase() == normalizedSearch ||
              p.universityName!.toLowerCase().contains(normalizedSearch) ||
              normalizedSearch.contains(p.universityName!.toLowerCase()))) {
        return true;
      }
      return false;
    }).toList();

    if (matchedPoints.isNotEmpty) {
      final isArabic = Get.locale?.languageCode == 'ar';
      return matchedPoints
          .map((p) => (isArabic && p.nameAr != null && p.nameAr!.isNotEmpty)
              ? p.nameAr!
              : p.name)
          .where((name) => name.trim().isNotEmpty)
          .toSet()
          .toList();
    }

    return [];
  }

  Future<bool> searchUniversityTrips(UniversitySearchRequest request) async {
    _lastSearchRequest = request;
    _isSearching = true;
    update();

    try {
      Response response = await universityService.findMatchingTrips(request);
      if (response.statusCode == 200 && response.body != null) {
        var rawList =
            response.body['content'] ?? response.body['data'] ?? response.body;
        if (rawList is List && rawList.isNotEmpty) {
          _matchingTrips = rawList
              .map((item) =>
                  UniversityTripModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _matchingTrips = _filterTripsFromAvailable(request);
        }
      } else {
        _matchingTrips = _filterTripsFromAvailable(request);
      }
    } catch (e) {
      _matchingTrips = _filterTripsFromAvailable(request);
    } finally {
      if (_matchingTrips.isNotEmpty) {
        _selectedTrip = _matchingTrips.first;
        _selectedPickupPoint = _selectedTrip!.pickupPoint;
      } else {
        _selectedTrip = null;
        _selectedPickupPoint = '';
      }
      _isSearching = false;
      update();
    }
    return true;
  }

  List<UniversityTripModel> _filterTripsFromAvailable(
      UniversitySearchRequest request) {
    if (!Get.isRegistered<AvailableTripsController>()) {
      return [];
    }

    final allRides = Get.find<AvailableTripsController>().availableTrips;
    final uniRides = allRides.where((r) {
      final type = (r.carpoolType ?? '').toLowerCase();
      final label = (r.carpoolTypeLabel ?? '').toLowerCase();
      final labelAr = r.carpoolTypeLabelAr ?? '';
      return type == 'university' ||
          label.contains('university') ||
          labelAr.contains('جامعة');
    }).toList();

    final reqUni = request.universityName.trim().toLowerCase();
    final reqPickup = request.pickupPointName.trim().toLowerCase();

    final matched = uniRides.where((ride) {
      final rideDropoff = ride.dropoffAddress.toLowerCase();
      final rideTitle = (ride.title ?? '').toLowerCase();
      final ridePickup = ride.pickupAddress.toLowerCase();

      bool matchUni = reqUni.isEmpty ||
          rideDropoff.contains(reqUni) ||
          reqUni.contains(rideDropoff) ||
          rideTitle.contains(reqUni) ||
          reqUni.contains(rideTitle);

      bool matchPickup = reqPickup.isEmpty ||
          ridePickup.contains(reqPickup) ||
          reqPickup.contains(ridePickup);

      return matchUni && matchPickup;
    }).toList();

    final resultList = matched.isNotEmpty
        ? matched
        : (reqUni.isNotEmpty
            ? uniRides.where((ride) {
                final rideDropoff = ride.dropoffAddress.toLowerCase();
                final rideTitle = (ride.title ?? '').toLowerCase();
                return rideDropoff.contains(reqUni) ||
                    reqUni.contains(rideDropoff) ||
                    rideTitle.contains(reqUni) ||
                    reqUni.contains(rideTitle);
              }).toList()
            : uniRides);

    return resultList.map((r) => UniversityTripModel.fromPoolRide(r)).toList();
  }

  Future<void> getPickupPointsForTrip(String tripId) async {
    _isLoadingPickupPoints = true;
    update();

    try {
      Response response = await universityService.getPickupPoints(tripId);
      if (response.statusCode == 200 && response.body != null) {
        var rawList =
            response.body['content'] ?? response.body['data'] ?? response.body;
        if (rawList is List && rawList.isNotEmpty) {
          _availablePickupPoints = rawList
              .map((item) => UniversityPickupPointModel.fromJson(
                  item as Map<String, dynamic>))
              .toList();
        } else {
          _availablePickupPoints = [];
          _populateFallbackPickupPoints(tripId);
        }
      } else {
        _availablePickupPoints = [];
        _populateFallbackPickupPoints(tripId);
      }
    } catch (e) {
      _availablePickupPoints = [];
      _populateFallbackPickupPoints(tripId);
    } finally {
      _isLoadingPickupPoints = false;
      update();
    }
  }

  void _populateFallbackPickupPoints(String tripId) {
    if (_availablePickupPoints.isNotEmpty) return;

    UniversityTripModel? trip;
    if (_selectedTrip != null && _selectedTrip!.id == tripId) {
      trip = _selectedTrip;
    } else {
      final match = _matchingTrips.where((t) => t.id == tripId).toList();
      if (match.isNotEmpty) {
        trip = match.first;
      } else {
        final avail = _availableRides.where((t) => t.id == tripId).toList();
        if (avail.isNotEmpty) trip = avail.first;
      }
    }

    List<UniversityPickupPointModel> points = [];

    if (trip != null) {
      if (trip.pickupPoint.isNotEmpty) {
        points.add(UniversityPickupPointModel(
          id: 'p_${trip.id}_primary',
          name: trip.pickupPoint,
          timing: trip.scheduleTime.isNotEmpty ? trip.scheduleTime : '07:30 AM',
          tag: 'Primary Stop',
          latitude: trip.pickupLatitude ?? trip.startLatitude,
          longitude: trip.pickupLongitude ?? trip.startLongitude,
        ));
      }

      final configured = getPickupPointsForUniversity(trip.toUniversity);
      int idx = 1;
      for (var cp in configured) {
        if (!points.any((p) => p.name.toLowerCase() == cp.toLowerCase())) {
          points.add(UniversityPickupPointModel(
            id: 'p_${trip.id}_$idx',
            name: cp,
            timing:
                '07:${((30 + idx * 10) % 60).toString().padLeft(2, '0')} AM',
            latitude: trip.startLatitude != null
                ? trip.startLatitude! + (idx * 0.005)
                : null,
            longitude: trip.startLongitude != null
                ? trip.startLongitude! + (idx * 0.005)
                : null,
          ));
          idx++;
        }
      }
    }

    if (points.isNotEmpty) {
      _availablePickupPoints = points;
    }
  }

  String? lastCreatedTripId;

  Future<bool> submitSubscription({
    required UniversitySubscribeRequest request,
    File? receiptImage,
  }) async {
    _isSubscribing = true;
    update();

    customPrint('Submitting University Subscription Request: ${request.toFieldsMap()}, receiptImage: ${receiptImage?.path}');

    try {
      Response response =
          await universityService.subscribeToTrip(request, receiptImage);
      _isSubscribing = false;
      update();

      customPrint('University Subscription Response Code: ${response.statusCode}');
      customPrint('University Subscription Response Body: ${response.body}');

      if (response.statusCode == 200) {
        customPrint('Subscription submitted successfully: ${response.body}');
        if (response.body != null && response.body['data'] != null) {
          final data = response.body['data'];
          if (data is Map) {
            lastCreatedTripId = (data['id'] as String?) ??
                (data['trip_request_id'] as String?) ??
                (data['ride_request_id'] as String?) ??
                (data['trip_id'] as String?);
          }
        }
        return true;
      } else {
        customPrint('Subscription failed with status ${response.statusCode}: ${response.statusText} | body: ${response.body}');
        ApiChecker.checkApi(response);
        return false;
      }
    } catch (e, s) {
      _isSubscribing = false;
      update();
      customPrint('Subscription API error: $e\n$s');
      return false;
    }
  }

  Future<void> getMySubscriptions() async {
    _isLoading = true;
    update();

    try {
      Response response = await universityService.getMySubscriptions();
      if (response.statusCode == 200 && response.body != null) {
        var rawList =
            response.body['content'] ?? response.body['data'] ?? response.body;
        if (rawList is List) {
          _mySubscriptions = rawList
              .map((item) => UniversitySubscriptionModel.fromJson(
                  item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      customPrint('Error fetching subscriptions: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> getActiveTrip() async {
    _isLoadingActiveTrip = true;
    update();

    try {
      Response response = await universityService.getActiveTrip();
      if (response.statusCode == 200 && response.body != null) {
        var content = response.body['content'] ?? response.body['data'];
        if (content is Map<String, dynamic>) {
          _activeTrip = UniversityActiveTripModel.fromJson(content);
        } else {
          _activeTrip = null;
        }
      } else {
        _activeTrip = null;
      }
    } catch (e) {
      _activeTrip = null;
    } finally {
      _isLoadingActiveTrip = false;
      update();
    }
  }
}
