import 'package:flutter/material.dart';
import 'package:flutter_paymob_sdk/flutter_paymob_sdk.dart';
import 'package:ride_sharing_user_app/features/payment/domain/services/paymob_config.dart';

/// Data model representing the payment intent tokens returned from the backend
class PaymobSDKIntentModel {
  final String? clientSecret;
  final String? publicKey;
  final String? secretKey;
  final int? integrationID;
  final double? amount;
  final String? currency;

  PaymobSDKIntentModel({
    this.clientSecret,
    this.publicKey,
    this.secretKey,
    this.integrationID,
    this.amount,
    this.currency = PaymobConfig.defaultCurrency,
  });

  factory PaymobSDKIntentModel.fromJson(Map<String, dynamic> json) {
    return PaymobSDKIntentModel(
      clientSecret: json['client_secret'] ?? json['token'],
      publicKey: json['public_key'],
      secretKey: json['secret_key'],
      integrationID: json['integration_id'],
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      currency: json['currency'] ?? PaymobConfig.defaultCurrency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_secret': clientSecret,
      'public_key': publicKey,
      'secret_key': secretKey,
      'integration_id': integrationID,
      'amount': amount,
      'currency': currency,
    };
  }
}

/// Service class integrating flutter_paymob_sdk for native payments
class PaymobSdkService {
  /// Initiates native PayMob SDK payment flow using PaymobService
  static Future<dynamic> startPayment({
    required BuildContext context,
    required PaymobSDKIntentModel intent,
  }) async {
    try {
      final paymobService = PaymobService();
      final result = await paymobService.payWithPaymob(
        publicKey: intent.publicKey ?? '',
        clientSecret: intent.clientSecret ?? '',
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
