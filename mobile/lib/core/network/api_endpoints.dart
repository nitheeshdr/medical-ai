class ApiEndpoints {
  static const String auth = '/auth';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  static const String userProfile = '/users/profile';
  static String userById(String id) => '/users/$id';

  static const String doctors = '/doctors';
  static String doctorById(String id) => '/doctors/$id';

  static const String prescriptions = '/prescriptions';
  static const String analyzePrescription = '/prescriptions/analyze';
  static String prescriptionById(String id) => '/prescriptions/$id';

  static const String reports = '/reports';
  static const String analyzeReport = '/reports/analyze';
  static String reportById(String id) => '/reports/$id';

  static const String appointments = '/appointments';
  static const String appointmentSlots = '/appointments/slots';
  static String appointmentById(String id) => '/appointments/$id';

  static const String medicines = '/medicines';

  static const String chat = '/chat';
  static const String chatStream = '/chat/stream';
  static String chatSession(String id) => '/chat/$id';

  static const String healthMetrics = '/health-metrics';

  static const String familyMembers = '/family/members';
  static String familyMember(String id) => '/family/$id';

  static const String emergencyContacts = '/emergency/contacts';

  static const String notifications = '/notifications';
  static const String fcmToken = '/users/fcm-token';

  static const String payments = '/payments';
  static const String subscriptions = '/subscriptions';
  static const String subscriptionPlans = '/subscriptions/plans';

  static const String aiChat = '/ai/chat';
  static const String aiScan = '/ai/scan';
  static const String aiAnalyzeReport = '/ai/analyze-report';
  static const String aiWellness = '/ai/wellness';
}
