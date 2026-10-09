import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SosFormWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController nameRelationController;
  final FocusNode phoneFocusNode;
  final FocusNode nameRelationFocusNode;

  static const Color _textDark = Color(0xFF1E2432);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  const SosFormWidget({
    super.key,
    required this.phoneController,
    required this.nameRelationController,
    required this.phoneFocusNode,
    required this.nameRelationFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'contact_name_or_relation'.tr,
            style: textSemiBold.copyWith(
              fontSize: 13,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: nameRelationController,
            focusNode: nameRelationFocusNode,
            nextFocus: phoneFocusNode,
            inputType: TextInputType.text,
            capitalization: TextCapitalization.words,
            hintText: 'e.g. Father, Sister, Ahmed'.tr,
            prefixIcon: Images.editProfileName,
            borderRadius: 12,
            showBorder: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
          const SizedBox(height: 18),
          Text(
            'contact_phone_number'.tr,
            style: textSemiBold.copyWith(
              fontSize: 13,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: phoneController,
            focusNode: phoneFocusNode,
            inputType: TextInputType.phone,
            hintText: 'e.g. +20 100 000 0000'.tr,
            prefixIcon: Images.editProfilePhone,
            borderRadius: 12,
            showBorder: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ],
      ),
    );
  }
}
