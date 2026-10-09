import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripDetailsActionButtonsWidget extends StatelessWidget {
  final VoidCallback onJoinTrip;
  final VoidCallback onViewFullRoute;

  const TripDetailsActionButtonsWidget({
    super.key,
    required this.onJoinTrip,
    required this.onViewFullRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onJoinTrip,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'join_a_ride'.tr,
              style: textBold.copyWith(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onViewFullRoute,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'view_full_route'.tr,
              style: textBold.copyWith(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
