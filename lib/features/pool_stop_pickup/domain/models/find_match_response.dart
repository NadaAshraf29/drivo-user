import 'pool_ride_model.dart';

class FindMatchResponse {
  final String responseCode;
  final String message;
  final int? totalSize;
  final int? limit;
  final int? offset;
  final List<PoolRide> data;
  final List<dynamic> errors;

  FindMatchResponse({
    required this.responseCode,
    required this.message,
    this.totalSize,
    this.limit,
    this.offset,
    required this.data,
    required this.errors,
  });

  factory FindMatchResponse.fromJson(Map<String, dynamic> json) {
    try {
      List<dynamic> dataList = [];
      final rawData = json['data'];
      if (rawData is List) {
        dataList = rawData;
      } else if (rawData is Map<String, dynamic>) {
        if (rawData['trips'] is List) {
          dataList = rawData['trips'];
        }
      }
      List<PoolRide> rides = [];

      for (int i = 0; i < dataList.length; i++) {
        try {
          PoolRide ride = PoolRide.fromJson(dataList[i]);
          rides.add(ride);
        } catch (e) {
          print('Error parsing ride $i: $e');
          // Continue parsing other rides instead of failing completely
          continue;
        }
      }

      return FindMatchResponse(
        responseCode: json['response_code'] ?? '',
        message: json['message'] ?? '',
        totalSize: json['total_size'], // Keep as null if null
        limit: json['limit'], // Keep as null if null
        offset: json['offset'], // Keep as null if null
        data: rides,
        errors: json['errors'] ?? [],
      );
    } catch (e) {
      print('Error parsing FindMatchResponse: $e');
      // Return empty response instead of throwing
      return FindMatchResponse(
        responseCode: '',
        message: 'Failed to parse response',
        data: [],
        errors: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'response_code': responseCode,
      'message': message,
      'total_size': totalSize,
      'limit': limit,
      'offset': offset,
      'data': data.map((e) => e.toJson()).toList(),
      'errors': errors,
    };
  }
}
