import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SeatsDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int?> onChanged;
  final String? label;

  const SeatsDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final int safeValue = (value >= 1 && value <= 3) ? value : 1;
    final displayLabel = label ??
        ('seats'.tr.isNotEmpty && 'seats'.tr != 'seats'
            ? 'seats'.tr
            : 'SEATS');

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: safeValue,
            isExpanded: true,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            focusColor: Colors.transparent,
            elevation: 3,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
            selectedItemBuilder: (BuildContext context) {
              return const [1, 2, 3].map((int seatNum) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayLabel.toUpperCase(),
                      style: textBold.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$seatNum ${seatNum == 1 ? ('seat'.tr.isNotEmpty && 'seat'.tr != 'seat' ? 'seat'.tr : 'Seat') : ('seats'.tr.isNotEmpty && 'seats'.tr != 'seats' ? 'seats'.tr : 'Seats')}',
                      style: textMedium.copyWith(
                        color: const Color(0xFF0F172A),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              }).toList();
            },
            items: const [1, 2, 3].map(
              (seatNum) {
                final isSelected = seatNum == safeValue;
                return DropdownMenuItem<int>(
                  value: seatNum,
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE0F2FE)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$seatNum ${seatNum == 1 ? ('seat'.tr.isNotEmpty && 'seat'.tr != 'seat' ? 'seat'.tr : 'Seat') : ('seats'.tr.isNotEmpty && 'seats'.tr != 'seats' ? 'seats'.tr : 'Seats')}',
                          style: (isSelected ? textBold : textMedium).copyWith(
                            color: isSelected
                                ? const Color(0xFF0284C7)
                                : const Color(0xFF0F172A),
                            fontSize: 13,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF00A0E9),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
