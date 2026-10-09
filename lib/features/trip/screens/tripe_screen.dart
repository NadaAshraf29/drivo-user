import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/choose_widget.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/my_tripe_view_widget.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_item_view.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/user_tripe_view.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/details_tripe/screens/details_trips_screen.dart';

class TripeScreen extends StatefulWidget {
  final bool fromProfile;

  const TripeScreen({super.key, required this.fromProfile});

  @override
  State<TripeScreen> createState() => _TripeScreenState();
}

class _TripeScreenState extends State<TripeScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final ScrollController scrollController = ScrollController();

  // Sample data for demonstration
  final List<Map<String, dynamic>> trips = [
    {
      'carName': 'تويوتا كورولا',
      'startPoint': 'شارع الملك فهد، الرياض',
      'endPoint': 'شارع التحلية، جدة',
      'price': '150 ريال',
      'status': 'قيد التنفيذ',
      'seats': '4 مقاعد',
      'hasAC': true,
      'smokingAllowed': true,
    },
    {
      'carName': 'هوندا سيفيك',
      'startPoint': 'شارع العليا، الرياض',
      'endPoint': 'شارع التحلية، جدة',
      'price': '180 ريال',
      'status': 'مكتملة',
      'seats': '4 مقاعد',
      'hasAC': true,
      'smokingAllowed': false,
    },
    {
      'carName': 'نيسان صني',
      'startPoint': 'شارع النخيل، الرياض',
      'endPoint': 'شارع التحلية، جدة',
      'price': '120 ريال',
      'status': 'ملغية',
      'seats': '4 مقاعد',
      'hasAC': true,
      'smokingAllowed': true,
    },
    {
      'carName': 'هيونداي النترا',
      'startPoint': 'شارع العليا، الرياض',
      'endPoint': 'شارع التحلية، جدة',
      'price': '160 ريال',
      'status': 'قيد التنفيذ',
      'seats': '4 مقاعد',
      'hasAC': true,
      'smokingAllowed': false,
    },
    {
      'carName': 'كيا سيراتو',
      'startPoint': 'شارع النخيل، الرياض',
      'endPoint': 'شارع التحلية، جدة',
      'price': '140 ريال',
      'status': 'مكتملة',
      'seats': '4 مقاعد',
      'hasAC': true,
      'smokingAllowed': true,
    },
  ];

  @override
  void initState() {
    tabController = TabController(length: 5, vsync: this);
    Get.find<TripController>().initData();
    Get.find<TripController>().getTripList(1);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        Get.find<TripController>().setStatusIndex(tabController.index);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        body: BodyWidget(
          appBar: AppBarWidget(
              title: 'رحلاتي',
              showBackButton: widget.fromProfile,
              centerTitle: true,
              showTripHistoryFilter: true),
          body: ListView.builder(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeDefault),
                child: _buildTripCard(context, trips[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Map<String, dynamic> trip) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsTripScreen(
              isMyTrip: true,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).hintColor.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  Images.carTripeIcon,
                  width: 24,
                  height: 24,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text(
                  trip['carName'],
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _buildTripDetail(
              context,
              icon: Images.currentLocation,
              title: 'نقطة البداية',
              value: trip['startPoint'],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _buildTripDetail(
              context,
              icon: Images.activityDirection,
              title: 'نقطة الوصول',
              value: trip['endPoint'],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFeatureChip(
                  context,
                  icon: Images.userIcon,
                  label: trip['seats'],
                ),
                _buildFeatureChip(
                  context,
                  icon: Images.windIcon,
                  label: 'مكيف',
                ),
                _buildFeatureChip(
                  context,
                  icon: Images.audioIcon,
                  label: trip['smokingAllowed']
                      ? 'مسموح بالتدخين'
                      : 'غير مسموح بالتدخين',
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'السعر: ${trip['price']}',
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    trip['status'],
                    style: textRegular.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetail(
    BuildContext context, {
    required String icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Image.asset(
          icon,
          width: 20,
          height: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
            ),
            Text(
              value,
              style: textMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureChip(
    BuildContext context, {
    required String icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 16,
            height: 16,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text(
            label,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
