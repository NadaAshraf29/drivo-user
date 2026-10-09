class ErrorResponse {
  String? responseCode;
  String? message;
  List<Errors>? errors;

  ErrorResponse(
      {this.responseCode,
        this.message,
        this.errors});

  ErrorResponse.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code']?.toString();
    message = json['message']?.toString();
    if (json['errors'] != null) {
      errors = <Errors>[];
      if (json['errors'] is List) {
        for (var v in (json['errors'] as List)) {
          if (v is Map<String, dynamic>) {
            errors!.add(Errors.fromJson(v));
          } else if (v is Map) {
            errors!.add(Errors.fromJson(Map<String, dynamic>.from(v)));
          } else {
            errors!.add(Errors(errorCode: '', message: v?.toString()));
          }
        }
      } else if (json['errors'] is Map) {
        (json['errors'] as Map).forEach((key, value) {
          String msg = '';
          if (value is List && value.isNotEmpty) {
            msg = value.map((e) => e.toString()).join(', ');
          } else {
            msg = value?.toString() ?? '';
          }
          errors!.add(Errors(errorCode: key.toString(), message: msg));
        });
      } else if (json['errors'] is String) {
        errors!.add(Errors(errorCode: '', message: json['errors'].toString()));
      }
    }
  }


}

class Errors {
  String? errorCode;
  String? message;

  Errors({this.errorCode, this.message});

  Errors.fromJson(Map<String, dynamic> json) {
    errorCode = json['error_code'];
    message = json['message'];
  }

}
