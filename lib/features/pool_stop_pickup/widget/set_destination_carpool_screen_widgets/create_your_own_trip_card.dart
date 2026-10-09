import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CreateYourOwnTripCard extends StatelessWidget {
  final VoidCallback onTap;

  const CreateYourOwnTripCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                // Car + Plus Icon Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.directions_car_rounded,
                        color: Color(0xFF00A0E9),
                        size: 24,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00A0E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Text Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'create_your_own_trip'.tr.isNotEmpty &&
                                'create_your_own_trip'.tr != 'create_your_own_trip'
                            ? 'create_your_own_trip'.tr
                            : 'Create your own trip',
                        style: textBold.copyWith(
                          fontSize: 15,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'going_somewhere_post_your_trip'.tr.isNotEmpty &&
                                'going_somewhere_post_your_trip'.tr !=
                                    'going_somewhere_post_your_trip'
                            ? 'going_somewhere_post_your_trip'.tr
                            : 'Going somewhere ? post your trip',
                        style: textRegular.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Chevron Arrow
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
