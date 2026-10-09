import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

class AvailableTripsController extends GetxController implements GetxService {
  final ApiClient apiClient;

  AvailableTripsController({required this.apiClient});

  bool _isLoading = false;
  List<PoolRide> _availableTrips = [];

  bool get isLoading => _isLoading;
  List<PoolRide> get availableTrips => _availableTrips;

  Future<void> getAvailableTrips({bool reload = false}) async {
    if (reload) {
      _isLoading = true;
      update();
    }

    try {
      Response response =
          await apiClient.getData(AppConstants.getAvailableTrips);

      if (response.statusCode == 200) {
        _availableTrips = [];
        final dynamic body = response.body;

        List<dynamic> dataList = [];
        if (body is List) {
          dataList = body;
        } else if (body is Map<String, dynamic>) {
          if (body['data'] is List) {
            dataList = body['data'];
          } else if (body['data'] is Map<String, dynamic> &&
              body['data']['trips'] is List) {
            dataList = body['data']['trips'];
          } else if (body['trips'] is List) {
            dataList = body['trips'];
          }
        }

        for (int i = 0; i < dataList.length; i++) {
          try {
            PoolRide ride = PoolRide.fromJson(dataList[i]);
            _availableTrips.add(ride);
          } catch (e) {
            print('Error parsing available trip $i: $e');
          }
        }
      } else {
        showCustomSnackBar(
            response.statusText ?? 'Failed to load available trips');
      }
    } catch (e) {
      showCustomSnackBar('An error occurred: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }
}
