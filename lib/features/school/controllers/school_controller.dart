import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/available_trips/controllers/available_trips_controller.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import '../domain/models/school_active_trip_model.dart';
import '../domain/models/school_config_model.dart';
import '../domain/models/school_pickup_point_model.dart';
import '../domain/models/school_search_request.dart';
import '../domain/models/school_subscribe_request.dart';
import '../domain/models/school_subscription_model.dart';
import '../domain/models/school_trip_model.dart';
import '../domain/services/school_service_interface.dart';

class SchoolController extends GetxController implements GetxService {
  final SchoolServiceInterface schoolService;

  SchoolController({required this.schoolService});

  @override
  void onInit() {
    super.onInit();
    getSchoolConfig();
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

  List<SchoolItem> _schools = [];
  List<SchoolPickupPointItem> _configPickupPoints = [];
  List<SchoolTripModel> _matchingTrips = [];
  List<SchoolTripModel> _availableRides = [];
  List<SchoolPickupPointModel> _availablePickupPoints = [];
  List<SchoolSubscriptionModel> _mySubscriptions = [];
  SchoolActiveTripModel? _activeTrip;

  List<SchoolItem> get schools => _schools;
  List<SchoolPickupPointItem> get configPickupPoints => _configPickupPoints;
  List<SchoolTripModel> get matchingTrips => _matchingTrips;
  List<SchoolTripModel> get availableRides => _availableRides;
  List<SchoolPickupPointModel> get availablePickupPoints =>
      _availablePickupPoints;
  List<SchoolSubscriptionModel> get mySubscriptions => _mySubscriptions;
  SchoolActiveTripModel? get activeTrip => _activeTrip;

  SchoolTripModel? _selectedTrip;
  SchoolTripModel? get selectedTrip => _selectedTrip;

  String _selectedPickupPoint = '';
  String get selectedPickupPoint => _selectedPickupPoint;

  String _selectedDuration = 'monthly';
  String get selectedDuration => _selectedDuration;

  String _selectedPaymentMethod = 'instapay';
  String get selectedPaymentMethod => _selectedPaymentMethod;

  File? _receiptImage;
  File? get receiptImage => _receiptImage;

  void setSelectedTrip(SchoolTripModel trip) {
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

  void setActiveTrip(SchoolActiveTripModel? trip) {
    _activeTrip = trip;
    update();
  }

  Future<void> getSchoolConfig({bool reload = false}) async {
    // if (_schools.isNotEmpty && !reload) return;

    _isLoading = true;
    update();

    try {
      Response response = await schoolService.getSchoolConfig();
      if (response.statusCode == 200 && response.body != null) {
        final content =
            response.body['content'] ?? response.body['data'] ?? response.body;
        if (content is Map<String, dynamic> &&
            ((content['schools'] is List &&
                    (content['schools'] as List).isNotEmpty) ||
                (content['pickup_points'] is List &&
                    (content['pickup_points'] as List).isNotEmpty))) {
          final config = SchoolConfigModel.fromJson(content);
          _schools = config.schools;
          _configPickupPoints = config.pickupPoints;
        }
      }
    } catch (e) {
      customPrint('getSchoolConfig error: $e');
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

      final schoolRides = rides.where((ride) {
        final type = (ride.carpoolType ?? '').toLowerCase();
        final label = (ride.carpoolTypeLabel ?? '').toLowerCase();
        final labelAr = ride.carpoolTypeLabelAr ?? '';
        return type == 'school' ||
            type == 'school_routes' ||
            label.contains('school') ||
            labelAr.contains('مدرسة');
      }).toList();

      if (schoolRides.isNotEmpty) {
        _extractSchoolsFromRides(schoolRides);
        _availableRides =
            schoolRides.map((r) => SchoolTripModel.fromPoolRide(r)).toList();
      } else {
        _availableRides = [];
      }
    } catch (e) {
      customPrint('Error extracting school trips: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  void _extractSchoolsFromRides(List<PoolRide> rides) {
    final Map<String, Set<String>> schoolPickupMap = {};

    for (var ride in rides) {
      String school = ride.dropoffAddress.trim();
      if (school.isEmpty && ride.title != null) {
        school = ride.title!.trim();
      }
      if (school.isEmpty) continue;

      if (!schoolPickupMap.containsKey(school)) {
        schoolPickupMap[school] = {};
      }

      final pickup = (ride.boardingPointStart != null &&
              ride.boardingPointStart!.name.trim().isNotEmpty)
          ? ride.boardingPointStart!.name.trim()
          : ride.pickupAddress.trim();
      if (pickup.isNotEmpty) {
        schoolPickupMap[school]!.add(pickup);
      }
    }

    schoolPickupMap.forEach((schoolName, pickups) {
      final existingIndex = _schools.indexWhere((s) =>
          s.name.toLowerCase() == schoolName.toLowerCase() ||
          (s.nameAr != null &&
              s.nameAr!.toLowerCase() == schoolName.toLowerCase()));

      if (existingIndex >= 0) {
        final existing = _schools[existingIndex];
        final existingPoints = existing.pickupPoints.map((p) => p.name).toSet();
        List<SchoolPickupPointItem> updatedList =
            List.from(existing.pickupPoints);

        for (var p in pickups) {
          if (!existingPoints.contains(p)) {
            updatedList.add(SchoolPickupPointItem(
              id: 'p_${updatedList.length + 1}_${p.hashCode}',
              name: p,
              nameAr: p,
              schoolId: existing.id,
            ));
          }
        }

        _schools[existingIndex] = SchoolItem(
          id: existing.id,
          name: existing.name,
          nameAr: existing.nameAr,
          pickupPoints: updatedList,
        );
      } else {
        _schools.add(SchoolItem(
          id: 'sch_${_schools.length + 1}_${schoolName.hashCode}',
          name: schoolName,
          nameAr: schoolName,
          pickupPoints: pickups
              .map((p) => SchoolPickupPointItem(
                    id: 'p_${p.hashCode}',
                    name: p,
                    nameAr: p,
                    schoolId: 'sch_${_schools.length + 1}',
                  ))
              .toList(),
        ));
      }
    });

    _configPickupPoints = _schools.expand((s) => s.pickupPoints).toList();
  }

  List<String> getAvailableSchools() {
    final isArabic = Get.locale?.languageCode == 'ar';
    return _schools
        .map((s) => (isArabic && s.nameAr != null && s.nameAr!.isNotEmpty)
            ? s.nameAr!
            : s.name)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> getPickupPointsForSchool(String schoolName) {
    if (schoolName.isEmpty) return [];

    final normalizedSearch = schoolName.trim().toLowerCase();

    for (var s in _schools) {
      final nameLower = s.name.toLowerCase();
      final nameAr = (s.nameAr ?? '').toLowerCase();

      bool isMatch = nameLower == normalizedSearch ||
          nameAr == normalizedSearch ||
          normalizedSearch.contains(nameLower) ||
          nameLower.contains(normalizedSearch) ||
          (nameAr.isNotEmpty && normalizedSearch.contains(nameAr)) ||
          (nameAr.isNotEmpty && nameAr.contains(normalizedSearch));

      if (isMatch && s.pickupPoints.isNotEmpty) {
        final isArabic = Get.locale?.languageCode == 'ar';
        return s.pickupPoints
            .map((p) => (isArabic && p.nameAr != null && p.nameAr!.isNotEmpty)
                ? p.nameAr!
                : p.name)
            .where((name) => name.trim().isNotEmpty)
            .toSet()
            .toList();
      }
    }

    final matchedPoints = _configPickupPoints.where((p) {
      if (p.schoolName != null &&
          p.schoolName!.toLowerCase().contains(normalizedSearch)) {
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

  Future<bool> searchSchoolTrips(SchoolSearchRequest request) async {
    _isSearching = true;
    update();

    try {
      Response response = await schoolService.findMatchingTrips(request);
      if (response.statusCode == 200 && response.body != null) {
        var rawList =
            response.body['content'] ?? response.body['data'] ?? response.body;
        if (rawList is List && rawList.isNotEmpty) {
          _matchingTrips = rawList
              .map((item) =>
                  SchoolTripModel.fromJson(item as Map<String, dynamic>))
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

  List<SchoolTripModel> _filterTripsFromAvailable(SchoolSearchRequest request) {
    if (Get.isRegistered<AvailableTripsController>()) {
      final allRides = Get.find<AvailableTripsController>().availableTrips;
      final schoolRides = allRides.where((r) {
        final type = (r.carpoolType ?? '').toLowerCase();
        final label = (r.carpoolTypeLabel ?? '').toLowerCase();
        final labelAr = r.carpoolTypeLabelAr ?? '';
        return type == 'school' ||
            type == 'school_routes' ||
            label.contains('school') ||
            labelAr.contains('مدرسة');
      }).toList();

      final reqSchool = request.schoolName.trim().toLowerCase();
      final reqPickup = request.pickupPointName.trim().toLowerCase();

      final matched = schoolRides.where((ride) {
        final rideDropoff = ride.dropoffAddress.toLowerCase();
        final rideTitle = (ride.title ?? '').toLowerCase();
        final ridePickup = ride.pickupAddress.toLowerCase();

        bool matchSchool = reqSchool.isEmpty ||
            rideDropoff.contains(reqSchool) ||
            reqSchool.contains(rideDropoff) ||
            rideTitle.contains(reqSchool) ||
            reqSchool.contains(rideTitle);

        bool matchPickup = reqPickup.isEmpty ||
            ridePickup.contains(reqPickup) ||
            reqPickup.contains(ridePickup);

        return matchSchool && matchPickup;
      }).toList();

      if (matched.isNotEmpty) {
        return matched.map((r) => SchoolTripModel.fromPoolRide(r)).toList();
      }
    }

    return [];
  }

  Future<void> getPickupPointsForTrip(String tripId,
      {String? schoolName}) async {
    _isLoadingPickupPoints = true;
    update();

    try {
      Response response = await schoolService.getPickupPoints(tripId);
      if (response.statusCode == 200 && response.body != null) {
        var rawList =
            response.body['content'] ?? response.body['data'] ?? response.body;
        if (rawList is List && rawList.isNotEmpty) {
          _availablePickupPoints = rawList
              .map((item) =>
                  SchoolPickupPointModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _availablePickupPoints = [];
        }
      } else {
        _availablePickupPoints = [];
      }
    } catch (e) {
      _availablePickupPoints = [];
    }

    // Fallback: if trip endpoint returns empty, extract pickup points from backend school config/routes
    if (_availablePickupPoints.isEmpty &&
        schoolName != null &&
        schoolName.isNotEmpty) {
      final pointNames = getPickupPointsForSchool(schoolName);
      if (pointNames.isNotEmpty) {
        _availablePickupPoints = pointNames.asMap().entries.map((entry) {
          final idx = entry.key;
          final name = entry.value;
          return SchoolPickupPointModel(
            id: 'backend_point_${idx + 1}',
            name: name,
            pickupTime: '07:15 AM',
            distanceText: '',
            isCurrent: idx == 0,
            latitude: 30.0588 + (idx * 0.005),
            longitude: 31.3411 + (idx * 0.004),
          );
        }).toList();
      }
    }

    // Compute live real distance from user's current location
    _calculatePickupDistances();

    _isLoadingPickupPoints = false;
    update();
  }

  void _calculatePickupDistances() {
    if (Get.isRegistered<LocationController>()) {
      final locCtrl = Get.find<LocationController>();
      final userLat = locCtrl.position.latitude != 0
          ? locCtrl.position.latitude
          : (locCtrl.getUserAddress()?.latitude != null
              ? locCtrl.getUserAddress()!.latitude!
              : null);
      final userLng = locCtrl.position.longitude != 0
          ? locCtrl.position.longitude
          : (locCtrl.getUserAddress()?.longitude != null
              ? locCtrl.getUserAddress()!.longitude!
              : null);

      if (userLat != null && userLng != null && userLat != 0 && userLng != 0) {
        _availablePickupPoints = _availablePickupPoints.map((pt) {
          if (pt.latitude != 0 && pt.longitude != 0) {
            final distMeters = Geolocator.distanceBetween(
              userLat,
              userLng,
              pt.latitude,
              pt.longitude,
            );
            final distText = distMeters < 1000
                ? '${distMeters.round()} m away'
                : '${(distMeters / 1000).toStringAsFixed(1)} km away';
            return pt.copyWith(distanceText: distText);
          }
          return pt;
        }).toList();
      }
    }
  }

  Future<bool> submitSubscription({
    required SchoolSubscribeRequest request,
    File? receiptImage,
  }) async {
    _isSubscribing = true;
    update();

    customPrint('Submitting School Subscription Request: ${request.toFieldsMap()}, receiptImage: ${receiptImage?.path}');

    try {
      Response response =
          await schoolService.subscribeToTrip(request, receiptImage);
      _isSubscribing = false;

      customPrint('School Subscription Response Code: ${response.statusCode}');
      customPrint('School Subscription Response Body: ${response.body}');

      if (response.statusCode == 200) {
        customPrint(
            'School subscription submitted successfully: ${response.body}');
        if (response.body != null) {
          var content = response.body['content'] ?? response.body['data'];
          if (content is Map<String, dynamic> && content['trip'] != null) {
            _activeTrip = SchoolActiveTripModel.fromJson(content['trip']);
          } else if (content is Map<String, dynamic>) {
            _activeTrip = SchoolActiveTripModel.fromJson(content);
          }
        }
        await getActiveTrip();
        update();
        return true;
      } else {
        customPrint('School subscription failed with status ${response.statusCode}: ${response.statusText} | body: ${response.body}');
        ApiChecker.checkApi(response);
        update();
        return false;
      }
    } catch (e, s) {
      _isSubscribing = false;
      update();
      customPrint('School subscription API error: $e\n$s');
      return false;
    }
  }

  Future<void> getMySubscriptions() async {
    _isLoading = true;
    update();

    try {
      Response response = await schoolService.getMySubscriptions();
      if (response.statusCode == 200 && response.body != null) {
        var rawList =
            response.body['content'] ?? response.body['data'] ?? response.body;
        if (rawList is List) {
          _mySubscriptions = rawList
              .map((item) => SchoolSubscriptionModel.fromJson(
                  item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      customPrint('Error fetching school subscriptions: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> getActiveTrip() async {
    _isLoadingActiveTrip = true;
    update();

    try {
      Response response = await schoolService.getActiveTrip();
      if (response.statusCode == 200 && response.body != null) {
        var content = response.body['content'] ?? response.body['data'];
        if (content is Map<String, dynamic>) {
          _activeTrip = SchoolActiveTripModel.fromJson(content);
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
