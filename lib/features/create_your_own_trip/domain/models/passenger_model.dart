import 'package:flutter/material.dart';

enum PassengerPaymentStatus {
  unpaid,
  waitingForPayment,
  paid;

  String get readableName {
    switch (this) {
      case PassengerPaymentStatus.paid:
        return 'Paid';
      case PassengerPaymentStatus.waitingForPayment:
        return 'Waiting for Payment';
      case PassengerPaymentStatus.unpaid:
        return 'Unpaid';
    }
  }

  Color get statusColor {
    switch (this) {
      case PassengerPaymentStatus.paid:
        return const Color(0xFF16A34A);
      case PassengerPaymentStatus.waitingForPayment:
        return const Color(0xFFEA580C);
      case PassengerPaymentStatus.unpaid:
        return const Color(0xFF64748B);
    }
  }
}

class SpecialTripPassengerModel {
  final String? id;
  final String name;
  final String phone;
  final String? avatar;
  final bool isCurrentUser;
  final PassengerPaymentStatus paymentStatus;
  final double? assignedFare;

  SpecialTripPassengerModel({
    this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.isCurrentUser = false,
    this.paymentStatus = PassengerPaymentStatus.unpaid,
    this.assignedFare,
  });

  /// Formats phone number ensuring it has the +20 country code for Egypt.
  /// Handles numbers with leading 0 (e.g. 010... -> +2010...),
  /// numbers without 0 (e.g. 10... -> +2010...),
  /// numbers already starting with +20, 0020, or 20,
  /// and converts Eastern Arabic digits to English digits.
  static String formatPhoneNumber(String phone, {String defaultDialCode = '+20'}) {
    if (phone.isEmpty) return phone;
    // Convert Eastern Arabic digits if present
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    String normalized = phone;
    for (int i = 0; i < 10; i++) {
      normalized = normalized.replaceAll(arabic[i], english[i]);
    }

    String clean = normalized.replaceAll(RegExp(r'[\s\-()]'), '').trim();
    if (clean.isEmpty) return clean;

    if (clean.startsWith('+200')) {
      return clean;
    }
    if (clean.startsWith('+20')) {
      return '+200${clean.substring(3)}';
    }
    if (clean.startsWith('00200')) {
      return '+200${clean.substring(5)}';
    }
    if (clean.startsWith('0020')) {
      return '+200${clean.substring(4)}';
    }
    if (clean.startsWith('200') && clean.length >= 12) {
      return '+200${clean.substring(3)}';
    }
    if (clean.startsWith('20') && clean.length >= 11) {
      return '+200${clean.substring(2)}';
    }
    if (clean.startsWith('0')) {
      return '+20$clean';
    }
    if (clean.startsWith('+')) {
      return clean;
    }
    return '+200$clean';
  }

  factory SpecialTripPassengerModel.fromJson(Map<String, dynamic> json) {
    PassengerPaymentStatus status = PassengerPaymentStatus.unpaid;
    final statusStr = json['payment_status']?.toString().toLowerCase();
    if (statusStr == 'paid') {
      status = PassengerPaymentStatus.paid;
    } else if (statusStr == 'waiting_for_payment' || statusStr == 'pending') {
      status = PassengerPaymentStatus.waitingForPayment;
    }

    final rawPhone = json['phone']?.toString() ?? '';
    final phone = rawPhone.isNotEmpty ? formatPhoneNumber(rawPhone) : '';

    return SpecialTripPassengerModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      phone: phone,
      avatar: json['avatar']?.toString() ?? json['profile_image']?.toString(),
      isCurrentUser: json['is_current_user'] == true,
      paymentStatus: status,
      assignedFare: (json['assigned_fare'] as num?)?.toDouble() ??
          (json['fare'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': formatPhoneNumber(phone),
      if (avatar != null) 'avatar': avatar,
      'is_current_user': isCurrentUser,
      'payment_status': paymentStatus.name,
      if (assignedFare != null) 'assigned_fare': assignedFare,
    };
  }

  factory SpecialTripPassengerModel.fromScheduledPassenger(Map<String, dynamic> json) {
    PassengerPaymentStatus status = PassengerPaymentStatus.unpaid;
    final statusStr = json['payment_status']?.toString().toLowerCase();
    if (statusStr == 'paid') {
      status = PassengerPaymentStatus.paid;
    } else if (statusStr == 'waiting_for_payment' || statusStr == 'pending') {
      status = PassengerPaymentStatus.waitingForPayment;
    }

    final rawPhone = json['phone']?.toString() ?? '';
    final phone = rawPhone.isNotEmpty ? formatPhoneNumber(rawPhone) : '';

    return SpecialTripPassengerModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      phone: phone,
      avatar: json['avatar']?.toString() ?? json['profile_image']?.toString(),
      isCurrentUser: json['is_current_user'] == true,
      paymentStatus: status,
      assignedFare: (json['fare_amount'] as num?)?.toDouble() ??
          (json['assigned_fare'] as num?)?.toDouble() ??
          (json['fare'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toApiPassengerJson() {
    return {
      'name': name,
      'phone': formatPhoneNumber(phone),
    };
  }

  SpecialTripPassengerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatar,
    bool? isCurrentUser,
    PassengerPaymentStatus? paymentStatus,
    double? assignedFare,
  }) {
    return SpecialTripPassengerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      assignedFare: assignedFare ?? this.assignedFare,
    );
  }
}

typedef ScheduledPassenger = SpecialTripPassengerModel;

