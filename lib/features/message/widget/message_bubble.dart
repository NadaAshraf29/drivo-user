import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ride_sharing_user_app/common_widgets/popup_banner/popup_banner.dart';
import 'package:ride_sharing_user_app/features/message/domain/models/message_model.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';

class ConversationBubble extends StatefulWidget {
  final Message message;
  final Message? previousMessage;
  final int index;
  final int length;

  const ConversationBubble({
    super.key,
    required this.message,
    this.previousMessage,
    required this.index,
    required this.length,
  });

  @override
  State<ConversationBubble> createState() => _ConversationBubbleState();
}

class _ConversationBubbleState extends State<ConversationBubble> {
  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  List<String> images = [];

  @override
  Widget build(BuildContext context) {
    images = [];
    final bool isMe = widget.message.user?.id ==
        Get.find<ProfileController>().profileModel?.data?.id;

    if (widget.message.conversationFiles != null) {
      for (var element in widget.message.conversationFiles!) {
        images.add(
            '${Get.find<ConfigController>().config!.imageBaseUrl!.conversation}/${element.fileName ?? ''}');
      }
    }

    final bool showTripHeader = (widget.length - 1 == widget.index);
    final bool showTripChange = widget.previousMessage != null &&
        widget.message.tripId != widget.previousMessage?.tripId;

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // TRIP HEADER CHIP
        if (showTripHeader) ...[
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cardBorder),
              ),
              child: Text(
                "${DateConverter.stringToLocalDateOnly(widget.message.createdAt ?? DateTime.now().toString())} · ${'trip'.tr} #${widget.index == 0 ? widget.message.tripId : widget.previousMessage?.tripId}",
                style: textMedium.copyWith(
                  color: _textSubtle,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // MESSAGE CONTENT ROW
        Padding(
          padding: EdgeInsets.fromLTRB(
            isMe ? 48 : 12,
            3,
            isMe ? 12 : 48,
            3,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              // Driver / Admin Avatar for incoming messages
              if (!isMe) ...[
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF3F5F8),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: ImageWidget(
                      height: 32,
                      width: 32,
                      image:
                          '${Get.find<ConfigController>().config?.imageBaseUrl?.profileImageDriver}/${widget.message.user?.profileImage ?? ''}',
                      placeholder: Images.personPlaceholder,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Message Body Bubble
              Flexible(
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // Text Bubble
                    if (widget.message.message != null &&
                        widget.message.message!.trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? _primaryBlue : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isMe ? 18 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 18),
                          ),
                          border: isMe ? null : Border.all(color: _cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: isMe
                                  ? _primaryBlue.withOpacity(0.18)
                                  : Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.message.message ?? '',
                          style: textRegular.copyWith(
                            color: isMe ? Colors.white : _textDark,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ),

                    // File / Image Attachments
                    if (widget.message.conversationFiles != null &&
                        widget.message.conversationFiles!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Directionality(
                        textDirection:
                            Get.find<LocalizationController>().isLtr
                                ? (isMe
                                    ? TextDirection.rtl
                                    : TextDirection.ltr)
                                : (isMe
                                    ? TextDirection.ltr
                                    : TextDirection.rtl),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: List.generate(
                            widget.message.conversationFiles!.length,
                            (index) {
                              final file = widget
                                  .message.conversationFiles![index];
                              final fileType =
                                  (file.fileType ?? '').toLowerCase();
                              final bool isImage = fileType == 'png' ||
                                  fileType == 'jpg' ||
                                  fileType == 'jpeg' ||
                                  fileType == 'webp';

                              if (isImage) {
                                return InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => PopupBanner(
                                    context: context,
                                    images: images,
                                    initIndex: index,
                                    dotsAlignment: Alignment.bottomCenter,
                                    onClick: (_) {},
                                    autoSlide: false,
                                    fit: BoxFit.contain,
                                  ).show(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: ImageWidget(
                                      height: 110,
                                      width: 110,
                                      fit: BoxFit.cover,
                                      image:
                                          '${Get.find<ConfigController>().config!.imageBaseUrl!.conversation}/${file.fileName ?? ''}',
                                    ),
                                  ),
                                );
                              }

                              return InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () async {
                                  final status =
                                      await Permission.storage.request();
                                  if (status.isGranted) {
                                    Directory? directory = Directory(
                                        '/storage/emulated/0/Download');
                                    if (!await directory.exists()) {
                                      directory = Platform.isAndroid
                                          ? await getExternalStorageDirectory()
                                          : await getApplicationSupportDirectory();
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _cardBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.insert_drive_file_rounded,
                                        color: _primaryBlue,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                            maxWidth: 140),
                                        child: Text(
                                          file.fileName ?? 'file',
                                          style: textMedium.copyWith(
                                            fontSize: 12,
                                            color: _textDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],

                    // Timestamp
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        DateConverter
                            .isoDateTimeStringToDifferentWithCurrentTime(
                          widget.message.createdAt ??
                              DateTime.now().toString(),
                        ),
                        style: textRegular.copyWith(
                          fontSize: 10,
                          color: _textSubtle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // TRIP CHANGE SEPARATOR
        if (showTripChange) ...[
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cardBorder),
              ),
              child: Text(
                "${DateConverter.stringToLocalDateOnly(widget.previousMessage?.createdAt ?? DateTime.now().toString())} · ${'trip'.tr} #${widget.index == 0 ? widget.message.tripId : widget.previousMessage?.tripId}",
                style: textMedium.copyWith(
                  color: _textSubtle,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
