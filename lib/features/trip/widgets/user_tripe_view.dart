import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/user_tripe_item.dart';

class UserTripeView extends StatelessWidget {
  const UserTripeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) => UserTripeItem(
        index: index,
      ),
    );
  }
}
