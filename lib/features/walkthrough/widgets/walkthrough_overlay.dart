import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import '../controllers/walkthrough_controller.dart';
import '../domain/models/walkthrough_model.dart';

class WalkthroughOverlayWidget extends StatefulWidget {
  const WalkthroughOverlayWidget({super.key});

  @override
  State<WalkthroughOverlayWidget> createState() =>
      _WalkthroughOverlayWidgetState();
}

class _WalkthroughOverlayWidgetState extends State<WalkthroughOverlayWidget>
  with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _animController.addListener(_updateTargetRect);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTargetRect();
    });
  }

  @override
  void dispose() {
    _animController.removeListener(_updateTargetRect);
    _animController.dispose();
    super.dispose();
  }

  void _updateTargetRect() {
    if (!mounted) return;
    final controller = Get.find<WalkthroughController>();
    final step = controller.currentStep;
    if (step != null) {
      final rect = controller.getTargetRect(step.targetKeyId);
      if (rect != null && rect != _targetRect) {
        setState(() {
          _targetRect = rect;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalkthroughController>(
      builder: (controller) {
        if (!controller.isActive || controller.currentStep == null) {
          return const SizedBox.shrink();
        }

        final step = controller.currentStep!;
        final screenSize = MediaQuery.of(context).size;
        final safePadding = MediaQuery.of(context).padding;

        // Fetch target rect
        final currentRect = controller.getTargetRect(step.targetKeyId);
        final targetRect = currentRect ?? _targetRect ??
            Rect.fromCenter(
              center: Offset(screenSize.width / 2, screenSize.height / 2),
              width: 100,
              height: 50,
            );

        final paddedRect = RRect.fromRectAndRadius(
          Rect.fromLTRB(
            targetRect.left - step.targetPadding.left,
            targetRect.top - step.targetPadding.top,
            targetRect.right + step.targetPadding.right,
            targetRect.bottom + step.targetPadding.bottom,
          ),
          Radius.circular(step.borderRadius),
        );

        final isArabic = (Get.isRegistered<LocalizationController>() &&
                Get.find<LocalizationController>().locale.languageCode == 'ar') ||
            Get.locale?.languageCode == 'ar';

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // 1. Dimmed background with animated cutout
              Positioned.fill(
                child: TweenAnimationBuilder<Rect?>(
                  tween: RectTween(
                    begin: paddedRect.outerRect,
                    end: paddedRect.outerRect,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  builder: (context, animatedRect, child) {
                    final animatedRRect = RRect.fromRectAndRadius(
                      animatedRect ?? paddedRect.outerRect,
                      Radius.circular(step.borderRadius),
                    );
                    return CustomPaint(
                      painter: _SpotlightPainter(
                        targetRRect: animatedRRect,
                        scrimColor: Colors.black.withValues(alpha: 0.72),
                      ),
                    );
                  },
                ),
              ),

              // 2. Animated Glowing Border Ring around target
              Positioned.fromRect(
                rect: paddedRect.outerRect,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(step.borderRadius),
                        border: Border.all(
                          color: const Color(0xFF00A0E9).withValues(alpha: 0.85),
                          width: 2.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00A0E9)
                                .withValues(alpha: 0.35 * _pulseAnimation.value),
                            blurRadius: 16 * _pulseAnimation.value,
                            spreadRadius: 2 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 3. Direct Tap Detector over highlighted component
              if (step.allowDirectTap)
                Positioned.fromRect(
                  rect: paddedRect.outerRect,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      // Allow passing tap to advance
                      controller.nextStep();
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),

              // 4. Floating Tooltip Card
              _buildTooltip(
                context: context,
                step: step,
                targetRect: paddedRect.outerRect,
                screenSize: screenSize,
                safePadding: safePadding,
                controller: controller,
                isArabic: isArabic,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTooltip({
    required BuildContext context,
    required WalkthroughStep step,
    required Rect targetRect,
    required Size screenSize,
    required EdgeInsets safePadding,
    required WalkthroughController controller,
    required bool isArabic,
  }) {
    final tooltipWidth = (screenSize.width - 40).clamp(280.0, 380.0);
    const tooltipEstimatedHeight = 190.0;

    // Determine vertical placement dynamically to prevent overlapping target
    double top;
    final spaceBelow = screenSize.height - safePadding.bottom - targetRect.bottom;
    final spaceAbove = targetRect.top - safePadding.top;
    const requiredHeight = tooltipEstimatedHeight + 14;

    bool placeBelow = true;
    if (step.preferredPosition == TooltipPosition.bottom) {
      if (spaceBelow >= requiredHeight) {
        placeBelow = true;
      } else if (spaceAbove >= requiredHeight) {
        placeBelow = false;
      } else {
        placeBelow = spaceBelow >= spaceAbove;
      }
    } else if (step.preferredPosition == TooltipPosition.top) {
      if (spaceAbove >= requiredHeight) {
        placeBelow = false;
      } else if (spaceBelow >= requiredHeight) {
        placeBelow = true;
      } else {
        placeBelow = spaceBelow >= spaceAbove;
      }
    } else {
      if (spaceBelow >= requiredHeight) {
        placeBelow = true;
      } else if (spaceAbove >= requiredHeight) {
        placeBelow = false;
      } else {
        placeBelow = spaceBelow >= spaceAbove;
      }
    }

    if (placeBelow) {
      top = (targetRect.bottom + 14).clamp(
        safePadding.top + 10,
        screenSize.height - safePadding.bottom - tooltipEstimatedHeight - 10,
      );
    } else {
      top = (targetRect.top - tooltipEstimatedHeight - 14).clamp(
        safePadding.top + 10,
        screenSize.height - safePadding.bottom - tooltipEstimatedHeight - 10,
      );
    }

    // Horizontal centering
    final left = ((screenSize.width - tooltipWidth) / 2).clamp(16.0, screenSize.width - tooltipWidth - 16);

    final title = isArabic ? step.titleAr : step.title;
    final description = isArabic ? step.descriptionAr : step.description;
    final stepNum = controller.currentStepIndex + 1;
    final totalSteps = controller.activeSteps.length;
    final isLastStep = controller.currentStepIndex == totalSteps - 1;

    return Positioned(
      left: left,
      top: top,
      width: tooltipWidth,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.9 + 0.1 * value,
            alignment: placeBelow ? Alignment.topCenter : Alignment.bottomCenter,
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 12),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: const Color(0xFF00A0E9).withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Header Row: Step Badge + Skip button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Step pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isArabic ? 'خطوة $stepNum من $totalSteps' : 'Step $stepNum of $totalSteps',
                      style: const TextStyle(
                        color: Color(0xFF0284C7),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        fontFamily: 'SFProText',
                      ),
                    ),
                  ),

                  // Skip Button
                  InkWell(
                    onTap: () => controller.skip(),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Text(
                        isArabic ? 'تخطي' : 'Skip',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          fontFamily: 'SFProText',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                title,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  fontFamily: 'SFProText',
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                description,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  fontFamily: 'SFProText',
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),

              // Action Buttons Row (Back, Next/Got It)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button (if index > 0)
                  if (controller.currentStepIndex > 0)
                    InkWell(
                      onTap: () => controller.previousStep(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isArabic)
                              const Icon(Icons.arrow_back_rounded,
                                  size: 15, color: Color(0xFF475569)),
                            if (!isArabic) const SizedBox(width: 4),
                            Text(
                              isArabic ? 'السابق' : 'Back',
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                fontFamily: 'SFProText',
                              ),
                            ),
                            if (isArabic) const SizedBox(width: 4),
                            if (isArabic)
                              const Icon(Icons.arrow_forward_rounded,
                                  size: 15, color: Color(0xFF475569)),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // Next / Done Button
                  InkWell(
                    onTap: () => controller.nextStep(),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00B2FE), Color(0xFF0088D4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00A0E9).withValues(alpha: 0.32),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLastStep
                                ? (isArabic ? 'فهمت' : 'Got it')
                                : (isArabic ? 'التالي' : 'Next'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              fontFamily: 'SFProText',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isLastStep
                                ? Icons.check_rounded
                                : (isArabic
                                    ? Icons.arrow_back_rounded
                                    : Icons.arrow_forward_rounded),
                            color: Colors.white,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final RRect targetRRect;
  final Color scrimColor;

  _SpotlightPainter({
    required this.targetRRect,
    required this.scrimColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()..addRRect(targetRRect);

    final combinedPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final paint = Paint()
      ..color = scrimColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(combinedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRRect != targetRRect ||
        oldDelegate.scrimColor != scrimColor;
  }
}
