import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class NoMatchingTripsCard extends StatelessWidget {
  final String tripType;
  final VoidCallback onChangeSearch;

  const NoMatchingTripsCard({
    super.key,
    required this.tripType,
    required this.onChangeSearch,
  });

  String get _titleKey {
    switch (tripType) {
      case 'routine':
        return 'no_matching_routine_trips';
      case 'travel':
        return 'no_matching_travel_trips';
      case 'north_coast':
        return 'no_matching_north_coast_trips';
      default:
        return 'no_matching_one_trip_trips';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.directions_car_filled_rounded,
                size: 44,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _titleKey.tr,
            style: textBold.copyWith(
              fontSize: 18,
              color: const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'no_matching_carpool_trips_desc'.tr,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onChangeSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A0E9),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'change_search'.tr,
                style: textSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
