import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class SosSaveButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  static const Color _primaryBlue = Color(0xFF00A3EC);

  const SosSaveButtonWidget({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ButtonWidget(
        buttonText: 'save'.tr,
        onPressed: onPressed,
        radius: 16,
        backgroundColor: _primaryBlue,
      ),
    );
  }
}
