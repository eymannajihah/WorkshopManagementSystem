// lib/pages/Payment/PaymentConfirmation.dart
import 'package:flutter/material.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final bool isSuccess;
  const PaymentConfirmationScreen({super.key, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess ? 'Payment Successful!' : 'Payment Failed',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isSuccess
                    ? 'Your transaction has been completed.'
                    : 'There was an issue with your payment. Please try again.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to the very first screen (PaymentList)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('DONE'),
              )
            ],
          ),
        ),
      ),
    );
  }
}