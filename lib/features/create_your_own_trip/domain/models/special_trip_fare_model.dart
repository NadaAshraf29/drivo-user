enum PaymentResponsibility {
  creatorPays,
  eachPassengerPays,
}

class SpecialTripFareModel {
  final double baseFare;
  final double totalFare;
  final double? driverNetFare;
  final double? adminCommission;
  final int totalActiveDays;
  final List<String> activeDates;
  final double? distanceKm;
  final bool? isReturnTrip;
  final int? seatsCount;
  final double creatorAmount;
  final double passengerAmount;
  final String currency;
  final Map<String, double>? perPassengerBreakdown;

  int get totalTripDays => activeDates.isNotEmpty ? activeDates.length : totalActiveDays;

  List<int> get activeWeekdays {
    if (activeDates.isEmpty) return [];
    final Set<int> set = {};
    for (var dateStr in activeDates) {
      final dt = DateTime.tryParse(dateStr.trim());
      if (dt != null) {
        set.add(dt.weekday);
      }
    }
    final sorted = set.toList()..sort();
    return sorted;
  }

  SpecialTripFareModel({
    required this.baseFare,
    required this.totalFare,
    this.driverNetFare,
    this.adminCommission,
    required this.totalActiveDays,
    this.activeDates = const [],
    this.distanceKm,
    this.isReturnTrip,
    this.seatsCount,
    required this.creatorAmount,
    required this.passengerAmount,
    this.currency = 'EGP',
    this.perPassengerBreakdown,
  });

  factory SpecialTripFareModel.fromJson(Map<String, dynamic> json) {
    Map<String, double> breakdown = {};
    if (json['passenger_breakdown'] is Map) {
      (json['passenger_breakdown'] as Map).forEach((key, val) {
        breakdown[key.toString()] = (val as num).toDouble();
      });
    }

    final double total = (json['total_fare'] as num?)?.toDouble() ??
        (json['fare'] as num?)?.toDouble() ??
        0.0;
    final int seats = (json['seats_count'] as num?)?.toInt() ?? 1;
    final double perPassenger = (json['passenger_amount'] as num?)?.toDouble() ??
        (seats > 0 ? (total / seats) : total);

    final List<String> dates = [];
    final rawDates = json['active_dates'] ??
        json['operating_dates'] ??
        json['working_dates'] ??
        json['trip_dates'] ??
        json['dates'];
    if (rawDates is List) {
      for (var d in rawDates) {
        dates.add(d.toString());
      }
    }

    final int calculatedDays = dates.isNotEmpty
        ? dates.length
        : ((json['total_active_days'] ??
                json['total_operating_days'] ??
                json['total_working_days'] ??
                json['total_trip_days'] ??
                json['total_days'] ??
                json['operating_days_count'] ??
                json['active_days_count']) as num?)
            ?.toInt() ??
        1;

    return SpecialTripFareModel(
      baseFare: (json['base_fare'] as num?)?.toDouble() ?? total,
      totalFare: total,
      driverNetFare: (json['driver_net_fare'] as num?)?.toDouble(),
      adminCommission: (json['admin_commission'] as num?)?.toDouble(),
      totalActiveDays: calculatedDays,
      activeDates: dates,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      isReturnTrip: json['is_return_trip'] == true,
      seatsCount: seats,
      creatorAmount: (json['creator_amount'] as num?)?.toDouble() ?? total,
      passengerAmount: perPassenger,
      currency: json['currency']?.toString() ?? 'EGP',
      perPassengerBreakdown: breakdown.isNotEmpty ? breakdown : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_fare': baseFare,
      'total_fare': totalFare,
      if (driverNetFare != null) 'driver_net_fare': driverNetFare,
      if (adminCommission != null) 'admin_commission': adminCommission,
      'total_active_days': totalActiveDays,
      'total_trip_days': totalActiveDays,
      'active_dates': activeDates,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (isReturnTrip != null) 'is_return_trip': isReturnTrip,
      if (seatsCount != null) 'seats_count': seatsCount,
      'creator_amount': creatorAmount,
      'passenger_amount': passengerAmount,
      'currency': currency,
      if (perPassengerBreakdown != null)
        'passenger_breakdown': perPassengerBreakdown,
    };
  }
}

typedef ScheduledRideEstimate = SpecialTripFareModel;

