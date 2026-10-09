import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/controller/create_your_own_trip_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class AddPassengerBottomSheet extends StatefulWidget {
  const AddPassengerBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    final controller = Get.find<CreateYourOwnTripController>();
    controller.clearPassengerSearch();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddPassengerBottomSheet(),
    );
  }

  @override
  State<AddPassengerBottomSheet> createState() => _AddPassengerBottomSheetState();
}

class _AddPassengerBottomSheetState extends State<AddPassengerBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: GetBuilder<CreateYourOwnTripController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'add_passenger'.tr,
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'search_registered_user_by_phone'.tr,
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),

                // Phone Input Field + Search Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone_iphone_rounded,
                              size: 20,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+20',
                                style: textBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: textMedium.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: const Color(0xFF0F172A),
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '10X XXX XXXX',
                                  hintStyle: textRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  isDense: true,
                                ),
                                onSubmitted: (val) {
                                  controller.searchPassengerByPhone(val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: controller.isSearchingPassenger
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              controller.searchPassengerByPhone(_phoneController.text);
                            },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: controller.isSearchingPassenger
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.search_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    'search'.tr,
                                    style: textBold.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),

                // Error Message if any
                if (controller.searchPassengerError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.searchPassengerError!,
                            style: textMedium.copyWith(
                              fontSize: 12,
                              color: const Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Matched User Result Card
                if (controller.searchedPassenger != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    'matched_passenger'.tr,
                    style: textSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFFDCFCE7),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF16A34A),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.searchedPassenger!.name,
                                style: textBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.searchedPassenger!.phone,
                                style: textRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            controller.confirmAddPassenger(controller.searchedPassenger!);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'confirm'.tr,
                                  style: textBold.copyWith(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}
