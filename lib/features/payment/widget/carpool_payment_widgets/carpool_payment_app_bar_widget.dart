import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarpoolPaymentAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;

  const CarpoolPaymentAppBarWidget({super.key, this.onBackPressed});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: InkWell(
            onTap: onBackPressed ?? () => Get.back(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Color(0xFF1E293B),
                size: 24,
              ),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'payment'.tr,
            style: textBold.copyWith(
              fontSize: 22,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
