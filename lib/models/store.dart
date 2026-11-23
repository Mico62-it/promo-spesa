class Store {
  final String id;
  final String brand; // es. Conad, Coop, Esselunga, Lidl
  final String address; // es. Via Roma 15
  final String city; // es. Milano

  Store({
    required this.id,
    required this.brand,
    required this.address,
    required this.city,
  });

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'address': address,
      'city': city,
    };
  }

  factory Store.fromMap(String id, Map<String, dynamic> map) {
    return Store(
      id: id,
      brand: map['brand'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
    );
  }

  String get displayName => '$brand ($address, $city)';
}
