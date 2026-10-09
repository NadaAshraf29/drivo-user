import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:talker/talker.dart';
import 'models/paymob_payment_result.dart';
import 'models/paymob_customization.dart';

/// Main service class for integrating Paymob payment SDK
class PaymobService {
  final Talker _talker = Talker();
  static const MethodChannel _methodChannel =
  MethodChannel('paymob_sdk_flutter');

  /// Initiates a payment using the Paymob SDK
  ///
  /// Parameters:
  /// - [publicKey]: Your Paymob public key
  /// - [clientSecret]: The client secret obtained from payment intention API
  /// - [customization]: Optional UI customization settings
  ///
  /// Returns a [PaymobPaymentResult] with the transaction status
  Future<PaymobPaymentResult> payWithPaymob({
    required String publicKey,
    required String clientSecret,
    PaymobCustomization? customization,
  }) async {
    try {
      final Map<String, dynamic> arguments = {
        'publicKey': publicKey,
        'clientSecret': clientSecret,
        ...?customization?.toMap(),
      };

      final dynamic result =
      await _methodChannel.invokeMethod('payWithPaymob', arguments);

      return _parsePaymentResult(result);
    } on PlatformException catch (e) {
      _talker.error("Failed to call native SDK: '${e.message}'");
      return PaymobPaymentResult(
        status: PaymentStatus.unknown,
        errorMessage: e.message ?? 'Unknown platform error',
      );
    } catch (e) {
      _talker.error("Unexpected error: $e");
      return PaymobPaymentResult(
        status: PaymentStatus.unknown,
        errorMessage: e.toString(),
      );
    }
  }

  /// Creates a payment intention and returns the credentials needed for SDK
  ///
  /// ⚠️ SECURITY WARNING: Using this method directly from your Flutter app
  /// exposes your secret key to potential extraction through reverse engineering.
  ///
  /// RECOMMENDED: Set [useSecureMode] to true and provide credentials from your server.
  ///
  /// Parameters:
  /// - [useSecureMode]: If true, expects [publicKey] and [clientSecret] to be provided
  ///   from your backend. If false, creates intention directly (INSECURE).
  /// - [secretKey]: Your Paymob secret key (Token) - only needed if useSecureMode=false
  /// - [publicKey]: Your Paymob public key
  /// - [clientSecret]: Client secret from your backend - only needed if useSecureMode=true
  /// - [amount]: Payment amount in the currency's main unit (e.g., EGP, not cents)
  /// - [currency]: Currency code (e.g., 'EGP')
  /// - [integrationId]: Your Paymob integration ID
  /// - [billingData]: Customer billing information
  /// - [items]: Optional list of items
  ///
  /// Returns a Map with 'publicKey' and 'clientSecret'
  Future<Map<String, String>> createPaymentIntention({
    bool useSecureMode = true,
    String? secretKey,
    required String publicKey,
    String? clientSecret,
    int? amount,
    String? currency,
    int? integrationId,
    Map<String, dynamic>? billingData,
    List<Map<String, dynamic>>? items,
    String? redirectionUrl = 'https://accept.paymob.com/api/acceptance/post_pay',
  }) async {
    // SECURE MODE: Credentials provided from backend
    if (useSecureMode) {
      if (clientSecret == null || clientSecret.isEmpty) {
        throw ArgumentError(
          'clientSecret is required when useSecureMode is true. '
          'Please obtain it from your backend API.',
        );
      }

      _talker.info('✅ Using secure backend mode - no secret key exposed');

      return {
        'publicKey': publicKey,
        'clientSecret': clientSecret,
      };
    }

    // LEGACY MODE: Direct API call (INSECURE)
    _talker.info('⚠️ WARNING: Using insecure legacy mode!');
    _talker.info('⚠️ Your secret key is exposed in the app and can be extracted.');
    _talker.info('⚠️ For production, use useSecureMode=true and get credentials from your server.');

    if (secretKey == null || secretKey.isEmpty) {
      throw ArgumentError(
        'secretKey is required when useSecureMode is false',
      );
    }

    if (amount == null || currency == null || integrationId == null || billingData == null) {
      throw ArgumentError(
        'amount, currency, integrationId, and billingData are required when useSecureMode is false',
      );
    }

    try {
      _talker.info('🔵 Creating payment intention with Paymob SDK V2 API...');

      final intentionResponse = await http.post(
        Uri.parse('https://accept.paymob.com/v1/intention/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $secretKey',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'payment_methods': [integrationId],
          'items': items ?? [],
          'billing_data': billingData,
          'redirection_url': redirectionUrl ?? 'https://accept.paymob.com/api/acceptance/post_pay',
        }),
      );

      _talker.info('Intention Response Status: ${intentionResponse.statusCode}');
      _talker.info('Intention Response Body: ${intentionResponse.body}');

      if (intentionResponse.statusCode != 200 &&
          intentionResponse.statusCode != 201) {
        throw Exception(
            'Intention creation failed: ${intentionResponse.body}');
      }

      final intentionData = jsonDecode(intentionResponse.body);
      final receivedClientSecret = intentionData['client_secret'];

      if (receivedClientSecret == null) {
        throw Exception(
            'Client secret is null. Response: ${intentionResponse.body}');
      }

      _talker.info('✅ Client secret received from Intention API');

      return {
        'publicKey': publicKey,
        'clientSecret': receivedClientSecret,
      };
    } catch (e) {
      _talker.error('❌ Error in createPaymentIntention: $e');
      rethrow;
    }
  }

  /// Parses the native platform result into a [PaymobPaymentResult]
  PaymobPaymentResult _parsePaymentResult(dynamic result) {
    if (result == null) {
      return PaymobPaymentResult(
        status: PaymentStatus.unknown,
        errorMessage: 'Payment cancelled or closed',
      );
    }

    if (result is Map) {
      final statusVal = result['status'];
      final statusStr = statusVal?.toString().toLowerCase() ?? '';

      final bool isSuccessBool = result['success'] == true ||
          result['success'] == 'true' ||
          result['is_success'] == true ||
          result['hmac_valid'] == true ||
          statusStr == 'successful' ||
          statusStr == 'success' ||
          statusStr == 'true' ||
          statusVal == true;

      if (isSuccessBool) {
        return PaymobPaymentResult(
          status: PaymentStatus.successful,
          transactionDetails: Map<String, dynamic>.from(
            result['details'] is Map ? result['details'] : result,
          ),
        );
      }

      final bool isRejectedBool = statusStr == 'rejected' ||
          statusStr == 'failed' ||
          statusStr == 'false' ||
          statusVal == false ||
          result['success'] == false;

      if (isRejectedBool) {
        return PaymobPaymentResult(
          status: PaymentStatus.rejected,
          errorMessage: result['message']?.toString() ??
              result['errorMessage']?.toString() ??
              'Payment was declined or rejected',
        );
      }

      if (statusStr == 'pending') {
        return PaymobPaymentResult(
          status: PaymentStatus.pending,
        );
      }
    }

    // Handle string result (JSON string or legacy format)
    if (result is String) {
      final trimmed = result.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map) {
            return _parsePaymentResult(decoded);
          }
        } catch (_) {}
      }

      final resultLower = result.toLowerCase();
      if (resultLower.contains('successful') ||
          resultLower.contains('"success":true') ||
          resultLower.contains('"success": true') ||
          resultLower.contains('"status":true') ||
          resultLower.contains('"status": "true"') ||
          resultLower.contains('success')) {
        return PaymobPaymentResult(status: PaymentStatus.successful);
      } else if (resultLower.contains('rejected') ||
          resultLower.contains('failed') ||
          resultLower.contains('"success":false') ||
          resultLower.contains('"status":false')) {
        return PaymobPaymentResult(
          status: PaymentStatus.rejected,
          errorMessage: 'Payment was declined or rejected',
        );
      } else if (resultLower.contains('pending')) {
        return PaymobPaymentResult(status: PaymentStatus.pending);
      }
    }

    return PaymobPaymentResult(
      status: PaymentStatus.unknown,
      errorMessage: 'Payment completed with unverified status',
    );
  }
}