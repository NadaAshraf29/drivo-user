import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityReturnCheckboxCard extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const UniversityReturnCheckboxCard({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF6FE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFBAE6FD),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF00A0E9) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked
                      ? const Color(0xFF00A0E9)
                      : const Color(0xFF94A3B8),
                  width: 1.5,
                ),
              ),
              child: isChecked
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
                    'i_also_need_return_ride'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'university_to_home_after_classes'.tr,
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
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
