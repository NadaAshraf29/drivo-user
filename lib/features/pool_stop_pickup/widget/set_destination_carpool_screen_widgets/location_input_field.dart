import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_search_field.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class LocationInputField extends StatelessWidget {
  final bool isReadOnly;
  final FocusNode? focusNode;
  final Widget? prefix;
  final String? label;
  final String? hint;
  final TextEditingController controller;
  final Future<dynamic> Function(String) onChanged;
  final VoidCallback? onTap;
  final VoidCallback onMapTap;
  final Color? mapIconColor;

  const LocationInputField({
    super.key,
    required this.isReadOnly,
    this.focusNode,
    required this.controller,
    required this.onChanged,
    this.onTap,
    required this.onMapTap,
    this.prefix,
    this.label,
    this.hint,
    this.mapIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (prefix != null)
            SizedBox(
              width: 22,
              child: Center(child: prefix!),
            ),
          SizedBox(width: prefix != null ? 8 : 0),
          Expanded(
            child: label == null
                ? CustomSearchField(
                    isReadOnly: isReadOnly,
                    focusNode: focusNode,
                    controller: controller,
                    hint: hint ?? 'location'.tr,
                    onChanged: onChanged,
                    onTap: onTap ?? () {},
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label!.toUpperCase(),
                        style: textBold.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(
                        height: 24,
                        child: CustomSearchField(
                          isReadOnly: isReadOnly,
                          focusNode: focusNode,
                          controller: controller,
                          hint: hint ?? 'location'.tr,
                          onChanged: onChanged,
                          onTap: onTap ?? () {},
                          contentPadding: 0,
                        ),
                      ),
                    ],
                  ),
          ),
          InkWell(
            onTap: onMapTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: Icon(
                Icons.location_on_outlined,
                color: mapIconColor ?? const Color(0xFF00A0E9),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
