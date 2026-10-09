import 'package:ride_sharing_user_app/features/home/domain/models/search_tripe_request_model.dart';

abstract class SearchTripeRepositoryInterface {
  Future<dynamic> searchTripe(SearchTripeRequestModel searchTripeRequestModel);
}
