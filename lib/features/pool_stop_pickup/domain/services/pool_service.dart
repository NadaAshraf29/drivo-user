import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import '../interfaces/pool_interface.dart';
import '../models/find_match_request.dart';
import '../models/find_match_response.dart';
import '../models/join_request.dart';
import '../models/boarding_point_model.dart';

class PoolService {
  final PoolInterface poolRepository;

  PoolService({required this.poolRepository});

  Future<FindMatchResponse?> findMatchingRides(FindMatchRequest request) async {
    try {
      Response response = await poolRepository.findMatchingRides(request);

      if (response.statusCode == 200) {
        return FindMatchResponse.fromJson(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error in PoolService.findMatchingRides: $e');
      return null;
    }
  }

  Future<bool> joinRide(JoinRequest request) async {
    try {
      Response response = await poolRepository.joinRide(request);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error in PoolService.joinRide: $e');
      return false;
    }
  }

  Future<List<BoardingPoint>?> getBoardingPoints() async {
    try {
      Response response = await poolRepository.getBoardingPoints();

      if (response.statusCode == 200) {
        List<dynamic> list = response.body['data'] as List? ?? [];
        return list.map((e) => BoardingPoint.fromJson(e)).toList();
      } else {
        return null;
      }
    } catch (e) {
      print('Error in PoolService.getBoardingPoints: $e');
      return null;
    }
  }

  Future<List<PoolRide>?> getNearMeTrips({
    required double lat,
    required double lng,
    int radius = 15,
  }) async {
    try {
      Response response = await poolRepository.getNearMeTrips(
        lat: lat,
        lng: lng,
        radius: radius,
      );

      if (response.statusCode == 200 && response.body != null) {
        final Map<String, dynamic> body =
            response.body is Map<String, dynamic> ? response.body : {};
        final Map<String, dynamic> data =
            (body['data'] as Map<String, dynamic>?) ??
                (body['content'] as Map<String, dynamic>?) ??
                body;
        final List<dynamic> tripsJson = (data['trips'] as List?) ?? [];
        return tripsJson.map((e) => PoolRide.fromJson(e)).toList();
      } else {
        return null;
      }
    } catch (e) {
      print('Error in PoolService.getNearMeTrips: $e');
      return null;
    }
  }
}
