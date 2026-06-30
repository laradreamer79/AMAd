import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main_screen.dart';
import 'login_otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _demoUsername = 'lara';
  static const _demoPassword = '123456';
  static const _useFirebaseOtp = false;

  // Replace this with your real saved phone number, for example +9665XXXXXXXX.
  static const _savedPhoneNumber = '+966543889380';

  final _usernameController = TextEditingController(text: _demoUsername);
  final _passwordController = TextEditingController(text: _demoPassword);
  bool _isSendingOtp = false;
  Timer? _sendOtpTimer;

  @override
  void dispose() {
    _sendOtpTimer?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _stopSendingOtp() {
    _sendOtpTimer?.cancel();
    _sendOtpTimer = null;
    if (mounted) {
      setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username != _demoUsername || password != _demoPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
      return;
    }

    if (!_useFirebaseOtp) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginOtpScreen(
            phoneNumber: _savedPhoneNumber,
            verificationId: LoginOtpScreen.demoVerificationId,
          ),
        ),
      );
      return;
    }

    if (_savedPhoneNumber.contains('X')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Replace the saved phone number in login_screen.dart.'),
        ),
      );
      return;
    }

    setState(() => _isSendingOtp = true);

    _sendOtpTimer = Timer(const Duration(seconds: 30), () {
      if (!mounted || !_isSendingOtp) return;
      _stopSendingOtp();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP request timed out. Check Firebase iOS setup.'),
        ),
      );
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _savedPhoneNumber,
        timeout: const Duration(seconds: 30),
        verificationCompleted: (credential) async {
          _stopSendingOtp();
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
        },
        verificationFailed: (error) {
          _stopSendingOtp();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'OTP could not be sent')),
          );
        },
        codeSent: (verificationId, resendToken) {
          _stopSendingOtp();
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LoginOtpScreen(
                phoneNumber: _savedPhoneNumber,
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) => _stopSendingOtp(),
      );
    } on FirebaseAuthException catch (error) {
      _stopSendingOtp();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'OTP could not be sent')),
      );
    } catch (error) {
      _stopSendingOtp();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OTP error: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A241A),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Color(0xFFD6A94A),
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Welcome to Ameen',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Log in with your username and password to continue.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Demo user: lara / 123456.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSendingOtp ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6A94A),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isSendingOtp ? 'Sending OTP...' : 'Log in',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
