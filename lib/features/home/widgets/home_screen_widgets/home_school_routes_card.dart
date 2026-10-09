import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class HomeSchoolRoutesCard extends StatelessWidget {
  final VoidCallback onTap;

  const HomeSchoolRoutesCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_bus_rounded,
                  color: Color(0xFF1E8E3E),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'school_routes'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'track_your_child_bus'.tr,
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // const SizedBox(width: 8),
            // Container(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 12,
            //     vertical: 6,
            //   ),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFE8F5E9),
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Container(
            //         width: 7,
            //         height: 7,
            //         decoration: const BoxDecoration(
            //           color: Color(0xFF1E8E3E),
            //           shape: BoxShape.circle,
            //         ),
            //       ),
            //       const SizedBox(width: 6),
            //       Text(
            //         'live'.tr,
            //         style: textSemiBold.copyWith(
            //           fontSize: Dimensions.fontSizeSmall,
            //           color: const Color(0xFF1E8E3E),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
