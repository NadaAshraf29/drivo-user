import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SelectedTripInfoCardWidget extends StatelessWidget {
  final PoolRide trip;

  const SelectedTripInfoCardWidget({
    super.key,
    required this.trip,
  });

  String _formatTimeStr(String raw) {
    if (raw.trim().isEmpty) return raw;
    DateTime? dt = DateTime.tryParse(raw);
    if (dt == null) {
      try {
        dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(raw.trim());
      } catch (_) {}
    }
    if (dt == null) {
      try {
        dt = DateFormat('HH:mm').parse(raw.trim());
      } catch (_) {}
    }
    if (dt != null) {
      return DateFormat('hh:mm a').format(dt.toLocal());
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final startAddress = trip.pickupAddress.isNotEmpty
        ? trip.pickupAddress
        : (trip.boardingPointStart?.name ?? 'Start Location');

    final destinationAddress = trip.dropoffAddress.isNotEmpty
        ? trip.dropoffAddress
        : (trip.boardingPointEnd?.name ?? 'Destination');

    final boardingStartName = trip.boardingPointStart?.name;
    final boardingEndName = trip.boardingPointEnd?.name;
    final closestPickupName = trip.closestPickup?.placeName;
    final closestDropoffName = trip.closestDropoff?.placeName;

    final departureTime = (trip.departureTime != null &&
            trip.departureTime!.trim().isNotEmpty)
        ? _formatTimeStr(trip.departureTime!)
        : (trip.startTime.isNotEmpty ? _formatTimeStr(trip.startTime) : '7:30 AM');

    final returnTime = (trip.returnTime != null &&
            trip.returnTime!.trim().isNotEmpty)
        ? _formatTimeStr(trip.returnTime!)
        : null;

    final price = trip.price > 0
        ? '${trip.price} EGP'
        : (trip.dailyPricePerSeat != null ? '${trip.dailyPricePerSeat} EGP' : '150 EGP');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Route Overview Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip Itinerary & Points'.tr,
                style: textBold.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${trip.seatsAvailable} ${'seats left'.tr}',
                  style: textSemiBold.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. Visual Route Timeline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline vertical indicator
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 2,
                    height: (closestPickupName != null || boardingStartName != null)
                        ? 58
                        : 42,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Route Points Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Start Point
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            startAddress,
                            style: textBold.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            departureTime,
                            style: textSemiBold.copyWith(
                              fontSize: 11,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (closestPickupName != null &&
                        closestPickupName.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.alt_route_rounded,
                              size: 13, color: Color(0xFF0284C7)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${'Meeting point:'.tr} $closestPickupName',
                              style: textMedium.copyWith(
                                fontSize: 11,
                                color: const Color(0xFF0284C7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ] else if (boardingStartName != null &&
                        boardingStartName.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${'Boarding point:'.tr} $boardingStartName',
                        style: textMedium.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF0284C7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 22),

                    // Destination Point
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            destinationAddress,
                            style: textBold.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (returnTime != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${'Return:'.tr} $returnTime',
                              style: textSemiBold.copyWith(
                                fontSize: 11,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (closestDropoffName != null &&
                        closestDropoffName.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${'Dropoff point:'.tr} $closestDropoffName',
                        style: textMedium.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else if (boardingEndName != null &&
                        boardingEndName.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${'End Boarding:'.tr} $boardingEndName',
                        style: textMedium.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1),
          const SizedBox(height: 16),

          // 3. Trip Specs Grid (Price & Type)
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  label: 'PRICE PER SEAT'.tr,
                  value: price,
                  valueColor: const Color(0xFF08A9F0),
                  icon: Icons.payments_outlined,
                ),
              ),
              Expanded(
                child: _buildInfoTile(
                  label: 'CARPOOL TYPE'.tr,
                  value: trip.carpoolTypeLabel ??
                      trip.carpoolType?.toUpperCase() ??
                      'ROUTINE',
                  valueColor: const Color(0xFF0F172A),
                  icon: Icons.commute_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4. Amenities & Preferences Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAmenityChip(
                icon: Icons.ac_unit_rounded,
                label: trip.isAc ? 'AC On'.tr : 'Standard'.tr,
                active: trip.isAc,
              ),
              _buildAmenityChip(
                icon: Icons.smoke_free_rounded,
                label: trip.isSmokingAllowed
                    ? 'Smoking'.tr
                    : 'No Smoking'.tr,
                active: !trip.isSmokingAllowed,
              ),
              _buildAmenityChip(
                icon: Icons.luggage_outlined,
                label: trip.allowLuggage
                    ? 'Luggage OK'.tr
                    : 'No Luggage'.tr,
                active: trip.allowLuggage,
              ),
              if (trip.hasMusic)
                _buildAmenityChip(
                  icon: Icons.music_note_rounded,
                  label: 'Music'.tr,
                  active: true,
                ),
              if (trip.allowedGender.isNotEmpty && trip.allowedGender != 'both')
                _buildAmenityChip(
                  icon: Icons.person_outline,
                  label: '${trip.allowedGender.capitalizeFirst} only'.tr,
                  active: true,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textBold.copyWith(
                  fontSize: 10,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textBold.copyWith(
                  fontSize: 14,
                  color: valueColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityChip({
    required IconData icon,
    required String label,
    required bool active,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: active ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: textMedium.copyWith(
              fontSize: 11,
              color: active ? const Color(0xFF15803D) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
