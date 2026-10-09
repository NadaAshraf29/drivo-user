import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripDetailsHeaderWidget extends StatelessWidget {
  final dynamic trip;

  const TripDetailsHeaderWidget({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final driver = trip.driver;
    final String driverName = (driver != null &&
            driver.fullName != null &&
            driver.fullName.isNotEmpty)
        ? driver.fullName
        : (trip.driverName ?? 'Ahmed Osman');
    final String? profileImage = driver?.profileImage;
    final String rating = trip.driver?.rating?.toString() ?? '4.9';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: profileImage != null && profileImage.isNotEmpty
                  ? Image.network(
                      profileImage,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackAvatar(context, driverName),
                    )
                  : _buildFallbackAvatar(context, driverName),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        driverName,
                        style: textBold.copyWith(
                          fontSize: 16,
                          color: const Color(0xFF1E2432),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: Color(0xFF00A3EC),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Color(0xFFFFB300),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating,
                            style: textBold.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF8D6E63),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'driver'.tr.isNotEmpty && !'driver'.tr.contains('driver')
                          ? 'driver'.tr
                          : 'Driver',
                      style: textMedium.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'carpool'.tr.isNotEmpty && !'carpool'.tr.contains('carpool')
                  ? 'carpool'.tr
                  : 'Carpool',
              style: textBold.copyWith(
                fontSize: 12,
                color: const Color(0xFF00A3EC),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar(BuildContext context, String name) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';
    return Container(
      width: 52,
      height: 52,
      color: const Color(0xFFE8F6FE),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: textBold.copyWith(
          fontSize: 20,
          color: const Color(0xFF00A3EC),
        ),
      ),
    );
  }
}
