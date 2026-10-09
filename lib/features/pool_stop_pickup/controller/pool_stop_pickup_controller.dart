import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ride_sharing_user_app/features/available_trips/controllers/available_trips_controller.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/carpoll_ride_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/services/pool_service.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/find_match_request.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/find_match_response.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/join_request.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/boarding_point_model.dart';

import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';

class PoolStopPickupController extends GetxController implements GetxService {
  final PoolService poolService;

  PoolStopPickupController({required this.poolService});
  // Map controller
  GoogleMapController? mapController;

  // Selected addresses
  Address? pickupAddress;
  Address? destinationAddress;

  // Loading states
  bool _isLoading = false;
  bool _isSearchingTrips = false;
  Set<int> _joiningRouteIds = {};

  // Text controllers
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  // Available trips for this route
  List<PoolRide> availableTrips = [];

  // Search parameters
  String selectedGender = 'both';
  int selectedSeats = 1;
  String selectedRideType = 'work';
  String selectedDate = '';

  // New carpool type state fields
  String selectedCarpoolType = 'trip';
  List<BoardingPoint> boardingPoints = [];
  
  String? selectedStartCity;
  String? selectedEndCity;
  BoardingPoint? selectedBoardingPointStart;
  BoardingPoint? selectedBoardingPointEnd;
  
  bool isLoadingBoardingPoints = false;
  String? selectedDepartureTime;
  String? selectedReturnTime;

  bool get isLoading => _isLoading;
  bool get isSearchingTrips => _isSearchingTrips;
  bool isJoining(int routeId) => _joiningRouteIds.contains(routeId);

  List<String> _splitString(String value) {
    final regex = RegExp(r'\s*-\s*|\s+to\s+');
    final parts = value.split(regex);
    return parts.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  String _getCityForPoint(BoardingPoint p, bool isLtr) {
    if (p.city.trim().isNotEmpty) {
      return p.city.trim();
    }
    final nameToUse = (isLtr ? p.name : p.nameAr).isNotEmpty 
        ? (isLtr ? p.name : p.nameAr) 
        : p.name;
    final parts = _splitString(nameToUse);
    return parts.isNotEmpty ? parts.first : '';
  }

  List<String> get availableCities {
    final isLtr = Get.find<LocalizationController>().isLtr;
    final cities = boardingPoints
        .map((p) => _getCityForPoint(p, isLtr))
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cities.sort();
    return cities;
  }

  List<BoardingPoint> getAreasForCity(String? city) {
    if (city == null) return [];
    final isLtr = Get.find<LocalizationController>().isLtr;
    return boardingPoints.where((p) {
      final pCity = _getCityForPoint(p, isLtr);
      return pCity.toLowerCase() == city.trim().toLowerCase();
    }).toList();
  }

  String getAreaName(BoardingPoint point) {
    final isLtr = Get.find<LocalizationController>().isLtr;
    final nameToUse = (isLtr ? point.name : point.nameAr).isNotEmpty 
        ? (isLtr ? point.name : point.nameAr) 
        : point.name;
    if (point.city.trim().isNotEmpty) {
      return nameToUse.trim();
    }
    final parts = _splitString(nameToUse);
    if (parts.length > 1) {
      return parts.sublist(1).join(' - ').trim();
    }
    return nameToUse.trim();
  }

  void setPickupAddress(Address address) {
    pickupAddress = address;
    pickupController.text = address.address ?? '';
    update();
  }

  void setDestinationAddress(Address address) {
    destinationAddress = address;
    destinationController.text = address.address ?? '';
    update();
  }

  void setSelectedCarpoolType(String type, {bool notify = true}) {
    selectedCarpoolType = type;
    if (notify) update();
  }

  void setSelectedStartCity(String? city) {
    selectedStartCity = city;
    selectedBoardingPointStart = null; // Reset area when city changes
    update();
  }

  void setSelectedEndCity(String? city) {
    selectedEndCity = city;
    selectedBoardingPointEnd = null; // Reset area when city changes
    update();
  }

  void setSelectedBoardingPointStart(BoardingPoint? point) {
    selectedBoardingPointStart = point;
    update();
  }

  void setSelectedBoardingPointEnd(BoardingPoint? point) {
    selectedBoardingPointEnd = point;
    update();
  }

  void setTimes({String? departure, String? returnTime}) {
    if (departure != null) selectedDepartureTime = departure;
    if (returnTime != null) selectedReturnTime = returnTime;
    update();
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> getBoardingPoints() async {
    isLoadingBoardingPoints = true;
    update();
    try {
      final list = await poolService.getBoardingPoints();
      if (list != null) {
        boardingPoints = list.where((bp) => bp.carpoolType == selectedCarpoolType).toList();
      }
    } catch (e) {
      print('Error in PoolStopPickupController.getBoardingPoints: $e');
    } finally {
      isLoadingBoardingPoints = false;
      update();
    }
  }

  Future<void> searchAvailableTrips() async {
    if (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') {
      if (selectedBoardingPointStart == null || selectedBoardingPointEnd == null) {
        showCustomSnackBar('Please select both start and end boarding points');
        return;
      }
    } else {
      if (pickupAddress == null || destinationAddress == null) {
        showCustomSnackBar('Please select both pickup and destination locations');
        return;
      }
    }

    if (selectedDate.isEmpty) {
      showCustomSnackBar('Please select a date');
      return;
    }

    _isSearchingTrips = true;
    update();

    try {
      // Create the request object
      FindMatchRequest request = FindMatchRequest(
        carpoolType: selectedCarpoolType,
        pickupLat: (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? null : pickupAddress!.latitude!,
        pickupLng: (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? null : pickupAddress!.longitude!,
        dropoffLat: (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? null : destinationAddress!.latitude!,
        dropoffLng: (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? null : destinationAddress!.longitude!,
        day: selectedDate,
        gender: selectedGender,
        seatsRequired: selectedSeats,
        rideType: selectedRideType,
        departureTime: selectedCarpoolType == 'routine' ? selectedDepartureTime : null,
        returnTime: selectedCarpoolType == 'routine' ? selectedReturnTime : null,
        boardingPointStartId: (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? selectedBoardingPointStart?.id : null,
        boardingPointEndId: (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? selectedBoardingPointEnd?.id : null,
      );

      // Make the API call
      FindMatchResponse? response =
          await poolService.findMatchingRides(request);

      // Process the response
      if (response != null && response.responseCode == 'default_200') {
        // Clear previous results
        availableTrips.clear();

        // Add new results
        availableTrips.addAll(response.data);

        // Update UI
        update();

        if (availableTrips.isEmpty) {
          showCustomSnackBar(
            'No Rides Found',
            subMessage: 'Try different route or date',
            isError: false,
          );
        } else {
          print('Found ${availableTrips.length} rides successfully');
        }
      } else {
        availableTrips.clear();
        showCustomSnackBar(response?.message ?? 'Failed to search for trips');
      }
    } catch (e) {
      availableTrips.clear();
      showCustomSnackBar('Failed to search for trips: ${e.toString()}');
    } finally {
      _isSearchingTrips = false;
      update();
    }
  }

  Future<String?> joinRide(PoolRide poolRide) async {
    if (selectedCarpoolType != 'travel' && selectedCarpoolType != 'north_coast') {
      if (pickupAddress == null || destinationAddress == null) {
        showCustomSnackBar('Pickup and destination addresses are required');
        return null;
      }
    }

    _joiningRouteIds.add(poolRide.routeId);
    update();

    try {
      // Create the join request
      JoinRequest request = JoinRequest(
        routeId: poolRide.routeId,
        seatsCount: selectedSeats,
        pickupLat: (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? (poolRide.closestPickup?.lat ?? 0.0) : pickupAddress!.latitude!,
        pickupLng: (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? (poolRide.closestPickup?.lng ?? 0.0) : pickupAddress!.longitude!,
        dropoffLat: (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? (poolRide.closestDropoff?.lat ?? 0.0) : destinationAddress!.latitude!,
        dropoffLng: (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? (poolRide.closestDropoff?.lng ?? 0.0) : destinationAddress!.longitude!,
        fare: poolRide.price,
      );

      // Make the API call
      bool success = await poolService.joinRide(request);

      if (success) {
        final response =
            await Get.find<CarPollRideController>().carpoolSubmitRideRequest(
          poolRide.routeId.toString(),
          poolRide.price.toDouble(),
          (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? (poolRide.closestPickup?.lat ?? 0.0) : pickupAddress!.latitude!,
          (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? (poolRide.closestPickup?.lng ?? 0.0) : pickupAddress!.longitude!,
          (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? (poolRide.closestDropoff?.lat ?? 0.0) : destinationAddress!.latitude!,
          (selectedCarpoolType == 'travel' || selectedCarpoolType == 'north_coast') ? (poolRide.closestDropoff?.lng ?? 0.0) : destinationAddress!.longitude!,
        );

        if (response.statusCode == 200 && response.body['data'] != null) {
          final tripId = response.body['data']['id']?.toString();
          if (tripId != null && tripId.isNotEmpty) {
            showCustomSnackBar(
              'Join request sent successfully! The driver will be notified.',
              isError: false,
            );
            return tripId;
          }
        }

        showCustomSnackBar('Failed to create trip. Please try again.');
      } else {
        showCustomSnackBar('Failed to send join request. Please try again.');
      }
    } catch (e) {
      showCustomSnackBar('Failed to join ride: ${e.toString()}');
    } finally {
      _joiningRouteIds.remove(poolRide.routeId);
      update();
    }
    return null;
  }

  void setSearchParameters({
    String? gender,
    int? seats,
    String? rideType,
    String? date,
  }) {
    if (gender != null) selectedGender = gender;
    if (seats != null) selectedSeats = seats;
    if (rideType != null) selectedRideType = rideType;
    if (date != null) selectedDate = date;
    update();
  }

  void clearAddresses() {
    pickupAddress = null;
    destinationAddress = null;
    selectedBoardingPointStart = null;
    selectedBoardingPointEnd = null;
    pickupController.clear();
    destinationController.clear();
    availableTrips.clear();
    update();
  }

  List<PoolRide> nearMeTrips = [];
  bool isLoadingNearMe = false;

  (double, double)? _getRidePickupCoordinates(PoolRide ride) {
    if (ride.closestPickup != null &&
        (ride.closestPickup!.lat != 0.0 || ride.closestPickup!.lng != 0.0)) {
      return (ride.closestPickup!.lat, ride.closestPickup!.lng);
    }
    if (ride.boardingPointStart != null &&
        (ride.boardingPointStart!.latitude != 0.0 ||
            ride.boardingPointStart!.longitude != 0.0)) {
      return (
        ride.boardingPointStart!.latitude,
        ride.boardingPointStart!.longitude
      );
    }
    if (ride.pickupMatchPoint.lat != 0.0 || ride.pickupMatchPoint.lng != 0.0) {
      return (ride.pickupMatchPoint.lat, ride.pickupMatchPoint.lng);
    }
    if (ride.routeStartPoint != null &&
        (ride.routeStartPoint!.lat != 0.0 || ride.routeStartPoint!.lng != 0.0)) {
      return (ride.routeStartPoint!.lat, ride.routeStartPoint!.lng);
    }
    return null;
  }

  Future<void> fetchNearMeTrips({double? lat, double? lng}) async {
    isLoadingNearMe = true;
    update();

    double searchLat = lat ?? 30.0444;
    double searchLng = lng ?? 31.2357;

    if (lat == null || lng == null) {
      if (Get.isRegistered<LocationController>()) {
        final locCtrl = Get.find<LocationController>();
        final userAddress = locCtrl.getUserAddress();
        if (userAddress?.latitude != null &&
            userAddress?.longitude != null &&
            userAddress!.latitude != 0.0 &&
            userAddress.longitude != 0.0) {
          searchLat = userAddress.latitude!;
          searchLng = userAddress.longitude!;
        } else if (locCtrl.pickPosition.latitude != 0.0 &&
            locCtrl.pickPosition.longitude != 0.0) {
          searchLat = locCtrl.pickPosition.latitude;
          searchLng = locCtrl.pickPosition.longitude;
        } else if (locCtrl.position.latitude != 0.0 &&
            locCtrl.position.longitude != 0.0) {
          searchLat = locCtrl.position.latitude;
          searchLng = locCtrl.position.longitude;
        }
      }
    }

    try {
      final Map<int, PoolRide> candidateMap = {};

      // 1. Fetch from poolService getNearMeTrips
      final trips = await poolService.getNearMeTrips(
        lat: searchLat,
        lng: searchLng,
        radius: 20,
      );
      if (trips != null) {
        for (var t in trips) {
          candidateMap[t.routeId] = t;
        }
      }

      // 2. Also check available trips controller if registered to not miss existing available carpool trips
      if (Get.isRegistered<AvailableTripsController>()) {
        final availableTripsCtrl = Get.find<AvailableTripsController>();
        if (availableTripsCtrl.availableTrips.isEmpty) {
          await availableTripsCtrl.getAvailableTrips();
        }
        for (var t in availableTripsCtrl.availableTrips) {
          candidateMap.putIfAbsent(t.routeId, () => t);
        }
      }

      final List<PoolRide> filteredList = [];

      for (var ride in candidateMap.values) {
        final coords = _getRidePickupCoordinates(ride);
        if (coords != null) {
          final distInMeters = Geolocator.distanceBetween(
            searchLat,
            searchLng,
            coords.$1,
            coords.$2,
          );
          final distKm = distInMeters / 1000.0;
          // Filter strictly to rides within 20 km of current user location
          if (distKm <= 20.0) {
            filteredList.add(ride.copyWith(distanceFromUserKm: distKm));
          }
        }
      }

      // Sort by distance ascending (closest first)
      filteredList.sort((a, b) =>
          (a.distanceFromUserKm ?? 999.0).compareTo(b.distanceFromUserKm ?? 999.0));

      nearMeTrips = filteredList;
    } catch (e) {
      print('Error in PoolStopPickupController.fetchNearMeTrips: $e');
      nearMeTrips = [];
    } finally {
      isLoadingNearMe = false;
      update();
    }
  }

  @override
  void onClose() {
    pickupController.dispose();
    destinationController.dispose();
    super.onClose();
  }
}

/*
Archived Code:
  List<String> get availableCities {
    final isLtr = Get.find<LocalizationController>().isLtr;
    final cities = boardingPoints
        .map((p) {
          final nameToUse = (isLtr ? p.name : p.nameAr).isNotEmpty 
              ? (isLtr ? p.name : p.nameAr) 
              : p.name;
          final parts = _splitString(nameToUse);
          return parts.isNotEmpty ? parts.first : '';
        })
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cities.sort();
    return cities;
  }

  List<BoardingPoint> getAreasForCity(String? city) {
    if (city == null) return [];
    final isLtr = Get.find<LocalizationController>().isLtr;
    return boardingPoints.where((p) {
      final nameToUse = (isLtr ? p.name : p.nameAr).isNotEmpty 
          ? (isLtr ? p.name : p.nameAr) 
          : p.name;
      final parts = _splitString(nameToUse);
      return parts.isNotEmpty && parts.first == city;
    }).toList();
  }

  String getAreaName(BoardingPoint point) {
    final isLtr = Get.find<LocalizationController>().isLtr;
    final nameToUse = (isLtr ? point.name : point.nameAr).isNotEmpty 
        ? (isLtr ? point.name : point.nameAr) 
        : point.name;
    final parts = _splitString(nameToUse);
    if (parts.length > 1) {
      return parts.sublist(1).join(' - ').trim();
    }
    return nameToUse.trim();
  }
*/

