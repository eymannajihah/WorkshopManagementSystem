import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domains/PaymentInfo.dart';
import '../../Repositories/PaymentInfo.dart';
import 'package:intl/intl.dart'; // We'll use this for date formatting

import 'MakePayment.dart';
import 'EditPayment.dart';

class ViewPaymentScreen extends StatefulWidget {
  final String paymentId;
  const ViewPaymentScreen({super.key, required this.paymentId});

  @override
  State<ViewPaymentScreen> createState() => _ViewPaymentScreenState();
}

class _ViewPaymentScreenState extends State<ViewPaymentScreen> {
  Future<ManagePayment?>? _paymentFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_paymentFuture == null) {
      final paymentInfoRepository = Provider.of<PaymentInfo>(context);
      _paymentFuture = paymentInfoRepository.getPaymentById(widget.paymentId);
    }
  }

  // This function is called when returning from the Edit screen to refresh the data
  void _refreshPaymentDetails() {
    final paymentInfoRepository = Provider.of<PaymentInfo>(context, listen: false);
    setState(() {
      _paymentFuture = paymentInfoRepository.getPaymentById(widget.paymentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // We use a FutureBuilder to handle the different states of fetching data
    return FutureBuilder<ManagePayment?>(
      future: _paymentFuture,
      builder: (context, snapshot) {
        // STATE 1: Still loading data from Firestore
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // STATE 2: An error occurred or the payment was not found
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Error: Payment not found.')),
          );
        }

        // STATE 3: Success! We have the payment data.
        final payment = snapshot.data!;

        // Now we build the full screen using the 'payment' data
        return Scaffold(
          appBar: AppBar(
            title: const Text('Payment Details'),
            // --- The "Edit" button is now here in the AppBar ---
            actions: [
              // Only show the Edit button if the payment is 'pending'
              if (payment.paymentStatus == 'pending')
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to Edit screen and refresh when we come back
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditPaymentScreen(paymentId: payment.paymentId),
                      ),
                    ).then((_) => _refreshPaymentDetails());
                  },
                ),
            ],
          ),
          // The body contains all the visual details
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Payment Description
                Text(
                  payment.paymentDescription,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),

                // Detail Rows
                _buildDetailRow('Amount', '\$${payment.paymentAmount.toStringAsFixed(2)}'),
                const Divider(),
                _buildDetailRow('Status', payment.paymentStatus.toUpperCase()),
                const Divider(),
                if (payment.paymentDate != null)
                  _buildDetailRow('Date', DateFormat.yMMMd().add_jms().format(payment.paymentDate!)),
                if (payment.paymentDate != null) const Divider(),
                _buildDetailRow('Transaction ID', payment.paymentId),

                // The Spacer pushes the button to the bottom
                const Spacer(),

                // The "Proceed" button
                if (payment.paymentStatus == 'pending')
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MakePaymentScreen(paymentId: payment.paymentId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Proceed to Payment'),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper widget to build consistently styled rows
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}