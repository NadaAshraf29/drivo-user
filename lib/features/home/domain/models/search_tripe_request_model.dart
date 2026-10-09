
class SearchTripeRequestModel {
  final double pickupLat;
  final double pickupLng;
  final double dropOffLat;
  final double dropOffLng;
  final int seatsRequired;
  final String day;

  SearchTripeRequestModel({
    required this.pickupLat,
    required this.pickupLng,
    required this.dropOffLat,
    required this.dropOffLng,
    required this.seatsRequired,
    required this.day,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'dropoff_lat': dropOffLat,
      'dropoff_lng': dropOffLng,
      'seats_required': seatsRequired,
      'day': day,
    };
  }
}