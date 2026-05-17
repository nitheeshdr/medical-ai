class AppException implements Exception {
  final String message;
  final int? statusCode;
  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String message = 'No internet connection']) : super(message);
}

class ServerException extends AppException {
  ServerException([String message = 'Server error. Please try again.', int? code])
      : super(message, statusCode: code);
}

class AuthException extends AppException {
  AuthException([String message = 'Authentication failed']) : super(message, statusCode: 401);
}

class NotFoundException extends AppException {
  NotFoundException([String message = 'Resource not found']) : super(message, statusCode: 404);
}

class ValidationException extends AppException {
  final Map<String, String>? errors;
  ValidationException(String message, {this.errors}) : super(message, statusCode: 422);
}
