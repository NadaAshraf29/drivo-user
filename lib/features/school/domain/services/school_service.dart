import 'dart:io';
import 'package:get/get_connect/http/src/response/response.dart';
import '../interfaces/school_interface.dart';
import '../models/school_search_request.dart';
import '../models/school_subscribe_request.dart';
import 'school_service_interface.dart';

class SchoolService implements SchoolServiceInterface {
  final SchoolInterface schoolRepository;

  SchoolService({required this.schoolRepository});

  @override
  Future<Response> getSchoolConfig() async {
    return await schoolRepository.getSchoolConfig();
  }

  @override
  Future<Response> findMatchingTrips(SchoolSearchRequest request) async {
    return await schoolRepository.findMatchingTrips(request);
  }

  @override
  Future<Response> getTripDetails(String tripId) async {
    return await schoolRepository.getTripDetails(tripId);
  }

  @override
  Future<Response> getPickupPoints(String tripId) async {
    return await schoolRepository.getPickupPoints(tripId);
  }

  @override
  Future<Response> subscribeToTrip(
    SchoolSubscribeRequest request,
    File? receiptImage,
  ) async {
    return await schoolRepository.subscribeToTrip(request, receiptImage);
  }

  @override
  Future<Response> getMySubscriptions() async {
    return await schoolRepository.getMySubscriptions();
  }

  @override
  Future<Response> getActiveTrip() async {
    return await schoolRepository.getActiveTrip();
  }
}
