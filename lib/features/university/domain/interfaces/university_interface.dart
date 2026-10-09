import 'dart:io';
import 'package:get/get_connect/http/src/response/response.dart';
import '../models/university_search_request.dart';
import '../models/university_subscribe_request.dart';

abstract class UniversityInterface {
  Future<Response> getUniversityConfig();
  Future<Response> findMatchingTrips(UniversitySearchRequest request);
  Future<Response> getTripDetails(String tripId);
  Future<Response> getPickupPoints(String tripId);
  Future<Response> subscribeToTrip(UniversitySubscribeRequest request, File? receiptImage);
  Future<Response> getMySubscriptions();
  Future<Response> getActiveTrip();
}

