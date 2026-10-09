import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/ride_request_item.dart';

class RideRequestView extends StatelessWidget {
  const RideRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return RideRequestItem();
        });
  }
}
