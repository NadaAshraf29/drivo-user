import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import '../models/passenger_model.dart';
import 'special_trip_repository_interface.dart';

class SpecialTripRepository implements SpecialTripRepositoryInterface {
  final ApiClient apiClient;

  SpecialTripRepository({required this.apiClient});

  @override
  Future<Response> estimateScheduledRide(Map<String, dynamic> requestBody) async {
    if (kDebugMode) {
      print('====> [SpecialTripRepository] estimateScheduledRide: ${AppConstants.scheduledSubscriptionEstimate}');
    }
    return await apiClient.postData(
      AppConstants.scheduledSubscriptionEstimate,
      requestBody,
    );
  }

  @override
  Future<Response> createScheduledRide(Map<String, dynamic> requestBody) async {
    if (kDebugMode) {
      print('====> [SpecialTripRepository] createScheduledRide: ${AppConstants.scheduledSubscriptionCreate}');
    }
    return await apiClient.postData(
      AppConstants.scheduledSubscriptionCreate,
      requestBody,
    );
  }

  @override
  Future<Response> createScheduledRidePaymobIntent(
    String tripRequestId, {
    double? amount,
    String selectedDuration = '1_month',
  }) async {
    if (kDebugMode) {
      print('====> [SpecialTripRepository] createScheduledRidePaymobIntent: ${AppConstants.paymobIntent} for trip: $tripRequestId, amount: $amount, duration: $selectedDuration');
    }
    final Map<String, dynamic> body = {
      'trip_request_id': tripRequestId,
      'trip_id': tripRequestId,
      'id': tripRequestId,
      'currency': 'EGP',
      'selected_duration': selectedDuration,
      'redirection_url': 'https://accept.paymob.com/api/acceptance/post_pay',
    };
    if (amount != null && amount > 0) {
      body['amount'] = amount;
    }
    Response response = await apiClient.postData(
      AppConstants.paymobIntent,
      body,
    );
    if ((response.statusCode != 200 || response.body?['data'] == null) &&
        (response.statusCode == 404 || response.statusCode == 405 || response.statusCode == 400 || response.statusCode == 500)) {
      if (kDebugMode) {
        print('====> [SpecialTripRepository] Fallback to ${AppConstants.scheduledSubscriptionPaymobIntent} for trip: $tripRequestId');
      }
      final fallbackResponse = await apiClient.postData(
        AppConstants.scheduledSubscriptionPaymobIntent,
        {
          'trip_request_id': tripRequestId,
          'trip_id': tripRequestId,
          'id': tripRequestId,
          if (amount != null && amount > 0) 'amount': amount,
        },
      );
      if (fallbackResponse.statusCode == 200 && fallbackResponse.body?['data'] != null) {
        return fallbackResponse;
      }
    }
    return response;
  }

  @override
  Future<Response> requestSpecialTripFare(Map<String, dynamic> tripData) async {
    return await estimateScheduledRide(tripData);
  }

  @override
  Future<Response> createSpecialTripRequest(Map<String, dynamic> requestData) async {
    return await createScheduledRide(requestData);
  }

  @override
  Future<Response> getSpecialTripDetails(String tripId) async {
    return await apiClient.getData('${AppConstants.tripDetails}$tripId');
  }

  @override
  Future<Response> verifyPaymentStatus(String tripId) async {
    return await apiClient.getData('${AppConstants.tripDetails}$tripId');
  }

  @override
  Future<Response> searchUserByPhone(String phone) async {
    final cleanPhone = SpecialTripPassengerModel.formatPhoneNumber(phone);
    try {
      if (kDebugMode) {
        print('====> [SpecialTripRepository] searchUserByPhone: $cleanPhone');
      }
      final response = await apiClient.postData(
        AppConstants.checkRegisteredUserUri,
        {'phone_or_email': cleanPhone},
      );
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['user'] ?? response.body['data'];
        String name = 'Passenger';
        if (data != null) {
          if (data['full_name'] != null && data['full_name'].toString().trim().isNotEmpty) {
            name = data['full_name'].toString().trim();
          } else if (data['name'] != null && data['name'].toString().trim().isNotEmpty) {
            name = data['name'].toString().trim();
          } else if (data['first_name'] != null || data['last_name'] != null) {
            name = '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim();
          }
        }
        if (name.isEmpty || name == 'Passenger') {
          name = 'Passenger (${cleanPhone.length > 4 ? cleanPhone.substring(cleanPhone.length - 4) : cleanPhone})';
        }
        return Response(
          statusCode: 200,
          body: {
            'response_code': 'default_200',
            'data': {
              'id': data?['id']?.toString() ?? 'usr_${cleanPhone.hashCode.abs()}',
              'name': name,
              'phone': data?['phone']?.toString() ?? cleanPhone,
              'avatar': data?['profile_image']?.toString(),
              'is_current_user': false,
              'payment_status': 'unpaid',
            },
          },
        );
      }
      return response;
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }
}
