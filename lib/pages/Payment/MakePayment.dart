// lib/pages/Payment/MakePayment.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domains/PaymentInfo.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Repositories/PaymentInfo.dart';
import 'PaymentConfirmation.dart'; // Import the confirmation screen

class MakePaymentScreen extends StatefulWidget {
  final String paymentId;
  const MakePaymentScreen({super.key, required this.paymentId});

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  Future<ManagePayment?>? _paymentFuture;
  bool _isPaying = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_paymentFuture == null) {
      final paymentInfoRepository = Provider.of<PaymentInfo>(context);
      _paymentFuture = paymentInfoRepository.getPaymentById(widget.paymentId);
    }
  }

  Future<void> _handlePayNow(ManagePayment payment) async {
    setState(() { _isPaying = true; });

    // --- NEW, MORE ROBUST AUTHENTICATION CHECK ---
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication error: Please restart the app."))
      );
      setState(() { _isPaying = false; });
      return; // Stop if user is somehow not logged in
    }
    // ------------------------------------------

    try {
      // We still use the region you confirmed earlier
      final functions = FirebaseFunctions.instanceFor(region: 'asia-southeast1');

      final result =
          await functions.httpsCallable('createStripePaymentIntent').call({
        'amount': (payment.paymentAmount * 100).toInt(),
        'currency': 'myr',
      });

      // ... The rest of the function is the same ...
      final clientSecret = result.data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'ManagePaymentApp',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      await Provider.of<PaymentInfo>(context, listen: false)
          .updatePaymentStatus(widget.paymentId, 'complete');
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => const PaymentConfirmationScreen(isSuccess: true)
        ));
      }
    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled) {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (_) => const PaymentConfirmationScreen(isSuccess: false)
          ));
        }
      }
    } catch (e) {
      print("Payment failed with error: $e");
      if (mounted) {
         Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (_) => const PaymentConfirmationScreen(isSuccess: false)
          ));
      }
    } finally {
      if (mounted) {
        setState(() { _isPaying = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Final Confirmation')),
      body: FutureBuilder<ManagePayment?>(
        future: _paymentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Error: Payment not found.'));
          }
          final payment = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Please confirm your payment for:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                
                // --- FIX #1: The Card UI is now filled in ---
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(payment.paymentDescription, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text(
                          'Amount: \$${payment.paymentAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ---------------------------------------------
                
                const Spacer(),
                if (payment.paymentStatus == 'pending')
                  ElevatedButton.icon(
                    onPressed: _isPaying ? null : () => _handlePayNow(payment),
                    icon: _isPaying
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                        : const Icon(Icons.payment),
                    label: Text(_isPaying ? 'PROCESSING...' : 'Pay Now'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  Text('Status: ${payment.paymentStatus.toUpperCase()}', textAlign: TextAlign.center),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}