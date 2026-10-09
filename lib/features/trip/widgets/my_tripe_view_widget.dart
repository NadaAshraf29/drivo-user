import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/my_tripe_item_widget.dart';

class MyTripeViewWidget extends StatelessWidget {
  const MyTripeViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return MyTripeItemWidget();
        });
  }
}
