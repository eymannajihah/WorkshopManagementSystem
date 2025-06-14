// lib/pages/Payment/EditPayment.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Repositories/PaymentInfo.dart';
import 'MakePayment.dart';

class EditPaymentScreen extends StatefulWidget {
  // paymentId is now optional. If it's null, we are creating. If it has a value, we are editing.
  final String? paymentId;
  const EditPaymentScreen({super.key, this.paymentId});

  @override
  State<EditPaymentScreen> createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  bool get _isEditing => widget.paymentId != null;

  @override
  void initState() {
    super.initState();
    // If we are in "Edit Mode", fetch the existing payment data
    if (_isEditing) {
      _loadPaymentData();
    }
  }

  Future<void> _loadPaymentData() async {
    final paymentInfoRepository = Provider.of<PaymentInfo>(context, listen: false);
    final payment = await paymentInfoRepository.getPaymentById(widget.paymentId!);
    if (payment != null) {
      _descriptionController.text = payment.paymentDescription;
      _amountController.text = payment.paymentAmount.toString();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final description = _descriptionController.text;

      if (_isEditing) {
        // --- UPDATE LOGIC ---
        await Provider.of<PaymentInfo>(context, listen: false).updatePaymentDetails(
          widget.paymentId!,
          description: description,
          amount: amount,
        );
        if (mounted) {
          // Go back to the previous screen after editing
          Navigator.pop(context);
        }
      } else {
        // --- CREATE LOGIC ---
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          setState(() { _isLoading = false; });
          return;
        }
        final newPaymentId = await Provider.of<PaymentInfo>(context, listen: false)
            .createPendingPayment(
          amount: amount,
          description: description,
          userId: currentUser.uid,
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MakePaymentScreen(paymentId: newPaymentId),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title changes depending on the mode
        title: Text(_isEditing ? 'Edit Payment' : 'Create New Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Payment Description'),
                validator: (v) => v!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => (double.tryParse(v!) == null) ? 'Please enter a valid number' : null,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEditing ? 'SAVE CHANGES' : 'SAVE AND PROCEED'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}