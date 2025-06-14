import 'dart:convert';
import 'dart:io';

void main() async {
  // Your Bearer token
  final token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtYWlsIjoiYWRtaW5AZXhhbXBsZS5jb20iLCJyb2xlIjoiU1VQRVJBRE1JTiIsImlhdCI6MTc0OTkwOTY2OCwiZXhwIjoxNzQ5OTk2MDY4fQ.6ruA6kUBtsIvljlZ8Lh2mSnulfNdKMHz1BkGPSxf_6M";
  
  // API base URL
  final baseUrl = "http://ec2-52-66-255-113.ap-south-1.compute.amazonaws.com/api";
  
  // First, let's get the available courts to see which court ID to use
  print('🔍 Fetching available courts...');
  
  final client = HttpClient();
  
  try {
    // Get courts first
    final courtsRequest = await client.getUrl(Uri.parse('$baseUrl/admin/courts'));
    courtsRequest.headers.set('Authorization', 'Bearer $token');
    courtsRequest.headers.set('Content-Type', 'application/json');
    
    final courtsResponse = await courtsRequest.close();
    final courtsBody = await courtsResponse.transform(utf8.decoder).join();
    
    print('📊 Courts Response:');
    print('Status: ${courtsResponse.statusCode}');
    print('Body: $courtsBody');
    
    if (courtsResponse.statusCode == 200) {
      final courtsData = jsonDecode(courtsBody);
      print('✅ Courts fetched successfully');
      
      // Extract court IDs
      List courts = courtsData['data'] ?? courtsData;
      if (courts.isNotEmpty) {
        final firstCourt = courts[0];
        final courtId = firstCourt['id'];
        
        print('🎯 Using Court ID: $courtId (${firstCourt['name']})');
        
        // Now create a time slot for this court
        await createTimeSlot(client, baseUrl, token, courtId);
      } else {
        print('❌ No courts found');
      }
    } else {
      print('❌ Failed to fetch courts: ${courtsResponse.statusCode}');
    }
    
  } catch (e) {
    print('💥 Error: $e');
  } finally {
    client.close();
  }
}

Future<void> createTimeSlot(HttpClient client, String baseUrl, String token, int courtId) async {
  print('\n🕐 Creating time slot for court $courtId...');
  
  // Time slot data
  final slotData = {
    "dayOfWeek": 1, // Monday (0=Sunday, 1=Monday, etc.)
    "startTime": "09:00",
    "endTime": "10:00",
    "isActive": true
  };
  
  try {
    final request = await client.postUrl(Uri.parse('$baseUrl/admin/courts/$courtId/timeslots'));
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Content-Type', 'application/json');
    
    // Add the JSON body
    final jsonBody = jsonEncode(slotData);
    request.write(jsonBody);
    
    print('📤 Request Details:');
    print('URL: $baseUrl/admin/courts/$courtId/timeslots');
    print('Headers: Authorization: Bearer ${token.substring(0, 20)}...');
    print('Body: $jsonBody');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('\n📡 Response:');
    print('Status: ${response.statusCode}');
    print('Body: $responseBody');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Time slot created successfully!');
      final responseData = jsonDecode(responseBody);
      print('Created slot: $responseData');
    } else {
      print('❌ Failed to create time slot');
      
      // Try to parse error message
      try {
        final errorData = jsonDecode(responseBody);
        print('Error details: $errorData');
      } catch (e) {
        print('Raw error response: $responseBody');
      }
    }
    
  } catch (e) {
    print('💥 Error creating time slot: $e');
  }
} 