import 'package:flutter/material.dart';

enum TooltipPosition {
  auto,
  top,
  bottom,
  left,
  right,
}

enum WalkthroughFlowType {
  home,
  regularRideSearch,
  workRideSearch,
  travelSearch,
  northCoastSearch,
  universitySearch,
  schoolSearch,
  customTripSearch,
  searchResults,
  booking,
}

class WalkthroughStep {
  final String id;
  final String targetKeyId;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final TooltipPosition preferredPosition;
  final EdgeInsets targetPadding;
  final double borderRadius;
  final bool autoScroll;
  final bool allowDirectTap;
  final VoidCallback? onStepEnter;
  final VoidCallback? onStepLeave;
  final bool Function()? isAvailable;

  const WalkthroughStep({
    required this.id,
    required this.targetKeyId,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    this.preferredPosition = TooltipPosition.auto,
    this.targetPadding = const EdgeInsets.all(8),
    this.borderRadius = 16,
    this.autoScroll = true,
    this.allowDirectTap = true,
    this.onStepEnter,
    this.onStepLeave,
    this.isAvailable,
  });
}
