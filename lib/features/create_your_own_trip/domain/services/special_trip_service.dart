import 'package:get/get_connect/http/src/response/response.dart';
import '../repositories/special_trip_repository_interface.dart';
import 'special_trip_service_interface.dart';

class SpecialTripService implements SpecialTripServiceInterface {
  final SpecialTripRepositoryInterface specialTripRepository;

  SpecialTripService({required this.specialTripRepository});

  @override
  Future<Response> searchUserByPhone(String phone) async {
    return await specialTripRepository.searchUserByPhone(phone);
  }

  @override
  Future<Response> estimateScheduledRide(Map<String, dynamic> requestBody) async {
    return await specialTripRepository.estimateScheduledRide(requestBody);
  }

  @override
  Future<Response> createScheduledRide(Map<String, dynamic> requestBody) async {
    return await specialTripRepository.createScheduledRide(requestBody);
  }

  @override
  Future<Response> createScheduledRidePaymobIntent(String tripRequestId, {double? amount, String selectedDuration = '1_month'}) async {
    return await specialTripRepository.createScheduledRidePaymobIntent(tripRequestId, amount: amount, selectedDuration: selectedDuration);
  }

  @override
  Future<Response> requestSpecialTripFare(Map<String, dynamic> tripData) async {
    return await specialTripRepository.requestSpecialTripFare(tripData);
  }

  @override
  Future<Response> createSpecialTripRequest(Map<String, dynamic> requestData) async {
    return await specialTripRepository.createSpecialTripRequest(requestData);
  }

  @override
  Future<Response> getSpecialTripDetails(String tripId) async {
    return await specialTripRepository.getSpecialTripDetails(tripId);
  }

  @override
  Future<Response> verifyPaymentStatus(String tripId) async {
    return await specialTripRepository.verifyPaymentStatus(tripId);
  }
}
