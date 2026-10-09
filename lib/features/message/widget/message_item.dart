import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/message/domain/models/channel_model.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/message/screens/message_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';

class MessageItem extends StatelessWidget {
  final bool isRead;
  final ChannelUsers? channelUsers;
  final String lastMessage;
  final String tripId;
  final int unReadCount;

  const MessageItem({
    super.key,
    this.isRead = false,
    required this.channelUsers,
    required this.lastMessage,
    required this.tripId,
    this.unReadCount = 0,
  });

  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  @override
  Widget build(BuildContext context) {
    if (channelUsers == null) return const SizedBox.shrink();

    final user = channelUsers?.user;
    final userName =
        '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    final profileImage = user?.profileImage ?? '';
    final hasUnread = unReadCount > 0;

    return Container(
      decoration: BoxDecoration(
        color: hasUnread ? const Color(0xFFF4FAFD) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasUnread ? _primaryBlue.withOpacity(0.3) : _cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.to(
            () => MessageScreen(
              channelId: channelUsers!.channelId!,
              tripId: tripId,
              userName: userName.isNotEmpty ? userName : 'Driver'.tr,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Avatar with border
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF3F5F8),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: ImageWidget(
                          height: 50,
                          width: 50,
                          image:
                              '${Get.find<ConfigController>().config?.imageBaseUrl?.profileImageDriver}/$profileImage',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: _primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Name & Message preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              userName.isNotEmpty ? userName : 'Driver'.tr,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: textBold.copyWith(
                                fontSize: 15,
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: _textDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateConverter
                                .isoDateTimeStringToDifferentWithCurrentTime(
                              channelUsers?.updatedAt ??
                                  DateTime.now().toString(),
                            ),
                            style: textRegular.copyWith(
                              fontSize: 11,
                              color: hasUnread ? _primaryBlue : _textSubtle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage.isNotEmpty
                                  ? lastMessage
                                  : 'send_an_attachment'.tr,
                              style: hasUnread
                                  ? textSemiBold.copyWith(
                                      fontSize: 13,
                                      color: _textDark,
                                    )
                                  : textRegular.copyWith(
                                      fontSize: 13,
                                      color: _textSubtle,
                                    ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _primaryBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                unReadCount.toString(),
                                style: textBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
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
