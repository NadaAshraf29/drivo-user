import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/message/controllers/message_controller.dart';
import 'package:ride_sharing_user_app/features/message/screens/message_screen.dart';
import 'package:ride_sharing_user_app/features/my_level/controller/level_controller.dart';
import 'package:ride_sharing_user_app/features/my_level/widget/level_complete_dialog_widget.dart';
import 'package:ride_sharing_user_app/features/my_offer/screens/my_offer_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/driver_request_dialog.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/payment/screens/carpool_payment_details_screen.dart';
import 'package:ride_sharing_user_app/features/payment/screens/review_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/carpool_active_ride_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/refer_and_earn/controllers/refer_and_earn_controller.dart';
import 'package:ride_sharing_user_app/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/confirmation_trip_dialog.dart';
import 'package:ride_sharing_user_app/features/settings/domain/html_enum_types.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/tripe_details_screen.dart';

import 'package:ride_sharing_user_app/features/wallet/screens/wallet_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/main.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';

class NotificationHelper {
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        onDidReceiveNotificationResponse: (NotificationResponse payload) async {
      return;
    }, onDidReceiveBackgroundNotificationResponse: myBackgroundMessageReceiver);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      AndroidInitializationSettings androidInitialize =
          const AndroidInitializationSettings('notification_icon');
      var iOSInitialize = const DarwinInitializationSettings();
      var initializationsSettings = InitializationSettings(
          android: androidInitialize, iOS: iOSInitialize);
      flutterLocalNotificationsPlugin.initialize(
        initializationsSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
          notificationRouteCheck(message.data);
          return;
        },
        onDidReceiveBackgroundNotificationResponse: myBackgroundMessageReceiver,
      );

      ///Debug print
      customPrint('onMessage: ${message.data}');

      ///Check maintenance mode
      if (!(Get.find<ConfigController>().config!.maintenanceMode != null &&
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
                  1) ||
          Get.find<ConfigController>().haveOngoingRides()) {
        ///Check Websocket Connection
        if (Get.find<ConfigController>().pusherConnectionStatus == null ||
            Get.find<ConfigController>().pusherConnectionStatus ==
                'Disconnected') {
          if (message.data['action'] == 'driver_assigned') {
            if (Get.isDialogOpen == true) {
              Navigator.pop(Get.context!);
            }
            Get.find<RideController>()
                .getRideDetails(message.data['ride_request_id'])
                .then((value) {
              if (value?.statusCode == 200) {
                if (message.data['type'] == 'parcel') {
                  Get.find<ParcelController>()
                      .updateParcelState(ParcelDeliveryState.acceptRider);
                  Get.find<RideController>().startLocationRecord();
                  Get.find<MapController>().notifyMapController();
                  Get.to(
                      () => const MapScreen(fromScreen: MapScreenType.parcel));
                  } else {
                    _openCarpoolPaymentDetails(
                      message.data['ride_request_id'], message.data);
                }
              }
            });
          } else if (message.data['action'] == "carpo") {
            if (Get.isDialogOpen == true) {
              Navigator.pop(Get.context!);
            }
            Get.find<RideController>()
                .getRideDetails(message.data['ride_request_id'])
                .then((value) {
              if (value?.statusCode == 200) {
                if (message.data['type'] == 'parcel') {
                  Get.find<ParcelController>()
                      .updateParcelState(ParcelDeliveryState.acceptRider);
                  Get.find<RideController>().startLocationRecord();
                  Get.find<MapController>().notifyMapController();
                  Get.to(
                      () => const MapScreen(fromScreen: MapScreenType.parcel));
                } else {
                  Get.find<RideController>()
                      .updateRideCurrentState(RideState.acceptingRider);
                  Get.find<RideController>().startLocationRecord();
                  Get.find<MapController>().notifyMapController();
                  Get.to(
                      () => const MapScreen(fromScreen: MapScreenType.splash));
                }
              }
            });
          } else if (message.data['action'] == "new_message_arrived" || message.data['action'] == "admin_message") {
            Get.find<MessageController>()
                .getConversation(message.data['type'] ?? message.data['channel_id'] ?? '', 1);
          } else if (message.data['action'] == 'otp_matched' &&
              message.data['type'] == 'ride_request') {
            Get.find<RideController>()
                .updateRideCurrentState(RideState.ongoingRide);
            Get.to(() => const MapScreen(fromScreen: MapScreenType.splash));
          } else if (message.data['action'] == 'trip_waited_message' &&
              message.data['type'] == 'ride_request') {
            Get.find<RideController>()
                .getRideDetails(message.data['ride_request_id']);
          } else if (message.data['action'] == 'otp_matched' &&
              message.data['type'] == 'parcel') {
            Get.find<MapController>().getPolyline();
            Get.find<ParcelController>()
                .updateParcelState(ParcelDeliveryState.parcelOngoing);
            if (Get.find<RideController>().tripDetails == null) {
              Get.find<RideController>()
                  .getRideDetails(message.data['ride_request_id'])
                  .then((value) {
                if (Get.find<RideController>()
                        .tripDetails!
                        .parcelInformation!
                        .payer ==
                    'sender') {
                  Get.find<RideController>()
                      .getFinalFare(message.data['ride_request_id'])
                      .then((value) {
                    if (value?.statusCode == 200) {
                      Get.find<MapController>().notifyMapController();
                      Get.off(() => const PaymentScreen(
                            fromParcel: true,
                          ));
                    }
                  });
                }
              });
            } else {
              if (Get.find<RideController>()
                      .tripDetails!
                      .parcelInformation!
                      .payer ==
                  'sender') {
                Get.find<RideController>()
                    .getFinalFare(message.data['ride_request_id'])
                    .then((value) {
                  if (value?.statusCode == 200) {
                    Get.find<MapController>().notifyMapController();
                    Get.off(() => const PaymentScreen(
                          fromParcel: true,
                        ));
                  }
                });
              }
            }
          } else if (message.data['action'] == 'payment_successful') {
            if (Get.find<ConfigController>().config!.reviewStatus! &&
                message.data['type'] == 'ride_request') {
              Get.off(
                  () => ReviewScreen(tripId: message.data['ride_request_id']));
              Get.find<RideController>().tripDetails = null;
            } else {
              Get.offAll(() => const DashboardScreen());
              Get.find<RideController>().tripDetails = null;
            }
          } else if (message.data['action'] == 'ride_completed' &&
              message.data['type'] == 'ride_request') {
            Get.dialog(const ConfirmationTripDialog(isStartedTrip: false),
                barrierDismissible: false);
            Get.find<RideController>()
                .getFinalFare(message.data['ride_request_id'])
                .then((value) {
              if (value?.statusCode == 200) {
                Get.find<RideController>()
                    .updateRideCurrentState(RideState.completeRide);
                Get.find<MapController>().notifyMapController();
                Get.off(() => const PaymentScreen());
              }
            });
          } else if (message.data['action'] == 'ride_completed' ||
              message.data['action'] == 'parcel_completed') {
            Get.find<RideController>().clearRideDetails();
            if (message.data['action'] == 'ride_completed') {
              Get.offAll(const DashboardScreen());
            } else {
              if (Get.find<ConfigController>().config!.reviewStatus!) {
                Get.offAll(
                    ReviewScreen(tripId: message.data['ride_request_id']));
              } else {
                Get.offAll(const DashboardScreen());
              }
            }
          } else if (message.data['action'] == 'ride_cancelled' &&
              message.data['type'] == 'ride_request') {
            await Get.find<RideController>()
                .getCurrentRideStatus(fromRefresh: true);
            Get.offAll(const DashboardScreen());
          } else if (message.data['action'] == 'driver_bid_received') {
            Get.find<RideController>()
                .getBiddingList(message.data['ride_request_id'], 1)
                .then((value) {
              if (value?.statusCode == 200) {
                if (Get.find<RideController>().biddingList.length != 1 && Get.isDialogOpen == true) {
                  Navigator.pop(Get.context!);
                }

                Get.dialog(
                    barrierDismissible: true,
                    barrierColor: Colors.black.withValues(alpha: 0.5),
                    transitionDuration: const Duration(milliseconds: 500),
                    DriverRideRequestDialog(
                        tripId: message.data['ride_request_id']));
              }
            });
          } else if (message.data['action'] == 'level_completed') {
            Get.find<LevelController>().getProfileLevelInfo();
            showDialog(
              context: Get.context!,
              barrierDismissible: false,
              builder: (_) => LevelCompleteDialogWidget(
                levelName: message.data['next_level'],
                rewardType: message.data['reward_type'],
                reward: message.data['reward_amount'],
              ),
            );
          } else if (message.data['action'] ==
              'driver_after_bid_trip_rejected') {
            Get.find<RideController>()
                .getBiddingList(message.data['ride_request_id'], 1)
                .then((value) {
              if (value?.statusCode == 200) {
                if (Get.find<RideController>().biddingList.isEmpty &&
                    Get.isDialogOpen == true) {
                  Navigator.pop(Get.context!);
                }
              }
            });
          } else if (message.data['action'] == 'parcel_cancelled') {
            Get.offAll(const DashboardScreen());
          } else if (message.data['action'] == 'parcel_returned') {
            Get.find<RideController>()
                .getRideDetails(message.data['ride_request_id']);
            Get.find<ParcelController>().getOngoingParcelList();
          } else if (message.data['action'] == 'referral_reward_received') {
            Get.find<ReferAndEarnController>().getEarningHistoryList(1);
            Get.find<ProfileController>().getProfileInfo();
          }

          ///If websocket not connected
        } else {
          if (message.data['action'] == 'driver_bid_received') {
            Get.find<RideController>()
                .getBiddingList(message.data['ride_request_id'], 1)
                .then((value) {
              if (value?.statusCode == 200) {
                if (Get.find<RideController>().biddingList.length != 1 && Get.isDialogOpen == true) {
                  Navigator.pop(Get.context!);
                }
                Get.dialog(
                    barrierDismissible: true,
                    barrierColor: Colors.black.withValues(alpha: 0.5),
                    transitionDuration: const Duration(milliseconds: 500),
                    DriverRideRequestDialog(
                        tripId: message.data['ride_request_id']));
              }
            });
          } else if (message.data['action'] == 'trip_waited_message' &&
              message.data['type'] == 'ride_request') {
            Get.find<RideController>()
                .getRideDetails(message.data['ride_request_id']);
          } else if (message.data['action'] == 'level_completed') {
            Get.find<LevelController>().getProfileLevelInfo();
            showDialog(
              context: Get.context!,
              barrierDismissible: false,
              builder: (_) => LevelCompleteDialogWidget(
                levelName: message.data['next_level'],
                rewardType: message.data['reward_type'],
                reward: message.data['reward_amount'],
              ),
            );
          } else if (message.data['action'] ==
              'driver_after_bid_trip_rejected') {
            Get.find<RideController>()
                .getBiddingList(message.data['ride_request_id'], 1)
                .then((value) {
              if (value?.statusCode == 200) {
                /* if(Get.find<RideController>().biddingList.isEmpty && Get.isDialogOpen!){
                Get.back();
              }*/
              }
            });
          } else if (message.data['action'] == 'parcel_cancelled') {
            Get.offAll(const DashboardScreen());
          } else if (message.data['action'] == 'parcel_returned') {
            Get.find<RideController>()
                .getRideDetails(message.data['ride_request_id']);
            Get.find<ParcelController>().getOngoingParcelList();
          } else if (message.data['action'] == 'referral_reward_received') {
            Get.find<ReferAndEarnController>().getEarningHistoryList(1);
            Get.find<ProfileController>().getProfileInfo();
          }
        }

        ///check for silent notification.
        if (!(message.data['type'] == 'maintenance_mode_on' ||
            message.data['type'] == 'maintenance_mode_off')) {
          if (message.data['status'] == '1') {
            NotificationHelper.showNotification(
                message, flutterLocalNotificationsPlugin, true);
          }
        }
      }

      if (message.data['type'] == 'maintenance_mode_on' ||
          message.data['type'] == 'maintenance_mode_off') {
        Get.find<ConfigController>().getConfigData();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      customPrint('onOpenApp: ${message.data}');
      notificationRouteCheck(message.data);
    });
  }

  static Future<void> hintForBetterServiceLocationTurnOn({String? body}) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body ??
          'When your\'re riding with ${AppConstants.appName}, your location is being collected for faster pick-ups and safety features. Manage permissions in your device\'s settings',
      htmlFormatBigText: true,
      contentTitle: 'Faster pick-ups, safer trips',
      htmlFormatContentTitle: true,
    );
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'hexaride',
      'hexaride',
      channelDescription: 'progress channel description',
      styleInformation: bigTextStyleInformation,
      channelShowBadge: true,
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
      showProgress: false,
      color: const Color(0xFF00A08D),
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
        0,
        'Faster pick-ups, safer trips',
        body ??
            'When your\'re riding with ${AppConstants.appName}, your location is being collected for faster pick-ups and safety features. Manage permissions in your device\'s settings',
        platformChannelSpecifics,
        payload: 'item x');
  }

  static Future<void> showNotification(RemoteMessage message,
      FlutterLocalNotificationsPlugin fln, bool data) async {
    String title = message.data['title'];
    String body = message.data['body'];
    String? orderID = message.data['order_id'];
    String? image = (message.data['image'] != null &&
            message.data['image'].isNotEmpty)
        ? message.data['image'].startsWith('http')
            ? message.data['image']
            : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}'
        : null;

    try {
      await showBigPictureNotificationHiddenLargeIcon(
          title, body, orderID, image, fln);
    } catch (e) {
      await showBigPictureNotificationHiddenLargeIcon(
          title, body, orderID, null, fln);
      customPrint('Failed to show notification: ${e.toString()}');
    }
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(
      String title,
      String body,
      String? orderID,
      String? image,
      FlutterLocalNotificationsPlugin fln) async {
    String? largeIconPath;
    String? bigPicturePath;
    BigPictureStyleInformation? bigPictureStyleInformation;
    BigTextStyleInformation? bigTextStyleInformation;
    if (image != null && !GetPlatform.isWeb) {
      largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
      bigPicturePath = largeIconPath;
      bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: body,
        htmlFormatSummaryText: true,
      );
    } else {
      bigTextStyleInformation = BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
      );
    }
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'hexaride',
      'hexaride',
      priority: Priority.max,
      importance: Importance.max,
      playSound: true,
      largeIcon:
          largeIconPath != null ? FilePathAndroidBitmap(largeIconPath) : null,
      styleInformation: largeIconPath != null
          ? bigPictureStyleInformation
          : bigTextStyleInformation,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static void notificationRouteCheck(Map<String, dynamic> data,
      {bool formSplash = false, String? userName}) {
    if (data['action'] == "new_message_arrived") {
      Get.find<MessageController>().getConversation(data['type'], 1);
      _toRoute(
          formSplash,
          MessageScreen(
              channelId: data['type'],
              tripId: data['ride_request_id'],
              userName: userName ?? data['user_name']));
    } else if (data['action'] == 'carpooling_trip_started') {
      final tripId = (data['ride_request_id'] ??
              data['trip_request_id'] ??
              data['route_id'] ??
              '')
          .toString();
      if (tripId.isEmpty) {
        _toRoute(formSplash, const DashboardScreen());
      } else {
        _toRoute(
          formSplash,
          TripDetailsScreen(
            tripId: tripId,
            fromCarpoolTab: true,
          ),
        );
      }
    } else if (data['action'] == 'driver_assigned') {
      _openCarpoolPaymentDetails(
          data['ride_request_id']?.toString() ?? '', data,
          formSplash: formSplash);
    } else if (data['action'] == 'otp_matched' &&
        data['type'] == 'ride_request') {
      notificationToRouteNavigate(data['ride_request_id'], formSplash);
    } else if (data['action'] == 'trip_waited_message' &&
        data['type'] == 'ride_request') {
      notificationToRouteNavigate(data['ride_request_id'], formSplash);
    } else if (data['action'] == 'otp_matched' && data['type'] == 'parcel') {
      notificationToRouteNavigate(data['ride_request_id'], formSplash);
    } else if (data['action'] == 'payment_successful') {
      notificationToRouteNavigate(data['ride_request_id'], formSplash);
    } else if (data['action'] == 'ride_completed' &&
        data['type'] == 'ride_request') {
      notificationToRouteNavigate(data['ride_request_id'], formSplash);
    } else if (data['action'] == 'ride_completed' ||
        data['action'] == 'parcel_completed') {
      notificationToRouteNavigate(data['ride_request_id'], formSplash);
    } else if (data['action'] == 'ride_cancelled' &&
        data['type'] == 'ride_request') {
      notificationToRouteNavigate(data['ride_request_id'], formSplash);
    } else if (data['action'] == 'driver_bid_received') {
      Get.find<RideController>()
          .getRideDetails(data['ride_request_id'])
          .then((value) => {
                if (Get.currentRoute != '/MapScreen')
                  {
                    Get.find<RideController>()
                        .updateRideCurrentState(RideState.findingRider),
                    _toRoute(formSplash,
                        const MapScreen(fromScreen: MapScreenType.ride)),
                  },
                Get.find<RideController>()
                    .getBiddingList(data['ride_request_id'], 1)
                    .then((value) async {
                  if (value?.statusCode == 200) {
                    Get.dialog(
                        barrierDismissible: true,
                        barrierColor: Colors.black.withValues(alpha: 0.5),
                        transitionDuration: const Duration(milliseconds: 500),
                        DriverRideRequestDialog(
                            tripId: data['ride_request_id']));
                  }
                })
              });
    } else if (data['action'] == 'level_completed') {
      Get.find<LevelController>().getProfileLevelInfo();

      if (formSplash) {
        _toRoute(formSplash, const DashboardScreen());
      }

      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (_) => LevelCompleteDialogWidget(
          levelName: data['next_level'],
          rewardType: data['reward_type'],
          reward: data['reward_amount'],
        ),
      );
    } else if (data['action'] == 'privacy_policy_page_updated') {
      Get.find<ConfigController>().getConfigData().then((value) {
        _toRoute(
            formSplash,
            PolicyScreen(
              htmlType: HtmlType.privacyPolicy,
              image:
                  Get.find<ConfigController>().config?.privacyPolicy?.image ??
                      '',
            ));
      });
    } else if (data['action'] == 'legal_page_updated') {
      Get.find<ConfigController>().getConfigData().then((value) {
        _toRoute(
            formSplash,
            PolicyScreen(
              htmlType: HtmlType.legal,
              image: Get.find<ConfigController>().config?.legal?.image ?? '',
            ));
      });
    } else if (data['action'] == 'terms_and_conditions_page_updated') {
      Get.find<ConfigController>().getConfigData().then((value) {
        _toRoute(
            formSplash,
            PolicyScreen(
              htmlType: HtmlType.termsAndConditions,
              image: Get.find<ConfigController>()
                      .config
                      ?.termsAndConditions
                      ?.image ??
                  '',
            ));
      });
    } else if (data['action'] == 'referral_reward_received') {
      Get.find<ReferAndEarnController>().updateCurrentTabIndex(1);
      _toRoute(formSplash, const ReferAndEarnScreen());
    } else if (data['action'] == 'parcel_returned') {
      _toRoute(formSplash, TripDetailsScreen(tripId: data['ride_request_id']));
    } else if (data['action'] == 'someone_used_your_code') {
      _toRoute(formSplash, const ReferAndEarnScreen());
    } else if (data['action'] == 'parcel_refund_request_approved') {
      _toRoute(formSplash, TripDetailsScreen(tripId: data['ride_request_id']));
    } else if (data['action'] == 'carpool_payment_approved') {
      _toRoute(
        formSplash,
        TripeDetailsScreen(
          tripId: data['ride_request_id']?.toString() ?? '',
          fromCarpoolTab: true,
        ),
      );
    } else if (data['action'] == 'parcel_refund_request_denied') {
      _toRoute(formSplash, TripDetailsScreen(tripId: data['ride_request_id']));
    } else if (data['action'] == 'refunded_to_wallet') {
      _toRoute(formSplash, const WalletScreen());
    } else if (data['action'] == 'refunded_as_coupon') {
      Get.find<CouponController>()
          .getCouponList(1, isUpdate: false)
          .then((value) {
        _toRoute(formSplash, MyOfferScreen(isCoupon: true));
      });
    } else if (data['action'] == 'fund_added') {
      _toRoute(formSplash, const WalletScreen());
    } else if (data['action'] == 'review_submit') {
      _toRoute(formSplash, TripDetailsScreen(tripId: data['ride_request_id']));
    } else if (data['action'] == 'withdraw_rejected') {
      _toRoute(formSplash, const WalletScreen());
    } else if (data['action'] == 'withdraw_reversed') {
      _toRoute(formSplash, const WalletScreen());
    } else {
      Get.offAll(const DashboardScreen());
    }
  }

  static void notificationToRouteNavigate(String tripId, bool formSplash) {
    Get.find<RideController>().getRideDetails(tripId).then((value) => {
          if (Get.find<RideController>().tripDetails!.currentStatus ==
                  'accepted' ||
              Get.find<RideController>().tripDetails!.currentStatus ==
                  'ongoing')
            {
              if (Get.currentRoute != '/MapScreen')
                {
                  if (Get.find<RideController>().tripDetails!.type == 'parcel')
                    {
                      if (Get.find<RideController>()
                              .tripDetails!
                              .currentStatus ==
                          'accepted')
                        {
                          Get.find<ParcelController>().updateParcelState(
                              ParcelDeliveryState.acceptRider)
                        }
                      else
                        {
                          Get.find<ParcelController>().updateParcelState(
                              ParcelDeliveryState.parcelOngoing)
                        }
                    }
                  else
                    {
                      if (Get.find<RideController>()
                              .tripDetails!
                              .currentStatus ==
                          'accepted')
                        {
                          Get.find<RideController>()
                              .updateRideCurrentState(RideState.acceptingRider)
                        }
                      else
                        {
                          Get.find<RideController>()
                              .updateRideCurrentState(RideState.ongoingRide)
                        }
                    },
                  _toRoute(
                      formSplash,
                      MapScreen(
                          fromScreen:
                              Get.find<RideController>().tripDetails!.type ==
                                      'parcel'
                                  ? MapScreenType.parcel
                                  : MapScreenType.ride)),
                }
            }
          else if (Get.find<RideController>().tripDetails!.currentStatus ==
                  'cancelled' ||
              (Get.find<RideController>().tripDetails!.currentStatus ==
                      'completed' &&
                  Get.find<RideController>().tripDetails!.paymentStatus ==
                      'paid'))
            {
              if (Get.currentRoute != '/TripDetailsScreen')
                {
                  _toRoute(
                      formSplash,
                      TripDetailsScreen(
                          tripId: tripId, fromNotification: true)),
                }
            }
          else if ((Get.find<RideController>().tripDetails!.currentStatus ==
                  'completed' &&
              Get.find<RideController>().tripDetails!.paymentStatus ==
                  'unpaid'))
            {
              if (Get.currentRoute != '/PaymentScreen')
                {
                  Get.find<RideController>().getFinalFare(tripId).then((_) {
                    _toRoute(
                        formSplash, const PaymentScreen(fromParcel: false));
                  })
                }
            }
        });
  }

  static void _openCarpoolPaymentDetails(String tripId,
      Map<String, dynamic> data, {bool formSplash = false}) {
    if (tripId.isEmpty) {
      _toRoute(formSplash, const DashboardScreen());
      return;
    }

    final rideController = Get.find<RideController>();
    rideController.getRideDetails(tripId).then((response) {
      if (response?.statusCode != 200 || rideController.tripDetails == null) {
        _toRoute(formSplash, const DashboardScreen());
        return;
      }

      final trip = rideController.tripDetails!;

      final String paymentStatusStr = (trip.paymentStatus ??
              data['payment_status'] ??
              '')
          .toString()
          .toLowerCase()
          .trim();

      final bool isPaid = paymentStatusStr == 'paid' ||
          paymentStatusStr == 'completed' ||
          paymentStatusStr == 'approved' ||
          paymentStatusStr == 'success' ||
          (trip.paidFare != null && trip.paidFare! > 0);

      // If already paid before the trip started, open the Active Ride Screen directly
      if (isPaid) {
        _toRoute(
          formSplash,
          CarpoolActiveRideScreen(tripId: tripId),
        );
        return;
      }

      final rawAccounts = data['payment_accounts'];
      final paymentAccounts = rawAccounts is List
          ? rawAccounts
              .whereType<Map>()
              .map((account) => Map<String, dynamic>.from(account))
              .toList()
          : <Map<String, dynamic>>[];
      final totalPrice = double.tryParse(
              data['total_fare']?.toString() ?? trip.totalFare ?? '') ??
          trip.actualFare ??
          trip.estimatedFare ??
          0;

      final pickupLoc = trip.pickupAddress ?? '';
      final dropoffLoc = trip.destinationAddress ?? '';

      final returnTime = trip.formattedReturnTime.isNotEmpty
          ? trip.formattedReturnTime
          : (trip.returnTime != null &&
                  trip.returnTime!.trim().isNotEmpty &&
                  trip.returnTime != 'null' &&
                  trip.returnTime != '00:00' &&
                  trip.returnTime != '00:00:00'
              ? trip.returnTime!
              : '');

      _toRoute(
        formSplash,
        CarpoolPaymentDetailsScreen(
          tripId: tripId,
          totalPrice: totalPrice.round(),
          paymentAccounts: paymentAccounts,
          proration: data['proration'] as Map<String, dynamic>?,
          routeTitle: _carpoolRouteTitle(pickupLoc, dropoffLoc),
          dateTimeText: _carpoolDateTime(
            trip.scheduledAt,
            departureTime: trip.departureTime,
            selectedDates: trip.selectedDates,
          ),
          returnTimeText: returnTime,
          pickupLocation: pickupLoc,
          dropoffLocation: dropoffLoc,
          carpoolType: trip.carpoolType,
        ),
      );
    });
  }

  static String _carpoolRouteTitle(String? pickup, String? destination) {
    final from = _shortLocation(pickup);
    final to = _shortLocation(destination);
    if (from.isEmpty && to.isEmpty) return '';
    if (from.isEmpty) return to;
    if (to.isEmpty) return from;
    return '$from -> $to';
  }

  static String _shortLocation(String? value) {
    final words = (value ?? '').trim().split(RegExp(r'\s+'));
    if (words.length <= 3) return words.join(' ');
    return words.take(3).join(' ');
  }

  static String _carpoolDateTime(String? scheduledAt,
      {String? departureTime, List<String>? selectedDates}) {
    final dateValue = scheduledAt ??
        (selectedDates != null && selectedDates.isNotEmpty
            ? selectedDates.first
            : null);
    final date = dateValue == null || dateValue.isEmpty
        ? null
        : DateTime.tryParse(dateValue)?.toLocal();
    final formattedDate = date == null
        ? ''
        : DateFormat('EEE, d MMM').format(date);
    final formattedTime = _formatCarpoolTime(departureTime);
    if (formattedDate.isEmpty) return formattedTime;
    if (formattedTime.isEmpty) return formattedDate;
    return '$formattedDate - $formattedTime';
  }

  static String _formatCarpoolTime(String? value) {
    if (value == null || value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return DateFormat('h:mm a').format(parsed.toLocal());
    final parts = value.split(':');
    if (parts.length < 2) return value;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return value;
    final time = DateTime(2000, 1, 1, hour, minute);
    return DateFormat('h:mm a').format(time);
  }

  static Future _toRoute(bool formSplash, Widget page) async {
    if (formSplash) {
      await Get.offAll(() => page);
    } else {
      await Get.to(() => page);
    }
  }
}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage remoteMessage) async {
  customPrint('onBackground: ${remoteMessage.data}');
  // var androidInitialize = new AndroidInitializationSettings('notification_icon');
  // var iOSInitialize = new IOSInitializationSettings();
  // var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  // NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, true);
}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageReceiver(
    NotificationResponse response) async {
  customPrint('onBackgroundClicked: ${response.payload}');
}
