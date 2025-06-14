import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Import the other screens so we can navigate to them
import 'ViewPayment.dart';
import 'MakePayment.dart';
import 'EditPayment.dart';

import '../../domains/PaymentInfo.dart';
import '../../Repositories/PaymentInfo.dart';


class PaymentList extends StatelessWidget {
  const PaymentList({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentInfoRepository = Provider.of<PaymentInfo>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
  appBar: AppBar(
    title: const Text('My Payments'),
  ),
  // ------------------ THIS IS THE UPDATED SECTION ------------------
  floatingActionButton: FloatingActionButton(
    onPressed: () {
      // This now simply opens the form screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditPaymentScreen()),
      );
    },
    child: const Icon(Icons.add),
  ),
  // ------------------ END OF UPDATED SECTION ------------------
  body: Center(
    child: currentUser == null
        ? const Text('Please sign in to see your payments.')
        : StreamBuilder<List<ManagePayment>>(
            stream: paymentInfoRepository.getUserPayments(currentUser.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('You have no payments. Tap + to add one.');
              }

              final payments = snapshot.data!;

              return ListView.builder(
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return ListTile(
                    title: Text(payment.paymentDescription),
                    subtitle: Text('Status: ${payment.paymentStatus}'),
                    trailing: Text('\$${payment.paymentAmount.toStringAsFixed(2)}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewPaymentScreen(paymentId: payment.paymentId),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
  ),
);
  }
}