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
  String? _selectedCategory;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _quickCategories = [
    {
      'name': 'Tutte',
      'icon': Icons.apps_rounded,
      'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Pasta & Riso',
      'icon': Icons.dinner_dining_rounded,
      'image': 'https://images.unsplash.com/photo-1621996346565-e3d5d6281699?w=200&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Frutta & Verdura',
      'icon': Icons.eco_rounded,
      'image': 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=200&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Carne & Pesce',
      'icon': Icons.kebab_dining_rounded,
      'image': 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=200&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Latticini & Formaggi',
      'icon': Icons.breakfast_dining_rounded,
      'image': 'https://images.unsplash.com/photo-1528750997573-59b89d56f4f7?w=200&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Colazione & Dolci',
      'icon': Icons.cookie_rounded,
      'image': 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=200&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Bevande & Vini',
      'icon': Icons.local_bar_rounded,
      'image': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=200&auto=format&fit=crop&q=80',
    },
  ];

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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar Trasparente con Titolo Elegante
          SliverAppBar(
            pinned: true,
            expandedHeight: 220.0,
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            title: const Text(
              'PromoSpesa',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.storefront_rounded, color: Colors.white),
                tooltip: 'Punti Vendita',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StoresScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.cleaning_services_rounded, color: Colors.white),
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
            // Hero Banner Grafico con Foto e Gradienti
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200&auto=format&fit=crop&q=80',
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0F766E).withOpacity(0.85),
                          const Color(0xFF042F2C).withOpacity(0.92),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'OFFERTE VOLANTINO',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Risparmia sulla Spesa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'I migliori prezzi dei supermercati della tua zona',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenuto Principale
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar Flottante
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cerca prodotto, marca o supermercato...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0F766E)),
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
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (val) {
                          setState(() => _searchQuery = val.trim());
                        },
                      ),
                    ),

                    // Categorie Fotografiche Orizzontali
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
                      child: Text(
                        'Esplora per Reparto',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _quickCategories.length,
                        itemBuilder: (context, index) {
                          final item = _quickCategories[index];
                          final name = item['name'] as String;
                          final isSelected = (_selectedCategory == null && name == 'Tutte') ||
                              _selectedCategory == name;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = name == 'Tutte' ? null : name;
                              });
                            },
                            child: Container(
                              width: 88,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  Container(
                                    height: 65,
                                    width: 65,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF0F766E) : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            item['image'] as String,
                                            fit: BoxFit.cover,
                                          ),
                                          if (isSelected)
                                            Container(
                                              color: const Color(0xFF0F766E).withOpacity(0.3),
                                              child: const Center(
                                                child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Filtro Supermercati della Zona
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Supermercati Attivi',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const StoresScreen()),
                              );
                            },
                            icon: const Icon(Icons.add_business_rounded, size: 16),
                            label: const Text('Gestisci'),
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<List<Store>>(
                      stream: _dealsService.getStoresStream(),
                      builder: (context, snapshot) {
                        final stores = snapshot.data ?? [];
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('Tutte le Insegne'),
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

                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Offerte in Corso',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (_selectedCategory != null)
                            Chip(
                              label: Text(_selectedCategory!),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: () => setState(() => _selectedCategory = null),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // Griglia / Lista Offerte
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: StreamBuilder<List<PromoDeal>>(
                  stream: _dealsService.getActiveDealsStream(
                    storeId: _selectedStoreId,
                    brandFilter: _searchQuery,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    var deals = snapshot.data ?? [];

                    // Filtro Categoria
                    if (_selectedCategory != null) {
                      deals = deals.where((d) => d.category.toLowerCase().contains(_selectedCategory!.toLowerCase()) ||
                          d.productName.toLowerCase().contains(_selectedCategory!.toLowerCase())).toList();
                    }

                    // Filtro Ricerca
                    if (_searchQuery.isNotEmpty) {
                      deals = deals.where((d) =>
                        d.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        d.productBrand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        d.storeBrand.toLowerCase().contains(_searchQuery.toLowerCase())
                      ).toList();
                    }

                    if (deals.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=500&auto=format&fit=crop&q=80',
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Il tuo carrello è ancora vuoto!',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Inizia registrando un supermercato e aggiungi la tua prima offerta con foto.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddDealScreen()),
                                );
                              },
                              icon: const Icon(Icons.add_photo_alternate_rounded, size: 20),
                              label: const Text('Pubblica Prima Offerta'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: deals.length,
                      itemBuilder: (context, index) {
                        final deal = deals[index];
                        final brandColor = _getBrandColor(deal.storeBrand);
                        final daysLeft = deal.endDate.difference(DateTime.now()).inDays + 1;
                        final discount = deal.discountPercentage;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 18),
                          clipBehavior: Clip.antiAlias,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.grey.shade200, width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Copertina Fotografica con Gradienti e Badge
                              Stack(
                                children: [
                                  Image.network(
                                    deal.displayImage,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(
                                      height: 160,
                                      color: Colors.grey.shade100,
                                      child: const Center(
                                        child: Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey),
                                      ),
                                    ),
                                    loadingBuilder: (ctx, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        height: 160,
                                        color: Colors.grey.shade100,
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      );
                                    },
                                  ),
                                  // Gradient Overlay
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.5),
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                          stops: const [0.0, 0.45, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Supermercato Insegna
                                  Positioned(
                                    top: 14,
                                    left: 14,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: brandColor,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 6),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.storefront_rounded, color: Colors.white, size: 14),
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
                                  // Badge Sconto Percentuale
                                  if (discount != null)
                                    Positioned(
                                      top: 14,
                                      right: 14,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
                                          ],
                                        ),
                                        child: Text(
                                          '-${discount.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Categoria e Indirizzo
                                  Positioned(
                                    bottom: 12,
                                    left: 14,
                                    right: 14,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            deal.category,
                                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          deal.storeAddress,
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Informazioni Prodotto & Prezzi
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
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 19,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                              if (deal.productBrand.isNotEmpty) ...[
                                                const SizedBox(height: 3),
                                                Text(
                                                  'Marca: ${deal.productBrand}',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline_rounded, size: 22, color: Colors.grey.shade400),
                                          onPressed: () => _dealsService.deleteDeal(deal.id),
                                          tooltip: 'Elimina offerta',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Prezzo e Scadenza
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        // Countdown
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: daysLeft <= 2
                                                ? Colors.red.shade50
                                                : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(12),
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
                                                size: 16,
                                                color: daysLeft <= 2 ? Colors.red.shade700 : const Color(0xFFF97316),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                daysLeft <= 0
                                                    ? 'Scade oggi!'
                                                    : daysLeft == 1
                                                        ? 'Ultimo giorno!'
                                                        : 'Scade tra $daysLeft gg (${_dateFormat.format(deal.endDate)})',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: daysLeft <= 2 ? Colors.red.shade800 : const Color(0xFF334155),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Prezzo promozionale grande
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
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            Text(
                                              '€${deal.promoPrice.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 28,
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
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 6,
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
