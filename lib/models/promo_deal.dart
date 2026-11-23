import 'package:cloud_firestore/cloud_firestore.dart';

class PromoDeal {
  final String id;
  final String storeId;
  final String storeBrand;
  final String storeAddress;
  final String productName;
  final String productBrand; // Marchio del prodotto (es. Barilla, Mulino Bianco)
  final double promoPrice;
  final double? originalPrice;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  PromoDeal({
    required this.id,
    required this.storeId,
    required this.storeBrand,
    required this.storeAddress,
    required this.productName,
    required this.productBrand,
    required this.promoPrice,
    this.originalPrice,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  bool get isExpired {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final dealEndDay = DateTime(endDate.year, endDate.month, endDate.day);
    return dealEndDay.isBefore(todayStart);
  }

  double? get discountPercentage {
    if (originalPrice == null || originalPrice! <= promoPrice) return null;
    return ((originalPrice! - promoPrice) / originalPrice!) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'storeBrand': storeBrand,
      'storeAddress': storeAddress,
      'productName': productName,
      'productBrand': productBrand,
      'promoPrice': promoPrice,
      'originalPrice': originalPrice,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PromoDeal.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return PromoDeal(
      id: doc.id,
      storeId: map['storeId'] ?? '',
      storeBrand: map['storeBrand'] ?? '',
      storeAddress: map['storeAddress'] ?? '',
      productName: map['productName'] ?? '',
      productBrand: map['productBrand'] ?? '',
      promoPrice: (map['promoPrice'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
