import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/calender_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/drop_down_widget.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final Color? backgroundColor;
  final bool showActionButton;
  final Function()? onBackPressed;
  final bool centerTitle;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isHome;
  final String? subTitle;
  final bool showTripHistoryFilter;
  final double? height;
  final double? toolbarHeight;
  final bool? isShowIcon;
  const AppBarWidget({
    super.key,
    required this.title,
    this.subTitle,
    this.showBackButton = true,
    this.backgroundColor,
    this.onBackPressed,
    this.centerTitle = false,
    this.showActionButton = true,
    this.isHome = false,
    this.showTripHistoryFilter = false,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.toolbarHeight,
    this.isShowIcon,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveHeight = height ??
        (isHome && isShowIcon == true
            ? 100.0
            : (toolbarHeight ?? kToolbarHeight));

    return PreferredSize(
      preferredSize: Size.fromHeight(effectiveHeight),
      child: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor ?? Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        toolbarHeight: toolbarHeight ?? kToolbarHeight,
        leadingWidth: showBackButton ? kToolbarHeight : null,
        automaticallyImplyLeading: false,
        centerTitle: centerTitle,
        titleSpacing: showBackButton ? 0 : Dimensions.paddingSizeDefault,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
                onPressed: () => onBackPressed != null
                    ? onBackPressed!()
                    : Navigator.canPop(context)
                        ? Get.back()
                        : Get.offAll(() => const DashboardScreen()),
              )
            : const SizedBox.shrink(),
        title: title.isNotEmpty
            ? InkWell(
                onTap: isHome
                    ? () {
                        Address? address =
                            Get.find<LocationController>().getUserAddress();
                        if (address == null || address.longitude == null) {
                          Get.to(() => const AccessLocationScreen());
                        } else {
                          Get.find<LocationController>().updatePosition(
                            LatLng(address.latitude!, address.longitude!),
                            false,
                            LocationType.location,
                          );
                          Get.to(() => const PickMapScreen(
                              type: LocationType.accessLocation,
                              oldLocationExist: true));
                        }
                      }
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: centerTitle
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    if (showTripHistoryFilter)
                      Row(
                        children: [
                          Text(
                            title.tr,
                            style: textBold.copyWith(
                              fontSize: fontSize ?? Dimensions.fontSizeLarge,
                              fontWeight: fontWeight ?? FontWeight.w700,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ),
                          GetBuilder<TripController>(
                            builder: (tripController) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          Dimensions.paddingSizeDefault),
                                  child: DropDownWidget<int>(
                                    showText: false,
                                    showLeftSide: false,
                                    menuItemWidth: 120,
                                    icon: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          shape: BoxShape.circle),
                                      child: Icon(Icons.filter_list_sharp,
                                          color: Theme.of(context).primaryColor,
                                          size: 16),
                                    ),
                                    maxListHeight: 200,
                                    items: tripController.filterList
                                        .map((item) =>
                                            CustomDropdownMenuItem<int>(
                                              value: tripController
                                                  .filterList
                                                  .indexOf(item),
                                              child: Text(
                                                item.tr,
                                                style: textRegular.copyWith(
                                                  color: Get.isDarkMode
                                                      ? Get.find<TripController>()
                                                                  .filterIndex ==
                                                              Get.find<TripController>()
                                                                  .filterList
                                                                  .indexOf(item)
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Colors.white
                                                      : Get.find<TripController>()
                                                                  .filterIndex ==
                                                              Get.find<TripController>()
                                                                  .filterList
                                                                  .indexOf(item)
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge!
                                                              .color,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    hintText: tripController
                                        .filterList[
                                            Get.find<TripController>()
                                                .filterIndex]
                                        .tr,
                                    borderRadius: 5,
                                    onChanged: (int selectedItem) {
                                      if (selectedItem ==
                                          tripController.filterList.length - 1) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => CalenderWidget(
                                              onChanged: (value) =>
                                                  Get.back()),
                                        );
                                      } else {
                                        tripController.setFilterTypeName(
                                            selectedItem);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    else
                      Text(
                        title.tr,
                        style: textBold.copyWith(
                          fontSize: fontSize ?? Dimensions.fontSizeLarge,
                          fontWeight: fontWeight ?? FontWeight.w700,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        textAlign:
                            centerTitle ? TextAlign.center : TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (subTitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${'trip'.tr} #$subTitle',
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        textAlign:
                            centerTitle ? TextAlign.center : TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (isHome && isShowIcon == true)
                      GetBuilder<LocationController>(
                        builder: (locationController) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeExtraSmall),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: centerTitle
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.place_outlined,
                                    color: Colors.black87, size: 16),
                                const SizedBox(
                                    width: Dimensions.paddingSizeSeven),
                                if (centerTitle)
                                  Flexible(
                                    child: Text(
                                      locationController
                                              .getUserAddress()
                                              ?.address ??
                                          '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: textRegular.copyWith(
                                          color: Colors.black87,
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: Text(
                                      locationController
                                              .getUserAddress()
                                              ?.address ??
                                          '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textRegular.copyWith(
                                          color: Colors.black87,
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      height ?? (isHome && isShowIcon == true ? 100.0 : (toolbarHeight ?? kToolbarHeight)));
}
