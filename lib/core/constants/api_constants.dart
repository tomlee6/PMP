class ApiConstants {
  // Replace with the actual local test IP or domain, e.g., 10.0.2.2 for Android Emulator, localhost for iOS/Web
  static const String baseUrl = "http://localhost:3000";
  static const String loginEndpoint = "/api/v1/auth/login";
  static const String profileEndpoint = "/api/v1/auth/profile";
  static const String changePasswordEndpoint = "/api/v1/auth/change-password";
  
  static const String hrRequestsEndpoint = "/api/v1/hr/requests";
  static const String nrmRequestsEndpoint = "/api/v1/nrm/requests";
  
  static const String maintenanceBreakdownsEndpoint = "/api/v1/maintenance/breakdowns";
  static const String maintenanceDropdownsEndpoint = "/api/v1/maintenance/dropdowns";
}
