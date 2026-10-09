import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/address/screens/search_and_pick_location_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class AddNewAddress extends StatefulWidget {
  final Address? address;
  const AddNewAddress({super.key, this.address});

  @override
  State<AddNewAddress> createState() => _AddNewAddressState();
}

class _AddNewAddressState extends State<AddNewAddress> {
  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController roadController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController addressLevelController = TextEditingController();
  CameraPosition? _cameraPosition;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    Get.find<LocationController>().initTextControllers();
    if (widget.address != null) {
      Get.find<LocationController>().locationController.text =
          widget.address!.address!;
      houseController.text = widget.address!.house ?? '';
      roadController.text = widget.address!.street ?? '';
      addressLevelController.text = widget.address?.addressLabel ?? '';
      Get.find<AddressController>().updateAddressIndex(
        widget.address!.addressLabel! == 'home'
            ? 0
            : widget.address!.addressLabel! == 'office'
                ? 1
                : 2,
        false,
      );
      _cameraPosition = CameraPosition(
        target: LatLng(widget.address!.latitude!, widget.address!.longitude!),
      );
    }
    phoneController.text =
        Get.find<ProfileController>().profileModel?.data?.phone ?? '';
    final firstName =
        Get.find<ProfileController>().profileModel?.data?.firstName ?? '';
    final lastName =
        Get.find<ProfileController>().profileModel?.data?.lastName ?? '';
    nameController.text = '$firstName $lastName'.trim();
  }

  @override
  void dispose() {
    Get.find<LocationController>().mapController?.dispose();
    _mapController?.dispose();
    nameController.dispose();
    phoneController.dispose();
    roadController.dispose();
    houseController.dispose();
    addressLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.address != null;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 248, 248),
      body: BodyWidget(
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                          isEdit ? 'update_address'.tr : 'add_address'.tr,
                          style: textBold.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          'Save your favorite location for easy booking'.tr,
                          style: textRegular.copyWith(
                            fontSize: 12,
                            color: _textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Scrollable Form Content
                Expanded(
                  child: GetBuilder<AddressController>(
                    builder: (addressController) {
                      return GetBuilder<LocationController>(
                        builder: (locationController) {
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // MAP PREVIEW CARD
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _cardBorder),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          height: 180,
                                          width: double.infinity,
                                          child: GoogleMap(
                                            initialCameraPosition:
                                                CameraPosition(
                                              target: widget.address != null
                                                  ? LatLng(
                                                      widget.address!.latitude!,
                                                      widget
                                                          .address!.longitude!)
                                                  : locationController
                                                      .initialPosition,
                                              zoom: 16,
                                            ),
                                            onMapCreated: (GoogleMapController
                                                controller) {
                                              _mapController = controller;
                                              locationController
                                                      .mapController =
                                                  controller;
                                            },
                                            onCameraIdle: () {
                                              if (_cameraPosition != null) {
                                                locationController
                                                    .updatePosition(
                                                  _cameraPosition?.target,
                                                  false,
                                                  null,
                                                );
                                              }
                                            },
                                            onCameraMove: ((position) =>
                                                _cameraPosition = position),
                                            minMaxZoomPreference:
                                                const MinMaxZoomPreference(
                                                    0, 16),
                                            myLocationEnabled: true,
                                            myLocationButtonEnabled: false,
                                            zoomControlsEnabled: false,
                                            compassEnabled: false,
                                            indoorViewEnabled: true,
                                            mapToolbarEnabled: false,
                                            style: Get.isDarkMode
                                                ? Get.find<ThemeController>()
                                                    .darkMap
                                                : Get.find<ThemeController>()
                                                    .lightMap,
                                          ),
                                        ),

                                        // Center Pin
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 24),
                                            child: SizedBox(
                                              width: 44,
                                              height: 44,
                                              child: Image.asset(
                                                Images.pickLocation,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Fullscreen expand button
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Material(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            elevation: 2,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              onTap: () => Get.to(
                                                () => PickMapScreen(
                                                  type: LocationType.location,
                                                  onLocationPicked: (Position
                                                          position,
                                                      String address) {
                                                    locationController
                                                        .mapController!
                                                        .moveCamera(
                                                      CameraUpdate
                                                          .newCameraPosition(
                                                        CameraPosition(
                                                          target: LatLng(
                                                              position.latitude,
                                                              position
                                                                  .longitude),
                                                          zoom: 16,
                                                        ),
                                                      ),
                                                    );
                                                    locationController
                                                            .locationController
                                                            .text =
                                                        address;
                                                  },
                                                  oldLocationExist:
                                                      locationController
                                                          .pickAddress
                                                          .isNotEmpty,
                                                ),
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 10,
                                                    vertical: 8),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.fullscreen_rounded,
                                                      size: 18,
                                                      color: _primaryBlue,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Full Map'.tr,
                                                      style:
                                                          textSemiBold.copyWith(
                                                        fontSize: 12,
                                                        color: _primaryBlue,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // LABEL SELECTOR SECTION
                                _buildSectionTitle('LABEL AS'.tr),
                                const SizedBox(height: 8),

                                Row(
                                  children: List.generate(
                                    addressController.addressTypeList.length,
                                    (index) {
                                      final isSelected = addressController
                                              .selectAddressIndex ==
                                          index;
                                      final type = addressController
                                          .addressTypeList[index];

                                      final isHome = index == 0;
                                      final isOffice = index == 1;

                                      final activeColor = isHome
                                          ? _primaryBlue
                                          : isOffice
                                              ? const Color(0xFF7C4DFF)
                                              : const Color(0xFFFF9800);

                                      final activeBg = isHome
                                          ? const Color(0xFFE8F6FE)
                                          : isOffice
                                              ? const Color(0xFFEDE7F6)
                                              : const Color(0xFFFFF3E0);

                                      return Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            right: index <
                                                    addressController
                                                            .addressTypeList
                                                            .length -
                                                        1
                                                ? 8
                                                : 0,
                                          ),
                                          child: Material(
                                            color: isSelected
                                                ? activeBg
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              onTap: () => addressController
                                                  .updateAddressIndex(
                                                      index, true),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? activeColor
                                                        : _cardBorder,
                                                    width: isSelected ? 1.5 : 1,
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      isHome
                                                          ? Icons.home_rounded
                                                          : isOffice
                                                              ? Icons
                                                                  .work_rounded
                                                              : Icons
                                                                  .location_on_rounded,
                                                      size: 24,
                                                      color: isSelected
                                                          ? activeColor
                                                          : _textSubtle,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      type.title.tr,
                                                      style:
                                                          textSemiBold.copyWith(
                                                        fontSize: 12,
                                                        color: isSelected
                                                            ? activeColor
                                                            : _textDark,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // ADDRESS DETAILS FORM CARD
                                _buildSectionTitle('ADDRESS DETAILS'.tr),
                                const SizedBox(height: 8),

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _cardBorder),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Custom Label Name (if Other is selected)
                                      if (addressController
                                              .selectAddressIndex ==
                                          2) ...[
                                        _buildFieldLabel(
                                            'address_level_name'.tr),
                                        const SizedBox(height: 6),
                                        CustomTextField(
                                          hintText:
                                              'e.g. Gym, University, Parent House'
                                                  .tr,
                                          inputType:
                                              TextInputType.streetAddress,
                                          prefixIcon: Images.location,
                                          controller: addressLevelController,
                                          borderRadius: 12,
                                          showBorder: true,
                                          fillColor: const Color(0xFFF8FAFC),
                                          inputAction: TextInputAction.next,
                                        ),
                                        const SizedBox(height: 14),
                                      ],

                                      // Pick Location string (Search & Pick)
                                      _buildFieldLabel('pick_location'.tr),
                                      const SizedBox(height: 6),
                                      CustomTextField(
                                        hintText: 'pick_location'.tr,
                                        inputType: TextInputType.name,
                                        prefixIcon: Images.location,
                                        read: true,
                                        controller: locationController
                                            .locationController,
                                        borderRadius: 12,
                                        showBorder: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        inputAction: TextInputAction.next,
                                        onTap: () {
                                          Get.to(() =>
                                              SearchAndPickLocationScreen(
                                                  mapController:
                                                      _mapController));
                                        },
                                      ),
                                      const SizedBox(height: 14),

                                      // Contact Person Name
                                      _buildFieldLabel('Contact Name'.tr),
                                      const SizedBox(height: 6),
                                      CustomTextField(
                                        hintText: 'name'.tr,
                                        inputType: TextInputType.name,
                                        prefixIcon: Images.person,
                                        controller: nameController,
                                        borderRadius: 12,
                                        showBorder: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        inputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 14),

                                      // Contact Phone Number
                                      _buildFieldLabel('Phone Number'.tr),
                                      const SizedBox(height: 6),
                                      CustomTextField(
                                        hintText: 'phone'.tr,
                                        inputType: TextInputType.phone,
                                        prefixIcon: Images.call,
                                        controller: phoneController,
                                        borderRadius: 12,
                                        showBorder: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        inputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 14),

                                      // Street / Building / Landmark
                                      _buildFieldLabel('street'.tr),
                                      const SizedBox(height: 6),
                                      CustomTextField(
                                        hintText:
                                            'e.g. Building 12, Street 90'.tr,
                                        inputType: TextInputType.name,
                                        controller: roadController,
                                        prefixIcon: Images.road,
                                        borderRadius: 12,
                                        showBorder: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        inputAction: TextInputAction.done,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // BOTTOM ACTION BUTTON
                GetBuilder<AddressController>(builder: (addressController) {
                  return GetBuilder<LocationController>(
                      builder: (locationController) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: !addressController.isLoading
                          ? ButtonWidget(
                              buttonText: widget.address != null
                                  ? 'update_address'.tr
                                  : 'save_address'.tr,
                              radius: 16,
                              backgroundColor: _primaryBlue,
                              onPressed: () async {
                                String location =
                                    locationController.locationController.text;
                                String name = nameController.text.trim();
                                String phone = phoneController.text.trim();
                                String street = roadController.text.trim();
                                String levelName =
                                    addressLevelController.text.trim();

                                if (location.isEmpty) {
                                  showCustomSnackBar('address_is_required'.tr);
                                } else if (name.isEmpty) {
                                  showCustomSnackBar('name_is_required'.tr);
                                } else if (phone.isEmpty) {
                                  showCustomSnackBar('phone_is_required'.tr);
                                } else if (addressController
                                            .selectAddressIndex ==
                                        2 &&
                                    levelName.isEmpty) {
                                  showCustomSnackBar(
                                    'address_level_name_required'.tr,
                                  );
                                } else {
                                  if (locationController.pickPosition.latitude ==
                                      0) {
                                    showCustomSnackBar(
                                      'pick_location_from_map'.tr,
                                    );
                                    return;
                                  }

                                  Address address = Address(
                                    id: widget.address?.id,
                                    address: location,
                                    latitude: locationController
                                        .pickPosition.latitude,
                                    longitude: locationController
                                        .pickPosition.longitude,
                                    contactPersonName: name,
                                    contactPersonPhone: phone,
                                    street: street,
                                    addressLabel: addressController
                                                .selectAddressIndex ==
                                            2
                                        ? levelName
                                        : addressController.selectAddress,
                                  );

                                  await addressController.addNewAddress(
                                    address,
                                    updateAddress: widget.address != null,
                                  );

                                  showCustomSnackBar(
                                    widget.address != null
                                        ? 'address_updated_successfully'.tr
                                        : 'address_added_successfully'.tr,
                                    isError: false,
                                  );

                                  Get.back();
                                }
                              },
                            )
                          : const Center(
                              child: SpinKitCircle(
                                color: _primaryBlue,
                                size: 40.0,
                              ),
                            ),
                    );
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: textSemiBold.copyWith(
          color: _textSubtle,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: textSemiBold.copyWith(
        fontSize: 13,
        color: _textDark,
      ),
    );
  }
}
