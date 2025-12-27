import 'package:flutter/material.dart';
import 'UI/pagemain.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// App Entry Point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

/// Root App Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      builder: (context, child) {
        return ForcedMobileView(child: child!);
      },
      home: const MyHomePage(),
    );
  }
}

/// Home Page (Firebase test runs once here)
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  /// Firebase Connection Test
  Future<void> _testFirebaseConnection() async {
    // Analytics test
    try {
      await analytics.logEvent(
        name: 'flutter_test_event',
        parameters: {'status': 'success'},
      );
      debugPrint('✅ Firebase Analytics connected');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }

    // Anonymous Authentication test
    try {
      final userCredential = await auth.signInAnonymously();
      debugPrint('✅ Firebase Auth UID: ${userCredential.user?.uid}');
    } catch (e) {
      debugPrint('❌ Auth error: $e');
    }

    // Firestore test write & read
    try {
      await firestore
          .collection('test_connection')
          .doc('status')
          .set({'connected': true});

      final snapshot =
          await firestore.collection('test_connection').doc('status').get();

      debugPrint('✅ Firestore data: ${snapshot.data()}');
    } catch (e) {
      debugPrint('❌ Firestore error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade200,
      body: pagemain(),
    );
  }
}

/// Forces Mobile UI Layout (Optional for Web)
class ForcedMobileView extends StatelessWidget {
  final Widget child;

  const ForcedMobileView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    const double mobileWidth = 450;
    const double mobileHeight = 900;

    final screenSize = MediaQuery.of(context).size;

    if (screenSize.width > mobileWidth || screenSize.height > mobileHeight) {
      return Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Zoom out browser to see full screen',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          const Text(
            'Web view is limited to mobile size',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          Center(
            child: Container(
              width: mobileWidth,
              height: mobileHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: const Size(mobileWidth, mobileHeight),
                ),
                child: child,
              ),
            ),
          ),
        ],
      );
    }

    return child;
  }
}
