import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class FirebaseAuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final ApiService _api = ApiService();
  
  String? _verificationId;
  int? _resendToken;
  
  // Send OTP using Firebase
  Future<bool> sendOtp({
    required String phone,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function(fb.PhoneAuthCredential) onAutoVerify,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (fb.PhoneAuthCredential credential) {
          // Auto-verification (Android only)
          onAutoVerify(credential);
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent('OTP sent successfully');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
      return true;
    } catch (e) {
      onError(e.toString());
      return false;
    }
  }
  
  // Verify OTP and get Firebase token
  Future<String?> verifyOtp(String otp) async {
    if (_verificationId == null) {
      throw Exception('Please request OTP first');
    }
    
    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Get Firebase ID token to send to backend
      final idToken = await userCredential.user?.getIdToken();
      return idToken;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw Exception('Invalid OTP');
      }
      throw Exception(e.message ?? 'Verification failed');
    }
  }
  
  // Sign in with auto-verified credential
  Future<String?> signInWithCredential(fb.PhoneAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    return await userCredential.user?.getIdToken();
  }
  
  // Get current user phone
  String? get currentUserPhone => _auth.currentUser?.phoneNumber;
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
