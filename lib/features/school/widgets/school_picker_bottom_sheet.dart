import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolPickerBottomSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String> onSelected;

  const SchoolPickerBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: textBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
              itemBuilder: (ctx, index) {
                final item = items[index];
                final isSelected = item == selectedItem;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE0F2FE)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    title: Text(
                      item,
                      style: (isSelected ? textBold : textRegular).copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: isSelected
                            ? const Color(0xFF0284C7)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF00A0E9),
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      onSelected(item);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
