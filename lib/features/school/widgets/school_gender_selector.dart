import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolGenderSelector extends StatelessWidget {
  final String selectedGender;
  final Function(String) onGenderSelected;

  const SchoolGenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    final genders = [
      {'key': 'male', 'label': 'male'.tr},
      {'key': 'female', 'label': 'female'.tr},
      {'key': 'both', 'label': 'both'.tr},
    ];

    return Row(
      children: genders.map((item) {
        final isSelected = selectedGender.toLowerCase() == item['key'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onGenderSelected(item['key']!),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00A0E9)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00A0E9)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    item['label']!,
                    style: textBold.copyWith(
                      fontSize: 13,
                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
