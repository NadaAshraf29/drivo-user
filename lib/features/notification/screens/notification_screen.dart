import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/notification/controllers/notification_controller.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_card.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    Get.find<NotificationController>().getNotificationList(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(
              'notifications'.tr,
              style: textBold.copyWith(
                color: const Color(0xFF1E2432),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All your Drivo notifications in one place.',
              style: textRegular.copyWith(
                color: const Color(0xFF8C94A3),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            GetBuilder<NotificationController>(builder: (notificationController) {
              return notificationController.notificationModel != null ?
              (notificationController.notificationModel!.data != null && notificationController.notificationModel!.data!.isNotEmpty) ?
              SingleChildScrollView(controller: scrollController,
                child: PaginatedListWidget(
                  scrollController: scrollController,
                  showPaginationButton: false,
                  totalSize: notificationController.notificationModel!.totalSize,
                  offset: (notificationController.notificationModel != null && notificationController.notificationModel!.offset != null) ?
                  int.parse(notificationController.notificationModel!.offset.toString()) : null,
                  onPaginate: (int? offset) async {
                    await notificationController.getNotificationList(offset!);
                  },
                  itemView: ListView.builder(
                    itemCount: notificationController.notificationModel!.data!.length,
                    padding: const EdgeInsets.all(0),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return NotificationCard(
                        previousNotification: index == 0 ? null : notificationController.notificationModel!.data![index - 1],
                        notification: notificationController.notificationModel!.data![index],
                        nextNotification: (index == notificationController.notificationModel!.data!.length-1) ? null : notificationController.notificationModel!.data![index + 1],
                      );
                    },
                  ),
                ),
              ) :
              const NoDataWidget(title: 'no_notification_found') :
              const NotificationShimmer();
            }),

            const SizedBox(height: 120),
          ]),
        ),
      ),
    );
  }
}
