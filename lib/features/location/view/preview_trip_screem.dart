import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/domain/models/navigation_model.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/widget/location_search_dialog.dart';
import 'package:ride_sharing_user_app/features/search_trips/screens/search_trips_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class PreviewTripScreen extends StatefulWidget {
  final LocationType type;
  final bool oldLocationExist;
  final Function(Position position, String address)? onLocationPicked;
  const PreviewTripScreen(
      {super.key,
      this.onLocationPicked,
      required this.type,
      this.oldLocationExist = false});

  @override
  State<PreviewTripScreen> createState() => _PreviewTripScreenState();
}

class _PreviewTripScreenState extends State<PreviewTripScreen> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  BitmapDescriptor? _customEndMarker;
  BitmapDescriptor? _customStartMarker;
  BitmapDescriptor? _customBreakpointMarker;

  @override
  void initState() {
    super.initState();

    if (widget.onLocationPicked != null) {
      Get.find<LocationController>().setPickData(widget.type);
    }

    // Load custom markers
    _loadCustomMarkers();

    // Initialize static data after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStaticData();
    });
  }

  Future<void> _loadCustomMarkers() async {
    // Load all custom markers
    _customEndMarker = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(48, 48)), Images.routeSquare);

    _customStartMarker = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(48, 48)), Images.routeSquare);

    _customBreakpointMarker = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(48, 48)), Images.breakpoint);

    setState(() {});
  }

  void _initializeStaticData() {
    final locationController = Get.find<LocationController>();

    // Initialize static breakpoints
    locationController.initializeStaticBreakpoints();

    // Set static start and end addresses
    locationController.fromAddress = Address(
      latitude: 30.0330,
      longitude: 31.2336,
      address:
          'Makram Ebeid, Al Manteqah Ath Thamenah, Nasr City, Cairo Governorate 4441564',
    );

    locationController.toAddress = Address(
      latitude: 30.0644,
      longitude: 31.2144,
      address:
          'Makram Ebeid, Al Manteqah Ath Thamenah, Nasr City, Cairo Governorate 4441564',
    );
  }

  Set<Polyline> _createPolylines() {
    final locationController = Get.find<LocationController>();
    List<LatLng> routePoints = [];

    // Add start point
    if (locationController.fromAddress != null) {
      routePoints.add(LatLng(
        locationController.fromAddress!.latitude!,
        locationController.fromAddress!.longitude!,
      ));
    }

    // Add breakpoints
    for (var breakpoint in locationController.breakpoints) {
      if (breakpoint['latitude'] != null && breakpoint['longitude'] != null) {
        routePoints.add(LatLng(
          breakpoint['latitude'],
          breakpoint['longitude'],
        ));
      }
    }

    // Add end point
    if (locationController.toAddress != null) {
      routePoints.add(LatLng(
        locationController.toAddress!.latitude!,
        locationController.toAddress!.longitude!,
      ));
    }

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: Color(0xFF002366),
        width: 6,
        patterns: [],
      ),
    };
  }

  Set<Marker> _createMarkers() {
    final locationController = Get.find<LocationController>();
    Set<Marker> markers = {};

    // Start marker
    if (locationController.fromAddress != null) {
      markers.add(Marker(
        markerId: const MarkerId('start'),
        position: LatLng(
          locationController.fromAddress!.latitude!,
          locationController.fromAddress!.longitude!,
        ),
        icon: _customStartMarker ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'بداية الرحلة'),
      ));
    }

    // Breakpoint markers
    for (int i = 0; i < locationController.breakpoints.length; i++) {
      var breakpoint = locationController.breakpoints[i];
      if (breakpoint['latitude'] != null && breakpoint['longitude'] != null) {
        markers.add(Marker(
          markerId: MarkerId('breakpoint_$i'),
          position: LatLng(
            breakpoint['latitude'],
            breakpoint['longitude'],
          ),
          icon: _customBreakpointMarker ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'نقطة استراحة ${i + 1}'),
        ));
      }
    }

    // End marker
    if (locationController.toAddress != null) {
      markers.add(Marker(
        markerId: const MarkerId('end'),
        position: LatLng(
          locationController.toAddress!.latitude!,
          locationController.toAddress!.longitude!,
        ),
        icon: _customEndMarker ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'نهاية الرحلة'),
      ));
    }

    return markers;
  }

  void _fitMapToRoute() {
    final locationController = Get.find<LocationController>();
    List<LatLng> allPoints = [];

    // Collect all points
    if (locationController.fromAddress != null) {
      allPoints.add(LatLng(
        locationController.fromAddress!.latitude!,
        locationController.fromAddress!.longitude!,
      ));
    }

    for (var breakpoint in locationController.breakpoints) {
      if (breakpoint['latitude'] != null && breakpoint['longitude'] != null) {
        allPoints.add(LatLng(
          breakpoint['latitude'],
          breakpoint['longitude'],
        ));
      }
    }

    if (locationController.toAddress != null) {
      allPoints.add(LatLng(
        locationController.toAddress!.latitude!,
        locationController.toAddress!.longitude!,
      ));
    }

    if (allPoints.isNotEmpty && _mapController != null) {
      // Calculate bounds
      double minLat =
          allPoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
      double maxLat =
          allPoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
      double minLng =
          allPoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
      double maxLng =
          allPoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: GetBuilder<LocationController>(builder: (locationController) {
            return Stack(children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      30.0487, 31.224), // Center point to show entire route
                  zoom: 12,
                ),
                polylines: _createPolylines(),
                markers: _createMarkers(),
                minMaxZoomPreference: const MinMaxZoomPreference(0, 18),
                onMapCreated: (GoogleMapController mapController) {
                  Future.delayed(const Duration(milliseconds: 1000))
                      .then((value) {
                    _mapController = mapController;
                    _fitMapToRoute();
                  });
                },
                zoomControlsEnabled: false,
                style: Get.isDarkMode
                    ? Get.find<ThemeController>().darkMap
                    : Get.find<ThemeController>().lightMap,
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: locationController.picking
                      ? Center(
                          child: SpinKitCircle(
                              color: Theme.of(context).primaryColor,
                              size: 40.0))
                      : SafeArea(
                          top: false,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, -1),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Trip Start Date
                                Text(
                                  'تبدأ الرحلة في 25 يونيو 2023',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 16),

                                // Start Location
                                _buildLocationItem(
                                  title: 'بداية الرحلة',
                                  address:
                                      locationController.fromAddress?.address ??
                                          'لم يتم تحديد نقطة البداية',
                                  icon: Images.car,
                                  iconColor: Colors.blue,
                                ),

                                // Breakpoints
                                ...locationController.breakpoints
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  var breakpoint = entry.value;
                                  return _buildLocationItem(
                                    title: 'نقطة استراحة',
                                    address: breakpoint['address'] ??
                                        'نقطة توقف ${index + 1}',
                                    icon: Images.location,
                                    iconColor: Colors.green,
                                  );
                                }).toList(),

                                // End Location
                                _buildLocationItem(
                                  title: 'نهاية الرحلة',
                                  address:
                                      locationController.toAddress?.address ??
                                          'لم يتم تحديد نقطة النهاية',
                                  icon: Images.car,
                                  iconColor: Colors.blue,
                                ),

                                SizedBox(height: 16),

                                // Confirm Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF002366),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: (locationController
                                                .buttonDisabled ||
                                            locationController.loading)
                                        ? null
                                        : () {
                                            // Handle confirm trip
                                            // Get.back();
                                            // Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>SearchTripsScreen()));
                                            // locationController.userSearchTrip();
                                            locationController.getPlaceWithLanLng(
                                                lat: 30.0444, lng: 31.2193);
                                          },
                                    child: Text(
                                      'تأكيد الرحلة',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
            ]);
          }),
        ),
      ),
    );
  }
}

List<Widget> generateBottomNavigationItems(
    BottomMenuController menuController, List<NavigationModel> item) {
  List<Widget> items = [];
  for (int index = 0; index < item.length; index++) {
    items.add(Expanded(
        child: CustomMenuItem(
      isSelected: menuController.currentTab == index,
      name: item[index].name,
      activeIcon: item[index].activeIcon,
      inActiveIcon: item[index].inactiveIcon,
      onTap: () => menuController.setTabIndex(index),
    )));
  }
  return items;
}

class CustomMenuItem extends StatelessWidget {
  final bool isSelected;
  final String name;
  final String activeIcon;
  final String inActiveIcon;
  final VoidCallback onTap;

  const CustomMenuItem({
    super.key,
    required this.isSelected,
    required this.name,
    required this.activeIcon,
    required this.inActiveIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Container(
            decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : null,
                borderRadius: isSelected ? BorderRadius.circular(20) : null),
            // width: isSelected ? 90 : 50,
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Image.asset(
                    isSelected ? activeIcon : inActiveIcon,
                    color: isSelected ? null : Colors.black38,
                    width: Dimensions.menuIconSize,
                    height: Dimensions.menuIconSize,
                  ),
                ),
                isSelected
                    ? Text(name.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeSmall))
                    : const SizedBox(),
              ],
            )),
      ),
    );
  }
}

Widget _buildLocationItem({
  required String title,
  required String address,
  required String icon,
  required Color iconColor,
}) {
  return Row(
    children: [
      Image.asset(
        icon,
        color: iconColor,
        width: Dimensions.menuIconSize,
        height: Dimensions.menuIconSize,
      ),
      SizedBox(width: 8),
      Expanded(
        child: Text(
          '$title: $address',
          style: TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
