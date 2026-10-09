class JoinRequest {
  final int routeId;
  final int seatsCount;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final int fare;

  JoinRequest({
    required this.routeId,
    required this.seatsCount,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.fare,
  });

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'seats_count': seatsCount,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'dropoff_lat': dropoffLat,
      'dropoff_lng': dropoffLng,
      'fare': fare,
    };
  }
}
