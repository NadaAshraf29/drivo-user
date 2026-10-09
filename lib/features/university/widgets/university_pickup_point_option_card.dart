import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityPickupPointOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? distanceText;
  final String? tag;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onNavigate;

  const UniversityPickupPointOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.distanceText,
    this.tag,
    required this.isSelected,
    required this.onTap,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF6FE) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00A0E9)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF00A0E9).withOpacity(0.08)
                  : Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00A0E9) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00A0E9)
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: isSelected
                          ? const Color(0xFF00A0E9)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: isSelected
                          ? const Color(0xFF00A0E9)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  if (distanceText != null && distanceText!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.near_me_rounded,
                          size: 12,
                          color: isSelected
                              ? const Color(0xFF00A0E9)
                              : const Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            distanceText!,
                            style: textMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: isSelected
                                  ? const Color(0xFF00A0E9)
                                  : const Color(0xFF0284C7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (tag != null && tag!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      tag!,
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: const Color(0xFF00A0E9),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onNavigate != null) ...[
              const SizedBox(width: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onNavigate,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF00A0E9).withOpacity(0.15)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00A0E9).withOpacity(0.3)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.directions_rounded,
                        size: 20,
                        color: isSelected
                            ? const Color(0xFF00A0E9)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
