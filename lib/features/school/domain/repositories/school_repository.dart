import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import '../interfaces/school_interface.dart';
import '../models/school_search_request.dart';
import '../models/school_subscribe_request.dart';

class SchoolRepository implements SchoolInterface {
  final ApiClient apiClient;

  SchoolRepository({required this.apiClient});

  @override
  Future<Response> getSchoolConfig() async {
    return await apiClient.getData(AppConstants.schoolConfigUri);
  }

  @override
  Future<Response> findMatchingTrips(SchoolSearchRequest request) async {
    return await apiClient.postData(
      AppConstants.schoolFindTripsUri,
      request.toJson(),
    );
  }

  @override
  Future<Response> getTripDetails(String tripId) async {
    return await apiClient.getData(
      '${AppConstants.schoolTripDetailsUri}$tripId',
    );
  }

  @override
  Future<Response> getPickupPoints(String tripId) async {
    return await apiClient.getData(
      '${AppConstants.schoolPickupPointsUri}$tripId/pickup-points',
    );
  }

  @override
  Future<Response> subscribeToTrip(
    SchoolSubscribeRequest request,
    File? receiptImage,
  ) async {
    if (receiptImage != null) {
      return await apiClient.postMultipartData(
        AppConstants.schoolSubscribeUri,
        request.toFieldsMap(),
        MultipartBody('receipt_image', XFile(receiptImage.path)),
        [],
      );
    } else {
      return await apiClient.postData(
        AppConstants.schoolSubscribeUri,
        request.toJson(),
      );
    }
  }

  @override
  Future<Response> getMySubscriptions() async {
    return await apiClient.getData(AppConstants.schoolMySubscriptionsUri);
  }

  @override
  Future<Response> getActiveTrip() async {
    return await apiClient.getData(AppConstants.schoolActiveTripUri);
  }
}
