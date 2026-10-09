import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripFieldTile extends StatelessWidget {
  final IconData icon;
  final String? label;
  final String value;
  final VoidCallback onTap;

  const TripFieldTile({
    super.key,
    required this.icon,
    this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: label != null && label!.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label!.toUpperCase(),
                          style: textBold.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          value,
                          style: textMedium.copyWith(
                            color: const Color(0xFF0F172A),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                  : Text(
                      value,
                      style: textMedium.copyWith(
                        color: const Color(0xFF0F172A),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            Icon(
              icon,
              color: const Color(0xFF94A3B8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
