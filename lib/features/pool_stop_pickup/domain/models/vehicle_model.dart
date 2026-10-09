class Vehicle {
  final String brand;
  final String model;
  final String? plateNumber;

  Vehicle({
    required this.brand,
    required this.model,
    this.plateNumber,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    try {
      String brandStr = '';
      if (json['brand'] != null) {
        if (json['brand'] is Map) {
          brandStr = json['brand']['name']?.toString() ??
              json['brand']['title']?.toString() ??
              '';
        } else {
          brandStr = json['brand'].toString();
        }
      }

      String modelStr = '';
      if (json['model'] != null) {
        if (json['model'] is Map) {
          modelStr = json['model']['name']?.toString() ??
              json['model']['model_name']?.toString() ??
              json['model']['title']?.toString() ??
              '';
        } else {
          modelStr = json['model'].toString();
        }
      }

      final plate = json['plate_number']?.toString() ??
          json['licence_plate_number']?.toString() ??
          '';

      return Vehicle(
        brand: brandStr,
        model: modelStr,
        plateNumber: plate,
      );
    } catch (e) {
      print('Error parsing Vehicle: $e');
      return Vehicle(
        brand: '',
        model: '',
        plateNumber: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'plate_number': plateNumber,
    };
  }
}
