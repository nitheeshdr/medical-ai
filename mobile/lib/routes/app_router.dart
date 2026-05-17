import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/profile/profile_setup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/dashboard_screen.dart';
import '../features/prescription/scanner_screen.dart';
import '../features/prescription/scanner_result_screen.dart';
import '../features/prescription/prescription_history_screen.dart';
import '../features/reports/report_upload_screen.dart';
import '../features/reports/report_analysis_screen.dart';
import '../features/chatbot/chat_screen.dart';
import '../features/appointments/appointment_list_screen.dart';
import '../features/appointments/doctor_list_screen.dart';
import '../features/appointments/doctor_profile_screen.dart';
import '../features/appointments/appointment_booking_screen.dart';
import '../features/medicine_store/store_screen.dart';
import '../features/medicine_store/medicine_detail_screen.dart';
import '../features/telemedicine/video_call_screen.dart';
import '../features/health_tracking/tracking_screen.dart';
import '../features/family/family_screen.dart';
import '../features/family/add_member_screen.dart';
import '../features/emergency/emergency_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/subscription/plans_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/security_screen.dart';
import '../features/settings/device_management_screen.dart';
import '../features/wellness/wellness_screen.dart';
import '../features/journal/journal_screen.dart';
import '../features/journal/journal_entry_screen.dart';
import '../features/wearable/wearable_screen.dart';
import '../features/timeline/timeline_screen.dart';
import '../features/document_wallet/wallet_screen.dart';
import '../providers/auth_provider.dart';
import 'route_names.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final isAuthenticated = authState.asData?.value != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == RouteNames.splash;
      final isOnboarding = state.matchedLocation == RouteNames.onboarding;

      if (isSplash || isOnboarding) return null;
      if (!isAuthenticated && !isAuthRoute) return RouteNames.login;
      if (isAuthenticated && isAuthRoute) return RouteNames.dashboard;
      return null;
    },
    routes: [
      GoRoute(path: RouteNames.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: RouteNames.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: RouteNames.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: RouteNames.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: RouteNames.profileSetup, builder: (_, __) => const ProfileSetupScreen()),

      // Home shell with bottom navigation
      ShellRoute(
        // Each shell gets its own Hero scope so FABs don't conflict
        // with the root navigator's Hero controller.
        builder: (context, state, child) => HeroControllerScope(
          controller: MaterialApp.createMaterialHeroController(),
          child: HomeScreen(child: child),
        ),
        routes: [
          GoRoute(path: RouteNames.dashboard, builder: (_, __) => const DashboardScreen()),
          GoRoute(
            path: RouteNames.scanner,
            builder: (_, __) => const ScannerScreen(),
            routes: [
              GoRoute(path: 'result', builder: (_, s) => ScannerResultScreen(data: s.extra as Map<String, dynamic>? ?? {})),
              GoRoute(path: 'history', builder: (_, __) => const PrescriptionHistoryScreen()),
            ],
          ),
          GoRoute(
            path: RouteNames.reports,
            builder: (_, __) => const ReportUploadScreen(),
            routes: [
              GoRoute(path: 'analysis', builder: (_, s) => ReportAnalysisScreen(reportId: s.extra as String)),
            ],
          ),
          GoRoute(path: RouteNames.chatbot, builder: (_, __) => const ChatScreen()),
          GoRoute(path: RouteNames.appointments, builder: (_, __) => const AppointmentListScreen()),
        ],
      ),

      GoRoute(path: RouteNames.medicineStore, builder: (_, __) => const StoreScreen()),
      GoRoute(path: RouteNames.medicineDetail, builder: (_, s) => MedicineDetailScreen(id: s.extra as String)),
      GoRoute(path: RouteNames.doctorList, builder: (_, __) => const DoctorListScreen()),
      GoRoute(path: RouteNames.doctorProfile, builder: (_, s) => DoctorProfileScreen(doctorId: s.extra as String)),
      GoRoute(path: RouteNames.bookAppointment, builder: (_, s) => AppointmentBookingScreen(doctorId: s.extra as String)),
      GoRoute(path: RouteNames.telemedicine, builder: (_, s) => VideoCallScreen(doctorId: s.extra as String)),
      GoRoute(path: RouteNames.healthTracking, builder: (_, __) => const TrackingScreen()),
      GoRoute(path: RouteNames.family, builder: (_, __) => const FamilyScreen()),
      GoRoute(path: RouteNames.addFamilyMember, builder: (_, __) => const AddMemberScreen()),
      GoRoute(path: RouteNames.emergency, builder: (_, __) => const EmergencyScreen()),
      GoRoute(path: RouteNames.notificationsPage, builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: RouteNames.subscription, builder: (_, __) => const PlansScreen()),
      GoRoute(path: RouteNames.settings, builder: (_, __) => const SettingsScreen()),
      GoRoute(path: RouteNames.security, builder: (_, __) => const SecurityScreen()),
      GoRoute(path: RouteNames.deviceManagement, builder: (_, __) => const DeviceManagementScreen()),
      GoRoute(path: RouteNames.wellness, builder: (_, __) => const WellnessScreen()),
      GoRoute(path: RouteNames.journal, builder: (_, __) => const JournalScreen()),
      GoRoute(path: RouteNames.journalEntry, builder: (_, s) => JournalEntryScreen(entryId: s.extra as String?)),
      GoRoute(path: RouteNames.wearable, builder: (_, __) => const WearableScreen()),
      GoRoute(path: RouteNames.timeline, builder: (_, __) => const TimelineScreen()),
      GoRoute(path: RouteNames.documentWallet, builder: (_, __) => const WalletScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text('Page not found', style: Theme.of(context).textTheme.titleLarge),
      ),
    ),
  );
});
