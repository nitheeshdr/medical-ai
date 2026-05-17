import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

final healthFactoryProvider = Provider<HealthFactory>((ref) {
  return HealthFactory();
});

final healthDataProvider = FutureProvider<Map<String, String>>((ref) async {
  final health = ref.read(healthFactoryProvider);

  final types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BLOOD_OXYGEN,
  ];

  final permissions = types.map((e) => HealthDataAccess.READ).toList();

  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));

  try {
    bool hasPermissions = await health.hasPermissions(types, permissions: permissions) ?? false;
    if (!hasPermissions) {
      bool requested = await health.requestAuthorization(types, permissions: permissions);
      if (!requested) {
        return {'error': 'Permissions not granted'};
      }
    }

    final healthData = await health.getHealthDataFromTypes(yesterday, now, types);
    healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));

    int steps = 0;
    try {
      steps = await health.getTotalStepsInInterval(
        DateTime(now.year, now.month, now.day), 
        now
      ) ?? 0;
    } catch (_) {}

    String heartRate = '--';
    String calories = '--';
    String spo2 = '--';

    for (var data in healthData) {
      if (data.type == HealthDataType.HEART_RATE && heartRate == '--') {
        heartRate = '${(data.value as NumericHealthValue).numericValue.round()}';
      }
      if (data.type == HealthDataType.ACTIVE_ENERGY_BURNED && calories == '--') {
        calories = '${(data.value as NumericHealthValue).numericValue.round()}';
      }
      if (data.type == HealthDataType.BLOOD_OXYGEN && spo2 == '--') {
        spo2 = '${((data.value as NumericHealthValue).numericValue * 100).round()}%';
      }
    }

    return {
      'steps': '$steps',
      'heartRate': heartRate,
      'calories': calories,
      'spo2': spo2,
    };
  } catch (e) {
    return {'error': 'Failed to read health data'};
  }
});
