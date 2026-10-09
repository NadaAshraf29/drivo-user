import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
import 'package:ride_sharing_user_app/features/message/controllers/message_controller.dart';
import 'package:ride_sharing_user_app/features/message/domain/models/message_model.dart';
import 'package:ride_sharing_user_app/features/message/widget/message_bubble.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageScreen extends StatefulWidget {
  final String channelId;
  final String tripId;
  final String userName;
  final String? profileImage;
  final String? userPhone;
  final bool isAdminChat;

  const MessageScreen({
    super.key,
    required this.channelId,
    required this.tripId,
    required this.userName,
    this.profileImage,
    this.userPhone,
    this.isAdminChat = false,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);
  static const Color _bgScreen = Color(0xFFF8FAFC);

  StreamSubscription<RemoteMessage>? _messageSubscription;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  List<String> get _quickReplies {
    if (widget.isAdminChat) {
      return [
        "Need help with ride 🚗",
        "Payment inquiry 💳",
        "Lost an item 🎒",
        "Account assistance 👤",
        "Thank you! 🙏",
      ];
    } else {
      return [
        "I'm on my way 🚗",
        "I'm outside 👋",
        "I've arrived 📍",
        "Where are you? 🗺️",
        "Wait 2 mins please ⏳",
        "Thank you! 🙏",
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    final messageController = Get.find<MessageController>();
    messageController.conversationController.clear();
    messageController.cleanOldData();

    _loadData();
    _listenToPushMessages();
  }

  void _listenToPushMessages() {
    _messageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final action = message.data['action'];
      if (action == 'new_message_arrived' ||
          action == 'admin_message' ||
          message.data.containsKey('body')) {
        Get.find<MessageController>().getConversation(widget.channelId, 1);
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    final messageController = Get.find<MessageController>();
    messageController.conversationController.clear();
    messageController.cleanOldData();
    messageController.messageModel = null;
    super.dispose();
  }

  Future _loadData() async {
    if (Get.find<ProfileController>().profileModel?.data?.id == null) {
      await Get.find<ProfileController>().getProfileInfo();
    }
    final messageController = Get.find<MessageController>();
    messageController.conversationController.clear();
    messageController.cleanOldData();

    // Fetch and display complete chat history
    await messageController.getConversation(widget.channelId, 1);

    if (!widget.isAdminChat) {
      messageController.findChannelRideStatus(widget.channelId);
      messageController.subscribeMessageChannel(widget.tripId);
    }
  }

  void _callUser() async {
    if (widget.userPhone != null && widget.userPhone!.isNotEmpty) {
      final clean = widget.userPhone!.replaceAll(' ', '');
      final uri = Uri.parse('tel:$clean');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        showCustomSnackBar('cannot_make_phone_call'.tr);
      }
    }
  }

  /// Automatically sends the quick reply phrase immediately
  void _sendQuickReply(String text) {
    final messageController = Get.find<MessageController>();
    if (messageController.isSending) return;
    messageController.conversationController.text = text;
    messageController.sendMessage(
      widget.channelId,
      widget.tripId,
      isAdminChat: widget.isAdminChat,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: _bgScreen,
        body: SafeArea(
          child: Column(
            children: [
              // 1. TOP APP BAR
              _buildTopHeader(context),

              // 2. CONVERSATION MESSAGES LIST
              Expanded(
                child: GetBuilder<MessageController>(
                  builder: (messageController) {
                    if (messageController.messageModel?.data == null) {
                      return const NotificationShimmer();
                    }

                    if (messageController.messageModel!.data!.isEmpty) {
                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _primaryBlue.withOpacity(0.08),
                                  border: Border.all(
                                    color: _primaryBlue.withOpacity(0.18),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 50,
                                    height: 50,
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
                                          color: _primaryBlue.withOpacity(0.35),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'no_message_found'.tr,
                                style: textBold.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Send a message or tap any phrase below to start the conversation.'
                                    .tr,
                                style: textRegular.copyWith(
                                  fontSize: 12.5,
                                  color: _textSubtle,
                                  height: 1.35,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: PaginatedListWidget(
                        reverse: true,
                        scrollController: _scrollController,
                        totalSize: messageController.messageModel?.totalSize,
                        offset: (messageController.messageModel != null &&
                                messageController.messageModel?.offset != null)
                            ? int.parse(messageController.messageModel!.offset
                                .toString())
                            : null,
                        onPaginate: (int? offset) async {
                          await messageController.getConversation(
                              widget.channelId, offset!);
                        },
                        itemView: ListView.builder(
                          reverse: true,
                          itemCount:
                              messageController.messageModel?.data?.length,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            if (index != 0) {
                              return ConversationBubble(
                                message: messageController
                                    .messageModel!.data![index],
                                previousMessage: messageController
                                    .messageModel!.data![index - 1],
                                index: index,
                                length: messageController
                                    .messageModel!.data!.length,
                              );
                            } else {
                              return ConversationBubble(
                                message: messageController
                                    .messageModel!.data![index],
                                index: index,
                                length: messageController
                                    .messageModel!.data!.length,
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 3. ATTACHMENT PREVIEWS
              GetBuilder<MessageController>(
                builder: (messageController) {
                  return Column(
                    children: [
                      _buildImageAttachmentPreview(messageController),
                      _buildFileAttachmentPreview(messageController),
                    ],
                  );
                },
              ),

              // 4. SMART QUICK REPLIES CHIPS BAR (Auto-Send on click)
              GetBuilder<MessageController>(
                builder: (messageController) {
                  final bool canSend =
                      widget.isAdminChat || messageController.channelRideStatus;
                  if (!canSend) return const SizedBox.shrink();
                  return _buildQuickRepliesBar();
                },
              ),

              // 5. COMPACT BOTTOM INPUT BAR OR DISABLED NOTICE
              GetBuilder<MessageController>(
                builder: (messageController) {
                  final bool canSend =
                      widget.isAdminChat || messageController.channelRideStatus;

                  if (!canSend) {
                    return _buildTripEndedNotice();
                  }

                  return _buildInputBar(context, messageController);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// TOP APP BAR HEADER
  Widget _buildTopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: _cardBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          Material(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Get.back(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _cardBorder),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: _textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // User / Admin Avatar
          Stack(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF1F5F9),
                  border: Border.all(color: _cardBorder, width: 1.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: widget.isAdminChat
                      ? const Icon(
                          Icons.support_agent_rounded,
                          color: _primaryBlue,
                          size: 22,
                        )
                      : ImageWidget(
                          height: 38,
                          width: 38,
                          image: widget.profileImage != null &&
                                  widget.profileImage!.isNotEmpty
                              ? '${Get.find<ConfigController>().config?.imageBaseUrl?.profileImageDriver}/${widget.profileImage}'
                              : '',
                          placeholder: Images.personPlaceholder,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),

          // Name and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.userName.isNotEmpty
                      ? widget.userName
                      : (widget.isAdminChat ? 'Support Team'.tr : 'Driver'.tr),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textBold.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.isAdminChat
                            ? 'Drivo Support · Online'.tr
                            : widget.tripId.isNotEmpty
                                ? '${'Trip'.tr} #${widget.tripId.length > 8 ? widget.tripId.substring(widget.tripId.length - 6) : widget.tripId}'
                                : 'Active Ride'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(
                          fontSize: 11,
                          color: _textSubtle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action: Call Driver (if phone provided)
          if (widget.userPhone != null && widget.userPhone!.isNotEmpty)
            Material(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _callUser,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.25),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.phone_rounded,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// SMART QUICK REPLIES BAR (Instant Auto-Send)
  Widget _buildQuickRepliesBar() {
    return Container(
      height: 36,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: _quickReplies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final reply = _quickReplies[index];
          return Material(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _sendQuickReply(reply),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                alignment: Alignment.center,
                child: Text(
                  reply,
                  style: textMedium.copyWith(
                    fontSize: 11.5,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// IMAGE ATTACHMENT PREVIEW
  Widget _buildImageAttachmentPreview(MessageController messageController) {
    if (messageController.pickedImageFile == null ||
        messageController.pickedImageFile!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 76,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: messageController.pickedImageFile!.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _cardBorder),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(messageController.pickedImageFile![index].path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: GestureDetector(
                  onTap: () =>
                      messageController.pickMultipleImage(true, index: index),
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// FILE ATTACHMENT PREVIEW
  Widget _buildFileAttachmentPreview(MessageController messageController) {
    if (messageController.otherFile == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.insert_drive_file_rounded,
                  color: _primaryBlue,
                  size: 16,
                ),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(
                    messageController.otherFile!.names.first ?? 'Attachment',
                    style:
                        textMedium.copyWith(fontSize: 11.5, color: _textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => messageController.pickOtherFile(true),
            child: const Icon(
              Icons.cancel_rounded,
              color: Color(0xFFEF4444),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  /// COMPACT & SLEEK BOTTOM INPUT BAR
  Widget _buildInputBar(
      BuildContext context, MessageController messageController) {
    final bool isLtr = Get.find<LocalizationController>().isLtr;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: _cardBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment Button
          Material(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(19),
            child: InkWell(
              borderRadius: BorderRadius.circular(19),
              onTap: () => messageController.pickMultipleImage(false),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: _cardBorder),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.attach_file_rounded,
                  color: _primaryBlue,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),

          // Message Input Field (Compact & Sleek)
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 40, minHeight: 38),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Form(
                key: messageController.conversationKey,
                child: Center(
                  child: TextField(
                    focusNode: _inputFocusNode,
                    minLines: 1,
                    maxLines: 3,
                    controller: messageController.conversationController,
                    textCapitalization: TextCapitalization.sentences,
                    style: textRegular.copyWith(
                      fontSize: 13.5,
                      color: _textDark,
                    ),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                      hintText: 'type_here'.tr,
                      hintStyle: textRegular.copyWith(
                        color: _textSubtle,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),

          // Compact Send Action Button
          Material(
            color: _primaryBlue,
            borderRadius: BorderRadius.circular(19),
            child: InkWell(
              borderRadius: BorderRadius.circular(19),
              onTap: () {
                if (messageController.conversationController.text
                        .trim()
                        .isEmpty &&
                    messageController.pickedImageFile!.isEmpty &&
                    messageController.otherFile == null) {
                  showCustomSnackBar('write_something'.tr, isError: true);
                } else if (messageController.conversationKey.currentState!
                    .validate()) {
                  messageController
                      .sendMessage(
                        widget.channelId,
                        widget.tripId,
                        isAdminChat: widget.isAdminChat,
                      )
                      .then((value) {});
                  messageController.conversationController.clear();
                }
              },
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryBlue.withOpacity(0.32),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: messageController.isSending ||
                        messageController.isImagePicked
                    ? const SpinKitCircle(color: Colors.white, size: 18)
                    : Transform(
                        alignment: Alignment.center,
                        transform: isLtr
                            ? Matrix4.rotationY(0)
                            : Matrix4.rotationY(math.pi),
                        child: const Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// INACTIVE TRIP NOTICE
  Widget _buildTripEndedNotice() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 16,
            color: _textSubtle,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "you_could't_replay_you_have_no_trip".tr,
              textAlign: TextAlign.center,
              style: textMedium.copyWith(
                fontSize: 12.5,
                color: _textSubtle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
