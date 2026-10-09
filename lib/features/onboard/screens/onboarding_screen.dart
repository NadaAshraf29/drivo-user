import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/onboard/controllers/on_board_page_controller.dart';
import 'package:ride_sharing_user_app/features/onboard/widget/pager_content.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController = PageController()
    ..addListener(_handlePageChanged);

  late final ValueNotifier<int> _currentPage = ValueNotifier(0)
    ..addListener(() => setState(() {}));

  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Widget> pages = AppConstants.onBoardPagerData
      .map(
        (data) => PagerContent(
          image: data.image,
          text: data.title,
          index: AppConstants.onBoardPagerData.indexOf(data),
        ),
      )
      .toList();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  void _handlePageChanged() {
    final int newPage = _pageController.page?.round() ?? 0;
    _currentPage.value = newPage;
  }

  void _handleSemanticSwipe(int dir) {
    final int currentPage = (_pageController.page ?? 0).round();
    final int targetPage = currentPage + dir;

    if (targetPage >= 0 && targetPage < AppConstants.onBoardPagerData.length) {
      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: GetBuilder<OnBoardController>(
        builder: (onBoardController) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Full screen onboarding images
              Positioned.fill(
                child: MergeSemantics(
                  child: Semantics(
                    onIncrease: () => _handleSemanticSwipe(1),
                    onDecrease: () => _handleSemanticSwipe(-1),
                    child: PageView(
                      controller: _pageController,
                      children: pages,
                      onPageChanged: (value) {
                        onBoardController.onPageChanged(value);

                        _controller.reset();
                        _controller.forward();
                      },
                    ),
                  ),
                ),
              ),

              // Skip / Next buttons over the image
              Positioned(
                right: 16,
                bottom: 14,
                child: SafeArea(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: onBoardController.pageIndex ==
                            AppConstants.onBoardPagerData.length - 1
                        ? const _GetStartedButtonWidget()
                        : _NavigationButtonWidget(
                            pageController: _pageController,
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
}

class _GetStartedButtonWidget extends StatelessWidget {
  const _GetStartedButtonWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: ButtonWidget(
        transparent: false,
        backgroundColor: Colors.white,
        textColor: const Color(0xFF06AAF2),
        showBorder: true,
        radius: 100,
        borderColor: const Color(0xFF06AAF2),
        buttonText: 'get_started'.tr,
        onPressed: () {
          Get.find<ConfigController>().disableIntro();

          Get.offAll(
            () => const SignInScreen(),
          );
        },
      ),
    );
  }
}

class _NavigationButtonWidget extends StatelessWidget {
  final PageController pageController;

  const _NavigationButtonWidget({
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Skip
        TextButton(
          onPressed: () {
            Get.find<ConfigController>().disableIntro();

            Get.offAll(
              () => const SignInScreen(),
            );
          },
          child: Text(
            'skip'.tr,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),

        // Next
        TextButton(
          onPressed: () {
            final onBoardController = Get.find<OnBoardController>();

            if (AppConstants.onBoardPagerData.length - 1 ==
                onBoardController.pageIndex) {
              Get.find<ConfigController>().disableIntro();

              Get.offAll(
                () => const SignInScreen(),
              );
            } else {
              pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'next'.tr,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 22,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
