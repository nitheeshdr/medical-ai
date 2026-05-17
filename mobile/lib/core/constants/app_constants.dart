class AppConstants {
  static const String appName = 'MediNova AI';
  static const String appVersion = '1.0.0';

  // Dev: http://localhost:3001/api  |  Prod: https://medinova-backend-omega.vercel.app/api
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://medinova-backend-omega.vercel.app/api');
  static const String wsUrl = String.fromEnvironment('WS_URL', defaultValue: 'wss://medinova-backend-omega.vercel.app/ws');
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 60000;

  static const String jwtKey = 'jwt_token';
  static const String refreshKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String onboardedKey = 'onboarded';

  static const List<String> subscriptionPlans = ['Free', 'Pro', 'Family', 'Enterprise'];

  static const List<String> reportTypes = ['Blood Report', 'MRI', 'ECG', 'CT Scan', 'X-Ray', 'Diabetes'];

  static const List<String> bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
}
