import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:ride_sharing_user_app/common_widgets/country_picker_widget.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/domain/models/sign_up_body.dart';
import 'package:ride_sharing_user_app/features/settings/domain/html_enum_types.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/splash/screens/language_selection_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  final FocusNode _fNameNode = FocusNode();
  final FocusNode _lNameNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();
  final FocusNode _identityNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final FocusNode _confirmPasswordNode = FocusNode();
  final FocusNode _referralNode = FocusNode();

  // Selected Identity Type ('nid' = National ID, 'passport' = Passport)
  String _selectedIdentityType = 'nid';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isTermsAccepted = false;

  static const Color _primaryColor = Color(0xFF00A3EC);
  static const Color _darkHeading = Color(0xFF0F172A);
  static const Color _subText = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _bgLight = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();

    final config = Get.find<ConfigController>().config;
    if (config?.countryCode != null) {
      final dialCode =
          CountryCode.fromCountryCode(config!.countryCode!).dialCode;
      if (dialCode != null) {
        Get.find<AuthController>().countryDialCode = dialCode;
      }
    }
  }

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _phoneController.dispose();
    _identityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();

    _fNameNode.dispose();
    _lNameNode.dispose();
    _phoneNode.dispose();
    _identityNode.dispose();
    _passwordNode.dispose();
    _confirmPasswordNode.dispose();
    _referralNode.dispose();
    super.dispose();
  }

  void _openLanguageSelection() {
    Get.to(() => LanguageSelectionScreen(
          onLanguageSelected: () {
            Get.offAll(() => const SignUpScreen());
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isLtr = Get.find<LocalizationController>().isLtr;
    final bool hasReferral =
        Get.find<ConfigController>().config?.referralEarningStatus ?? false;

    final bool isNid = _selectedIdentityType == 'nid';

    return SafeArea(
      child: Scaffold(
        backgroundColor: _bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Center(
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: _darkHeading,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: _openLanguageSelection,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded,
                          size: 18, color: _primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        isLtr ? 'EN' : 'عربي',
                        style: textSemiBold.copyWith(
                          fontSize: 13,
                          color: _darkHeading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: GetBuilder<AuthController>(builder: (authController) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge, vertical: 12),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER LOGO & TITLE
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      Images.drivoLogo,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'sign_up'.tr,
                  style: textBold.copyWith(
                    color: _darkHeading,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'sign_up_message'.tr,
                  style: textMedium.copyWith(
                    color: _subText,
                    fontSize: Dimensions.fontSizeDefault,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // FIRST NAME & LAST NAME (SIDE BY SIDE)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('first_name'.tr),
                          const SizedBox(height: 8),
                          _buildTextInput(
                            controller: _fNameController,
                            focusNode: _fNameNode,
                            nextFocus: _lNameNode,
                            hintText: 'first_name'.tr,
                            prefixIcon: Icons.person_outline_rounded,
                            capitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('last_name'.tr),
                          const SizedBox(height: 8),
                          _buildTextInput(
                            controller: _lNameController,
                            focusNode: _lNameNode,
                            nextFocus: _phoneNode,
                            hintText: 'last_name'.tr,
                            prefixIcon: Icons.person_outline_rounded,
                            capitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // PHONE NUMBER FIELD
                _buildFieldLabel('phone'.tr),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CodePickerWidget(
                              flagWidth: 24,
                              padding: EdgeInsets.zero,
                              onChanged: (CountryCode countryCode) {
                                authController.countryDialCode =
                                    countryCode.dialCode!;
                                authController
                                    .setCountryCode(countryCode.dialCode!);
                              },
                              initialSelection: authController.countryDialCode,
                              showDropDownButton: true,
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              showFlagDialog: true,
                              hideMainText: true,
                              enabled: true,
                              showFlagMain: true,
                              dialogBackgroundColor: Colors.white,
                              textStyle: textMedium.copyWith(
                                fontSize: 14,
                                color: _darkHeading,
                              ),
                            ),
                            Text(
                              authController.countryDialCode,
                              style: textSemiBold.copyWith(
                                fontSize: 14,
                                color: _darkHeading,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: _borderColor,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          focusNode: _phoneNode,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          style: textMedium.copyWith(
                            fontSize: 15,
                            color: _darkHeading,
                          ),
                          decoration: InputDecoration(
                            hintText: 'phone'.tr,
                            hintStyle: textRegular.copyWith(
                              fontSize: 14,
                              color: _subText.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_identityNode);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // IDENTITY TYPE BUTTON SELECTOR (National ID & Passport Buttons)
                _buildFieldLabel('identity_type'.tr),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Row(
                    children: [
                      // National ID Button
                      Expanded(
                        child: _buildIdentityTypeButton(
                          title: 'National ID'.tr,
                          icon: Icons.badge_outlined,
                          isSelected: isNid,
                          onTap: () {
                            setState(() {
                              _selectedIdentityType = 'nid';
                              _identityController.clear();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Passport Button
                      Expanded(
                        child: _buildIdentityTypeButton(
                          title: 'passport'.tr,
                          icon: Icons.menu_book_rounded,
                          isSelected: !isNid,
                          onTap: () {
                            setState(() {
                              _selectedIdentityType = 'passport';
                              _identityController.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // DYNAMIC IDENTITY NUMBER INPUT FIELD
                _buildFieldLabel(isNid ? 'National ID'.tr : 'Passport'.tr),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _identityController,
                    focusNode: _identityNode,
                    keyboardType:
                        isNid ? TextInputType.number : TextInputType.text,
                    textInputAction: TextInputAction.next,
                    inputFormatters: isNid
                        ? [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(14),
                          ]
                        : [
                            LengthLimitingTextInputFormatter(20),
                          ],
                    style: textMedium.copyWith(
                      fontSize: 15,
                      color: _darkHeading,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          isNid ? 'Enter National ID'.tr : 'Enter Passport'.tr,
                      hintStyle: textRegular.copyWith(
                        fontSize: 14,
                        color: _subText.withOpacity(0.6),
                      ),
                      prefixIcon: Icon(
                        isNid ? Icons.badge_outlined : Icons.menu_book_rounded,
                        color: _primaryColor,
                        size: 20,
                      ),
                      suffixIcon: isNid
                          ? ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _identityController,
                              builder: (context, value, child) {
                                final length = value.text.length;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  child: Text(
                                    '$length/14',
                                    style: textMedium.copyWith(
                                      fontSize: 12,
                                      color: length == 14
                                          ? _primaryColor
                                          : _subText.withOpacity(0.6),
                                      fontWeight: length == 14
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordNode);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // PASSWORD FIELD
                _buildFieldLabel('password'.tr),
                const SizedBox(height: 8),
                _buildPasswordInput(
                  controller: _passwordController,
                  focusNode: _passwordNode,
                  nextFocus: _confirmPasswordNode,
                  hintText: 'enter_password'.tr,
                  isObscure: _obscurePassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // CONFIRM PASSWORD FIELD
                _buildFieldLabel('confirm_password'.tr),
                const SizedBox(height: 8),
                _buildPasswordInput(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordNode,
                  nextFocus: hasReferral ? _referralNode : null,
                  hintText: 'enter_confirm_password'.tr,
                  isObscure: _obscureConfirmPassword,
                  textInputAction:
                      hasReferral ? TextInputAction.next : TextInputAction.done,
                  onToggleObscure: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),

                // REFERRAL CODE (IF ENABLED)
                if (hasReferral) ...[
                  const SizedBox(height: 16),
                  _buildFieldLabel('refer_code'.tr),
                  const SizedBox(height: 8),
                  _buildTextInput(
                    controller: _referralCodeController,
                    focusNode: _referralNode,
                    hintText: 'refer_code'.tr,
                    prefixIcon: Icons.card_giftcard_outlined,
                    textInputAction: TextInputAction.done,
                  ),
                ],
                const SizedBox(height: 20),

                // TERMS & CONDITIONS CHECKBOX ROW
                InkWell(
                  onTap: () {
                    setState(() {
                      _isTermsAccepted = !_isTermsAccepted;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            checkColor: Colors.white,
                            activeColor: _primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: BorderSide(
                              color: _isTermsAccepted
                                  ? _primaryColor
                                  : _borderColor,
                              width: 1.5,
                            ),
                            value: _isTermsAccepted,
                            onChanged: (bool? isChecked) {
                              setState(() {
                                _isTermsAccepted = isChecked ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: '${'i_agree_to_the'.tr} ',
                              style: textMedium.copyWith(
                                color: _darkHeading,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: 'terms_and_condition'.tr,
                                  style: textBold.copyWith(
                                    color: _primaryColor,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(() => const PolicyScreen(
                                            htmlType:
                                                HtmlType.termsAndConditions,
                                          ));
                                    },
                                ),
                                TextSpan(
                                  text: ' ${'and'.tr} ',
                                  style: textMedium.copyWith(
                                    color: _darkHeading,
                                    fontSize: 13,
                                  ),
                                ),
                                TextSpan(
                                  text: 'privacy_policy'.tr,
                                  style: textBold.copyWith(
                                    color: _primaryColor,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(() => const PolicyScreen(
                                            htmlType: HtmlType.privacyPolicy,
                                          ));
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // SIGN UP BUTTON
                authController.isLoading
                    ? const Center(
                        child: SpinKitCircle(
                          color: _primaryColor,
                          size: 40.0,
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00B2FE), Color(0xFF0088D4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'sign_up'.tr,
                            style: textBold.copyWith(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),

                // ALREADY HAVE AN ACCOUNT? LOG IN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${'already_have_an_account'.tr} ',
                      style: textRegular.copyWith(
                        fontSize: 14,
                        color: _subText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text(
                        'log_in'.tr,
                        style: textBold.copyWith(
                          color: _primaryColor,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    ),
  );
}

  Widget _buildFieldLabel(String title) {
    return Text(
      title,
      style: textSemiBold.copyWith(
        fontSize: 14,
        color: _darkHeading,
      ),
    );
  }

  Widget _buildIdentityTypeButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42,
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : _subText,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: isSelected
                  ? textBold.copyWith(
                      fontSize: 13,
                      color: Colors.white,
                    )
                  : textMedium.copyWith(
                      fontSize: 13,
                      color: _darkHeading,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: capitalization,
        style: textMedium.copyWith(
          fontSize: 15,
          color: _darkHeading,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: textRegular.copyWith(
            fontSize: 14,
            color: _subText.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: _primaryColor,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
        onSubmitted: (_) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        },
      ),
    );
  }

  Widget _buildPasswordInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String hintText,
    required bool isObscure,
    required VoidCallback onToggleObscure,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isObscure,
        textInputAction: textInputAction,
        style: textMedium.copyWith(
          fontSize: 15,
          color: _darkHeading,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: textRegular.copyWith(
            fontSize: 14,
            color: _subText.withOpacity(0.6),
          ),
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: _primaryColor,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isObscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: _subText,
              size: 20,
            ),
            onPressed: onToggleObscure,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
        onSubmitted: (_) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        },
      ),
    );
  }

  void _handleSignUp() {
    final authController = Get.find<AuthController>();
    String fName = _fNameController.text.trim();
    String lName = _lNameController.text.trim();
    String phone = _phoneController.text.trim();
    String identityNumber = _identityController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (fName.isEmpty) {
      showCustomSnackBar('first_name_is_required'.tr);
      FocusScope.of(context).requestFocus(_fNameNode);
    } else if (lName.isEmpty) {
      showCustomSnackBar('last_name_is_required'.tr);
      FocusScope.of(context).requestFocus(_lNameNode);
    } else if (phone.isEmpty) {
      showCustomSnackBar('phone_is_required'.tr);
      FocusScope.of(context).requestFocus(_phoneNode);
    } else if (!PhoneNumber.parse(authController.countryDialCode + phone)
        .isValid(type: PhoneNumberType.mobile)) {
      showCustomSnackBar('phone_number_is_not_valid'.tr);
      FocusScope.of(context).requestFocus(_phoneNode);
    } else if (identityNumber.isEmpty) {
      showCustomSnackBar('identity_number_is_required'.tr);
      FocusScope.of(context).requestFocus(_identityNode);
    } else if (_selectedIdentityType == 'nid' && identityNumber.length != 14) {
      showCustomSnackBar('national_id_must_be_14_digits'.tr);
      FocusScope.of(context).requestFocus(_identityNode);
    } else if (password.isEmpty) {
      showCustomSnackBar('password_is_required'.tr);
      FocusScope.of(context).requestFocus(_passwordNode);
    } else if (password.length < 8) {
      showCustomSnackBar('minimum_password_length_is_8'.tr);
      FocusScope.of(context).requestFocus(_passwordNode);
    } else if (confirmPassword.isEmpty) {
      showCustomSnackBar('confirm_password_is_required'.tr);
      FocusScope.of(context).requestFocus(_confirmPasswordNode);
    } else if (password != confirmPassword) {
      showCustomSnackBar('password_is_mismatch'.tr);
      FocusScope.of(context).requestFocus(_confirmPasswordNode);
    } else if (!_isTermsAccepted) {
      showCustomSnackBar('please_accept_terms_and_conditions'.tr);
    } else {
      authController.register(SignUpBody(
        fName: fName,
        lName: lName,
        phone: authController.countryDialCode + phone,
        password: password,
        confirmPassword: confirmPassword,
        identificationType: _selectedIdentityType,
        identificationNumber: identityNumber,
        referralCode: _referralCodeController.text.trim(),
      ));
    }
  }
}
