import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';

class HomeMapView extends StatefulWidget {
  final String title;
  const HomeMapView({super.key, required this.title});

  @override
  HomeMapViewState createState() => HomeMapViewState();
}

class HomeMapViewState extends State<HomeMapView> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_mapController != null) {
      _mapController!.dispose();
      _mapController = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapController>(
      builder: (mapController) {
        return GetBuilder<LocationController>(
          builder: (locationController) {
            return mapController.nearestDeliveryManMarkers != null
                ? Padding(
                    padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      Expanded(
                        child: GoogleMap(
                          key: const ValueKey('home_map'),
                          style: Get.isDarkMode
                              ? Get.find<ThemeController>().darkMap
                              : Get.find<ThemeController>().lightMap,
                          markers:
                              mapController.nearestDeliveryManMarkers!.toSet(),
                          initialCameraPosition: CameraPosition(
                              target: LatLng(
                                Get.find<LocationController>()
                                            .position
                                            .latitude !=
                                        0
                                    ? Get.find<LocationController>()
                                        .position
                                        .latitude
                                    : Get.find<LocationController>()
                                            .getUserAddress()
                                            ?.latitude ??
                                        0,
                                Get.find<LocationController>()
                                            .position
                                            .longitude !=
                                        0
                                    ? Get.find<LocationController>()
                                        .position
                                        .longitude
                                    : Get.find<LocationController>()
                                            .getUserAddress()
                                            ?.longitude ??
                                        0,
                              ),
                              zoom: 16),
                          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer(),
                            ),
                          },
                          minMaxZoomPreference:
                              const MinMaxZoomPreference(8, 20),
                          onMapCreated: (gController) {
                            if (_mapController == null) {
                              _mapController = gController;
                              mapController.setMapController(gController);
                            }
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomGesturesEnabled: true,
                          scrollGesturesEnabled: true,
                          rotateGesturesEnabled: true,
                          tiltGesturesEnabled: true,
                        ),
                      )
                    ]),
                  )
                : GoogleMap(
                    key: const ValueKey('home_map_fallback'),
                    style: Get.isDarkMode
                        ? Get.find<ThemeController>().darkMap
                        : Get.find<ThemeController>().lightMap,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(
                          Get.find<LocationController>()
                                  .getUserAddress()
                                  ?.latitude ??
                              0,
                          Get.find<LocationController>()
                                  .getUserAddress()
                                  ?.longitude ??
                              0,
                        ),
                        zoom: 18),
                    minMaxZoomPreference: const MinMaxZoomPreference(8, 20),
                  );
          },
        );
      },
    );
  }
}
