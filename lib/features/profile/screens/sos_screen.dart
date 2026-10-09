import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/widgets/sos_form_widget.dart';
import 'package:ride_sharing_user_app/features/profile/widgets/sos_save_button_widget.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameRelationController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _nameRelationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEmergencyContact();
    });
  }

  void _loadEmergencyContact() {
    final profileController = Get.find<ProfileController>();
    final profileData = profileController.profileModel?.data;

    if (profileData?.emergencyContactName != null &&
        profileData!.emergencyContactName!.isNotEmpty) {
      _nameRelationController.text = profileData.emergencyContactName!;
    }
    if (profileData?.emergencyContactPhone != null &&
        profileData!.emergencyContactPhone!.isNotEmpty) {
      _phoneController.text = profileData.emergencyContactPhone!;
    }

    profileController.getEmergencyContact().then((response) {
      if (!mounted) return;
      if (response.statusCode == 200 &&
          response.body != null &&
          response.body['data'] != null) {
        final data = response.body['data'];
        if (data['emergency_contact_name'] != null) {
          _nameRelationController.text = data['emergency_contact_name'];
        }
        if (data['emergency_contact_phone'] != null) {
          _phoneController.text = data['emergency_contact_phone'];
        }
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameRelationController.dispose();
    _phoneFocusNode.dispose();
    _nameRelationFocusNode.dispose();
    super.dispose();
  }

  void _saveEmergencyContact() {
    final String nameRelation = _nameRelationController.text.trim();
    final String phone = _phoneController.text.trim();

    if (nameRelation.isEmpty) {
      showCustomSnackBar('please_enter_contact_name'.tr);
      return;
    }
    if (phone.isEmpty) {
      showCustomSnackBar('please_enter_phone_number'.tr);
      return;
    }

    Get.find<ProfileController>()
        .saveEmergencyContact(nameRelation, phone)
        .then((response) {
      if (!mounted) return;
      if (response.statusCode == 200) {
        showCustomSnackBar('emergency_contact_saved'.tr, isError: false);
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 248, 248),
      body: BodyWidget(
        body: SafeArea(
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
                          'SoS / Emergency Contact'.tr,
                          style: textBold.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          'Keep your emergency contact up to date'.tr,
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

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Safety Info Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFCDD2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF5350),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.health_and_safety_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Emergency Contact'.tr,
                                      style: textBold.copyWith(
                                        color: const Color(0xFFC62828),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'In case of emergency, you can trigger SOS during active trips to alert your trusted contact and our safety response team.'.tr,
                                      style: textRegular.copyWith(
                                        color: const Color(0xFFD32F2F),
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Form Section
                        SosFormWidget(
                          phoneController: _phoneController,
                          nameRelationController: _nameRelationController,
                          phoneFocusNode: _phoneFocusNode,
                          nameRelationFocusNode: _nameRelationFocusNode,
                        ),
                      ],
                    ),
                  ),
                ),

                SosSaveButtonWidget(
                  onPressed: _saveEmergencyContact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
