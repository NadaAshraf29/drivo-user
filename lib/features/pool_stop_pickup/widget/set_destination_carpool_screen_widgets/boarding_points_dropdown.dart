import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class BoardingPointsDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? label;
  final IconData? leadingIcon;
  final Color leadingIconColor;

  const BoardingPointsDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.leadingIcon,
    this.leadingIconColor = const Color(0xFF06AAF2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, color: leadingIconColor, size: 18),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: DropdownButton<T>(
                value: value,
                hint: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label != null)
                      Text(
                        label!,
                        style: textBold.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    Text(
                      hint,
                      style: textMedium.copyWith(
                        color: const Color(0xFF0F172A),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Colors.black),
                items: items,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
