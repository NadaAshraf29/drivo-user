import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarpoolPaymentUploadCardWidget extends StatelessWidget {
  final File? screenshot;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const CarpoolPaymentUploadCardWidget({
    super.key,
    required this.screenshot,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (screenshot != null) {
      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF08A9F0), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                screenshot!,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.65),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'payment_screenshot_uploaded'.tr,
                    textAlign: TextAlign.center,
                    style: textSemiBold.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.file_upload_outlined,
              color: Color(0xFF94A3B8),
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              'upload_payment_screen'.tr,
              style: textRegular.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
