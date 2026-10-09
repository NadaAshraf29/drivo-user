import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/add_car_body_model.dart';
import 'package:ride_sharing_user_app/features/home/domain/repositories/add_car_repository_interface.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_sharing_user_app/features/home/services/add_car_services_interface.dart';

class AddCarServices implements AddCarServiceInterface {
  final AddCarRepositoryInterface addCarRepositoryInterface;
  AddCarServices({required this.addCarRepositoryInterface});

  @override
  Future addNewVehicle(
      AddCarBodyModel addCarBody, List<MultipartDocument> file) {
    return addCarRepositoryInterface.addNewVehicle(addCarBody, file);
  }

  @override
  Future updateVehicle(AddCarBodyModel addCarBody, String driverId) {
    return addCarRepositoryInterface.updateVehicle(addCarBody, driverId);
  }

  @override
  Future dailyLog() {
    return addCarRepositoryInterface.dailyLog();
  }

  @override
  Future getCategoryList(int offset) {
    return addCarRepositoryInterface.getCategoryList(offset);
  }

  @override
  Future getProfileInfo() {
    return addCarRepositoryInterface.getProfileInfo();
  }

  @override
  Future getVehicleBrandList(int offset) {
    return addCarRepositoryInterface.getVehicleBrandList(offset);
  }

  @override
  Future getVehicleModelList(int offset) {
    return addCarRepositoryInterface.getVehicleModelList(offset);
  }

  @override
  Future profileOnlineOffline() {
    return addCarRepositoryInterface.profileOnlineOffline();
  }

  @override
  Future updateProfileInfo(
      String firstName,
      String lastname,
      String email,
      String identityType,
      String identityNumber,
      XFile? profile,
      List<MultipartBody>? identityImage,
      List<String> services) {
    return addCarRepositoryInterface.updateProfileInfo(firstName, lastname,
        email, identityType, identityNumber, profile, identityImage, services);
  }

  @override
  Future getProfileLevelInfo() {
    return addCarRepositoryInterface.getProfileLevelInfo();
  }
}
