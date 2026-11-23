import 'package:cloud_firestore/cloud_firestore.dart';

class PromoDeal {
  final String id;
  final String storeId;
  final String storeBrand;
  final String storeAddress;
  final String productName;
  final String productBrand;
  final String category; // es. Pasta, Carne, Frutta, Bevande, Dolci, Latticini, Altro
  final String? imageUrl;
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
    this.category = 'Alimentari',
    this.imageUrl,
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

  /// Restituisce un'immagine realistica di qualità se l'utente non ne inserisce una propria
  String get displayImage {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return imageUrl!;
    }
    final cat = category.toLowerCase();
    final prod = productName.toLowerCase();

    if (prod.contains('pasta') || cat.contains('pasta') || prod.contains('spaghetti')) {
      return 'https://images.unsplash.com/photo-1621996346565-e3d5d6281699?w=500&auto=format&fit=crop&q=80';
    }
    if (prod.contains('caffè') || prod.contains('caffe') || prod.contains('coffee')) {
      return 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&auto=format&fit=crop&q=80';
    }
    if (prod.contains('latte') || prod.contains('formaggio') || prod.contains('mozzarella') || cat.contains('latticini')) {
      return 'https://images.unsplash.com/photo-1528750997573-59b89d56f4f7?w=500&auto=format&fit=crop&q=80';
    }
    if (prod.contains('pizza')) {
      return 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=80';
    }
    if (prod.contains('biscotti') || prod.contains('dolci') || prod.contains('cioccolat') || cat.contains('dolci')) {
      return 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=500&auto=format&fit=crop&q=80';
    }
    if (prod.contains('frutta') || prod.contains('mela') || prod.contains('banana') || cat.contains('frutta')) {
      return 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=500&auto=format&fit=crop&q=80';
    }
    if (prod.contains('carne') || prod.contains('pollo') || prod.contains('bistecca') || cat.contains('carne')) {
      return 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=500&auto=format&fit=crop&q=80';
    }
    if (prod.contains('olio') || prod.contains('extravergine')) {
      return 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&auto=format&fit=crop&q=80';
    }
    if (prod.contains('vino') || prod.contains('birra') || cat.contains('bevande') || prod.contains('acqua')) {
      return 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=500&auto=format&fit=crop&q=80';
    }
    if (prod.contains('detersivo') || prod.contains('sapone') || cat.contains('casa')) {
      return 'https://images.unsplash.com/photo-1585421514738-01798e348b17?w=500&auto=format&fit=crop&q=80';
    }
    // Default spesa generica
    return 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500&auto=format&fit=crop&q=80';
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'storeBrand': storeBrand,
      'storeAddress': storeAddress,
      'productName': productName,
      'productBrand': productBrand,
      'category': category,
      'imageUrl': imageUrl,
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
      category: map['category'] ?? 'Alimentari',
      imageUrl: map['imageUrl'],
      promoPrice: (map['promoPrice'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
