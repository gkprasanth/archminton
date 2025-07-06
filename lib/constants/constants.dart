class AppConstants {
  // Primary endpoint - using direct IP to bypass DNS issues
  static const String baseUrl = "https://backend.asynclabs.org/api";
  
  // Alternative endpoints for fallback
  static const List<String> alternativeEndpoints = [
    "http://ec2-52-66-255-113.ap-south-1.compute.amazonaws.com/api",
    "https://archminton-backend.onrender.com/api",
  ];
  
  // Test endpoint for connectivity check
  static const String testEndpoint = "/auth/test";
}