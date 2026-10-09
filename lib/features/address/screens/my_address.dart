import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_dialog_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/address/screens/add_new_address.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class MyAddressScreen extends StatefulWidget {
  const MyAddressScreen({super.key});

  @override
  State<MyAddressScreen> createState() => _MyAddressScreenState();
}

class _MyAddressScreenState extends State<MyAddressScreen> {
  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  @override
  void initState() {
    super.initState();
    Get.find<AddressController>().getAddressList(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 248, 248),
      body: BodyWidget(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          'my_address'.tr,
                          style: textBold.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          'Saved pickup and destination points'.tr,
                          style: textRegular.copyWith(
                            fontSize: 12,
                            color: _textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Address List
                Expanded(
                  child: GetBuilder<AddressController>(
                    builder: (addressController) {
                      if (addressController.addressList == null) {
                        return const Center(
                          child: SpinKitCircle(
                            color: _primaryBlue,
                            size: 40.0,
                          ),
                        );
                      }

                      if (addressController.addressList!.isEmpty) {
                        return const Center(
                          child: NoDataWidget(
                            title: 'no_address_found',
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: addressController.addressList!.length,
                        padding: const EdgeInsets.only(bottom: 90),
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) => AddressCard(
                          address: addressController.addressList![index],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryBlue,
        elevation: 4,
        highlightElevation: 6,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: Text(
          'add_address'.tr,
          style: textBold.copyWith(color: Colors.white, fontSize: 14),
        ),
        onPressed: () {
          Get.to(() => const AddNewAddress());
        },
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final Address address;
  const AddressCard({super.key, required this.address});

  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  @override
  Widget build(BuildContext context) {
    final label = (address.addressLabel ?? 'other').toLowerCase();
    final isHome = label == 'home';
    final isOffice = label == 'office' || label == 'work';

    final Color iconColor = isHome
        ? const Color(0xFF00A3EC)
        : isOffice
            ? const Color(0xFF7C4DFF)
            : const Color(0xFFFF9800);

    final Color iconBg = isHome
        ? const Color(0xFFE8F6FE)
        : isOffice
            ? const Color(0xFFEDE7F6)
            : const Color(0xFFFFF3E0);

    final IconData addressIcon = isHome
        ? Icons.home_rounded
        : isOffice
            ? Icons.work_rounded
            : Icons.location_on_rounded;

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                addressIcon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Label & Address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (address.addressLabel ?? 'other').tr,
                      style: textSemiBold.copyWith(
                        fontSize: 11,
                        color: iconColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.address ?? '',
                    style: textMedium.copyWith(
                      fontSize: 14,
                      color: _textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Edit button
            Material(
              color: const Color(0xFFF3F5F8),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Get.to(() => AddNewAddress(address: address)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    Images.editIcon,
                    width: 16,
                    height: 16,
                    color: _primaryBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Delete button
            Material(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Get.dialog(
                    ConfirmationDialogWidget(
                      icon: Images.completeIcon,
                      description: 'are_you_sure'.tr,
                      onYesPressed: () {
                        Get.find<AddressController>()
                            .deleteAddress(address.id.toString());
                      },
                    ),
                    barrierDismissible: false,
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF5350),
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
