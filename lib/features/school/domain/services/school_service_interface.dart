import 'dart:io';
import 'package:get/get_connect/http/src/response/response.dart';
import '../models/school_search_request.dart';
import '../models/school_subscribe_request.dart';

abstract class SchoolServiceInterface {
  Future<Response> getSchoolConfig();
  Future<Response> findMatchingTrips(SchoolSearchRequest request);
  Future<Response> getTripDetails(String tripId);
  Future<Response> getPickupPoints(String tripId);
  Future<Response> subscribeToTrip(SchoolSubscribeRequest request, File? receiptImage);
  Future<Response> getMySubscriptions();
  Future<Response> getActiveTrip();
}
