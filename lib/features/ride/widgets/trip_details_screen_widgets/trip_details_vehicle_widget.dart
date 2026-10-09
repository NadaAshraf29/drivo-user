import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripDetailsVehicleWidget extends StatelessWidget {
  final dynamic trip;

  const TripDetailsVehicleWidget({
    super.key,
    required this.trip,
  });

  String _getVehicleBrand() {
    try {
      // 1. Direct trip.vehicle
      if (trip.vehicle != null) {
        if (trip.vehicle is Map) {
          final b = trip.vehicle['brand'] ??
              trip.vehicle['vehicle_brand'] ??
              trip.vehicle['brand_name'];
          if (b is Map) {
            final name = b['name']?.toString().trim() ??
                b['title']?.toString().trim() ??
                '';
            if (name.isNotEmpty && name != 'null') return name;
          } else if (b != null &&
              b.toString().trim().isNotEmpty &&
              b.toString().trim() != 'null') {
            return b.toString().trim();
          }
        } else {
          final b = trip.vehicle.brand ?? trip.vehicle.model?.brand;
          if (b != null &&
              b.toString().trim().isNotEmpty &&
              b.toString().trim() != 'null') {
            return b.toString().trim();
          }
        }
      }

      // 2. trip.driver?.vehicle
      if (trip.driver != null && trip.driver.vehicle != null) {
        if (trip.driver.vehicle is Map) {
          final b = trip.driver.vehicle['brand'] ??
              trip.driver.vehicle['vehicle_brand'] ??
              trip.driver.vehicle['brand_name'];
          if (b is Map) {
            final name = b['name']?.toString().trim() ??
                b['title']?.toString().trim() ??
                '';
            if (name.isNotEmpty && name != 'null') return name;
          } else if (b != null &&
              b.toString().trim().isNotEmpty &&
              b.toString().trim() != 'null') {
            return b.toString().trim();
          }
        } else {
          final b = trip.driver.vehicle.brand ??
              trip.driver.vehicle.model?.brand;
          if (b != null &&
              b.toString().trim().isNotEmpty &&
              b.toString().trim() != 'null') {
            return b.toString().trim();
          }
        }
      }

      // 3. Map properties
      if (trip is Map) {
        if (trip['driver'] is Map && trip['driver']['vehicle'] != null) {
          final v = trip['driver']['vehicle'];
          if (v is Map) {
            final b = v['brand'] ?? v['vehicle_brand'] ?? v['brand_name'];
            if (b is Map) {
              final name = b['name']?.toString().trim() ?? '';
              if (name.isNotEmpty && name != 'null') return name;
            } else if (b != null &&
                b.toString().trim().isNotEmpty &&
                b.toString().trim() != 'null') {
              return b.toString().trim();
            }
          }
        }
      }

      // 4. Direct top-level fields
      if (trip.vehicleBrand != null &&
          trip.vehicleBrand.toString().trim().isNotEmpty &&
          trip.vehicleBrand.toString().trim() != 'null') {
        return trip.vehicleBrand.toString().trim();
      }
      if (trip.brand != null &&
          trip.brand.toString().trim().isNotEmpty &&
          trip.brand.toString().trim() != 'null') {
        return trip.brand.toString().trim();
      }
    } catch (_) {}
    return '';
  }

  String _getVehicleModel() {
    try {
      // 1. Direct trip.vehicle
      if (trip.vehicle != null) {
        if (trip.vehicle is Map) {
          final m = trip.vehicle['model'] ??
              trip.vehicle['vehicle_model'] ??
              trip.vehicle['model_name'] ??
              trip.vehicle['name'] ??
              trip.vehicle['title'];
          if (m is Map) {
            final name = m['name']?.toString().trim() ??
                m['title']?.toString().trim() ??
                '';
            if (name.isNotEmpty && name != 'null') return name;
          } else if (m != null &&
              m.toString().trim().isNotEmpty &&
              m.toString().trim() != 'null' &&
              !m.toString().trim().startsWith('{')) {
            return m.toString().trim();
          }
        } else {
          final m = trip.vehicle.model;
          if (m != null) {
            if (m is String && m.trim().isNotEmpty && m.trim() != 'null') {
              return m.trim();
            }
            final name = m.name;
            if (name != null &&
                name.toString().trim().isNotEmpty &&
                name.toString().trim() != 'null') {
              return name.toString().trim();
            }
          }
          final name = trip.vehicle.name;
          if (name != null &&
              name.toString().trim().isNotEmpty &&
              name.toString().trim() != 'null') {
            return name.toString().trim();
          }
        }
      }

      // 2. trip.driver?.vehicle
      if (trip.driver != null && trip.driver.vehicle != null) {
        if (trip.driver.vehicle is Map) {
          final m = trip.driver.vehicle['model'] ??
              trip.driver.vehicle['vehicle_model'] ??
              trip.driver.vehicle['model_name'] ??
              trip.driver.vehicle['name'];
          if (m is Map) {
            final name = m['name']?.toString().trim() ??
                m['title']?.toString().trim() ??
                '';
            if (name.isNotEmpty && name != 'null') return name;
          } else if (m != null &&
              m.toString().trim().isNotEmpty &&
              m.toString().trim() != 'null' &&
              !m.toString().trim().startsWith('{')) {
            return m.toString().trim();
          }
        } else {
          final m = trip.driver.vehicle.model;
          if (m != null) {
            if (m is String && m.trim().isNotEmpty && m.trim() != 'null') {
              return m.trim();
            }
            final name = m.name;
            if (name != null &&
                name.toString().trim().isNotEmpty &&
                name.toString().trim() != 'null') {
              return name.toString().trim();
            }
          }
        }
      }

      // 3. Map properties
      if (trip is Map) {
        if (trip['driver'] is Map) {
          final d = trip['driver'];
          final direct = d['vehicle_model'] ??
              d['car_model'] ??
              d['model_name'] ??
              d['vehicle_name'];
          if (direct != null &&
              direct.toString().trim().isNotEmpty &&
              direct.toString().trim() != 'null' &&
              !direct.toString().trim().startsWith('{')) {
            return direct.toString().trim();
          }
        }
      }

      // 4. Direct top-level fields
      if (trip.vehicleModel != null &&
          trip.vehicleModel.toString().trim().isNotEmpty &&
          trip.vehicleModel.toString().trim() != 'null' &&
          !trip.vehicleModel.toString().trim().startsWith('{')) {
        return trip.vehicleModel.toString().trim();
      }
      if (trip.carModel != null &&
          trip.carModel.toString().trim().isNotEmpty &&
          trip.carModel.toString().trim() != 'null') {
        return trip.carModel.toString().trim();
      }
    } catch (_) {}
    return '';
  }

  String _getCarPlate() {
    try {
      // 1. Direct trip.vehicle
      if (trip.vehicle != null) {
        if (trip.vehicle is Map) {
          final plate = trip.vehicle['licence_plate_number'] ??
              trip.vehicle['plate_number'] ??
              trip.vehicle['license_plate_number'] ??
              trip.vehicle['car_plate'] ??
              trip.vehicle['plate'] ??
              trip.vehicle['licencePlateNumber'] ??
              trip.vehicle['plateNumber'];
          if (plate != null &&
              plate.toString().trim().isNotEmpty &&
              plate.toString().trim() != 'null' &&
              !plate.toString().trim().startsWith('{')) {
            return plate.toString().trim();
          }
        } else {
          final plate = trip.vehicle.licencePlateNumber ??
              trip.vehicle.plateNumber ??
              trip.vehicle.licensePlateNumber;
          if (plate != null &&
              plate.toString().trim().isNotEmpty &&
              plate.toString().trim() != 'null' &&
              !plate.toString().trim().startsWith('{')) {
            return plate.toString().trim();
          }
        }
      }

      // 2. trip.driver?.vehicle
      if (trip.driver != null && trip.driver.vehicle != null) {
        if (trip.driver.vehicle is Map) {
          final plate = trip.driver.vehicle['licence_plate_number'] ??
              trip.driver.vehicle['plate_number'] ??
              trip.driver.vehicle['license_plate_number'] ??
              trip.driver.vehicle['plate'];
          if (plate != null &&
              plate.toString().trim().isNotEmpty &&
              plate.toString().trim() != 'null' &&
              !plate.toString().trim().startsWith('{')) {
            return plate.toString().trim();
          }
        } else {
          final plate = trip.driver.vehicle.licencePlateNumber ??
              trip.driver.vehicle.plateNumber ??
              trip.driver.vehicle.licensePlateNumber;
          if (plate != null &&
              plate.toString().trim().isNotEmpty &&
              plate.toString().trim() != 'null' &&
              !plate.toString().trim().startsWith('{')) {
            return plate.toString().trim();
          }
        }
      }

      // 3. Map properties
      if (trip is Map) {
        final plate = trip['licence_plate_number'] ??
            trip['plate_number'] ??
            trip['license_plate_number'] ??
            trip['car_plate'] ??
            (trip['driver'] is Map
                ? (trip['driver']['plate_number'] ??
                    trip['driver']['licence_plate_number'] ??
                    trip['driver']['license_plate_number'])
                : null);
        if (plate != null &&
            plate.toString().trim().isNotEmpty &&
            plate.toString().trim() != 'null' &&
            !plate.toString().trim().startsWith('{')) {
          return plate.toString().trim();
        }
      }

      // 4. Direct top-level fields
      final directPlate = trip.licencePlateNumber ??
          trip.plateNumber ??
          trip.carPlate ??
          trip.licensePlateNumber ??
          trip.licensePlate;
      if (directPlate != null &&
          directPlate.toString().trim().isNotEmpty &&
          directPlate.toString().trim() != 'null' &&
          !directPlate.toString().trim().startsWith('{')) {
        return directPlate.toString().trim();
      }
    } catch (_) {}
    return '';
  }

  String _getCategoryName() {
    try {
      if (trip.vehicleCategory != null) {
        final name = trip.vehicleCategory.name?.toString().trim();
        if (name != null && name.isNotEmpty && name != 'null') {
          return name;
        }
      }
      if (trip.category != null) {
        final name = trip.category.toString().trim();
        if (name.isNotEmpty && name != 'null') {
          return name;
        }
      }
      if (trip is Map && trip['vehicle_category'] is Map) {
        final name = trip['vehicle_category']['name']?.toString().trim();
        if (name != null && name.isNotEmpty && name != 'null') {
          return name;
        }
      }
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final String brand = _getVehicleBrand();
    final String model = _getVehicleModel();
    final String carPlate = _getCarPlate();
    final String category = _getCategoryName();
    final bool allowLuggage = trip.allowLuggage == true;

    String vehicleDisplayName = '';
    if (brand.isNotEmpty && model.isNotEmpty) {
      if (model.toLowerCase().contains(brand.toLowerCase())) {
        vehicleDisplayName = model;
      } else {
        vehicleDisplayName = '$brand $model';
      }
    } else if (brand.isNotEmpty) {
      vehicleDisplayName = brand;
    } else if (model.isNotEmpty) {
      vehicleDisplayName = model;
    } else if (category.isNotEmpty) {
      vehicleDisplayName = category;
    } else {
      vehicleDisplayName =
          'vehicle'.tr.isNotEmpty && !'vehicle'.tr.contains('vehicle')
              ? 'vehicle'.tr
              : 'Standard Vehicle';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Vehicle Icon in Rounded Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.directions_car_filled_rounded,
                size: 22,
                color: Color(0xFF00A0E9),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Vehicle Name & Plate Number in Container
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vehicleDisplayName,
                  style: textBold.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                if (carPlate.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pin_rounded,
                          size: 11,
                          color: Color(0xFF00A0E9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          carPlate,
                          style: textBold.copyWith(
                            fontSize: 11,
                            color: const Color(0xFF1E293B),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    category.isNotEmpty
                        ? category
                        : ('vehicle'.tr.isNotEmpty &&
                                !'vehicle'.tr.contains('vehicle')
                            ? 'vehicle'.tr
                            : 'Standard Vehicle'),
                    style: textRegular.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
          ),

          // Luggage Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: allowLuggage
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  allowLuggage
                      ? Icons.business_center_rounded
                      : Icons.luggage_outlined,
                  size: 13,
                  color: allowLuggage
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  allowLuggage
                      ? ('luggage_allowed'.tr.isNotEmpty &&
                              !'luggage_allowed'.tr.contains('luggage_allowed')
                          ? 'luggage_allowed'.tr
                          : 'Luggage allowed')
                      : ('no_luggage'.tr.isNotEmpty &&
                              !'no_luggage'.tr.contains('no_luggage')
                          ? 'no_luggage'.tr
                          : 'No luggage'),
                  style: textMedium.copyWith(
                    fontSize: 11,
                    color: allowLuggage
                        ? const Color(0xFF2E7D32)
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
