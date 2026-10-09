import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class LocationSuggestionList extends StatelessWidget {
  final LocationController locationController;
  final LocationType targetType;

  const LocationSuggestionList({
    super.key,
    required this.locationController,
    required this.targetType,
  });

  @override
  Widget build(BuildContext context) {
    if (!locationController.resultShow ||
        locationController.locationType != targetType ||
        locationController.predictionList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: locationController.predictionList.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final prediction = locationController.predictionList[index];
          return InkWell(
            onTap: () {
              if (prediction.placeId != null && prediction.description != null) {
                locationController.setLocation(
                  prediction.placeId!,
                  prediction.description!,
                  null,
                  type: targetType,
                  fromSearch: true,
                );
                FocusScope.of(context).unfocus();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeDefault,
                horizontal: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      prediction.description ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
