import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/features/trip/screens/tripe_details_screen.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import '../../../helper/price_converter.dart';
import '../../ride/domain/models/trip_details_model.dart';
import '../domain/models/trip_model.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/special_trip_model.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/screens/special_trip_details_screen.dart';

class TripScreen extends StatefulWidget {
  final bool fromProfile;

  const TripScreen({
    super.key,
    required this.fromProfile,
  });

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);

  // Service filter options: 'All', 'Routine', 'Travel', 'Sahel', 'University', 'School', 'Parcel'
  int _selectedServiceIndex = 0;
  final List<Map<String, String>> _services = [
    {'key': 'all', 'label': 'All'},
    {'key': 'routine', 'label': 'Routine'},
    {'key': 'trip', 'label': 'One Trip'},
    {'key': 'travel', 'label': 'Travel'},
    {'key': 'north_coast', 'label': 'Sahel'},
    {'key': 'university', 'label': 'University'},
    {'key': 'school', 'label': 'School'},
    {'key': 'parcel', 'label': 'Parcel'},
  ];

  // Activity status filter options: 'All', 'Pending', 'Pending Payment', 'Upcoming', 'Ongoing', 'Completed', 'Cancelled'
  int _selectedStatusIndex = 0;
  final List<Map<String, String>> _statusFilters = [
    {'key': 'all', 'label': 'all'},
    {'key': 'pending', 'label': 'pending'},
    {'key': 'accepted_pending_payment', 'label': 'trip_pending_payment'},
    {'key': 'accepted', 'label': 'upcoming'},
    {'key': 'ongoing', 'label': 'ongoing'},
    {'key': 'completed', 'label': 'completed'},
    {'key': 'cancelled', 'label': 'cancelled'},
  ];

  final ScrollController _mainScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final controller = Get.find<TripController>();
    controller.initData();
    _fetchCurrentData(reload: true);
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  void _fetchCurrentData({bool reload = false, int offset = 1}) {
    final controller = Get.find<TripController>();
    final serviceKey = _services[_selectedServiceIndex]['key']!;
    final statusKey = _statusFilters[_selectedStatusIndex]['key']!;
    final safeStatus = (statusKey == 'accepted_pending_payment') ? 'all' : statusKey;

    if (serviceKey == 'parcel') {
      controller.getParcelTripList(
        offset,
        reload: reload,
        status: safeStatus,
      );
    } else {
      controller.getCarpoolTripList(
        offset,
        reload: reload,
        status: safeStatus,
      );
    }
  }

  List<TripDetails> _filterRides(List<TripDetails> rides) {
    final serviceKey = _services[_selectedServiceIndex]['key']!;
    final statusKey = _statusFilters[_selectedStatusIndex]['key']!;

    var filtered = rides;

    // Filter by service
    if (serviceKey != 'all' && serviceKey != 'parcel') {
      filtered = filtered.where((trip) {
        final type = (trip.carpoolType ?? '').toLowerCase();
        final rawType = (trip.type ?? '').toLowerCase();
        if (serviceKey == 'north_coast') {
          return type == 'north_coast' ||
              type == 'sahel' ||
              rawType == 'north_coast' ||
              rawType == 'sahel';
        }
        if (serviceKey == 'routine') {
          return type == 'routine' ||
              rawType == 'routine' ||
              type.contains('routine') ||
              rawType.contains('routine') ||
              trip.isScheduledSubscription;
        }
        return type == serviceKey || rawType == serviceKey;
      }).toList();
    }

    // Filter by status if tab is 'accepted_pending_payment'
    if (statusKey == 'accepted_pending_payment') {
      filtered = filtered.where((trip) {
        final st = (trip.currentStatus ?? '').toLowerCase();
        if (st == 'accepted_pending_payment' ||
            st == 'waiting_for_payment' ||
            st == 'waiting_payment') {
          return true;
        }
        final isUnpaid = trip.paymentStatus?.toLowerCase() == 'unpaid' ||
            (trip.paidFare == null || trip.paidFare == 0);
        final isNotCancelled =
            st != 'cancelled' && st != 'canceled' && st != 'completed';
        final hasDriver = trip.driver != null;
        return hasDriver && isUnpaid && isNotCancelled;
      }).toList();
    } else if (statusKey == 'pending') {
      filtered = filtered.where((trip) {
        final st = (trip.currentStatus ?? '').toLowerCase();
        return st != 'accepted_pending_payment' && st != 'waiting_for_payment';
      }).toList();
    } else if (statusKey == 'accepted') {
      filtered = filtered.where((trip) {
        final st = (trip.currentStatus ?? '').toLowerCase();
        return st != 'accepted_pending_payment' && st != 'waiting_for_payment';
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 246, 248, 248),
        body: SafeArea(
          child: RefreshIndicator(
            color: _primaryBlue,
            onRefresh: () async => _fetchCurrentData(reload: true),
            child: SingleChildScrollView(
              controller: _mainScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Text(
                    'Activity'.tr,
                    style: textBold.copyWith(
                      color: _textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All your Drivo trips and services in one place.'.tr,
                    style: textRegular.copyWith(
                      color: _textSubtle,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// SERVICE FILTER BOX
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFEBEFF5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SERVICE'.tr,
                          style: textSemiBold.copyWith(
                            color: _textSubtle,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(_services.length, (index) {
                              final isSelected = _selectedServiceIndex == index;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    if (_selectedServiceIndex != index) {
                                      setState(() {
                                        _selectedServiceIndex = index;
                                      });
                                      _fetchCurrentData(reload: true);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _primaryBlue
                                          : const Color(0xFFF3F5F8),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _services[index]['label']!.tr,
                                      style: textSemiBold.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : _textDark,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// MY ACTIVITY SECTION HEADER
                  Text(
                    'My activity'.tr,
                    style: textBold.copyWith(
                      color: _textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// MY ACTIVITY STATUS FILTER BAR
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEBEFF5)),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_statusFilters.length, (index) {
                          final isSelected = _selectedStatusIndex == index;
                          return InkWell(
                            onTap: () {
                              if (_selectedStatusIndex != index) {
                                setState(() {
                                  _selectedStatusIndex = index;
                                });
                                _fetchCurrentData(reload: true);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE6F6FE)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _statusFilters[index]['label']!.tr,
                                style: textSemiBold.copyWith(
                                  color:
                                      isSelected ? _primaryBlue : _textSubtle,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// TRIP LIST VIEW CONTENT
                  GetBuilder<TripController>(
                    builder: (controller) {
                      final isParcel =
                          _services[_selectedServiceIndex]['key'] == 'parcel';
                      final TripModel? model = isParcel
                          ? controller.parcelTripModel
                          : controller.carpoolTripModel;

                      if (model == null || model.data == null) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _primaryBlue,
                            ),
                          ),
                        );
                      }

                      List<TripDetails> rides =
                          isParcel ? (model.parcelRides) : (model.carpoolRides);

                      // Also include parcel rides when 'All' service is selected
                      if (_services[_selectedServiceIndex]['key'] == 'all' &&
                          controller.parcelTripModel?.data != null) {
                        rides = [
                          ...rides,
                          ...controller.parcelTripModel!.parcelRides
                        ];
                      }

                      final filteredRides = _filterRides(rides);

                      if (filteredRides.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: NoDataWidget(title: 'no_trip_found'),
                        );
                      }

                      return PaginatedListWidget(
                        scrollController: _mainScrollController,
                        totalSize: _statusFilters[_selectedStatusIndex]['key'] ==
                                'accepted_pending_payment'
                            ? filteredRides.length
                            : model.totalSize,
                        offset: model.offset != null
                            ? int.tryParse(model.offset.toString())
                            : null,
                        onPaginate: (int? offset) async {
                          if (offset != null) {
                            _fetchCurrentData(offset: offset);
                          }
                        },
                        itemView: ListView.separated(
                          itemCount: filteredRides.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 120),
                          itemBuilder: (context, index) {
                            return ActivityItemCard(
                                tripDetails: filteredRides[index]);
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Redesigned Activity Card Widget
// ─────────────────────────────────────────────────────────────────────────────
class ActivityItemCard extends StatelessWidget {
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _primaryBlue = Color(0xFF00A3EC);

  final TripDetails tripDetails;

  const ActivityItemCard({
    super.key,
    required this.tripDetails,
  });

  Widget _buildChip(String label, {required bool isPrimary, String? status}) {
    Color bg = isPrimary ? const Color(0xFFE6F6FE) : const Color(0xFFF3F5F8);
    Color fg = isPrimary ? _primaryBlue : _textSubtle;

    if (status == 'accepted_pending_payment') {
      bg = const Color(0xFFFFF7ED);
      fg = const Color(0xFFEA580C);
    } else if (status == 'completed') {
      bg = const Color(0xFFF0FDF4);
      fg = const Color(0xFF16A34A);
    } else if (status == 'cancelled') {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFDC2626);
    } else if (status == 'pending') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textSemiBold.copyWith(
          color: fg,
          fontSize: 11,
        ),
      ),
    );
  }

  List<String> _getStartPoints(TripDetails trip) {
    final typeLower = (trip.carpoolType ?? trip.type ?? '').toLowerCase();
    final rawTypeLower = (trip.type ?? '').toLowerCase();
    final isRoutine = typeLower == 'routine' ||
        typeLower.contains('routine') ||
        rawTypeLower == 'routine' ||
        rawTypeLower.contains('routine') ||
        trip.isScheduledSubscription;

    // Routine type: start_address is the primary key (e.g. Heliopolis)
    if (isRoutine) {
      final s = (trip.startAddress ?? '').trim();
      if (s.isNotEmpty && !TripDetails.isGenericPlaceholder(s)) {
        return [s];
      }
      final rawStart = (trip.rawJson?['start_address'] ??
              trip.rawJson?['pickup_address'] ??
              trip.rawJson?['from_address'])
          ?.toString()
          .trim();
      if (rawStart != null &&
          rawStart.isNotEmpty &&
          !TripDetails.isGenericPlaceholder(rawStart)) {
        return [rawStart];
      }
    }

    final List<String> list = [];
    if (trip.pickupLocations != null && trip.pickupLocations!.isNotEmpty) {
      for (final loc in trip.pickupLocations!) {
        final a = (loc.address ?? '').trim();
        if (a.isNotEmpty && !TripDetails.isGenericPlaceholder(a)) {
          list.add(a);
        }
      }
    }
    if (list.isEmpty) {
      final a = trip.startAddressDisplay.trim();
      if (a.isNotEmpty && !TripDetails.isGenericPlaceholder(a)) {
        list.add(a);
      }
    }
    if (list.isEmpty) {
      final a = (trip.pickupAddress ?? trip.startAddress ?? '').trim();
      if (a.isNotEmpty && !TripDetails.isGenericPlaceholder(a)) {
        list.add(a);
      }
    }
    if (list.isEmpty) {
      final rawStart = (trip.rawJson?['start_address'] ??
              trip.rawJson?['pickup_address'])
          ?.toString()
          .trim();
      if (rawStart != null &&
          rawStart.isNotEmpty &&
          !TripDetails.isGenericPlaceholder(rawStart)) {
        list.add(rawStart);
      }
    }
    if (list.isEmpty && trip.stops != null && trip.stops!.isNotEmpty) {
      for (final s in trip.stops!) {
        final a = (s.address ?? s.name).trim();
        if (a.isNotEmpty && !TripDetails.isGenericPlaceholder(a)) {
          list.add(a);
        }
      }
    }
    if (list.isEmpty && trip.carpoolRideLocation?.address != null) {
      final a = trip.carpoolRideLocation!.address!.trim();
      if (a.isNotEmpty && !TripDetails.isGenericPlaceholder(a)) {
        list.add(a);
      }
    }
    return list;
  }

  List<String> _getEndPoints(TripDetails trip) {
    final typeLower = (trip.carpoolType ?? trip.type ?? '').toLowerCase();
    final rawTypeLower = (trip.type ?? '').toLowerCase();
    final isRoutine = typeLower == 'routine' ||
        typeLower.contains('routine') ||
        rawTypeLower == 'routine' ||
        rawTypeLower.contains('routine') ||
        trip.isScheduledSubscription;

    // Routine type: end_address is the primary key (e.g. New Cairo)
    if (isRoutine) {
      final e = (trip.endAddress ?? '').trim();
      if (e.isNotEmpty && !TripDetails.isGenericPlaceholder(e)) {
        return [e];
      }
      final rawEnd = (trip.rawJson?['end_address'] ??
              trip.rawJson?['destination_address'] ??
              trip.rawJson?['to_address'])
          ?.toString()
          .trim();
      if (rawEnd != null &&
          rawEnd.isNotEmpty &&
          !TripDetails.isGenericPlaceholder(rawEnd)) {
        return [rawEnd];
      }
    }

    final List<String> list = [];
    if (trip.destinationLocations != null && trip.destinationLocations!.isNotEmpty) {
      for (final loc in trip.destinationLocations!) {
        final a = (loc.address ?? '').trim();
        if (a.isNotEmpty && !TripDetails.isGenericPlaceholder(a)) {
          list.add(a);
        }
      }
    }
    if (list.isEmpty) {
      final a = trip.endAddressDisplay.trim();
      if (a.isNotEmpty && !TripDetails.isGenericPlaceholder(a)) {
        list.add(a);
      }
    }
    if (list.isEmpty) {
      final a = (trip.destinationAddress ?? trip.endAddress ?? '').trim();
      if (a.isNotEmpty && !TripDetails.isGenericPlaceholder(a)) {
        list.add(a);
      }
    }
    if (list.isEmpty) {
      final rawEnd = (trip.rawJson?['end_address'] ??
              trip.rawJson?['destination_address'])
          ?.toString()
          .trim();
      if (rawEnd != null &&
          rawEnd.isNotEmpty &&
          !TripDetails.isGenericPlaceholder(rawEnd)) {
        list.add(rawEnd);
      }
    }
    if (list.isEmpty && trip.stops != null && trip.stops!.isNotEmpty) {
      for (final s in trip.stops!.reversed) {
        final a = (s.address ?? s.name).trim();
        if (a.isNotEmpty && !TripDetails.isGenericPlaceholder(a)) {
          list.add(a);
          break;
        }
      }
    }
    if (list.isEmpty && trip.carpoolDropoffLocation?.address != null) {
      final a = trip.carpoolDropoffLocation!.address!.trim();
      if (a.isNotEmpty && !TripDetails.isGenericPlaceholder(a)) {
        list.add(a);
      }
    }
    return list;
  }

  Widget _buildRoutePointsSection({
    required List<String> startPoints,
    required List<String> endPoints,
    required String defaultStart,
    required String defaultEnd,
    bool isParcel = false,
  }) {
    final actualStarts =
        startPoints.isNotEmpty ? startPoints : [defaultStart];
    final actualEnds =
        endPoints.isNotEmpty ? endPoints : [defaultEnd];

    final startLabelBase = isParcel
        ? ('pickup_location'.tr == 'pickup_location'
            ? 'Pickup Location'
            : 'pickup_location'.tr)
        : ('start_point'.tr == 'start_point'
            ? 'Start Point'
            : 'start_point'.tr);
    final endLabelBase = isParcel
        ? ('destination'.tr == 'destination'
            ? 'Destination'
            : 'destination'.tr)
        : ('end_point'.tr == 'end_point'
            ? 'End Point'
            : 'end_point'.tr);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Start point(s)
          ...actualStarts.asMap().entries.map((entry) {
            final idx = entry.key;
            final addr = entry.value;
            final isMulti = actualStarts.length > 1;
            final label =
                isMulti ? '$startLabelBase #${idx + 1}' : startLabelBase;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                        border: Border.all(color: _primaryBlue, width: 3),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 24,
                      color: const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: textSemiBold.copyWith(
                            color: _textSubtle,
                            fontSize: 10,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          addr,
                          style: textBold.copyWith(
                            color: _textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),

          // End point(s)
          ...actualEnds.asMap().entries.map((entry) {
            final idx = entry.key;
            final addr = entry.value;
            final isMulti = actualEnds.length > 1;
            final isLast = idx == actualEnds.length - 1;
            final label =
                isMulti ? '$endLabelBase #${idx + 1}' : endLabelBase;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFEF4444), width: 3),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 24,
                        color: const Color(0xFFCBD5E1),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: textSemiBold.copyWith(
                          color: _textSubtle,
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        addr,
                        style: textBold.copyWith(
                          color: _textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isParcel =
        tripDetails.type == 'parcel' || tripDetails.parcelInformation != null;
    final isScheduled = tripDetails.isScheduledSubscription;
    final typeLower =
        (tripDetails.carpoolType ?? tripDetails.type ?? '').toLowerCase();
    final rawTypeLower = (tripDetails.type ?? '').toLowerCase();
    final isRoutine = typeLower == 'routine' ||
        typeLower.contains('routine') ||
        rawTypeLower == 'routine' ||
        rawTypeLower.contains('routine');
    final isSubscription = isScheduled ||
        isRoutine ||
        (tripDetails.type != null &&
            tripDetails.type!.toLowerCase().contains('subscri')) ||
        (tripDetails.carpoolType != null &&
            tripDetails.carpoolType!.toLowerCase().contains('subscri')) ||
        tripDetails.type?.toLowerCase() == 'special_request' ||
        tripDetails.carpoolType?.toLowerCase() == 'special_request' ||
        tripDetails.type?.toLowerCase() == 'special_trip' ||
        tripDetails.carpoolType?.toLowerCase() == 'special_trip';

    final categoryLabel = isRoutine
        ? ('routine'.tr == 'routine' ? 'Routine' : 'routine'.tr)
        : isSubscription
            ? ((tripDetails.type != null &&
                        tripDetails.type!.toLowerCase().contains('subscri')) ||
                    (tripDetails.carpoolType != null &&
                        tripDetails.carpoolType!.toLowerCase().contains('subscri'))
                ? ('subscription'.tr == 'subscription'
                    ? 'Subscription'
                    : 'subscription'.tr)
                : ('scheduled_ride'.tr == 'scheduled_ride'
                    ? 'Scheduled Ride'
                    : 'scheduled_ride'.tr))
            : isParcel
                ? 'parcel'.tr
                : (tripDetails.carpoolTypeString.isNotEmpty
                    ? tripDetails.carpoolTypeString.tr
                    : 'carpool'.tr);

    final String rawStatus = (tripDetails.currentStatus ?? 'Upcoming').toLowerCase();
    final String statusLabel;
    if (rawStatus == 'accepted_pending_payment') {
      statusLabel = 'trip_pending_payment'.tr == 'trip_pending_payment'
          ? 'Pending Payment'
          : 'trip_pending_payment'.tr;
    } else if (rawStatus.tr != rawStatus) {
      statusLabel = rawStatus.tr;
    } else {
      statusLabel = rawStatus.replaceAll('_', ' ').capitalizeFirst ?? rawStatus;
    }

    final price = tripDetails.actualFare ??
        tripDetails.estimatedFare ??
        tripDetails.paidFare ??
        0;

    final startPoints = _getStartPoints(tripDetails);
    final endPoints = _getEndPoints(tripDetails);

    final startAddress = startPoints.isNotEmpty
        ? startPoints.first
        : ((tripDetails.startAddress != null &&
                tripDetails.startAddress!.trim().isNotEmpty &&
                !TripDetails.isGenericPlaceholder(tripDetails.startAddress))
            ? tripDetails.startAddress!.trim()
            : (tripDetails.startAddressDisplay.isNotEmpty
                ? tripDetails.startAddressDisplay.split('-').first.trim()
                : (tripDetails.pickupAddress?.split('-').first.trim() ??
                    'pickup_location'.tr)));
    final endAddress = endPoints.isNotEmpty
        ? endPoints.last
        : ((tripDetails.endAddress != null &&
                tripDetails.endAddress!.trim().isNotEmpty &&
                !TripDetails.isGenericPlaceholder(tripDetails.endAddress))
            ? tripDetails.endAddress!.trim()
            : (tripDetails.endAddressDisplay.isNotEmpty
                ? tripDetails.endAddressDisplay.split('-').first.trim()
                : (tripDetails.destinationAddress?.split('-').first.trim() ??
                    'destination'.tr)));

    // Custom or route title
    final customTitle = (tripDetails.title != null &&
            tripDetails.title!.trim().isNotEmpty &&
            tripDetails.title!.trim().toLowerCase() != 'scheduled subscription' &&
            tripDetails.title!.trim().toLowerCase() != 'subscription' &&
            tripDetails.title!.trim().toLowerCase() != 'subscribtion' &&
            tripDetails.title!.trim().toLowerCase() != 'routine')
        ? tripDetails.title!.trim()
        : (tripDetails.routeName != null &&
                tripDetails.routeName!.trim().isNotEmpty &&
                tripDetails.routeName!.trim().toLowerCase() != 'scheduled subscription' &&
                tripDetails.routeName!.trim().toLowerCase() != 'subscription' &&
                tripDetails.routeName!.trim().toLowerCase() != 'subscribtion' &&
                tripDetails.routeName!.trim().toLowerCase() != 'routine')
            ? tripDetails.routeName!.trim()
            : null;

    final String dateStr = tripDetails.formattedDate.isNotEmpty
        ? tripDetails.formattedDate
        : (tripDetails.startDate != null && tripDetails.startDate!.isNotEmpty
            ? tripDetails.startDate!
            : 'today'.tr);
    final String timeStr = tripDetails.formattedTime.isNotEmpty
        ? tripDetails.formattedTime
        : (tripDetails.startTime ?? '');
    final scheduleSubtitle = [dateStr, if (timeStr.isNotEmpty) timeStr].join(' · ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEFF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (tripDetails.id != null && tripDetails.id!.isNotEmpty) {
              if (isSubscription) {
                Get.to(() => SpecialTripDetailsScreen(
                      trip: SpecialTripRequestModel.fromTripDetails(tripDetails),
                    ));
              } else {
                Get.to(() => TripeDetailsScreen(
                      tripId: tripDetails.id!,
                      fromCarpoolTab: true,
                    ));
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// CHIPS & PRICE ROW (Safe Wrap layout preventing overflow crashes)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildChip(categoryLabel, isPrimary: true),
                          _buildChip(statusLabel, isPrimary: false, status: rawStatus),
                        ],
                      ),
                    ),
                    if (price > 0) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 0,
                        child: Text(
                          PriceConverter.convertPrice(price.toDouble()),
                          style: textBold.copyWith(
                            color: _textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                /// TITLE (if custom title exists)
                if (customTitle != null) ...[
                  Text(
                    customTitle,
                    style: textBold.copyWith(
                      color: _textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],

                /// DATE & TIME
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 13, color: _textSubtle),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        scheduleSubtitle,
                        style: textRegular.copyWith(
                          color: _textSubtle,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                /// ROUTE POINTS SECTION
                _buildRoutePointsSection(
                  startPoints: startPoints,
                  endPoints: endPoints,
                  defaultStart: startAddress,
                  defaultEnd: endAddress,
                  isParcel: isParcel,
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF0F3F7)),
                const SizedBox(height: 10),

                /// BOTTOM FOOTER (Payment / Details link)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isSubscription
                            ? '${'payment'.tr}: ${tripDetails.paymentStatus?.capitalizeFirst ?? 'Unpaid'}'
                            : isParcel
                                ? 'parcel_delivery'.tr
                                : '${'payment'.tr}: ${tripDetails.paymentMethod?.tr ?? 'card'.tr}',
                        style: textRegular.copyWith(
                          color: _textSubtle,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'View details ›'.tr,
                      style: textSemiBold.copyWith(
                        color: _primaryBlue,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
Archived Code:
                      if (model == null || model.data == null) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: NotificationShimmer(),
                        );
                      }
*/
