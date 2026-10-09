import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RideCardLocationPointsWidget extends StatelessWidget {
  final String pickupAddress;
  final String dropoffAddress;

  const RideCardLocationPointsWidget({
    super.key,
    required this.pickupAddress,
    required this.dropoffAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pickup Point Row
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Text(
                pickupAddress.isNotEmpty ? pickupAddress : 'Pickup Point',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),

        // Vertical connecting line
        Padding(
          padding: const EdgeInsets.only(left: 3.5, top: 2, bottom: 2),
          child: Container(
            width: 1,
            height: 12,
            color: Colors.grey.shade300,
          ),
        ),

        // Dropoff Point Row
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 12,
              color: Colors.red.shade400,
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Text(
                dropoffAddress.isNotEmpty ? dropoffAddress : 'Destination',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
