import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';
import 'profile_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String? emailError;
  String? passwordError;
  String? generalError;

  Future<void> handleSignup() async {
    setState(() {
      loading = true;
      emailError = null;
      passwordError = null;
      generalError = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    // basic validation
    if (password.length < 6) {
      setState(() {
        passwordError = 'Password must be at least 6 characters';
        loading = false;
      });
      return;
    }

    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        emailError = 'Enter a valid email address';
        loading = false;
      });
      return;
    }

    try {
      final firestoreOk = await AuthState.signup(email, password, name);

      if (!mounted) return;

      // If Firestore write was denied, inform the user but still navigate
      if (!firestoreOk) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Profile not saved'),
            content: const Text(
                'Account created but Firestore write was denied (permission issue). Please check your Firestore rules.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    } on FirebaseAuthException catch (e) {
      // handle firebase auth specific errors
      if (e.code == 'email-already-in-use') {
        setState(() => emailError = 'This email is already in use');
      } else if (e.code == 'weak-password') {
        setState(() => passwordError = 'The password is too weak');
      } else if (e.code == 'invalid-email') {
        setState(() => emailError = 'Invalid email address');
      } else {
        setState(() => generalError = e.message ?? e.code);
      }
    } catch (e) {
      setState(() => generalError = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: emailError,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: passwordError,
              ),
            ),
            if (generalError != null) ...[
              const SizedBox(height: 12),
              Text(generalError!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : handleSignup,
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
