import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class HowItWorksButton extends StatelessWidget {
  final VoidCallback onTap;
  final String? customLabel;
  final bool compact;

  const HowItWorksButton({
    super.key,
    required this.onTap,
    this.customLabel,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = (Get.isRegistered<LocalizationController>() &&
            Get.find<LocalizationController>().locale.languageCode == 'ar') ||
        Get.locale?.languageCode == 'ar';

    final label = customLabel ?? (isArabic ? 'طريقة الاستخدام' : 'How it works');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 5 : 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2FE).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFBAE6FD),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00A0E9).withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.help_outline_rounded,
              size: 15,
              color: Color(0xFF0284C7),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: textBold.copyWith(
                fontSize: compact ? 11 : 12,
                color: const Color(0xFF0284C7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
