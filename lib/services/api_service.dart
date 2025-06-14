import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';

class ApiService {
  static final String baseUrl = AppConstants.baseUrl;

  static Future<Map<String, String>> get headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<List<Map<String, dynamic>>> getCourts(String venueId) async {
    try {
      final requestHeaders = await headers;
      final url = '$baseUrl/admin/courts?venueId=$venueId';
      print('🌐 API Call: GET $url');
      print('🔑 Headers: $requestHeaders');
      
      final response = await http.get(
        Uri.parse(url),
        headers: requestHeaders,
      );
      
      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle different response formats
        List<Map<String, dynamic>> courts = [];
        if (data is List) {
          courts = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] is List) {
          courts = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is Map && data['courts'] is List) {
          courts = List<Map<String, dynamic>>.from(data['courts']);
        }
        
        print('🏟️ Parsed ${courts.length} courts');
        return courts;
      } else {
        throw Exception('Failed to load courts: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 API Error: $e');
      throw Exception('Error loading courts: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getCourtTimeSlots(int courtId, {bool includeInactive = false}) async {
    try {
      final requestHeaders = await headers;
      final queryParams = includeInactive ? '?includeInactive=true' : '';
      final url = '$baseUrl/courts/$courtId/timeslots$queryParams';
      print('🌐 API Call: GET $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: requestHeaders,
      );
      
      print('📡 Time Slots Response Status: ${response.statusCode}');
      print('📄 Time Slots Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle different response formats
        List<Map<String, dynamic>> timeSlots = [];
        if (data is List) {
          timeSlots = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] is List) {
          timeSlots = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is Map && data['timeSlots'] is List) {
          timeSlots = List<Map<String, dynamic>>.from(data['timeSlots']);
        }
        
        print('🕐 Parsed ${timeSlots.length} time slots for court $courtId');
        return timeSlots;
      } else {
        // Try alternative admin endpoint
        print('🔄 Trying alternative admin endpoint...');
        final altUrl = '$baseUrl/admin/courts/$courtId/timeslots$queryParams';
        final altResponse = await http.get(
          Uri.parse(altUrl),
          headers: requestHeaders,
        );
        
        if (altResponse.statusCode == 200) {
          final altData = json.decode(altResponse.body);
          List<Map<String, dynamic>> altTimeSlots = [];
          if (altData is List) {
            altTimeSlots = List<Map<String, dynamic>>.from(altData);
          } else if (altData is Map && altData['data'] is List) {
            altTimeSlots = List<Map<String, dynamic>>.from(altData['data']);
          } else if (altData is Map && altData['timeSlots'] is List) {
            altTimeSlots = List<Map<String, dynamic>>.from(altData['timeSlots']);
          }
          return altTimeSlots;
        }
        
        print('⚠️ Both endpoints failed, returning empty time slots for court $courtId');
        return [];
      }
    } catch (e) {
      print('💥 Time Slots API Error for court $courtId: $e');
      return []; // Return empty array instead of throwing to prevent breaking
    }
  }

  static Future<Map<String, dynamic>> getAvailability({
    required int courtId,
    required String date,
  }) async {
    try {
      final requestHeaders = await headers;
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/availability?courtId=$courtId&date=$date'),
        headers: requestHeaders,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load availability: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading availability: $e');
    }
  }

  static Future<Map<String, dynamic>> createRazorpayOrder({
    required double amount,
    required String currency,
    String? receipt,
  }) async {
    try {
      print('💰 Creating Razorpay order...');
      print('💰 Amount: $amount');
      print('💰 Currency: $currency');
      print('💰 Receipt: $receipt');
      
      final requestHeaders = await headers;
      final body = {
        'amount': (amount * 100).toInt(), // Razorpay expects amount in paise
        'currency': currency,
        'receipt': receipt ?? 'receipt_${DateTime.now().millisecondsSinceEpoch}',
      };
      
      print('🌐 API Call: POST $baseUrl/payments/create-order');
      print('📦 Request Body: ${json.encode(body)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/payments/create-order'),
        headers: requestHeaders,
        body: json.encode(body),
      );
      
      print('📡 Order Creation Response Status: ${response.statusCode}');
      print('📄 Order Creation Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData['data'], // Extract just the data part
          'message': responseData['message'] ?? 'Order created successfully'
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception('Order creation failed: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}');
        } catch (parseError) {
          throw Exception('Order creation failed: HTTP ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('💥 Order Creation Exception: $e');
      throw Exception('Error creating order: $e');
    }
  }

  static Future<Map<String, dynamic>> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
    required int bookingId,
  }) async {
    try {
      print('🔐 Verifying payment...');
      print('🔐 Payment ID: $paymentId');
      print('🔐 Order ID: $orderId');
      print('🔐 Signature: $signature');
      print('🔐 Booking ID: $bookingId');
      
      final requestHeaders = await headers;
      final body = {
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': orderId,
        'razorpay_signature': signature,
        'booking_id': bookingId,
      };
      
      print('🌐 API Call: POST $baseUrl/payments/verify');
      print('📦 Request Body: ${json.encode(body)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/payments/verify'),
        headers: requestHeaders,
        body: json.encode(body),
      );
      
      print('📡 Payment Verification Response Status: ${response.statusCode}');
      print('📄 Payment Verification Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Payment verified successfully'
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception('Payment verification failed: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}');
        } catch (parseError) {
          throw Exception('Payment verification failed: HTTP ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('💥 Payment Verification Exception: $e');
      throw Exception('Error verifying payment: $e');
    }
  }

  static Future<Map<String, dynamic>> createBooking({
    required int courtId,
    required int timeSlotId,
    required String bookingDate,
    List<Map<String, dynamic>>? addOns,
  }) async {
    try {
      // Check if user is authenticated
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated - no access token found');
      }
      
      // Match the API schema exactly
      final body = {
        'courtId': courtId,
        'timeSlotId': timeSlotId,
        'bookingDate': bookingDate,
        'addOns': addOns ?? [], // Use provided addOns or empty array
      };
      
      print('🎯 Creating booking with data: $body');
      print('🌐 API Call: POST $baseUrl/bookings');
      print('🔐 Token available: ${token.substring(0, 20)}...');

      final requestHeaders = await headers;
      print('🔑 Request Headers: $requestHeaders');
      print('📦 Request Body: ${json.encode(body)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: requestHeaders,
        body: json.encode(body),
      );
      
      print('📡 Booking Response Status: ${response.statusCode}');
      print('📄 Booking Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Booking created successfully'
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          print('❌ Booking Error Data: $errorData');
          throw Exception('Error creating booking: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}');
        } catch (parseError) {
          print('❌ Failed to parse error response: $parseError');
          throw Exception('Error creating booking: HTTP ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('💥 Booking Creation Exception: $e');
      throw Exception('Exception: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserBookings() async {
    try {
      print('🔄 ApiService: Starting getUserBookings...');
      
      final requestHeaders = await headers;
      final url = '$baseUrl/users/bookings';
      
      print('🌐 API Call: GET $url');
      print('🔑 Request Headers: $requestHeaders');
      
      final response = await http.get(
        Uri.parse(url),
        headers: requestHeaders,
      );
      
      print('📡 User Bookings Response Status: ${response.statusCode}');
      print('📄 User Bookings Response Body: ${response.body}');
      print('📄 Response Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        print('✅ Successfully decoded response: ${decodedResponse.runtimeType}');
        return decodedResponse;
      } else {
        print('❌ API Error - Status: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        
        // Try to parse error message from response
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
          throw Exception('Failed to load user bookings: $errorMessage');
        } catch (parseError) {
          throw Exception('Failed to load user bookings: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('💥 getUserBookings Exception: $e');
      print('💥 Exception type: ${e.runtimeType}');
      throw Exception('Error loading user bookings: $e');
    }
  }

  static Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    try {
      final requestHeaders = await headers;
      final response = await http.delete(
        Uri.parse('$baseUrl/bookings/$bookingId'),
        headers: requestHeaders,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to cancel booking');
      }
    } catch (e) {
      throw Exception('Error cancelling booking: $e');
    }
  }

  // Membership API methods
  static Future<List<Map<String, dynamic>>> getMembershipRequests() async {
    try {
      final requestHeaders = await headers;
      final url = '$baseUrl/membership-requests';
      print('🌐 API Call: GET $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: requestHeaders,
      );
      
      print('📡 Membership Requests Response Status: ${response.statusCode}');
      print('📄 Membership Requests Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle different response formats
        List<Map<String, dynamic>> requests = [];
        if (data is List) {
          requests = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] is List) {
          requests = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is Map && data['requests'] is List) {
          requests = List<Map<String, dynamic>>.from(data['requests']);
        }
        
        print('📋 Parsed ${requests.length} membership requests');
        return requests;
      } else {
        throw Exception('Failed to load membership requests: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 Membership Requests API Error: $e');
      throw Exception('Error loading membership requests: $e');
    }
  }

  static Future<Map<String, dynamic>> createMembershipRequest({
    required int societyId,
    String? reviewNote,
  }) async {
    try {
      final requestHeaders = await headers;
      final body = {
        'societyId': societyId,
        if (reviewNote != null) 'reviewNote': reviewNote,
      };
      
      print('🎯 Creating membership request with data: $body');
      print('🌐 API Call: POST $baseUrl/membership-requests');
      
      final response = await http.post(
        Uri.parse('$baseUrl/membership-requests'),
        headers: requestHeaders,
        body: json.encode(body),
      );
      
      print('📡 Create Membership Response Status: ${response.statusCode}');
      print('📄 Create Membership Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Membership request created successfully'
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception('Error creating membership request: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}');
        } catch (parseError) {
          throw Exception('Error creating membership request: HTTP ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('💥 Create Membership Request Exception: $e');
      throw Exception('Exception: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteMembershipRequest(int requestId) async {
    try {
      final requestHeaders = await headers;
      final url = '$baseUrl/membership-requests/$requestId';
      print('🌐 API Call: DELETE $url');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: requestHeaders,
      );
      
      print('📡 Delete Membership Response Status: ${response.statusCode}');
      print('📄 Delete Membership Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Membership request deleted successfully'
        };
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete membership request');
      }
    } catch (e) {
      print('💥 Delete Membership Request Exception: $e');
      throw Exception('Error deleting membership request: $e');
    }
  }
} 