import 'package:get/get_connect/http/src/response/response.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';

abstract class ProfileRepositoryInterface {
  Future<dynamic> getProfileInfo();
  Future<dynamic> updateProfileInfo(
      String firstName,
      String lastname,
      String identification,
      String idType,
      String? gender,
      XFile? profile,
      List<MultipartBody>? identityImage);
  Future<Response?> getEmergencyContact();
  Future<Response?> saveEmergencyContact(String name, String phone);
  Future<Response?> sendSos(
      {String? tripId, double? latitude, double? longitude, String? note});
}
