import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityOngoingActionsCard extends StatelessWidget {
  final VoidCallback onMessage;
  final VoidCallback onCall;

  const UniversityOngoingActionsCard({
    super.key,
    required this.onMessage,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Message Button
        Expanded(
          child: InkWell(
            onTap: onMessage,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF00A0E9),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'message'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Call Button
        Expanded(
          child: InkWell(
            onTap: onCall,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF00A0E9),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'call'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
