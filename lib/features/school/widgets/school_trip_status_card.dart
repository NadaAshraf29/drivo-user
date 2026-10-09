import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolTripStatusCard extends StatelessWidget {
  final String status;

  const SchoolTripStatusCard({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Text(
        status,
        style: textSemiBold.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: const Color(0xFF059669),
        ),
      ),
    );
  }
}
