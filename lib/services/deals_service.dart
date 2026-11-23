import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/store.dart';
import '../models/promo_deal.dart';

class DealsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _storesCol => _firestore.collection('stores');
  CollectionReference get _dealsCol => _firestore.collection('deals');

  // --- GESTIONE PUNTI VENDITA ---
  Stream<List<Store>> getStoresStream() {
    return _storesCol.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Store.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addStore(Store store) async {
    await _storesCol.add(store.toMap());
  }

  Future<void> deleteStore(String storeId) async {
    await _storesCol.doc(storeId).delete();
  }

  // --- GESTIONE OFFERTE ---
  /// Restituisce lo stream delle offerte attive (data fine >= inizio giornata odierna).
  /// In questo modo le offerte scadute vengono filtrate istantaneamente e non compaiono nell'app.
  Stream<List<PromoDeal>> getActiveDealsStream({String? storeId, String? brandFilter}) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayTimestamp = Timestamp.fromDate(todayStart);

    Query query = _dealsCol
        .where('endDate', isGreaterThanOrEqualTo: todayTimestamp)
        .orderBy('endDate', descending: false);

    if (storeId != null && storeId.isNotEmpty) {
      query = query.where('storeId', isEqualTo: storeId);
    }

    return query.snapshots().map((snapshot) {
      final deals = snapshot.docs.map((doc) => PromoDeal.fromFirestore(doc)).toList();
      if (brandFilter != null && brandFilter.isNotEmpty) {
        return deals.where((d) =>
          d.storeBrand.toLowerCase().contains(brandFilter.toLowerCase()) ||
          d.productBrand.toLowerCase().contains(brandFilter.toLowerCase())
        ).toList();
      }
      return deals;
    });
  }

  /// Aggiunta di una nuova offerta
  Future<void> addDeal(PromoDeal deal) async {
    await _dealsCol.add(deal.toMap());
  }

  /// Cancellazione manuale di un'offerta
  Future<void> deleteDeal(String dealId) async {
    await _dealsCol.doc(dealId).delete();
  }

  /// Pulizia fisica dal database delle offerte con endDate antecedente a oggi
  Future<int> purgeExpiredDeals() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayTimestamp = Timestamp.fromDate(todayStart);

    final snapshot = await _dealsCol
        .where('endDate', isLessThan: todayTimestamp)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    return snapshot.docs.length;
  }
}
