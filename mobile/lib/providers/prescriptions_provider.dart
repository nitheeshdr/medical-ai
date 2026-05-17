import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';

class PrescriptionMedicine {
  final String name, dosage, frequency, duration;
  const PrescriptionMedicine({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  factory PrescriptionMedicine.fromJson(Map<String, dynamic> j) => PrescriptionMedicine(
        name: j['name'] ?? '',
        dosage: j['dosage'] ?? '',
        frequency: j['frequency'] ?? '',
        duration: j['duration'] ?? '',
      );
}

class PrescriptionAnalysis {
  final List<PrescriptionMedicine> medicines;
  final List<String> sideEffects, foodRestrictions, warnings;
  final String summary;

  const PrescriptionAnalysis({
    required this.medicines,
    required this.sideEffects,
    required this.foodRestrictions,
    required this.warnings,
    required this.summary,
  });

  factory PrescriptionAnalysis.fromJson(Map<String, dynamic> j) => PrescriptionAnalysis(
        medicines: (j['medicines'] as List? ?? [])
            .map((m) => PrescriptionMedicine.fromJson(m as Map<String, dynamic>))
            .toList(),
        sideEffects: List<String>.from(j['sideEffects'] ?? []),
        foodRestrictions: List<String>.from(j['foodRestrictions'] ?? []),
        warnings: List<String>.from(j['warnings'] ?? []),
        summary: j['summary'] ?? '',
      );
}

class Prescription {
  final String id, ocrText, imageUrl;
  final PrescriptionAnalysis aiAnalysis;
  final DateTime createdAt;

  const Prescription({
    required this.id,
    required this.ocrText,
    required this.imageUrl,
    required this.aiAnalysis,
    required this.createdAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> j) => Prescription(
        id: j['_id'] ?? '',
        ocrText: j['ocrText'] ?? '',
        imageUrl: j['imageUrl'] ?? '',
        aiAnalysis: PrescriptionAnalysis.fromJson(
            j['aiAnalysis'] as Map<String, dynamic>? ?? {}),
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      );
}

// List all prescriptions
final prescriptionsProvider = FutureProvider.autoDispose<List<Prescription>>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get('/prescriptions');
  final list = res.data is List ? res.data as List : [];
  return list.map((e) => Prescription.fromJson(e as Map<String, dynamic>)).toList();
});

// Scan + analyze a prescription image via NVIDIA vision
class PrescriptionScanNotifier extends AsyncNotifier<Prescription?> {
  @override
  Future<Prescription?> build() async => null;

  Future<Prescription?> scan(String imageBase64, {String mimeType = 'image/jpeg'}) async {
    state = const AsyncLoading();
    final api = ref.read(apiClientProvider);
    try {
      final res = await api.post('/ai/scan', data: {
        'imageBase64': imageBase64,
        'mimeType': mimeType,
      });
      final data = res.data as Map<String, dynamic>;
      final prescription = Prescription.fromJson(
          data['prescription'] as Map<String, dynamic>? ?? {});
      state = AsyncData(prescription);
      ref.invalidate(prescriptionsProvider);
      return prescription;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final prescriptionScanProvider =
    AsyncNotifierProvider<PrescriptionScanNotifier, Prescription?>(
        PrescriptionScanNotifier.new);
