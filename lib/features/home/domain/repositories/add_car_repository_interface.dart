import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/add_car_body_model.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:image_picker/image_picker.dart';

abstract class AddCarRepositoryInterface implements RepositoryInterface {
  Future<Response?> profileOnlineOffline();
  Future<Response?> getProfileInfo();
  Future<Response?> dailyLog();
  Future<Response?> getVehicleModelList(int offset);
  Future<Response?> getVehicleBrandList(int offset);
  Future<Response?> getCategoryList(int offset);
  Future<Response?> addNewVehicle(
      AddCarBodyModel addCarBody, List<MultipartDocument> file);
  Future<Response?> updateVehicle(AddCarBodyModel addCarBody, String driverId);
  Future<Response?> updateProfileInfo(
      String firstName,
      String lastname,
      String email,
      String identityType,
      String identityNumber,
      XFile? profile,
      List<MultipartBody>? identityImage,
      List<String> services);
  Future<Response> getProfileLevelInfo();
}

abstract class RepositoryInterface<T> {
  Future<dynamic> add(T value);

  Future<dynamic> update(Map<String, dynamic> body, int id);

  Future<dynamic> delete(int id);

  Future<dynamic> getList({int? offset = 1});

  Future<dynamic> get(String id);
}
