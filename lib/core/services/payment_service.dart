import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final Razorpay _razorpay = Razorpay();
  final String razorpayKey = 'rzp_test_ScvaUZtfQzPnC0'; // Using the key found in your project

  // State to track current purchase for success handler
  Function(String paymentId, String orderId)? _onExternalSuccess;
  Function(String message)? _onExternalError;

  String? _currentCourseName;
  double? _currentAmount;

  void init({
    Function(String paymentId, String orderId)? onSuccess,
    Function(String message)? onFailure,
  }) {
    _onExternalSuccess = onSuccess;
    _onExternalError = onFailure;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> purchaseSubject({
    required String subjectId,
    required String subjectName,
    required double amount,
    required String userEmail,
    required String userName,
  }) async {
    _currentCourseName = subjectName;
    _currentAmount = amount;
    await _createOrderAndPay(
      amount: amount,
      type: 'subject',
      itemId: subjectId,
      description: 'Unlock Subject: $subjectName',
      userEmail: userEmail,
      userName: userName,
    );
  }

  Future<void> purchaseBundle({
    required String bundleId,
    required String bundleName,
    required double amount,
    required String userEmail,
    required String userName,
  }) async {
    _currentCourseName = bundleName;
    _currentAmount = amount;
    await _createOrderAndPay(
      amount: amount,
      type: 'bundle',
      itemId: bundleId,
      description: 'Bundle: $bundleName',
      userEmail: userEmail,
      userName: userName,
    );
  }

  Future<void> _createOrderAndPay({
    required double amount,
    required String type,
    required String itemId,
    required String description,
    required String userEmail,
    required String userName,
  }) async {
    try {
      debugPrint('Creating Razorpay Order via Edge Function... Type: $type, Item: $itemId');
      
      final response = await Supabase.instance.client.functions.invoke(
        'create-razorpay-order',
        body: {
          'amount': (amount * 100).toInt(),
          'currency': 'INR',
          'type': type,
          'itemId': itemId,
          'receipt': '${type}_${itemId}_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      if (response.data == null || response.data['id'] == null) {
        final errorMsg = response.data?['error'] ?? 'Order creation failed';
        debugPrint('Edge Function Error: $errorMsg');
        throw Exception(errorMsg);
      }

      final orderId = response.data['id'];

      var options = {
        'key': razorpayKey,
        'amount': (amount * 100).toInt(),
        'currency': 'INR',
        'name': 'Unani Academy',
        'description': description,
        'order_id': orderId,
        'prefill': {
          'contact': '',
          'email': userEmail,
          'name': userName,
        },
        'method': {
          'upi': true,
          'card': true,
          'netbanking': true,
          'wallet': true,
        },
        'config': {
          'display': {
            'blocks': {
              'upi': {
                'name': 'Pay via UPI',
                'instruments': [
                  {'method': 'upi'}
                ]
              }
            },
            'sequence': ['block.upi'],
            'preferences': {'show_default_blocks': true}
          }
        },
        'theme': {'color': '#6B21A8'},
      };

      debugPrint('Opening Razorpay Checkout with OrderID: $orderId');
      _razorpay.open(options);

    } catch (e) {
      debugPrint('Payment Service Error: $e');
      _onExternalError?.call(e.toString());
      throw Exception('Payment failed: ${e.toString()}');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Razorpay Success: ${response.paymentId}');
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('purchases').insert({
          'user_id': user.id,
          'payment_id': response.paymentId,
          'order_id': response.orderId,
          'course_name': _currentCourseName ?? 'Unknown Course',
          'amount': _currentAmount ?? 0,
          'purchased_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error saving purchase: $e');
    }

    // 1. Callback to UI (Repository will handle sync)
    _onExternalSuccess?.call(response.paymentId ?? '', response.orderId ?? '');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Razorpay Error: ${response.code} - ${response.message}');
    _onExternalError?.call(response.message ?? 'Payment Failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet Selected: ${response.walletName}');
  }

  void dispose() {
    _razorpay.clear();
  }
}
