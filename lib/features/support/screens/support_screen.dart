import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/features/support/widgets/contact_us_view.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 246, 248, 248),
      resizeToAvoidBottomInset: false,
      body: BodyWidget(
        body: ContactUsView(),
      ),
    );
  }
}
