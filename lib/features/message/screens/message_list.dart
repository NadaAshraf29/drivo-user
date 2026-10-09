import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/message/controllers/message_controller.dart';
import 'package:ride_sharing_user_app/features/message/domain/models/channel_model.dart';
import 'package:ride_sharing_user_app/features/message/widget/message_item.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    Get.find<MessageController>().getChannelList(1);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 248, 248),
      body: BodyWidget(
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                // Top Navigation Bar
                Row(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Get.back(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _cardBorder),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: _textDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Messages'.tr,
                          style: textBold.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          'Conversations with drivers & support'.tr,
                          style: textRegular.copyWith(
                            fontSize: 12,
                            color: _textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Messages Content List
                Expanded(
                  child: GetBuilder<MessageController>(
                    builder: (messageController) {
                      if (messageController.channelModel?.data == null) {
                        return const NotificationShimmer();
                      }

                      if (messageController.channelModel!.data!.isEmpty) {
                        return Center(
                          child: SingleChildScrollView(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Glowing Icon Container
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF00A3EC)
                                        .withOpacity(0.08),
                                    border: Border.all(
                                      color: const Color(0xFF00A3EC)
                                          .withOpacity(0.18),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF00B2FE),
                                            Color(0xFF0088D4),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00A3EC)
                                                .withOpacity(0.35),
                                            blurRadius: 14,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 26,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),

                                Text(
                                  'no_chat_found'.tr,
                                  style: textBold.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _textDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  'Your conversations with drivers and support will appear here.'
                                      .tr,
                                  style: textRegular.copyWith(
                                    fontSize: 13,
                                    color: _textSubtle,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),

                                // Start Support Chat Action Button
                                InkWell(
                                  onTap: () => messageController
                                      .createChannelWithAdmin(),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00A3EC),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00A3EC)
                                              .withOpacity(0.28),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.support_agent_rounded,
                                          color: Colors.white,
                                          size: 19,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'talk_to_admin'.tr,
                                          style: textBold.copyWith(
                                            color: Colors.white,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        controller: scrollController,
                        child: PaginatedListWidget(
                          reverse: true,
                          scrollController: scrollController,
                          totalSize: messageController.channelModel!.totalSize,
                          offset: messageController.channelModel?.offset != null
                              ? int.tryParse(messageController
                                      .channelModel!.offset
                                      .toString()) ??
                                  1
                              : 1,
                          onPaginate: (int? offset) async {
                            await messageController.getChannelList(offset!);
                          },
                          itemView: ListView.separated(
                            itemCount:
                                messageController.channelModel!.data!.length,
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (BuildContext context, int index) {
                              final channelData =
                                  messageController.channelModel!.data![index];
                              ChannelUsers? channelUser;
                              if (channelData.channelUsers != null) {
                                for (var element
                                    in channelData.channelUsers!) {
                                  if (element.user?.userType == 'driver') {
                                    channelUser = element;
                                  }
                                }
                              }

                              return channelData.lastChannelConversations != null
                                  ? MessageItem(
                                      isRead: false,
                                      channelUsers: channelUser,
                                      unReadCount:
                                          channelData.unReadCount ?? 0,
                                      lastMessage: channelData
                                              .lastChannelConversations
                                              ?.message ??
                                          '',
                                      tripId: channelData.tripId ?? '',
                                    )
                                  : const SizedBox();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
