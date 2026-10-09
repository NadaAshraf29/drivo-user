import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/search_tripe_request_model.dart';

abstract class SearchTripeServiceInterface {
  Future<dynamic> searchTripe(SearchTripeRequestModel searchTripeRequestModel);
}
