import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/message/controllers/message_controller.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  @override
  Widget build(BuildContext context) {
    final email =
        Get.find<ConfigController>().config?.businessContactEmail ?? 'support@drivo.com';
    final phone =
        Get.find<ConfigController>().config?.businessContactPhone ?? '+20 100 000 0000';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                      'help_and_support'.tr,
                      style: textBold.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    Text(
                      'We are here to help you 24/7'.tr,
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

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Support Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00A3EC), Color(0xFF0083BE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryBlue.withOpacity(0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.support_agent_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '24/7 Available'.tr,
                                  style: textBold.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'How can we help you?'.tr,
                            style: textBold.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Have questions about a trip or payment? Talk with our support team or reach out directly.'.tr,
                            style: textRegular.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Primary Live Chat Button
                    GetBuilder<MessageController>(
                      builder: (messageController) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryBlue.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ButtonWidget(
                            buttonText: 'talk_to_admin'.tr,
                            icon: Icons.chat_bubble_rounded,
                            radius: 18,
                            backgroundColor: _primaryBlue,
                            onPressed: () {
                              messageController.createChannelWithAdmin();
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // SECTION: DIRECT CONTACT CHANNELS
                    Text(
                      'CONTACT CHANNELS'.tr,
                      style: textSemiBold.copyWith(
                        color: _textSubtle,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          children: [
                            // Email Us Tile
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  await launchUrl(
                                    Uri(scheme: 'mailto', path: email),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F6FE),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.email_outlined,
                                          color: _primaryBlue,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'contact_us_through_email'.tr,
                                              style: textSemiBold.copyWith(
                                                fontSize: 14,
                                                color: _textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              email,
                                              style: textRegular.copyWith(
                                                fontSize: 13,
                                                color: _textSubtle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.open_in_new_rounded,
                                        size: 18,
                                        color: Color(0xFFB0B7C3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(
                                height: 1,
                                thickness: 0.8,
                                color: Color(0xFFF0F3F7),
                              ),
                            ),

                            // Call Us Tile
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  await launchUrl(
                                    Uri(scheme: 'tel', path: phone),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.phone_outlined,
                                          color: Color(0xFF2E7D32),
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'contact_us_through_phone'.tr,
                                              style: textSemiBold.copyWith(
                                                fontSize: 14,
                                                color: _textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              phone,
                                              style: textRegular.copyWith(
                                                fontSize: 13,
                                                color: _textSubtle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.open_in_new_rounded,
                                        size: 18,
                                        color: Color(0xFFB0B7C3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
