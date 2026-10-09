import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/walkthrough_model.dart';
import '../widgets/walkthrough_overlay.dart';

class WalkthroughController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;

  WalkthroughController({required this.sharedPreferences});

  static const String keyHome = 'has_seen_home_walkthrough';
  static const String keyRegularRide = 'has_seen_regular_ride_guide';
  static const String keyWorkRide = 'has_seen_work_ride_guide';
  static const String keyTravel = 'has_seen_travel_guide';
  static const String keyNorthCoast = 'has_seen_north_coast_guide';
  static const String keyUniversity = 'has_seen_university_guide';
  static const String keySchool = 'has_seen_school_guide';
  static const String keyCustomTrip = 'has_seen_custom_trip_guide';
  static const String keySearchResults = 'has_seen_search_results_guide';
  static const String keyBooking = 'has_seen_booking_guide';

  final Map<String, GlobalKey> _registeredKeys = {};
  final Map<String, Rect Function()> _customRectProviders = {};

  List<WalkthroughStep> _activeSteps = [];
  int _currentStepIndex = 0;
  bool _isActive = false;
  WalkthroughFlowType? _currentFlowType;
  OverlayEntry? _overlayEntry;

  List<WalkthroughStep> get activeSteps => _activeSteps;
  int get currentStepIndex => _currentStepIndex;
  bool get isActive => _isActive;
  WalkthroughFlowType? get currentFlowType => _currentFlowType;
  WalkthroughStep? get currentStep =>
      (_isActive && _currentStepIndex >= 0 && _currentStepIndex < _activeSteps.length)
          ? _activeSteps[_currentStepIndex]
          : null;

  String _getStorageKey(WalkthroughFlowType type) {
    switch (type) {
      case WalkthroughFlowType.home:
        return keyHome;
      case WalkthroughFlowType.regularRideSearch:
        return keyRegularRide;
      case WalkthroughFlowType.workRideSearch:
        return keyWorkRide;
      case WalkthroughFlowType.travelSearch:
        return keyTravel;
      case WalkthroughFlowType.northCoastSearch:
        return keyNorthCoast;
      case WalkthroughFlowType.universitySearch:
        return keyUniversity;
      case WalkthroughFlowType.schoolSearch:
        return keySchool;
      case WalkthroughFlowType.customTripSearch:
        return keyCustomTrip;
      case WalkthroughFlowType.searchResults:
        return keySearchResults;
      case WalkthroughFlowType.booking:
        return keyBooking;
    }
  }

  bool hasSeenFlow(WalkthroughFlowType type) {
    return sharedPreferences.getBool(_getStorageKey(type)) ?? false;
  }

  Future<void> setSeenFlow(WalkthroughFlowType type) async {
    await sharedPreferences.setBool(_getStorageKey(type), true);
  }

  Future<void> resetFlow(WalkthroughFlowType type) async {
    await sharedPreferences.remove(_getStorageKey(type));
  }

  Future<void> resetAllFlows() async {
    for (final type in WalkthroughFlowType.values) {
      await sharedPreferences.remove(_getStorageKey(type));
    }
  }

  void registerTarget(String keyId, GlobalKey key, {Rect Function()? rectProvider}) {
    _registeredKeys[keyId] = key;
    if (rectProvider != null) {
      _customRectProviders[keyId] = rectProvider;
    }
  }

  void unregisterTarget(String keyId) {
    _registeredKeys.remove(keyId);
    _customRectProviders.remove(keyId);
  }

  GlobalKey? getKey(String keyId) => _registeredKeys[keyId];

  Rect? getTargetRect(String keyId) {
    if (_customRectProviders.containsKey(keyId)) {
      try {
        return _customRectProviders[keyId]!();
      } catch (_) {}
    }

    final key = _registeredKeys[keyId];
    if (key == null || key.currentContext == null) return null;

    try {
      final renderBox = key.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize && renderBox.attached) {
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        return Rect.fromLTWH(
          position.dx,
          position.dy,
          size.width,
          size.height,
        );
      }
    } catch (_) {}
    return null;
  }

  Future<void> startFlow(
    WalkthroughFlowType flowType,
    List<WalkthroughStep> steps, {
    bool isManual = false,
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    // If not manual and already seen, do not run automatically
    if (!isManual && hasSeenFlow(flowType)) {
      return;
    }

    // Filter available steps dynamically (context-aware skip)
    final availableSteps = steps.where((step) {
      if (step.isAvailable != null) {
        return step.isAvailable!();
      }
      return true;
    }).toList();

    if (availableSteps.isEmpty) return;

    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    _removeOverlay();

    _currentFlowType = flowType;
    _activeSteps = availableSteps;
    _currentStepIndex = 0;
    _isActive = true;

    _showOverlay();
    _onStepChanged();
    update();
  }

  void _showOverlay() {
    final targetContext = Get.overlayContext ?? Get.context ?? Get.key.currentContext;
    if (targetContext == null) return;
    final overlayState = Overlay.maybeOf(targetContext, rootOverlay: true) ??
        Get.key.currentState?.overlay;
    if (overlayState == null) return;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => const WalkthroughOverlayWidget(),
    );

    overlayState.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onStepChanged() {
    if (!_isActive || currentStep == null) return;

    final step = currentStep!;
    step.onStepEnter?.call();

    // Auto scroll target into view if needed
    if (step.autoScroll) {
      final key = _registeredKeys[step.targetKeyId];
      if (key?.currentContext != null) {
        try {
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.35,
          );
        } catch (_) {}
      }
    }
  }

  void nextStep() {
    if (!_isActive) return;

    currentStep?.onStepLeave?.call();

    if (_currentStepIndex < _activeSteps.length - 1) {
      _currentStepIndex++;
      _onStepChanged();
      update();
    } else {
      finish();
    }
  }

  void previousStep() {
    if (!_isActive || _currentStepIndex <= 0) return;

    currentStep?.onStepLeave?.call();
    _currentStepIndex--;
    _onStepChanged();
    update();
  }

  void skip() {
    finish();
  }

  void finish() {
    if (!_isActive) return;

    currentStep?.onStepLeave?.call();

    if (_currentFlowType != null) {
      setSeenFlow(_currentFlowType!);
    }

    _isActive = false;
    _activeSteps = [];
    _currentStepIndex = 0;
    _currentFlowType = null;
    _removeOverlay();
    update();
  }

  void autoAdvanceIfCurrentStep(String stepId) {
    if (_isActive && currentStep?.id == stepId) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (_isActive && currentStep?.id == stepId) {
          nextStep();
        }
      });
    }
  }

  @override
  void onClose() {
    _removeOverlay();
    super.onClose();
  }
}
