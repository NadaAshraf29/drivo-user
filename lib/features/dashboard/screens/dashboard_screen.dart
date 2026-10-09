import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/domain/models/navigation_model.dart';
import 'package:ride_sharing_user_app/features/home/screens/home_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/notification/screens/notification_screen.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import '../../message/controllers/message_controller.dart';
import 'package:ride_sharing_user_app/features/walkthrough/controllers/walkthrough_controller.dart';
import 'package:ride_sharing_user_app/features/walkthrough/helpers/walkthrough_helper.dart';

class DashboardScreen extends StatefulWidget {
  final int initialTabIndex;
  const DashboardScreen({super.key, this.initialTabIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageStorageBucket bucket = PageStorageBucket();
  final GlobalKey _activityKey = GlobalKey();
  final GlobalKey _notificationKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.initialTabIndex != 0) {
      Get.find<BottomMenuController>().setTabIndex(widget.initialTabIndex);
    }
    if (Get.isRegistered<WalkthroughController>()) {
      final walkthroughCtrl = Get.find<WalkthroughController>();
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetHomeNavActivity, _activityKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetHomeNavNotifications, _notificationKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetHomeNavProfile, _profileKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<NavigationModel> item = [
      NavigationModel(
        name: 'home'.tr,
        activeIcon: Images.homeActive,
        inactiveIcon: Images.homeOutline,
        screen: const HomeScreen(),
      ),
      // NavigationModel(
      // //   name: "carpool".tr,
      // //   activeIcon: Images.peopleIcon,
      // //   inactiveIcon: Images.peopleoutlineIcon,
      // //   screen: const CarpoolScreen(),
      // // ),
      NavigationModel(
        name: 'activity'.tr,
        activeIcon: Images.activityActive,
        inactiveIcon: Images.activityOutline,
        screen:
            // WelcomePoolScreen()

            const TripScreen(fromProfile: false),
      ),
      NavigationModel(
        name: 'notification'.tr,
        activeIcon: Images.notificationActive,
        inactiveIcon: Images.notificationOutline,
        screen: const NotificationScreen(),
      ),
      NavigationModel(
        name: 'profile'.tr,
        activeIcon: Images.profileActive,
        inactiveIcon: Images.profileOutline,
        screen: const ProfileScreen(),
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, val) async {
        if (Get.find<BottomMenuController>().currentTab != 0) {
          Get.find<BottomMenuController>().setTabIndex(0);
          return;
        } else {
          Get.find<BottomMenuController>().exitApp();
        }
        return;
      },
      child: GetBuilder<BottomMenuController>(
        builder: (menuController) {
          return Scaffold(
            floatingActionButton:
                GetBuilder<MessageController>(builder: (messageController) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00B2FE), Color(0xFF0088D4)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00A3EC).withOpacity(0.38),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  elevation: 0,
                  focusElevation: 0,
                  hoverElevation: 0,
                  highlightElevation: 0,
                  backgroundColor: Colors.transparent,
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    messageController.createChannelWithAdmin();
                  },
                ),
              );
            }),
            resizeToAvoidBottomInset: false,
            // extendBody lets the Stack paint underneath the floating nav bar
            extendBody: true,
            body: Stack(
              children: [
                PageStorage(
                    bucket: bucket,
                    child: item[menuController.currentTab].screen),
              ],
            ),
            bottomNavigationBar: ValueListenableBuilder<bool>(
              valueListenable:
                  Get.find<LocationController>().bottomNavVisibility,
              builder: (context, showBottomNav, child) {
                // Only show the bottom navigation bar if:
                // 1. locationController.bottomNavVisibility is true, OR
                // 2. we're not on the home screen (currentTab != 0)
                bool shouldShowBottomBar =
                    showBottomNav || menuController.currentTab != 0;

                return shouldShowBottomBar
                    ? SafeArea(
                        top: false,
                        left: false,
                        right: false,
                        bottom: true,
                        child: Container(
                          margin: const EdgeInsets.only(
                            left: Dimensions.paddingSizeDefault,
                            right: Dimensions.paddingSizeDefault,
                            bottom: Dimensions.paddingSizeDefault,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                height: 65,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .cardColor
                                      .withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Get.isDarkMode
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.6),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: generateBottomNavigationItems(
                                        menuController, item)),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  List<Widget> generateBottomNavigationItems(
      BottomMenuController menuController, List<NavigationModel> item) {
    List<Widget> items = [];
    for (int index = 0; index < item.length; index++) {
      Key? itemKey;
      if (index == 1) itemKey = _activityKey;
      if (index == 2) itemKey = _notificationKey;
      if (index == 3) itemKey = _profileKey;

      items.add(Expanded(
          child: KeyedSubtree(
        key: itemKey,
        child: CustomMenuItem(
          isSelected: menuController.currentTab == index,
          name: item[index].name,
          activeIcon: item[index].activeIcon,
          inActiveIcon: item[index].inactiveIcon,
          onTap: () => menuController.setTabIndex(index),
        ),
      )));
    }
    return items;
  }
}

class CustomMenuItem extends StatelessWidget {
  final bool isSelected;
  final String name;
  final String activeIcon;
  final String inActiveIcon;
  final VoidCallback onTap;

  const CustomMenuItem({
    super.key,
    required this.isSelected,
    required this.name,
    required this.activeIcon,
    required this.inActiveIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
            width: isSelected ? 90 : 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  isSelected ? activeIcon : inActiveIcon,
                  color: activeIcon == Images.carTripeIcon && !isSelected
                      ? Colors.white.withOpacity(0.5)
                      : isSelected
                      ? activeIcon == Images.notificationActive
                        ? const Color(0xFF06AAF2)
                        : const Color(0xFF08A9F0)
                          : Colors.grey,
                  width: Dimensions.menuIconSize,
                  height: Dimensions.menuIconSize,
                ),
                isSelected
                    ? Text(name.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(
                            color: isSelected
                                ? const Color(0xFF08A9F0)
                                : Colors.white,
                            fontSize: Dimensions.fontSizeExtraSmall))
                    : const SizedBox(),
              ],
            )),
      ),
    );
  }
}
