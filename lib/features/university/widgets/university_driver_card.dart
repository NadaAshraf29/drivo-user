import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityDriverCard extends StatelessWidget {
  final String driverName;
  final String vehicle;
  final double rating;
  final String? driverImage;
  final VoidCallback onDetails;

  const UniversityDriverCard({
    super.key,
    required this.driverName,
    required this.vehicle,
    required this.rating,
    this.driverImage,
    required this.onDetails,
  });

  String _fullImageUrl(String? img) {
    if (img == null || img.isEmpty) return '';
    if (img.startsWith('http://') || img.startsWith('https://')) return img;
    if (Get.isRegistered<ConfigController>()) {
      final config = Get.find<ConfigController>().config;
      if (config?.imageBaseUrl?.profileImageDriver != null) {
        return '${config!.imageBaseUrl!.profileImageDriver}/$img';
      }
    }
    return img;
  }

  @override
  Widget build(BuildContext context) {
    final initial = driverName.isNotEmpty ? driverName[0].toUpperCase() : 'D';
    final imageUrl = _fullImageUrl(driverImage);
    final displayRating = (rating > 0) ? rating.toStringAsFixed(1) : '5.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(44),
              child: imageUrl.isNotEmpty
                  ? ImageWidget(
                      image: imageUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      placeholder: Images.personPlaceholder,
                    )
                  : Center(
                      child: Text(
                        initial,
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: const Color(0xFF00A0E9),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'driver'.tr.toUpperCase(),
                  style: textRegular.copyWith(
                    fontSize: 10,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  driverName,
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        vehicle,
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      displayRating,
                      style: textSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onDetails,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'details'.tr,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

