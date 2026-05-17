import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../routes/route_names.dart';
import '../../shared/widgets/wise/wise_card.dart';

// ── Model ──────────────────────────────────────────────────────────────────────

class MedicineItem {
  final String id, name, category, dosage, description;
  final double price;
  final int stock;
  final bool requiresPrescription;

  const MedicineItem({
    required this.id,
    required this.name,
    required this.category,
    required this.dosage,
    required this.description,
    required this.price,
    required this.stock,
    required this.requiresPrescription,
  });

  factory MedicineItem.fromJson(Map<String, dynamic> j) => MedicineItem(
        id: j['_id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        category: j['category'] as String? ?? '',
        dosage: j['dosage'] as String? ?? '',
        description: j['description'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        stock: (j['stock'] as num?)?.toInt() ?? 0,
        requiresPrescription: j['requiresPrescription'] as bool? ?? false,
      );

  String get priceDisplay => '\$${price.toStringAsFixed(2)}';
  bool get inStock => stock > 0;
}

// ── Provider ───────────────────────────────────────────────────────────────────

final medicinesProvider = FutureProvider.family<List<MedicineItem>, String>((ref, category) async {
  final api = ref.read(apiClientProvider);
  final params = category == 'All' ? <String, dynamic>{} : <String, dynamic>{'category': category};
  final res = await api.get('/medicines', params: params);
  final body = res.data as Map<String, dynamic>;
  final list = body['medicines'] as List? ?? body as List? ?? [];
  return list.map((e) => MedicineItem.fromJson(e as Map<String, dynamic>)).toList();
});

// ── Screen ────────────────────────────────────────────────────────────────────

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  String _category = 'All';
  String _search = '';

  static const _categories = ['All', 'Antibiotics', 'Cardiovascular', 'Diabetes', 'Gastrointestinal', 'Pain Relief'];

  @override
  Widget build(BuildContext context) {
    final medicinesAsync = ref.watch(medicinesProvider(_category));

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Medicine Store'),
        backgroundColor: kBackground,
        foregroundColor: kPrimaryText,
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _search = v.toLowerCase()),
                style: const TextStyle(color: kPrimaryText),
                decoration: const InputDecoration(
                  hintText: 'Search medicines...',
                  hintStyle: TextStyle(color: kTertiaryText),
                  prefixIcon: Icon(Icons.search, color: kSecondaryText),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _categories.map((c) => GestureDetector(
                onTap: () => setState(() => _category = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _category == c ? kAccent : kSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _category == c ? kAccent : kBorder),
                  ),
                  child: Text(c, style: TextStyle(
                    color: _category == c ? Colors.white : kSecondaryText,
                    fontSize: 13, fontWeight: FontWeight.w500,
                  )),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: medicinesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: kAccent)),
              error: (e, _) => Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.wifi_off_rounded, size: 48, color: kTertiaryText),
                  const SizedBox(height: 12),
                  const Text('Could not load medicines', style: TextStyle(color: kSecondaryText)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => ref.invalidate(medicinesProvider),
                    child: const Text('Retry', style: TextStyle(color: kAccent)),
                  ),
                ]),
              ),
              data: (medicines) {
                final filtered = _search.isEmpty
                    ? medicines
                    : medicines.where((m) =>
                        m.name.toLowerCase().contains(_search) ||
                        m.category.toLowerCase().contains(_search)).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.local_pharmacy_outlined, size: 48, color: kTertiaryText),
                      const SizedBox(height: 12),
                      Text(
                        medicines.isEmpty ? 'No medicines in stock' : 'No results for "$_search"',
                        style: const TextStyle(color: kSecondaryText),
                      ),
                    ]),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.82,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _MedicineCard(medicine: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Medicine card ──────────────────────────────────────────────────────────────

class _MedicineCard extends StatelessWidget {
  final MedicineItem medicine;
  const _MedicineCard({required this.medicine});

  static IconData _iconFor(String category) {
    switch (category.toLowerCase()) {
      case 'antibiotics': return Icons.biotech_rounded;
      case 'vitamins': return Icons.wb_sunny_rounded;
      case 'diabetes': return Icons.science_rounded;
      case 'cardiovascular': return Icons.favorite_rounded;
      case 'pain relief': return Icons.healing_rounded;
      case 'gastrointestinal': return Icons.restaurant_rounded;
      default: return Icons.local_pharmacy_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WiseCard(
      onTap: () => context.push(RouteNames.medicineDetail, extra: medicine.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80, width: double.infinity,
            decoration: BoxDecoration(
              color: kAccentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconFor(medicine.category), color: kAccent, size: 36),
          ),
          const SizedBox(height: 10),
          Text(medicine.name,
              style: const TextStyle(color: kPrimaryText, fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(medicine.category, style: const TextStyle(color: kSecondaryText, fontSize: 11)),
          if (medicine.requiresPrescription)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: kWarningLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Rx', style: TextStyle(color: kWarningOrange, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(medicine.priceDisplay,
                  style: const TextStyle(color: kPrimaryText, fontSize: 15, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: medicine.inStock ? kAccent : kBorder,
                  shape: BoxShape.circle,
                ),
                child: Icon(medicine.inStock ? Icons.add : Icons.close,
                    color: medicine.inStock ? Colors.white : kSecondaryText, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
