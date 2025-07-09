import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'profileoptions/MyBookings.dart';

class RazorpayPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final VoidCallback? onBookingSuccess;

  const RazorpayPaymentScreen({
    super.key, 
    required this.bookingData,
    this.onBookingSuccess,
  });

  @override
  State<RazorpayPaymentScreen> createState() => _RazorpayPaymentScreenState();
}

class _RazorpayPaymentScreenState extends State<RazorpayPaymentScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    
    // Start payment process immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPayment();
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _startPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final bookingData = widget.bookingData;
      final price = bookingData['price'] ?? 300;
      
      // Step 1: Create Razorpay order
      print('🚀 Creating Razorpay order...');
      final orderResult = await ApiService.createRazorpayOrder(
        amount: price.toDouble(),
        currency: 'INR',
        receipt: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      if (orderResult['success'] != true) {
        throw Exception(orderResult['message'] ?? 'Failed to create payment order');
      }
      
      final orderId = orderResult['data']?['id'];
      print('✅ Order created successfully: $orderId');
      print('🔍 Full order result: $orderResult');
      print('🔍 Order data: ${orderResult['data']}');
      
      if (orderId == null || orderId.toString().isEmpty) {
        throw Exception('Order created but no order ID returned. Response: $orderResult');
      }
      
      // Validate that we have all required data for Razorpay
      if (price <= 0) {
        throw Exception('Invalid amount: $price');
      }
      
      // Step 2: Open Razorpay with order ID
      final amountInPaise = (price * 100).toInt();
      
      // Validate amount
      if (amountInPaise <= 0) {
        throw Exception('Invalid amount: $amountInPaise paise');
      }
      
      const razorpayKey = 'rzp_live_nWO09X889iyAzF';
      
      // Validate Razorpay key format
      if (!razorpayKey.startsWith('rzp_test_') && !razorpayKey.startsWith('rzp_live_')) {
        throw Exception('Invalid Razorpay key format: $razorpayKey');
      }
      
      var options = <String, dynamic>{
        'key': razorpayKey,
        'amount': amountInPaise,
        'currency': 'INR',
        'name': 'Archminton',
        'order_id': orderId.toString(),
        'description': 'Court Booking - ${bookingData['courtName'] ?? 'Court'}',
        'prefill': <String, String>{
          'contact': '9999999999',
          'email': 'user@example.com'
        },
        'theme': <String, String>{
          'color': '#FF6B35'
        },
        'modal': <String, bool>{
          'backdropclose': false,
          'escape': false,
          'handleback': true,
        }
      };

      print('🎯 Razorpay Options: $options');
      print('🔑 Order ID being passed: "$orderId" (${orderId.runtimeType})');
      print('💰 Amount being passed: $amountInPaise paise');
      print('💰 Original price: $price');
      
      // Add a small delay to ensure UI is ready
      await Future.delayed(const Duration(milliseconds: 100));
      
      setState(() {
        _isProcessing = false; // Reset processing state before opening Razorpay
      });

      try {
        _razorpay.open(options);
      } catch (razorpayError) {
        print('❌ Razorpay.open() failed: $razorpayError');
        
        // Try without order_id as fallback
        print('🔄 Trying payment without order_id...');
        final fallbackOptions = Map<String, dynamic>.from(options);
        fallbackOptions.remove('order_id');
        
        try {
          _razorpay.open(fallbackOptions);
        } catch (fallbackError) {
          print('❌ Fallback payment also failed: $fallbackError');
          throw Exception('Both payment methods failed: $razorpayError');
        }
      }
    } catch (e) {
      print('❌ Payment initialization error: $e');
      
      // Show error dialog with option to retry or proceed without order
      _showPaymentInitErrorDialog(e.toString());
    }
  }

  void _showPaymentInitErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 30),
            const SizedBox(width: 10),
            Text(
              'Payment Setup Issue',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'There was an issue setting up the payment.',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                'Error: $error',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.red[700],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You can try again or proceed with basic payment (without verification).',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to booking summary
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _startBasicPayment(); // Proceed without order
            },
            child: Text(
              'Pay Anyway',
              style: GoogleFonts.poppins(color: Colors.blue),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _startPayment(); // Retry
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _startBasicPayment() {
    setState(() {
      _isProcessing = true;
    });

    final bookingData = widget.bookingData;
    final price = bookingData['price'] ?? 300;
    
    // Basic payment without order ID (fallback)
    var options = {
      'key': 'rzp_live_nWO09X889iyAzF',
      'amount': (price * 100).toInt(),
      'currency': 'INR',
      'name': 'Archminton',
      'description': 'Court Booking - ${bookingData['courtName']}',
      'prefill': {
        'contact': '9999999999',
        'email': 'user@example.com'
      },
      'theme': {
        'color': '#FF6B35'
      }
    };

    print('🎯 Basic Razorpay Options (no order): $options');

    try {
      _razorpay.open(options);
    } catch (e) {
      print('❌ Basic payment also failed: $e');
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment gateway error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    print('Order ID: ${response.orderId}');
    print('Signature: ${response.signature}');
    
    // Show immediate success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! Verifying and creating booking...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    _processBookingWithPaymentVerification(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    setState(() {
      _isProcessing = false;
    });
    
    _showPaymentErrorDialog(response);
  }

  void _showPaymentErrorDialog(PaymentFailureResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 30),
            const SizedBox(width: 10),
            Text(
              'Payment Failed',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your payment could not be processed.',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                'Error: ${response.message ?? 'Unknown error occurred'}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.red[700],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You can try again or go back to modify your booking.',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog first
              Navigator.of(context).pop();
              
              // Add a small delay to ensure dialog is closed
              Future.delayed(const Duration(milliseconds: 100), () {
                try {
                  // Check if we can navigate
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    // If we can't pop, we're already at the first route
                    print('Already at first route');
                  }
                } catch (e) {
                  print('Navigation error: $e');
                  // If all else fails, try to close the current screen
                  if (mounted && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }
              });
            },
            child: Text(
              'Go Back',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _startPayment(); // Retry payment
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
      ),
    );
  }

  void _processBookingWithPaymentVerification(PaymentSuccessResponse paymentResponse) async {
    try {
      setState(() {
        _isProcessing = true;
      });
      
      final bookingData = widget.bookingData;
      
      // Validate required fields
      if (bookingData['courtId'] == null || bookingData['slotId'] == null || bookingData['date'] == null) {
        throw Exception('Missing required booking data: courtId=${bookingData['courtId']}, slotId=${bookingData['slotId']}, date=${bookingData['date']}');
      }
      
      final dateString = DateFormat('yyyy-MM-dd').format(bookingData['date']);
      
      print('🔍 Booking data received: $bookingData');
      print('🔍 Court ID: ${bookingData['courtId']} (type: ${bookingData['courtId'].runtimeType})');
      print('🔍 Slot ID: ${bookingData['slotId']} (type: ${bookingData['slotId'].runtimeType})');
      print('🔍 Date: ${bookingData['date']} (type: ${bookingData['date'].runtimeType})');
      print('🔍 Date string: $dateString');
      
      // Ensure IDs are integers
      final courtId = bookingData['courtId'] is int 
          ? bookingData['courtId'] 
          : int.parse(bookingData['courtId'].toString());
      final timeSlotId = bookingData['slotId'] is int 
          ? bookingData['slotId'] 
          : int.parse(bookingData['slotId'].toString());
      
      print('🔍 Converted Court ID: $courtId (type: ${courtId.runtimeType})');
      print('🔍 Converted Slot ID: $timeSlotId (type: ${timeSlotId.runtimeType})');
      
      // Step 1: Create the booking first
      print('📝 Step 1: Creating booking...');
      final bookingResult = await ApiService.createBooking(
        courtId: courtId,
        timeSlotId: timeSlotId,
        bookingDate: dateString,
        addOns: [], // No add-ons for now
      );
      
      if (bookingResult['success'] != true) {
        throw Exception(bookingResult['message'] ?? 'Booking creation failed');
      }
      
      // Extract booking ID from the response
      // The API response is wrapped, so we need to access data.data.id
      final bookingId = bookingResult['data']?['data']?['id'] ?? 
                       bookingResult['data']?['id'] ?? 
                       bookingResult['data']?['bookingId'];
      
      print('🔍 Debug booking response structure:');
      print('🔍 bookingResult keys: ${bookingResult.keys}');
      print('🔍 bookingResult[data] type: ${bookingResult['data']?.runtimeType}');
      print('🔍 bookingResult[data] keys: ${bookingResult['data']?.keys}');
      if (bookingResult['data']?['data'] != null) {
        print('🔍 bookingResult[data][data] keys: ${bookingResult['data']['data']?.keys}');
        print('🔍 bookingResult[data][data][id]: ${bookingResult['data']['data']['id']}');
      }
      
      if (bookingId == null) {
        throw Exception('Booking created but no booking ID returned');
      }
      
      print('✅ Booking created successfully with ID: $bookingId');
      
      // Step 2: Verify the payment and update booking status
      if (paymentResponse.orderId != null && paymentResponse.signature != null) {
        print('🔐 Step 2: Verifying payment...');
        
        final verificationResult = await ApiService.verifyPayment(
          paymentId: paymentResponse.paymentId!,
          orderId: paymentResponse.orderId!,
          signature: paymentResponse.signature!,
          bookingId: int.parse(bookingId.toString()),
        );
        
        if (verificationResult['success'] == true) {
          print('✅ Payment verified successfully');
          setState(() {
            _isProcessing = false;
          });
                     _showSuccessDialog(paymentResponse.paymentId, bookingId.toString(), true);
        } else {
          throw Exception('Payment verification failed: ${verificationResult['message']}');
        }
      } else {
        // Fallback: If we don't have order ID or signature, still show success but mark as unverified
        print('⚠️ Payment verification skipped - missing order ID or signature');
        setState(() {
          _isProcessing = false;
        });
                 _showSuccessDialog(paymentResponse.paymentId, bookingId.toString(), false);
      }
      
    } catch (e) {
      print('❌ Booking/Payment process failed: $e');
      setState(() {
        _isProcessing = false;
      });
      
      _showBookingErrorDialog(paymentResponse.paymentId, e.toString());
    }
  }

  void _processBooking(String? paymentId) async {
    try {
      final bookingData = widget.bookingData;
      
      // Validate required fields
      if (bookingData['courtId'] == null || bookingData['slotId'] == null || bookingData['date'] == null) {
        throw Exception('Missing required booking data: courtId=${bookingData['courtId']}, slotId=${bookingData['slotId']}, date=${bookingData['date']}');
      }
      
      final dateString = DateFormat('yyyy-MM-dd').format(bookingData['date']);
      
      print('🔍 Booking data received: $bookingData');
      print('🔍 Court ID: ${bookingData['courtId']} (type: ${bookingData['courtId'].runtimeType})');
      print('🔍 Slot ID: ${bookingData['slotId']} (type: ${bookingData['slotId'].runtimeType})');
      print('🔍 Date: ${bookingData['date']} (type: ${bookingData['date'].runtimeType})');
      print('🔍 Date string: $dateString');
      
      // Ensure IDs are integers
      final courtId = bookingData['courtId'] is int 
          ? bookingData['courtId'] 
          : int.parse(bookingData['courtId'].toString());
      final timeSlotId = bookingData['slotId'] is int 
          ? bookingData['slotId'] 
          : int.parse(bookingData['slotId'].toString());
      
      print('🔍 Converted Court ID: $courtId (type: ${courtId.runtimeType})');
      print('🔍 Converted Slot ID: $timeSlotId (type: ${timeSlotId.runtimeType})');
      
      final result = await ApiService.createBooking(
        courtId: courtId,
        timeSlotId: timeSlotId,
        bookingDate: dateString,
        addOns: [], // No add-ons for now
      );
      
      setState(() {
        _isProcessing = false;
      });
      
      if (result['success'] == true) {
        // Show success dialog
        _showSuccessDialog(paymentId);
      } else {
        throw Exception(result['message'] ?? 'Booking failed');
      }
    } catch (e) {
      print('Booking creation failed: $e');
      setState(() {
        _isProcessing = false;
      });
      
      // Show detailed error dialog instead of brief snackbar
      _showBookingErrorDialog(paymentId, e.toString());
    }
  }

  void _showBookingErrorDialog(String? paymentId, String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 30),
            const SizedBox(width: 10),
            Text(
              'Payment Successful',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your payment was successful, but there was an issue creating the booking.',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 10),
            if (paymentId != null) ...[
              Text(
                'Payment ID: $paymentId',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 10),
            ],
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                'Error: $errorMessage',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.red[700],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please contact support with your payment ID for assistance.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _retryBookingCreation(paymentId);
            },
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(color: Colors.orange),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              
              // Add a small delay to ensure dialog is closed
              Future.delayed(const Duration(milliseconds: 100), () {
                try {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).popUntil((route) => route.isFirst); // Go to home
                  } else {
                    print('Already at first route');
                  }
                  // Call the callback to refresh the booking screen
                  if (widget.onBookingSuccess != null) {
                    widget.onBookingSuccess!();
                  }
                } catch (e) {
                  print('Navigation error: $e');
                  if (mounted && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Go Home',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _retryBookingCreation(String? paymentId) {
    setState(() {
      _isProcessing = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Retrying booking creation...'),
        backgroundColor: Colors.blue,
      ),
    );
    
    _processBooking(paymentId);
  }

  void _showSuccessDialog(String? paymentId, [String? bookingId, bool verified = false]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              verified ? Icons.check_circle : Icons.pending, 
              color: verified ? Colors.green : Colors.orange, 
              size: 30
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                verified ? 'Booking Confirmed!' : 'Booking Created!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: verified ? Colors.green : Colors.orange,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                verified 
                  ? 'Your court booking has been confirmed and payment verified successfully.'
                  : 'Your court booking has been created. Payment verification is in progress.',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 10),
              
              // Payment verification status
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: verified ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: verified ? Colors.green[200]! : Colors.orange[200]!
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      verified ? Icons.verified : Icons.pending,
                      size: 16,
                      color: verified ? Colors.green[700] : Colors.orange[700],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        verified ? 'Payment Verified' : 'Payment Verification Pending',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: verified ? Colors.green[700] : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              if (bookingId != null) ...[
                Text(
                  'Booking ID: #$bookingId',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 5),
              ],
              if (paymentId != null) ...[
                Text(
                  'Payment ID: $paymentId',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
              ],
              Text(
                'Booking Details:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '• Court: ${widget.bookingData['courtName']}',
                style: GoogleFonts.poppins(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '• Date: ${DateFormat('dd MMM yyyy').format(widget.bookingData['date'])}',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              Text(
                '• Time: ${widget.bookingData['timeSlot']}',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              Text(
                '• Amount: ₹${widget.bookingData['price']}',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate to My Bookings page
              Navigator.of(context).pop(); // Close dialog
              Future.delayed(const Duration(milliseconds: 100), () {
                try {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    // Call the callback to refresh the booking screen
                    if (widget.onBookingSuccess != null) {
                      widget.onBookingSuccess!();
                    }
                    // Navigate to My Bookings page
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MyBookingsScreen(),
                      ),
                    );
                  }
                } catch (e) {
                  print('Navigation error: $e');
                }
              });
            },
            child: Text(
              'View Bookings',
              style: GoogleFonts.poppins(color: Colors.green),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate back to home screen (pop all screens)
              Navigator.of(context).pop(); // Close dialog
              Future.delayed(const Duration(milliseconds: 100), () {
                try {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                  // Call the callback to refresh the booking screen
                  if (widget.onBookingSuccess != null) {
                    widget.onBookingSuccess!();
                  }
                } catch (e) {
                  print('Navigation error: $e');
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Done',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookingData = widget.bookingData;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        automaticallyImplyLeading: !_isProcessing,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            opacity: 0.05,
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isProcessing) ...[
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Processing Payment...',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please complete the payment in the Razorpay window',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Icon(
                    Icons.payment,
                    size: 80,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Payment Gateway',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Redirecting to payment...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                
                // Booking Summary Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Summary',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Court:', style: GoogleFonts.poppins()),
                            Text(
                              bookingData['courtName'] ?? 'N/A',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Date:', style: GoogleFonts.poppins()),
                            Text(
                              DateFormat('dd MMM yyyy').format(bookingData['date']),
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Time:', style: GoogleFonts.poppins()),
                            Text(
                              bookingData['timeSlot'] ?? 'N/A',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount:',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${bookingData['price']}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (!_isProcessing) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _startPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      'Retry Payment',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 