import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/parcel/screens/parcel_screen.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/screens/set_destination_carpool_screen.dart';
import 'package:ride_sharing_user_app/features/university/screens/university_search_screen.dart';
import 'package:ride_sharing_user_app/features/school/screens/school_search_screen.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'home_compact_type_card.dart';
import 'home_sahel_card.dart';
import 'home_school_routes_card.dart';

class HomeCarpoolSection extends StatelessWidget {
  const HomeCarpoolSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'get_moving'.tr,
          style: textBold.copyWith(
            fontSize: 20,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        HomeCompactTypeCard(
          icon: Icons.people_alt_rounded,
          title: 'Anytime Rides'.tr,
          subtitle: 'Book a ride Instantly'.tr,
          iconColor: const Color(0xFF0284C7),
          iconBackgroundColor: const Color(0xFFE0F2FE),
          onTap: () => Get.to(
            () => const SetDestinationCarPoolScreen(
              carpoolType: 'trip',
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        // Top Row: Sahel (Left) + Travel & University (Right)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: HomeSahelCard(
                  onTap: () => Get.to(
                    () => const SetDestinationCarPoolScreen(
                      carpoolType: 'north_coast',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: HomeCompactTypeCard(
                        icon: Icons.flight_takeoff_rounded,
                        title: 'travel'.tr,
                        subtitle: 'travel_from_and_to_anywhere_in_egypt'.tr,
                        iconColor: const Color(0xFF0284C7),
                        iconBackgroundColor: const Color(0xFFE0F2FE),
                        onTap: () => Get.to(
                          () => const SetDestinationCarPoolScreen(
                            carpoolType: 'travel',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: HomeCompactTypeCard(
                        icon: Icons.school_rounded,
                        title: 'university'.tr,
                        subtitle: 'affordable_and_safe_rides'.tr,
                        iconColor: const Color(0xFF7E22CE),
                        iconBackgroundColor: const Color(0xFFF3E8FF),
                        onTap: () => Get.to(
                          () => const UniversitySearchScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Middle Row: Routine & Parcel
        Row(
          children: [
            Expanded(
              child: HomeCompactTypeCard(
                icon: Icons.sync_alt_rounded,
                title: 'Work Rides'.tr,
                subtitle: 'monthly_rides'.tr,
                iconColor: const Color(0xFFE65100),
                iconBackgroundColor: const Color(0xFFFFF3E0),
                onTap: () => Get.to(
                  () => const SetDestinationCarPoolScreen(
                    carpoolType: 'routine',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HomeCompactTypeCard(
                icon: Icons.inventory_2_outlined,
                title: 'parcel'.tr,
                subtitle: 'send_packages_anywhere'.tr,
                iconColor: const Color(0xFF0284C7),
                iconBackgroundColor: const Color(0xFFE0F2FE),
                onTap: () => Get.to(() => const ParcelScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Bottom Row: School routes
        HomeSchoolRoutesCard(
          onTap: () => Get.to(() => const SchoolSearchScreen()),
        ),
      ],
    );
  }
}

// ==========================================
// ARCHIVED PREVIOUS GRID LAYOUT
// ==========================================
/*
class _OldHomeCarpoolSection extends StatelessWidget {
  const _OldHomeCarpoolSection();

  @override
  Widget build(BuildContext context) {
    List<String> titles = [
      "One Trip".tr,
      "Travel".tr,
      "Routine".tr,
      "North Coast".tr,
    ];
    List<String> subtitles = [
      "Book a ride instantly".tr,
      "Travel from and to anywhere in Egypt".tr,
      "Weekly and Monthly rides".tr,
      "Summer trips inside north coast".tr
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: List.generate(
        titles.length,
        (index) => HomeCarpoolCard(
          icon: [
            Icons.directions_car,
            Icons.flight_takeoff,
            Icons.repeat,
            Icons.beach_access,
          ][index],
          title: titles[index],
          subtitle: subtitles[index],
          color: [
            Colors.teal,
            Colors.blue,
            Colors.orange,
            Colors.purple,
          ][index],
          onTap: () => Get.to(() => SetDestinationCarPoolScreen(
                carpoolType: [
                  'trip',
                  'travel',
                  'routine',
                  'north_coast',
                ][index],
              )),
        ),
      ),
    );
  }
}
*/
