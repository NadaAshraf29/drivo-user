import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityUploadReceiptCard extends StatelessWidget {
  final File? receiptImage;
  final ValueChanged<File?> onImageSelected;

  const UniversityUploadReceiptCard({
    super.key,
    required this.receiptImage,
    required this.onImageSelected,
  });

  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        onImageSelected(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (receiptImage != null) {
      return Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00A0E9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                receiptImage!,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => onImageSelected(null),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: const Color(0xFF00A0E9).withOpacity(0.9),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'payment_screenshot_uploaded'.tr,
                        style: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.upload_rounded,
              size: 28,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 8),
            Text(
              'upload_payment_screen'.tr,
              style: textMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
// ==================== ARCHIVED CODE ====================
// class UniversityUploadReceiptCard extends StatelessWidget {
//   final bool hasUploaded;
//   final VoidCallback onUpload;
// 
//   const UniversityUploadReceiptCard({
//     super.key,
//     required this.hasUploaded,
//     required this.onUpload,
//   });
// 
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onUpload,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         width: double.infinity,
//         height: 120,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: hasUploaded
//                 ? const Color(0xFF00A0E9)
//                 : const Color(0xFFE2E8F0),
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.02),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               hasUploaded ? Icons.check_circle_rounded : Icons.upload_rounded,
//               size: 28,
//               color: hasUploaded
//                   ? const Color(0xFF00A0E9)
//                   : const Color(0xFF94A3B8),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               hasUploaded
//                   ? 'payment_screenshot_uploaded'.tr
//                   : 'upload_payment_screen'.tr,
//               style: textMedium.copyWith(
//                 fontSize: Dimensions.fontSizeSmall,
//                 color: hasUploaded
//                     ? const Color(0xFF00A0E9)
//                     : const Color(0xFF64748B),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// =======================================================
*/
