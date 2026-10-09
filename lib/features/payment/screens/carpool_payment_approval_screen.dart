import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_approval_notice_widget.dart';

class CarpoolPaymentApprovalScreen extends StatelessWidget {
  const CarpoolPaymentApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('payment'.tr),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: CarpoolPaymentApprovalNoticeWidget(),
        ),
      ),
    );
  }
}
