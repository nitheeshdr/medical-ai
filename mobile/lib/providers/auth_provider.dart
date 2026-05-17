import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import 'notification_provider.dart';

const _storage = FlutterSecureStorage();

// ── Auth state — AsyncNotifier restores user from secure storage on build ──────

class _AuthNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async {
    final raw = await _storage.read(key: AppConstants.userKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return Map<String, dynamic>.from(decoded as Map);
    } catch (_) {
      return null;
    }
  }

  void setUser(Map<String, dynamic>? user) {
    state = AsyncData(user);
  }
}

final authStateProvider =
    AsyncNotifierProvider<_AuthNotifier, Map<String, dynamic>?>(_AuthNotifier.new);

// Derived provider — always returns Map or null, never AsyncValue
final currentUserProvider = Provider<Map<String, dynamic>?>((ref) {
  final async = ref.watch(authStateProvider);
  final Map<String, dynamic>? user = async.asData?.value;
  return user;
});

// ── Auth controller ────────────────────────────────────────────────────────────

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  late final ApiClient _api;

  @override
  Future<void> build() async {
    _api = ref.read(apiClientProvider);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = res.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String? ?? '';
      final Map<String, dynamic> user = Map<String, dynamic>.from(
          data['user'] as Map? ?? {'email': email});

      await _storage.write(key: AppConstants.jwtKey, value: token);
      await _storage.write(key: AppConstants.refreshKey, value: refreshToken);
      await _storage.write(key: AppConstants.userKey, value: jsonEncode(user));
      ref.read(authStateProvider.notifier).setUser(user);
      
      // Register FCM token for pushes now that we have an auth token
      ref.read(notificationServiceProvider).registerTokenWithBackend();
    });
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await _api.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      final data = res.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String? ?? '';
      final Map<String, dynamic> user = Map<String, dynamic>.from(
          data['user'] as Map? ?? {'name': name, 'email': email});

      await _storage.write(key: AppConstants.jwtKey, value: token);
      await _storage.write(key: AppConstants.refreshKey, value: refreshToken);
      await _storage.write(key: AppConstants.userKey, value: jsonEncode(user));
      ref.read(authStateProvider.notifier).setUser(user);
      
      ref.read(notificationServiceProvider).registerTokenWithBackend();
    });
  }

  Future<void> signOut() async {
    await _storage.delete(key: AppConstants.jwtKey);
    await _storage.delete(key: AppConstants.refreshKey);
    await _storage.delete(key: AppConstants.userKey);
    ref.read(authStateProvider.notifier).setUser(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userKey);
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) throw Exception('Google Sign-In canceled');

      final res = await _api.post('/auth/google', data: {
        'name': account.displayName ?? 'Google User',
        'email': account.email,
        'googleId': account.id,
      });
      final data = res.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String? ?? '';
      final Map<String, dynamic> user = Map<String, dynamic>.from(
          data['user'] as Map? ?? {'email': account.email});

      await _storage.write(key: AppConstants.jwtKey, value: token);
      await _storage.write(key: AppConstants.refreshKey, value: refreshToken);
      await _storage.write(key: AppConstants.userKey, value: jsonEncode(user));
      ref.read(authStateProvider.notifier).setUser(user);
      
      ref.read(notificationServiceProvider).registerTokenWithBackend();
    });
  }

  Future<void> resetPassword(String email) async {
    await _api.post('/auth/forgot-password', data: {'email': email});
  }
}
