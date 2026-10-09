class EstimatedFareModel {
  String? responseCode;
  String? message;
  List<FareModel>? data;

  EstimatedFareModel({
    this.responseCode,
    this.message,
    this.data,
  });

  EstimatedFareModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    final dynamic rawData = json['content'] ?? json['data'];
    if (rawData != null) {
      data = <FareModel>[];
      if (rawData is List) {
        for (var v in rawData) {
          if (v is Map<String, dynamic>) {
            data!.add(FareModel.fromJson(v));
          }
        }
      } else if (rawData is Map<String, dynamic>) {
        data!.add(FareModel.fromJson(rawData));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> res = <String, dynamic>{};
    res['response_code'] = responseCode;
    res['message'] = message;
    if (data != null) {
      res['data'] = data!.map((v) => v.toJson()).toList();
      res['content'] = res['data'];
    }
    return res;
  }
}

class FareModel {
  String? id;
  String? zoneId;
  String? vehicleCategoryId;
  String? vehicleCategoryType;
  double? baseFare;
  double? baseFarePerKm;
  double? fare;
  String? estimatedDistance;
  String? estimatedDuration;
  double? estimatedFare;
  double? discountFare;
  double? discountAmount;
  bool? couponApplicable;
  String? requestType;
  String? polyline;
  String? areaId;
  double? extraEstimatedFare;
  double? extraDiscountFare;
  double? extraDiscountAmount;
  double? extraReturnFee;
  double? extraCancellationFee;
  double? extraFareAmount;
  double? extraFareFee;
  String? extraFareReason;
  String? currency;

  FareModel({
    this.id,
    this.zoneId,
    this.vehicleCategoryId,
    this.vehicleCategoryType,
    this.baseFare,
    this.baseFarePerKm,
    this.fare,
    this.estimatedDistance,
    this.estimatedDuration,
    this.estimatedFare,
    this.requestType,
    this.polyline,
    this.areaId,
    this.discountAmount,
    this.couponApplicable,
    this.discountFare,
    this.extraCancellationFee,
    this.extraDiscountAmount,
    this.extraDiscountFare,
    this.extraEstimatedFare,
    this.extraFareAmount,
    this.extraFareFee,
    this.extraFareReason,
    this.extraReturnFee,
    this.currency,
  });

  FareModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    zoneId = json['zone_id']?.toString();
    vehicleCategoryId = json['vehicle_category_id']?.toString();
    vehicleCategoryType = json['vehicle_category_type']?.toString();
    baseFare = json['base_fare'] != null ? double.tryParse(json['base_fare'].toString()) : null;
    baseFarePerKm = json['base_fare_per_km'] != null
        ? double.tryParse(json['base_fare_per_km'].toString())
        : (json['per_km_fare'] != null ? double.tryParse(json['per_km_fare'].toString()) : null);
    fare = json['fare'] != null
        ? double.tryParse(json['fare'].toString())
        : (json['estimated_fare'] != null ? double.tryParse(json['estimated_fare'].toString()) : null);
    estimatedDistance = json['estimated_distance']?.toString() ??
        (json['distance_km'] != null ? '${json['distance_km']} km' : null);
    estimatedDuration = json['estimated_duration']?.toString() ??
        (json['duration_minutes'] != null ? '${json['duration_minutes']} min' : null);
    estimatedFare = json['estimated_fare'] != null ? double.tryParse(json['estimated_fare'].toString()) : null;
    requestType = json['request type'] ?? json['type'];
    polyline = json['encoded_polyline'] ?? json['polyline'];
    areaId = json['area_id']?.toString();
    discountAmount = json['discount_amount'] != null ? double.tryParse(json['discount_amount'].toString()) : null;
    couponApplicable = json['coupon_applicable'];
    discountFare = json['discount_fare'] != null ? double.tryParse(json['discount_fare'].toString()) : null;
    extraEstimatedFare = double.tryParse('${json['extra_estimated_fare']}');
    extraDiscountFare = double.tryParse('${json['extra_discount_fare']}');
    extraDiscountAmount = double.tryParse('${json['extra_discount_amount']}');
    extraReturnFee = double.tryParse('${json['extra_return_fee']}');
    extraCancellationFee = double.tryParse('${json['extra_cancellation_fee']}');
    extraFareAmount = double.tryParse('${json['extra_fare_amount']}');
    extraFareFee = double.tryParse('${json['extra_fare_fee']}');
    extraFareReason = json['extra_fare_reason']?.toString();
    currency = json['currency']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['zone_id'] = zoneId;
    data['vehicle_category_id'] = vehicleCategoryId;
    data['base_fare'] = baseFare;
    data['base_fare_per_km'] = baseFarePerKm;
    data['fare'] = fare;
    data['estimated_distance'] = estimatedDistance;
    data['estimated_duration'] = estimatedDuration;
    data['estimated_fare'] = estimatedFare;
    data['request type'] = requestType;
    data['encoded_polyline'] = polyline;
    data['area_id'] = areaId;
    data['currency'] = currency;
    return data;
  }
}
