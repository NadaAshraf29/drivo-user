import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/country_picker_widget.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/forgot_password_screen.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_up_screen.dart';
import 'package:ride_sharing_user_app/features/settings/domain/html_enum_types.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/splash/screens/language_selection_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  bool _obscurePassword = true;

  static const Color _primaryColor = Color(0xFF00A3EC);
  static const Color _darkHeading = Color(0xFF0F172A);
  static const Color _subText = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _bgLight = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();

    if (Get.find<AuthController>().getUserNumber(false).isNotEmpty) {
      _phoneController.text = Get.find<AuthController>().getUserNumber(false);
    }
    _passwordController.text = Get.find<AuthController>().getUserPassword(false);

    if (_passwordController.text.isNotEmpty) {
      Get.find<AuthController>().setRememberMe();
    }

    final config = Get.find<ConfigController>().config;
    if (Get.find<AuthController>().getLoginCountryCode(false).isNotEmpty) {
      Get.find<AuthController>().countryDialCode =
          Get.find<AuthController>().getLoginCountryCode(false);
    } else if (config?.countryCode != null) {
      final dialCode =
          CountryCode.fromCountryCode(config!.countryCode!).dialCode;
      if (dialCode != null) {
        Get.find<AuthController>().countryDialCode = dialCode;
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _phoneController.dispose();
    _phoneNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  void _openLanguageSelection() {
    Get.to(() => LanguageSelectionScreen(
          onLanguageSelected: () {
            Get.offAll(() => const SignInScreen());
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isLtr = Get.find<LocalizationController>().isLtr;

    return SafeArea(
      child: Scaffold(
        backgroundColor: _bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BRANDING LOGO
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        Images.drivoLogo,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // HEADINGS
                  Text(
                    'log_in'.tr,
                    style: textBold.copyWith(
                      color: _darkHeading,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'log_in_message'.tr,
                    style: textMedium.copyWith(
                      color: _subText,
                      fontSize: Dimensions.fontSizeDefault,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // PHONE FIELD LABEL
                  _buildFieldLabel('phone'.tr),
                  const SizedBox(height: 8),

                  // PHONE INPUT CONTAINER
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
                        // Country Code Picker
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
                        // Number Input
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
                              FocusScope.of(context)
                                  .requestFocus(_passwordNode);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // PASSWORD FIELD LABEL
                  _buildFieldLabel('password'.tr),
                  const SizedBox(height: 8),

                  // PASSWORD INPUT CONTAINER
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
                      controller: _passwordController,
                      focusNode: _passwordNode,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      style: textMedium.copyWith(
                        fontSize: 15,
                        color: _darkHeading,
                      ),
                      decoration: InputDecoration(
                        hintText: 'enter_password'.tr,
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
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: _subText,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // REMEMBER ME & FORGOT PASSWORD ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => authController.toggleRememberMe(),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 2),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: _primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  side: BorderSide(
                                    color: authController.isActiveRememberMe
                                        ? _primaryColor
                                        : _borderColor,
                                    width: 1.5,
                                  ),
                                  value: authController.isActiveRememberMe,
                                  onChanged: (bool? isChecked) =>
                                      authController.toggleRememberMe(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'remember'.tr,
                                style: textMedium.copyWith(
                                  fontSize: 13,
                                  color: _darkHeading,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(() => const ForgotPasswordScreen());
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'forgot_password?'.tr,
                          style: textSemiBold.copyWith(
                            fontSize: 13,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // LOGIN BUTTON
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
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'log_in'.tr,
                              style: textBold.copyWith(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 24),

                  // SIGN UP PROMPT
                  if (!(Get.find<ConfigController>().config?.externalSystem ??
                      false)) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${'do_not_have_an_account'.tr} ',
                          style: textRegular.copyWith(
                            fontSize: 14,
                            color: _subText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const SignUpScreen());
                          },
                          child: Text(
                            'sign_up'.tr,
                            style: textBold.copyWith(
                              color: _primaryColor,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],

                  // TERMS AND CONDITION FOOTER
                  Center(
                    child: InkWell(
                      onTap: () => Get.to(() => const PolicyScreen(
                            htmlType: HtmlType.termsAndConditions,
                          )),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(
                          'terms_and_condition'.tr,
                          style: textMedium.copyWith(
                            decoration: TextDecoration.underline,
                            color: _subText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      }),
        bottomNavigationBar:
            GetBuilder<AuthController>(builder: (authController) {
          return ((Get.find<ConfigController>().config?.externalSystem ??
                      false) &&
                  authController.showNavigationBar)
              ? SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                      color:
                          Theme.of(Get.context!).textTheme.titleMedium!.color!),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(
                            Dimensions.paddingSizeExtraSmall),
                        child: Icon(Icons.info,
                            size: 20, color: Theme.of(context).cardColor),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text('this_is_not_an_independent_app'.tr,
                                      style: textRegular.copyWith(
                                          color: Theme.of(context).cardColor)),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall),
                                  RichText(
                                      text: TextSpan(
                                          text:
                                              'this_app_is_connected_with_6ammart'
                                                  .tr,
                                          style: textRegular.copyWith(
                                              color: Theme.of(context)
                                                  .cardColor
                                                  .withOpacity(0.7),
                                              fontSize: Dimensions
                                                  .fontSizeExtraSmall),
                                          children: [
                                        TextSpan(
                                            text:
                                                ' ${'click_here_to_sigh_up'.tr}',
                                            style: textRegular.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainer,
                                                fontSize: Dimensions
                                                    .fontSizeExtraSmall,
                                                decoration:
                                                    TextDecoration.underline),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                navigateToMart(
                                                    'sixammart://open?country_code=&phone=signUp&password=}');
                                              }),
                                        TextSpan(
                                            text: '  ${'or'.tr}  ',
                                            style: textRegular.copyWith(
                                                color:
                                                    Theme.of(context).cardColor,
                                                fontSize: Dimensions
                                                    .fontSizeExtraSmall)),
                                        TextSpan(
                                            text: 'download_mart'.tr,
                                            style: textRegular.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainer,
                                                fontSize: Dimensions
                                                    .fontSizeExtraSmall,
                                                decoration:
                                                    TextDecoration.underline),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                if (GetPlatform.isAndroid &&
                                                    Get.find<ConfigController>()
                                                            .config
                                                            ?.martPlayStoreUrl !=
                                                        null) {
                                                  navigateToMart(
                                                      Get.find<ConfigController>()
                                                          .config!
                                                          .martPlayStoreUrl!);
                                                } else if (GetPlatform.isIOS &&
                                                    Get.find<ConfigController>()
                                                            .config
                                                            ?.martAppStoreUrl !=
                                                        null) {
                                                  navigateToMart(
                                                      Get.find<ConfigController>()
                                                          .config!
                                                          .martAppStoreUrl!);
                                                } else {
                                                  showCustomSnackBar(
                                                      'contact_with_support'.tr);
                                                }
                                              })
                                      ]))
                                ])),
                            InkWell(
                              onTap: () => authController.toggleNavigationBar(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.paddingSizeExtraSmall),
                                child: Icon(Icons.clear,
                                    color: Theme.of(context).cardColor),
                              ),
                            )
                          ])),
                    ]),
                  ]),
                ),
              )
            : const SizedBox();
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

  void _handleLogin() {
    final authController = Get.find<AuthController>();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();

    if (phone.isEmpty) {
      showCustomSnackBar('phone_number_is_required'.tr);
      FocusScope.of(context).requestFocus(_phoneNode);
    } else if (!GetUtils.isPhoneNumber(authController.countryDialCode + phone)) {
      showCustomSnackBar('phone_number_is_not_valid'.tr);
      FocusScope.of(context).requestFocus(_phoneNode);
    } else if (password.isEmpty) {
      showCustomSnackBar('password_is_required'.tr);
      FocusScope.of(context).requestFocus(_passwordNode);
    } else if (password.length < 8) {
      showCustomSnackBar('minimum_password_length_is_8'.tr);
    } else {
      authController.login(authController.countryDialCode, phone, password);
    }
  }

  void navigateToMart(String url) async {
    if (GetPlatform.isAndroid) {
      try {
        await launchUrl(Uri.parse(url));
      } catch (exception) {
        navigateToStores(url);
      }
    } else if (GetPlatform.isIOS) {
      if (await launchUrl(Uri.parse(url))) {
      } else {
        navigateToStores(url);
      }
    }
  }

  void navigateToStores(String url) async {
    if (GetPlatform.isAndroid &&
        Get.find<ConfigController>().config?.martPlayStoreUrl != null) {
      await launchUrl(
          Uri.parse(Get.find<ConfigController>().config!.martPlayStoreUrl!));
    } else if (GetPlatform.isIOS &&
        Get.find<ConfigController>().config?.martAppStoreUrl != null) {
      await launchUrl(
          Uri.parse(Get.find<ConfigController>().config!.martAppStoreUrl!));
    } else {
      showCustomSnackBar('contact_with_support'.tr);
    }
  }
}
