class ApiConstants {
  // ngrok public URL
  static const String baseUrl = 'https://proverbial-jane-hazardous.ngrok-free.dev/api';
  
  // For Android Emulator use 10.0.2.2 (localhost of host machine)
  // static const String baseUrl = 'http://10.0.2.2:8080/api';  // Android Emulator
  // static const String baseUrl = 'http://192.168.x.x:8080/api';  // Physical Device
  // static const String baseUrl = 'http://localhost:8080/api';  // iOS Simulator
  
  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  
  // User
  static const String currentUser = '/users/me';
  static const String updateLocation = '/users/me/location';
  
  // Requests
  static const String requests = '/requests';
  
  // Volunteer
  static const String volunteerRequests = '/volunteer/requests';
  static const String activeRequests = '/volunteer/requests/active';
  
  // Notifications
  static const String notifications = '/notifications';
  static const String unreadNotifications = '/notifications/unread';
}

class HelpTypes {
  static const String onlineHelp = 'ONLINE_HELP';
  static const String writerHelp = 'WRITER_HELP';
  static const String navigationAssistance = 'NAVIGATION_ASSISTANCE';
  static const String documentReading = 'DOCUMENT_READING';
  
  static String getLabel(String type) {
    switch (type) {
      case onlineHelp: return 'Online Help';
      case writerHelp: return 'Writer Help';
      case navigationAssistance: return 'Navigation Assistance';
      case documentReading: return 'Document Reading';
      default: return type;
    }
  }
  
  static String getDescription(String type) {
    switch (type) {
      case onlineHelp: return 'Help with reading messages or documents online';
      case writerHelp: return 'Help with writing exam answers or documents';
      case navigationAssistance: return 'Help reaching a location';
      case documentReading: return 'Help reading printed documents';
      default: return '';
    }
  }
}
