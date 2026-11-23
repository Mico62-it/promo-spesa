import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/store.dart';
import '../models/promo_deal.dart';
import '../services/deals_service.dart';

class AddDealScreen extends StatefulWidget {
  const AddDealScreen({super.key});

  @override
  State<AddDealScreen> createState() => _AddDealScreenState();
}

class _AddDealScreenState extends State<AddDealScreen> {
  final _formKey = GlobalKey<FormState>();
  final DealsService _dealsService = DealsService();

  Store? _selectedStore;
  final _productNameController = TextEditingController();
  final _productBrandController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _promoPriceController = TextEditingController();
  final _originalPriceController = TextEditingController();

  String _selectedCategory = 'Pasta & Riso';
  final List<String> _categories = [
    'Pasta & Riso',
    'Frutta & Verdura',
    'Carne & Pesce',
    'Latticini & Formaggi',
    'Colazione & Dolci',
    'Bevande & Vini',
    'Olio & Condimenti',
    'Cura Casa & Persona',
    'Altro',
  ];

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> _pickDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitDeal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: const Text('Seleziona prima un punto vendita'),
        ),
      );
      return;
    }

    final promoPrice = double.tryParse(_promoPriceController.text.replaceAll(',', '.')) ?? 0.0;
    final originalPriceText = _originalPriceController.text.trim().replaceAll(',', '.');
    final originalPrice = originalPriceText.isNotEmpty ? double.tryParse(originalPriceText) : null;
    final customImage = _imageUrlController.text.trim();

    final newDeal = PromoDeal(
      id: '',
      storeId: _selectedStore!.id,
      storeBrand: _selectedStore!.brand,
      storeAddress: '${_selectedStore!.address}, ${_selectedStore!.city}',
      productName: _productNameController.text.trim(),
      productBrand: _productBrandController.text.trim(),
      category: _selectedCategory,
      imageUrl: customImage.isNotEmpty ? customImage : null,
      promoPrice: promoPrice,
      originalPrice: originalPrice,
      startDate: _startDate,
      endDate: _endDate,
      createdAt: DateTime.now(),
    );

    await _dealsService.addDeal(newDeal);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: const Text('Offerta con immagine pubblicata con successo!'),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi Offerta con Foto'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: StreamBuilder<List<Store>>(
            stream: _dealsService.getStoresStream(),
            builder: (context, snapshot) {
              final stores = snapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dettagli Promozione & Categoria',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<Store>(
                              value: _selectedStore,
                              decoration: InputDecoration(
                                labelText: 'Punto Vendita',
                                prefixIcon: Icon(Icons.storefront_rounded, color: primaryColor),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              hint: const Text('Seleziona supermercato'),
                              items: stores.map((store) {
                                return DropdownMenuItem<Store>(
                                  value: store,
                                  child: Text('${store.brand} (${store.address})'),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedStore = val),
                              validator: (val) => val == null ? 'Seleziona un supermercato' : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: InputDecoration(
                                labelText: 'Categoria Prodotto (assegna foto automatica)',
                                prefixIcon: Icon(Icons.category_rounded, color: primaryColor),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              items: _categories.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedCategory = val);
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _productNameController,
                              decoration: InputDecoration(
                                labelText: 'Nome Prodotto',
                                hintText: 'Es. Spaghetti Barilla 1kg, Mozzarella Santa Lucia',
                                prefixIcon: Icon(Icons.shopping_bag_outlined, color: primaryColor),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              validator: (val) => (val == null || val.trim().isEmpty) ? 'Inserisci il nome del prodotto' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _productBrandController,
                              decoration: InputDecoration(
                                labelText: 'Marca Prodotto',
                                hintText: 'Es. Barilla, Mulino Bianco, Lavazza',
                                prefixIcon: Icon(Icons.label_outline_rounded, color: primaryColor),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              validator: (val) => (val == null || val.trim().isEmpty) ? 'Inserisci la marca' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _imageUrlController,
                              decoration: InputDecoration(
                                labelText: 'Link Immagine Personalizzata (Opzionale)',
                                hintText: 'Incolla URL foto web o lascia vuoto per foto automatica',
                                prefixIcon: Icon(Icons.image_outlined, color: primaryColor),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _promoPriceController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Prezzo Offerta (€)',
                                      hintText: 'Es. 0.99',
                                      prefixIcon: const Icon(Icons.euro_rounded, color: Color(0xFF0F766E)),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Obbligatorio';
                                      if (double.tryParse(val.replaceAll(',', '.')) == null) return 'Non valido';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _originalPriceController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Prezzo Intero (€)',
                                      hintText: 'Opzionale (1.49)',
                                      prefixIcon: const Icon(Icons.money_off_rounded, color: Colors.grey),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Durata Promozione',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () => _pickDate(true),
                                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                                    label: Text('Dal: ${_dateFormat.format(_startDate)}'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      side: const BorderSide(color: Color(0xFFF97316)),
                                      foregroundColor: const Color(0xFFF97316),
                                    ),
                                    onPressed: () => _pickDate(false),
                                    icon: const Icon(Icons.event_available_rounded, size: 18),
                                    label: Text('Al: ${_dateFormat.format(_endDate)}'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        onPressed: _submitDeal,
                        child: const Text('Pubblica Offerta con Immagine'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
