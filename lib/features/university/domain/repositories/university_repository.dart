import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import '../interfaces/university_interface.dart';
import '../models/university_search_request.dart';
import '../models/university_subscribe_request.dart';

class UniversityRepository implements UniversityInterface {
  final ApiClient apiClient;

  UniversityRepository({required this.apiClient});

  @override
  Future<Response> getUniversityConfig() async {
    return await apiClient.getData(AppConstants.universityConfigUri);
  }

  @override
  Future<Response> findMatchingTrips(UniversitySearchRequest request) async {
    return await apiClient.postData(
      AppConstants.universityFindTripsUri,
      request.toJson(),
    );
  }

  @override
  Future<Response> getTripDetails(String tripId) async {
    return await apiClient.getData(
      '${AppConstants.universityTripDetailsUri}$tripId',
    );
  }

  @override
  Future<Response> getPickupPoints(String tripId) async {
    return await apiClient.getData(
      '${AppConstants.universityPickupPointsUri}$tripId/pickup-points',
    );
  }

  @override
  Future<Response> subscribeToTrip(
    UniversitySubscribeRequest request,
    File? receiptImage,
  ) async {
    if (receiptImage != null) {
      return await apiClient.postMultipartData(
        AppConstants.universitySubscribeUri,
        request.toFieldsMap(),
        MultipartBody('receipt_image', XFile(receiptImage.path)),
        [],
      );
    } else {
      return await apiClient.postData(
        AppConstants.universitySubscribeUri,
        request.toJson(),
      );
    }
  }

  @override
  Future<Response> getMySubscriptions() async {
    return await apiClient.getData(AppConstants.universityMySubscriptionsUri);
  }

  @override
  Future<Response> getActiveTrip() async {
    return await apiClient.getData(AppConstants.universityActiveTripUri);
  }
}

