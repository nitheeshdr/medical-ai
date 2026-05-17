import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final String fee;
  final bool available;
  final String experience;
  final String? imageUrl;
  final String? about;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.fee,
    required this.available,
    required this.experience,
    this.imageUrl,
    this.about,
  });

  factory Doctor.fromJson(Map<String, dynamic> j) => Doctor(
        id: j['_id'] as String? ?? j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        specialty: j['specialization'] as String? ?? j['specialty'] as String? ?? '',
        rating: (j['averageRating'] as num?)?.toDouble() ?? 0.0,
        fee: '\$${j['consultationFee'] ?? 0}',
        available: j['isVerified'] as bool? ?? true,
        experience: '${j['experience'] ?? 0} yrs',
        imageUrl: j['imageUrl'] as String?,
        about: j['bio'] as String?,
      );

  String get initials => name
      .split(' ')
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase())
      .take(2)
      .join();
}

final doctorsProvider = FutureProvider.family<List<Doctor>, String?>((ref, specialty) async {
  final api = ref.read(apiClientProvider);
  final params = specialty != null && specialty != 'All'
      ? <String, dynamic>{'specialty': specialty}
      : <String, dynamic>{};
  final res = await api.get('/doctors', params: params);
  // After _UnwrapInterceptor: res.data = { doctors: [...], total, page, pages }
  final body = res.data as Map<String, dynamic>;
  final list = (body['doctors'] ?? body) as List<dynamic>;
  return list.map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
});

final doctorDetailProvider = FutureProvider.family<Doctor, String>((ref, id) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get('/doctors/$id');
  return Doctor.fromJson(res.data as Map<String, dynamic>);
});
