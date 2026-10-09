import 'dart:io';
import 'package:get/get_connect/http/src/response/response.dart';
import '../interfaces/university_interface.dart';
import '../models/university_search_request.dart';
import '../models/university_subscribe_request.dart';
import 'university_service_interface.dart';

class UniversityService implements UniversityServiceInterface {
  final UniversityInterface universityRepository;

  UniversityService({required this.universityRepository});

  @override
  Future<Response> getUniversityConfig() async {
    return await universityRepository.getUniversityConfig();
  }

  @override
  Future<Response> findMatchingTrips(UniversitySearchRequest request) async {
    return await universityRepository.findMatchingTrips(request);
  }

  @override
  Future<Response> getTripDetails(String tripId) async {
    return await universityRepository.getTripDetails(tripId);
  }

  @override
  Future<Response> getPickupPoints(String tripId) async {
    return await universityRepository.getPickupPoints(tripId);
  }

  @override
  Future<Response> subscribeToTrip(
    UniversitySubscribeRequest request,
    File? receiptImage,
  ) async {
    return await universityRepository.subscribeToTrip(request, receiptImage);
  }

  @override
  Future<Response> getMySubscriptions() async {
    return await universityRepository.getMySubscriptions();
  }

  @override
  Future<Response> getActiveTrip() async {
    return await universityRepository.getActiveTrip();
  }
}

