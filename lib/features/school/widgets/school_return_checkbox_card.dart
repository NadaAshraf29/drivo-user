import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolReturnCheckboxCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SchoolReturnCheckboxCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? const Color(0xFF00A0E9) : const Color(0xFFE2E8F0),
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF00A0E9) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? const Color(0xFF00A0E9) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'i_also_need_a_return_ride'.tr,
                    style: textSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'school_to_home_after_classes'.tr,
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
