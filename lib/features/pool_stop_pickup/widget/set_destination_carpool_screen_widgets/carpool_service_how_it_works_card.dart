import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarpoolServiceHowItWorksCard extends StatelessWidget {
  final String carpoolType;

  const CarpoolServiceHowItWorksCard({
    super.key,
    required this.carpoolType,
  });

  String _getServiceTitle() {
    switch (carpoolType) {
      case 'routine':
        return 'Routine Daily Commute'.tr;
      case 'travel':
        return 'Intercity Travel Carpool'.tr;
      case 'north_coast':
        return 'North Coast Getaway'.tr;
      default:
        return 'Smart Shared Carpool'.tr;
    }
  }

  String _getServiceDesc() {
    switch (carpoolType) {
      case 'routine':
        return 'Scheduled daily shared rides between work, university and home with verified community drivers.'
            .tr;
      case 'travel':
        return 'Comfortable, scheduled long-distance rides between governorates at affordable shared rates.'
            .tr;
      case 'north_coast':
        return 'Direct coastal trips with comfortable vehicles, designated boarding points, and flexible timing.'
            .tr;
      default:
        return 'Share your route with verified drivers heading the same way and save up to 70% of ride costs.'
            .tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRoutine = carpoolType == 'routine';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF00A0E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isRoutine
                        ? Icons.repeat_rounded
                        : Icons.directions_car_filled_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getServiceTitle(),
                        style: textBold.copyWith(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'How it works & Benefits'.tr,
                        style: textMedium.copyWith(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Service Description Paragraph
                Text(
                  _getServiceDesc(),
                  style: textRegular.copyWith(
                    fontSize: 13,
                    height: 1.45,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Key Benefits Highlights Grid
                Text(
                  'Key Benefits'.tr,
                  style: textBold.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildBenefitPill(
                        icon: Icons.verified_user_outlined,
                        title: 'Verified Drivers'.tr,
                        subtitle: 'Safe & Rated'.tr,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildBenefitPill(
                        icon: Icons.savings_outlined,
                        title: 'Save up to 70%'.tr,
                        subtitle: 'Split Ride Cost'.tr,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildBenefitPill(
                        icon: Icons.access_time_rounded,
                        title: 'Fixed Schedules'.tr,
                        subtitle: 'No Detours'.tr,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildBenefitPill(
                        icon: Icons.ac_unit_rounded,
                        title: 'Air Conditioned'.tr,
                        subtitle: 'Clean & Comfort'.tr,
                        color: const Color(0xFF06B6D4),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                const SizedBox(height: 16),

                // 4. How It Works Steps
                Text(
                  '3 Simple Steps'.tr,
                  style: textBold.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),

                _buildStepItem(
                  stepNumber: '1',
                  title: 'Select Route & Time'.tr,
                  description:
                      'Enter your pickup, destination, dates, and preferred departure time.'
                          .tr,
                ),
                const SizedBox(height: 14),
                _buildStepItem(
                  stepNumber: '2',
                  title: 'View Matching Driver Routes'.tr,
                  description:
                      'Tap "Find trips" to see all available drivers and nearest pickup points on the map.'
                          .tr,
                ),
                const SizedBox(height: 14),
                _buildStepItem(
                  stepNumber: '3',
                  title: 'Confirm Seat & Enjoy Ride'.tr,
                  description:
                      'Select your trip, review meeting spots, book your seat, and commute easily!'
                          .tr,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitPill({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textBold.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: textRegular.copyWith(
                    fontSize: 9.5,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String stepNumber,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  stepNumber,
                  style: textBold.copyWith(
                    fontSize: 13,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: const Color(0xFFE2E8F0),
                margin: const EdgeInsets.symmetric(vertical: 3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textSemiBold.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: textRegular.copyWith(
                  fontSize: 11,
                  height: 1.35,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
