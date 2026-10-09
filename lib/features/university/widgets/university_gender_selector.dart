import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityGenderSelector extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;

  const UniversityGenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final genders = [
      {'key': 'male', 'label': 'male'.tr},
      {'key': 'female', 'label': 'female'.tr},
      {'key': 'both', 'label': 'both'.tr},
    ];

    return Row(
      children: genders.map((gender) {
        final isSelected = selectedGender == gender['key'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onGenderChanged(gender['key']!),
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
                    gender['label']!,
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
