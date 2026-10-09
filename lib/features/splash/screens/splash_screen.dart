import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/maintainance_mode/maintainance_screen.dart';
import 'package:ride_sharing_user_app/features/onboard/screens/onboarding_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/edit_profile_screen.dart';
import 'package:ride_sharing_user_app/features/refund_request/controllers/refund_request_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/splash/domain/models/config_model.dart';
import 'package:ride_sharing_user_app/features/splash/screens/app_version_warning_screen.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/helper/firebase_helper.dart';
import 'package:ride_sharing_user_app/helper/notification_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/features/splash/screens/language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  final Map<String, dynamic>? notificationData;
  final String? userName;
  const SplashScreen({super.key, this.notificationData, this.userName});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _sub;
  late AnimationController _controller;
  late Animation _animation;
  late AnimationController _textController;
  late Animation _textAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _textController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _textAnimation = Tween(begin: -200.0, end: 0.0).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ))
      ..addListener(() {
        setState(() {});
      });

    _controller.repeat(max: 1);
    _controller.forward();

    // Start text animation after a small delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _textController.forward();
    });

    Get.find<ConfigController>().initSharedData();

    _checkConnectivity();
  }

  void _checkConnectivity() {
    bool isFirst = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);
      if (!isFirst || !isConnected) {
        ScaffoldMessenger.of(Get.context!).removeCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(
            isConnected ? 'connected'.tr : 'no_connection'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if (isConnected) {
          _handleIncomingLinks();
        }
      } else {
        ScaffoldMessenger.of(Get.context!).removeCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        _handleIncomingLinks();
      }
      isFirst = false;
    });
  }

  void _handleIncomingLinks() {
    Get.find<TripController>().getRideCancellationReasonList();
    Get.find<TripController>().getParcelCancellationReasonList();
    Get.find<RefundRequestController>().getParcelRefundReasonList();
    FirebaseHelper().subscribeFirebaseTopic();

    Get.find<ConfigController>().getConfigData().then((value) {
      if (_isForceUpdate(Get.find<ConfigController>().config)) {
        Get.offAll(() => const AppVersionWarningScreen());
      } else {
        _appLinks.getInitialLink().then((Uri? uri) {
          if (uri != null) {
            _handleUri(uri);
          } else {
            _route();
            if (GetPlatform.isIOS) {
              _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
                if (uri != null) {
                  _handleUri(uri);
                }
              });
            }
          }
        });
      }
    });
  }

  bool _isForceUpdate(ConfigModel? config) {
    double minimumVersion = Platform.isAndroid
        ? config?.androidAppMinimumVersion ?? 0
        : Platform.isIOS
            ? config?.iosAppMinimumVersion ?? 0
            : 0;

    return minimumVersion > 0 && minimumVersion > AppConstants.appVersion;
  }

  void _handleUri(Uri uri) {
    final String? fromMartPhone = uri.queryParameters['phone'];
    final String? fromMartPassword = uri.queryParameters['password'];
    final String? fromCountryCode = uri.queryParameters['country_code'];
    if (Get.find<AuthController>().getUserToken().isNotEmpty) {
      Get.find<ProfileController>().getProfileInfo().then((value) {
        if (value.statusCode == 200) {
          Get.find<AuthController>().updateToken();
          if (Get.find<ProfileController>().profileModel?.data?.phone ==
              '+${fromCountryCode!.trim()}$fromMartPhone') {
            _route();
          } else {
            Get.find<AuthController>().externalLogin(
                '+${fromCountryCode.trim()}',
                fromMartPhone!,
                fromMartPassword!);
          }
        }
      });
    } else {
      Get.find<AuthController>().externalLogin(
          '+${fromCountryCode!.trim()}', fromMartPhone!, fromMartPassword!);
    }
  }

  void _route() async {
    if (Get.find<AuthController>().getUserToken().isNotEmpty) {
      PusherHelper.initializePusher();
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (Get.find<AuthController>().isLoggedIn()) {
        forLoginUserRoute();
      } else {
        forNotLoginUserRoute();
      }
    });
  }

  void forNotLoginUserRoute() {
    if (Get.find<ConfigController>().config!.maintenanceMode != null &&
        Get.find<ConfigController>()
                .config!
                .maintenanceMode!
                .maintenanceStatus ==
            1 &&
        Get.find<ConfigController>()
                .config!
                .maintenanceMode!
                .selectedMaintenanceSystem!
                .userApp ==
            1) {
      Get.offAll(() => const MaintenanceScreen());
    } else {
      if (Get.find<ConfigController>().showIntro()) {
        Get.offAll(() => const OnBoardingScreen());
      } else {
        Get.offAll(() => const SignInScreen());
      }
    }
  }

  void forLoginUserRoute() {
    if (widget.notificationData != null) {
      NotificationHelper.notificationRouteCheck(widget.notificationData!,
          formSplash: true, userName: widget.userName);
    } else if (Get.find<LocationController>().getUserAddress() != null &&
        Get.find<LocationController>().getUserAddress()!.address != null &&
        Get.find<LocationController>().getUserAddress()!.address!.isNotEmpty) {
      Get.find<ProfileController>().getProfileInfo().then((value) {
        if (value.statusCode == 200) {
          Get.find<AuthController>().updateToken();
          if (value.body['data']['is_profile_verified'] == 1) {
            Get.find<AuthController>().remainingFindingRideTime();
            Get.offAll(() => const DashboardScreen());
            // Get.find<RideController>().getCurrentRideStatus();
          } else {
            Get.offAll(() => const EditProfileScreen(fromLogin: true));
          }
        }
      });
    } else {
      Get.offAll(() => const AccessLocationScreen());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _onConnectivityChanged?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double logoWidth = Get.width * 0.42;
    final double fadeOpacity = _animation.value.clamp(0.0, 1.0).toDouble();
    final double logoScale = 0.86 + (fadeOpacity * 0.14);

    return Scaffold(
      backgroundColor: const Color(0xFF06AAF2),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xFF06AAF2),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF06AAF2),
                      Color(0xFF0AA9F4),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -60,
                      left: -40,
                      child: _GlowCircle(size: Get.width * 0.7),
                    ),
                    Positioned(
                      bottom: -80,
                      right: -30,
                      child: _GlowCircle(size: Get.width * 0.8),
                    ),
                    Positioned(
                      bottom: Get.height * 0.18,
                      left: Get.width * 0.2,
                      child: _GlowCircle(size: Get.width * 0.28),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: logoScale,
                    child: Opacity(
                      opacity: fadeOpacity,
                      child: Image.asset(
                        Get.isDarkMode
                            ? Images.logoWithNameWhite
                            : Images.logoWithNameBlack,
                        width: logoWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Transform.translate(
                    offset: Offset(0, _textAnimation.value * 0.08),
                    child: Opacity(
                      opacity: fadeOpacity,
                      child: Text(
                        'MOVE TOGETHER',
                        textAlign: TextAlign.center,
                        style: textBold.copyWith(
                          fontSize: 15,
                          letterSpacing: 2.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: fadeOpacity * 0.9,
                    child: Text(
                      'GO FURTHER',
                      textAlign: TextAlign.center,
                      style: textRegular.copyWith(
                        fontSize: 11,
                        letterSpacing: 3,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.9),
                        ),
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
}

class _GlowCircle extends StatelessWidget {
  final double size;

  const _GlowCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.08),
      ),
    );
  }
}
