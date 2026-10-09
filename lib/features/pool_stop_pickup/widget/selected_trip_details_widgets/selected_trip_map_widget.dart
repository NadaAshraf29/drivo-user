import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_details_screen_widgets/search_trip_details_map_preview_widget.dart';

class SelectedTripMapWidget extends StatelessWidget {
  final dynamic trip;
  final VoidCallback onTap;

  const SelectedTripMapWidget({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SearchTripDetailsMapPreviewWidget(
        trip: trip,
        fromSearch: true,
        onTap: onTap,
      ),
    );
  }
}
