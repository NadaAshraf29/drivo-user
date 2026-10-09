import 'package:get/get_connect/http/src/response/response.dart';

abstract class SpecialTripServiceInterface {
  Future<Response> searchUserByPhone(String phone);
  Future<Response> estimateScheduledRide(Map<String, dynamic> requestBody);
  Future<Response> createScheduledRide(Map<String, dynamic> requestBody);
  Future<Response> createScheduledRidePaymobIntent(String tripRequestId, {double? amount, String selectedDuration = '1_month'});
  Future<Response> getSpecialTripDetails(String tripId);
  Future<Response> verifyPaymentStatus(String tripId);
  Future<Response> requestSpecialTripFare(Map<String, dynamic> tripData);
  Future<Response> createSpecialTripRequest(Map<String, dynamic> requestData);
}
