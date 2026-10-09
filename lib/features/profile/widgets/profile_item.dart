import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? icon;
  final IconData? iconData;
  final Function()? onTap;
  final bool divider;
  final bool isDestructive;
  final Widget? trailing;
  final String? badgeText;

  const ProfileMenuItem({
    super.key,
    required this.title,
    this.icon,
    this.iconData,
    this.subtitle,
    this.onTap,
    this.divider = true,
    this.isDestructive = false,
    this.trailing,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDestructive
        ? const Color(0xFFEF5350)
        : const Color(0xFF00A3EC);
    final iconBgColor = isDestructive
        ? const Color(0xFFFFEBEE)
        : const Color(0xFFE8F6FE);
    final textColor = isDestructive
        ? const Color(0xFFD32F2F)
        : const Color(0xFF1E2432);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: icon != null
                        ? Image.asset(
                            icon!,
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                            color: primaryColor,
                          )
                        : Icon(
                            iconData ?? Icons.circle,
                            size: 20,
                            color: primaryColor,
                          ),
                  ),
                  const SizedBox(width: 14),

                  // Title & optional subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.tr,
                          style: textSemiBold.copyWith(
                            fontSize: 15,
                            color: textColor,
                            fontWeight: isDestructive
                                ? FontWeight.w600
                                : FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!.tr,
                            style: textRegular.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF8C94A3),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Badge or trailing
                  if (badgeText != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A3EC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText!.tr,
                        style: textBold.copyWith(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  if (trailing != null)
                    trailing!
                  else if (!isDestructive)
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: Color(0xFFB0B7C3),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (divider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: Color(0xFFF0F3F7),
            ),
          ),
      ],
    );
  }
}
