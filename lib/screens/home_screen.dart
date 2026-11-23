import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/promo_deal.dart';
import '../models/store.dart';
import '../services/deals_service.dart';
import 'add_deal_screen.dart';
import 'stores_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DealsService _dealsService = DealsService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final TextEditingController _searchController = TextEditingController();

  String? _selectedStoreId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // All'avvio dell'app esegue la pulizia in background delle offerte scadute dal DB
    _dealsService.purgeExpiredDeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PromoSpesa - Offerte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            tooltip: 'Gestione Punti Vendita',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoresScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: 'Pulisci offerte scadute',
            onPressed: () async {
              final count = await _dealsService.purgeExpiredDeals();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rimosse $count offerte scadute dal database.')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra filtri (Ricerca per nome/marca e filtro per supermercato)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cerca per prodotto o marca...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<Store>>(
                  stream: _dealsService.getStoresStream(),
                  builder: (context, snapshot) {
                    final stores = snapshot.data ?? [];
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Tutti i Negozi'),
                            selected: _selectedStoreId == null,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedStoreId = null);
                            },
                          ),
                          const SizedBox(width: 8),
                          ...stores.map((store) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text('${store.brand} (${store.address})'),
                                selected: _selectedStoreId == store.id,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedStoreId = selected ? store.id : null;
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Lista offerte attive in tempo reale
          Expanded(
            child: StreamBuilder<List<PromoDeal>>(
              stream: _dealsService.getActiveDealsStream(
                storeId: _selectedStoreId,
                brandFilter: _searchQuery,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Errore: ${snapshot.error}'),
                    ),
                  );
                }

                var deals = snapshot.data ?? [];

                // Filtro locale aggiuntivo sul nome prodotto se specificato
                if (_searchQuery.isNotEmpty) {
                  deals = deals.where((d) =>
                    d.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    d.productBrand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    d.storeBrand.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                if (deals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Nessuna offerta attiva trovata.\nInserisci una nuova offerta con il tasto +',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: deals.length,
                  itemBuilder: (context, index) {
                    final deal = deals[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    deal.storeBrand.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                  onPressed: () => _dealsService.deleteDeal(deal.id),
                                  tooltip: 'Elimina offerta',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              deal.storeAddress,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const Divider(height: 16),
                            Text(
                              deal.productName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            if (deal.productBrand.isNotEmpty)
                              Text(
                                'Marca: ${deal.productBrand}',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Valida fino al:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Row(
                                      children: [
                                        const Icon(Icons.timer, size: 16, color: Colors.orange),
                                        const SizedBox(width: 4),
                                        Text(
                                          _dateFormat.format(deal.endDate),
                                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    if (deal.originalPrice != null) ...[
                                      Text(
                                        '€${deal.originalPrice!.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      '€${deal.promoPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDealScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuova Offerta'),
      ),
    );
  }
}
