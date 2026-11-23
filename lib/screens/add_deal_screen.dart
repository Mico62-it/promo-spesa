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
  final _promoPriceController = TextEditingController();
  final _originalPriceController = TextEditingController();

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
        const SnackBar(content: Text('Seleziona prima un punto vendita')),
      );
      return;
    }

    final promoPrice = double.tryParse(_promoPriceController.text.replaceAll(',', '.')) ?? 0.0;
    final originalPriceText = _originalPriceController.text.trim().replaceAll(',', '.');
    final originalPrice = originalPriceText.isNotEmpty ? double.tryParse(originalPriceText) : null;

    final newDeal = PromoDeal(
      id: '',
      storeId: _selectedStore!.id,
      storeBrand: _selectedStore!.brand,
      storeAddress: '${_selectedStore!.address}, ${_selectedStore!.city}',
      productName: _productNameController.text.trim(),
      productBrand: _productBrandController.text.trim(),
      promoPrice: promoPrice,
      originalPrice: originalPrice,
      startDate: _startDate,
      endDate: _endDate,
      createdAt: DateTime.now(),
    );

    await _dealsService.addDeal(newDeal);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offerta inserita con successo!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuova Offerta'),
      ),
      body: StreamBuilder<List<Store>>(
        stream: _dealsService.getStoresStream(),
        builder: (context, snapshot) {
          final stores = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<Store>(
                    value: _selectedStore,
                    decoration: const InputDecoration(
                      labelText: 'Supermercato / Store',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.storefront),
                    ),
                    hint: const Text('Seleziona il punto vendita'),
                    items: stores.map((store) {
                      return DropdownMenuItem<Store>(
                        value: store,
                        child: Text('${store.brand} (${store.address})'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedStore = val),
                    validator: (val) => val == null ? 'Campo obbligatorio' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _productNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Prodotto',
                      hintText: 'Es. Pasta Spaghetti n.5 1kg',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_bag),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Inserisci il nome del prodotto' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _productBrandController,
                    decoration: const InputDecoration(
                      labelText: 'Marca del Prodotto',
                      hintText: 'Es. Barilla, De Cecco, Mulino Bianco',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Inserisci la marca' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _promoPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Prezzo Offerta (€)',
                            hintText: 'Es. 0.99',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.euro),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Obbligatorio';
                            if (double.tryParse(val.replaceAll(',', '.')) == null) return 'Prezzo non valido';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _originalPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Prezzo Pieno (€)',
                            hintText: 'Opzionale (es. 1.49)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.money_off),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Periodo di Validità Promozione', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(true),
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text('Inizio: ${_dateFormat.format(_startDate)}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(false),
                          icon: const Icon(Icons.event, size: 18),
                          label: Text('Fine: ${_dateFormat.format(_endDate)}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _submitDeal,
                    child: const Text('Pubblica Offerta'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
