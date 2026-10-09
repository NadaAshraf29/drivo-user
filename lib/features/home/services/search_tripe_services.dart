import 'package:ride_sharing_user_app/features/home/domain/models/search_tripe_request_model.dart';
import 'package:ride_sharing_user_app/features/home/domain/repositories/search_tripe_repository_interface.dart';
import 'package:ride_sharing_user_app/features/home/services/search_tripe_services_interface%20copy.dart';

class SearchTripeService implements SearchTripeServiceInterface {
  final SearchTripeRepositoryInterface searchTripeRepositoryInterface;

  SearchTripeService({required this.searchTripeRepositoryInterface});

  @override
  Future<dynamic> searchTripe(
      SearchTripeRequestModel searchTripeRequestModel) async {
    return await searchTripeRepositoryInterface
        .searchTripe(searchTripeRequestModel);
  }
}
