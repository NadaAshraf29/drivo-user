
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/domain/repositories/profile_repository_interface.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

class ProfileRepository implements ProfileRepositoryInterface{
  final ApiClient apiClient;
  ProfileRepository({required this.apiClient});

  @override
  Future<Response?> getProfileInfo() async {
    return await apiClient.getData(AppConstants.profileInfo);
  }

  @override
  Future<Response?> updateProfileInfo(String firstName, String lastname, String identification, String idType, String? gender, XFile? profile, List<MultipartBody>? identityImage) async {
    Map<String, String> fields = <String, String> {
      '_method': 'put',
      'first_name': firstName,
      'last_name': lastname,
      "identification_number" : identification,
      "identification_type" : idType,
      if(gender != null && gender.isNotEmpty) 'gender': gender,
    };
    List<MultipartBody> multipartList = [];
    for(int i =0; i< Get.find<ProfileController>().identityImages.length; i++){
      multipartList.add(MultipartBody('identity_images[$i]', Get.find<ProfileController>().identityImages[i]));
    }

    return await apiClient.postMultipartData(
      AppConstants.updateProfileInfo,
      fields, MultipartBody('profile_image',profile), multipartList
    );
  }

  @override
  Future<Response?> getEmergencyContact() async {
    return await apiClient.getData(AppConstants.emergencyContactUri);
  }

  @override
  Future<Response?> saveEmergencyContact(String name, String phone) async {
    return await apiClient.putData(
      AppConstants.emergencyContactUri,
      {
        "emergency_contact_name": name,
        "emergency_contact_phone": phone,
      },
    );
  }

  @override
  Future<Response?> sendSos({String? tripId, double? latitude, double? longitude, String? note}) async {
    Map<String, dynamic> body = {};
    if (tripId != null && tripId.isNotEmpty) body['trip_id'] = tripId;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (note != null && note.isNotEmpty) body['note'] = note;

    return await apiClient.postData(AppConstants.sendSosUri, body);
  }

}