import 'package:flutter/material.dart';
import '../models/store.dart';
import '../services/deals_service.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final DealsService _dealsService = DealsService();

  void _showAddStoreDialog() {
    final brandController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuovo Supermercato'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: brandController,
                decoration: const InputDecoration(
                  labelText: 'Marchio / Insegna',
                  hintText: 'Es. Conad, Coop, Esselunga, Lidl',
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Indirizzo',
                  hintText: 'Es. Via Roma 15',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Città / Zona',
                  hintText: 'Es. Milano',
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              final brand = brandController.text.trim();
              final address = addressController.text.trim();
              final city = cityController.text.trim();

              if (brand.isEmpty || address.isEmpty || city.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Compila tutti i campi')),
                );
                return;
              }

              final newStore = Store(
                id: '',
                brand: brand,
                address: address,
                city: city,
              );

              await _dealsService.addStore(newStore);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punti Vendita della Zona'),
      ),
      body: StreamBuilder<List<Store>>(
        stream: _dealsService.getStoresStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final stores = snapshot.data ?? [];
          if (stores.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store_mall_directory_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Nessun punto vendita inserito.\nAggiungi i supermercati della tua zona!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddStoreDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Aggiungi Supermercato'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: stores.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final store = stores[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    store.brand.isNotEmpty ? store.brand[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(
                  store.brand,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text('${store.address}, ${store.city}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _dealsService.deleteStore(store.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStoreDialog,
        tooltip: 'Aggiungi Supermercato',
        child: const Icon(Icons.add_business),
      ),
    );
  }
}
