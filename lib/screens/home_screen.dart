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
    _dealsService.purgeExpiredDeals();
  }

  Color _getBrandColor(String brand) {
    final b = brand.toLowerCase();
    if (b.contains('conad')) return const Color(0xFFE11D48);
    if (b.contains('coop')) return const Color(0xFFDC2626);
    if (b.contains('esselunga')) return const Color(0xFF1E3A8A);
    if (b.contains('lidl')) return const Color(0xFF2563EB);
    if (b.contains('eurospin')) return const Color(0xFF0284C7);
    if (b.contains('carrefour')) return const Color(0xFF0D9488);
    if (b.contains('despar') || b.contains('spar')) return const Color(0xFF16A34A);
    return const Color(0xFF0F766E);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'PromoSpesa',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 21, letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_rounded),
            tooltip: 'Negozi della zona',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoresScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.auto_delete_outlined),
            tooltip: 'Pulisci scadute',
            onPressed: () async {
              final count = await _dealsService.purgeExpiredDeals();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: Text('Rimosse $count offerte scadute.'),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              // Search & Filter Header
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cerca per nome prodotto o marca...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => _searchQuery = val.trim());
                      },
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<Store>>(
                      stream: _dealsService.getStoresStream(),
                      builder: (context, snapshot) {
                        final stores = snapshot.data ?? [];
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('Tutti i Punti Vendita'),
                                selected: _selectedStoreId == null,
                                onSelected: (sel) {
                                  if (sel) setState(() => _selectedStoreId = null);
                                },
                                selectedColor: primaryColor.withOpacity(0.12),
                                checkmarkColor: primaryColor,
                                labelStyle: TextStyle(
                                  fontWeight: _selectedStoreId == null ? FontWeight.bold : FontWeight.w500,
                                  color: _selectedStoreId == null ? primaryColor : Colors.grey.shade700,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                side: BorderSide(
                                  color: _selectedStoreId == null ? primaryColor : Colors.grey.shade300,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ...stores.map((store) {
                                final isSelected = _selectedStoreId == store.id;
                                final bColor = _getBrandColor(store.brand);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: FilterChip(
                                    avatar: CircleAvatar(
                                      radius: 8,
                                      backgroundColor: bColor,
                                    ),
                                    label: Text('${store.brand} • ${store.address}'),
                                    selected: isSelected,
                                    onSelected: (sel) {
                                      setState(() => _selectedStoreId = sel ? store.id : null);
                                    },
                                    selectedColor: bColor.withOpacity(0.12),
                                    checkmarkColor: bColor,
                                    labelStyle: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? bColor : Colors.grey.shade700,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    side: BorderSide(
                                      color: isSelected ? bColor : Colors.grey.shade300,
                                    ),
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

              // Lista Offerte con Foto e Design Grafico
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

                    var deals = snapshot.data ?? [];
                    if (_searchQuery.isNotEmpty) {
                      deals = deals.where((d) =>
                        d.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        d.productBrand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        d.storeBrand.toLowerCase().contains(_searchQuery.toLowerCase())
                      ).toList();
                    }

                    if (deals.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.teal.shade300),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Nessuna offerta attiva',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aggiungi una nuova promozione con foto o registra un punto vendita!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AddDealScreen()),
                                  );
                                },
                                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                                label: const Text('Inserisci Offerta con Foto'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: deals.length,
                      itemBuilder: (context, index) {
                        final deal = deals[index];
                        final brandColor = _getBrandColor(deal.storeBrand);
                        final daysLeft = deal.endDate.difference(DateTime.now()).inDays + 1;
                        final discount = deal.discountPercentage;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          clipBehavior: Clip.antiAlias,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(color: Colors.grey.shade200, width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Immagine di copertina con badge sovrapposti
                              Stack(
                                children: [
                                  Image.network(
                                    deal.displayImage,
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(
                                      height: 140,
                                      color: Colors.grey.shade100,
                                      child: const Center(
                                        child: Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey),
                                      ),
                                    ),
                                    loadingBuilder: (ctx, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        height: 140,
                                        color: Colors.grey.shade100,
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      );
                                    },
                                  ),
                                  // Gradient Overlay per leggibilità
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.4),
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.6),
                                          ],
                                          stops: const [0.0, 0.4, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Badge Negozio in alto a sinistra
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: brandColor,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.store, color: Colors.white, size: 14),
                                          const SizedBox(width: 6),
                                          Text(
                                            deal.storeBrand.toUpperCase(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Badge Sconto in alto a destra
                                  if (discount != null)
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF97316),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6),
                                          ],
                                        ),
                                        child: Text(
                                          '-${discount.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Categoria e Indirizzo sul fondo dell'immagine
                                  Positioned(
                                    bottom: 10,
                                    left: 12,
                                    right: 12,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.55),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            deal.category,
                                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Text(
                                          deal.storeAddress,
                                          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Informazioni Prodotto, Prezzo e Scadenza
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                deal.productName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 18,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                              if (deal.productBrand.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Marca: ${deal.productBrand}',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline_rounded, size: 20, color: Colors.grey.shade400),
                                          onPressed: () => _dealsService.deleteDeal(deal.id),
                                          tooltip: 'Elimina offerta',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),

                                    // Prezzo e Scadenza
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        // Countdown
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: daysLeft <= 2
                                                ? Colors.red.shade50
                                                : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: daysLeft <= 2
                                                  ? Colors.red.shade200
                                                  : Colors.grey.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.alarm_rounded,
                                                size: 15,
                                                color: daysLeft <= 2 ? Colors.red.shade700 : const Color(0xFFF97316),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                daysLeft <= 0
                                                    ? 'Scade oggi'
                                                    : daysLeft == 1
                                                        ? 'Ultimo giorno'
                                                        : 'Scade tra $daysLeft gg (${_dateFormat.format(deal.endDate)})',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: daysLeft <= 2 ? Colors.red.shade800 : const Color(0xFF334155),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Prezzo promozionale
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            if (deal.originalPrice != null) ...[
                                              Text(
                                                '€${deal.originalPrice!.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  decoration: TextDecoration.lineThrough,
                                                  color: Colors.grey.shade400,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            Text(
                                              '€${deal.promoPrice.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF0F766E),
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDealScreen()),
          );
        },
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text(
          'Nuova Offerta',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
