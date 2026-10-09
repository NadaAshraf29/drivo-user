class PaymobIntentResponse {
  final String? clientSecret;
  final String? publicKey;
  final String? secretKey;
  final String? paymentUrl;
  final int? amountCents;
  final String? currency;
  final String? expiresAt;

  PaymobIntentResponse({
    this.clientSecret,
    this.publicKey,
    this.secretKey,
    this.paymentUrl,
    this.amountCents,
    this.currency,
    this.expiresAt,
  });

  factory PaymobIntentResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] is Map<String, dynamic>
        ? (json['data'] as Map<String, dynamic>)
        : (json['data'] is Map
            ? Map<String, dynamic>.from(json['data'] as Map)
            : json);

    String? clientSecret = data['client_secret']?.toString() ??
        json['client_secret']?.toString() ??
        data['token']?.toString() ??
        json['token']?.toString() ??
        data['payment_token']?.toString() ??
        json['payment_token']?.toString() ??
        data['payment_key']?.toString() ??
        json['payment_key']?.toString() ??
        data['clientSecret']?.toString() ??
        json['clientSecret']?.toString() ??
        data['payment_key_token']?.toString() ??
        json['payment_key_token']?.toString();

    String? publicKey = data['public_key']?.toString() ??
        json['public_key']?.toString() ??
        data['publicKey']?.toString() ??
        json['publicKey']?.toString() ??
        data['public_key_token']?.toString() ??
        json['public_key_token']?.toString() ??
        data['public_key_id']?.toString() ??
        json['public_key_id']?.toString() ??
        data['api_key']?.toString() ??
        json['api_key']?.toString();

    String? secretKey = data['secret_key']?.toString() ??
        json['secret_key']?.toString() ??
        data['secretKey']?.toString() ??
        json['secretKey']?.toString();

    final paymentUrl = data['payment_url']?.toString() ??
        json['payment_url']?.toString() ??
        data['url']?.toString() ??
        json['url']?.toString() ??
        data['redirect_url']?.toString() ??
        json['redirect_url']?.toString() ??
        data['redirection_url']?.toString() ??
        json['redirection_url']?.toString() ??
        data['iframe_url']?.toString() ??
        json['iframe_url']?.toString();

    // If clientSecret or publicKey is missing, try extracting from paymentUrl query parameters
    if (paymentUrl != null && (clientSecret == null || publicKey == null)) {
      try {
        final uri = Uri.parse(paymentUrl);
        clientSecret ??= uri.queryParameters['payment_token'] ??
            uri.queryParameters['token'] ??
            uri.queryParameters['client_secret'] ??
            uri.queryParameters['payment_key'];
        publicKey ??= uri.queryParameters['public_key'] ??
            uri.queryParameters['publicKey'];
      } catch (_) {}
    }

    final amountVal = data['amount_cents'] ??
        json['amount_cents'] ??
        data['amount'] ??
        json['amount'];
    int? amountCents;
    if (amountVal is num) {
      amountCents = amountVal.toInt();
    } else if (amountVal is String) {
      amountCents = int.tryParse(amountVal);
    }

    return PaymobIntentResponse(
      clientSecret: clientSecret,
      publicKey: publicKey,
      secretKey: secretKey,
      paymentUrl: paymentUrl,
      amountCents: amountCents,
      currency: (data['currency'] ?? json['currency'])?.toString() ?? 'EGP',
      expiresAt: (data['expires_at'] ??
              json['expires_at'] ??
              data['expired_at'] ??
              json['expired_at'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (clientSecret != null) 'client_secret': clientSecret,
      if (publicKey != null) 'public_key': publicKey,
      if (secretKey != null) 'secret_key': secretKey,
      if (paymentUrl != null) 'payment_url': paymentUrl,
      if (amountCents != null) 'amount_cents': amountCents,
      if (currency != null) 'currency': currency,
      if (expiresAt != null) 'expires_at': expiresAt,
    };
  }
}
