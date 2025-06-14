import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Adjust this import path to where your repository is located
import 'Repositories/PaymentInfo.dart';

// Adjust this import path to where your PaymentList screen is located
import 'pages/Payment/PaymentList.dart';


void main() async {
  // Standard Flutter & Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Stripe.publishableKey = 'pk_test_51RZTlhELyXHhdRCoPA5COMaHxcQ338EyeIUJuzJHl295KrgoUJHs53c6ZXXzYiQnDsJobMSTswu9hD1sjfq2MtJO006AIYDNoo'; // Replace with your key
  await Stripe.instance.applySettings();

  // Sign in anonymously for testing purposes
  await FirebaseAuth.instance.signInAnonymously();

  // THIS IS THE CRUCIAL PART
  runApp(
    // You are providing the PaymentInfo instance here...
    Provider<PaymentInfo>(
      create: (_) => PaymentInfo(),
      // ...so that the child (MyApp) and all its descendants can access it.
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // The PaymentList widget is a descendant, so it can find the provider.
      home: const PaymentList(),
    );
  }
}