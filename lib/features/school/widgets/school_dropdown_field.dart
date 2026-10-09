import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? prefix;

  const SchoolDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            if (prefix != null) ...[
              SizedBox(
                width: 22,
                child: Center(child: prefix!),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: textBold.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
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
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
