import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/accessibility_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _otpSent = false;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get otpSent => _otpSent;
  
  // Send OTP via Firebase (FREE!)
  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    _error = null;
    _otpSent = false;
    notifyListeners();
    
    final completer = Completer<bool>();
    
    await _firebaseAuth.sendOtp(
      phone: phone,
      onCodeSent: (message) {
        _otpSent = true;
        _isLoading = false;
        notifyListeners();
        completer.complete(true);
      },
      onError: (error) {
        _error = error;
        _isLoading = false;
        notifyListeners();
        completer.complete(false);
      },
      onAutoVerify: (credential) async {
        // Auto-verified on Android
        await _signInWithCredential(credential, phone);
        completer.complete(true);
      },
    );
    
    return completer.future;
  }
  
  // Verify OTP
  Future<bool> verifyOtp(String phone, String otp, {String? name, String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Verify with Firebase
      final firebaseToken = await _firebaseAuth.verifyOtp(otp);
      
      if (firebaseToken == null) {
        throw Exception('Failed to get Firebase token');
      }
      
      // Send Firebase token to our backend to create/login user
      final response = await _api.post(ApiConstants.verifyOtp, data: {
        'phone': phone,
        'firebaseToken': firebaseToken,
        'name': name,
        'role': role,
      });
      
      final data = response.data['data'];
      await _api.setToken(data['token']);
      _user = User(
        id: data['userId'],
        name: data['name'],
        phone: data['phone'],
        role: data['role'],
      );
      
      _isLoading = false;
      _otpSent = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> _signInWithCredential(fb.PhoneAuthCredential credential, String phone) async {
    try {
      final firebaseToken = await _firebaseAuth.signInWithCredential(credential);
      
      final response = await _api.post(ApiConstants.verifyOtp, data: {
        'phone': phone,
        'firebaseToken': firebaseToken,
      });
      
      final data = response.data['data'];
      await _api.setToken(data['token']);
      _user = User(
        id: data['userId'],
        name: data['name'],
        phone: data['phone'],
        role: data['role'],
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkAuth() async {
    final token = await _api.getToken();
    if (token == null) return false;
    
    try {
      final response = await _api.get(ApiConstants.currentUser)
          .timeout(const Duration(seconds: 5));
      _user = User.fromJson(response.data['data']);
      notifyListeners();
      return true;
    } catch (e) {
      await _api.clearToken();
      return false;
    }
  }
  
  Future<void> logout() async {
    await _api.clearToken();
    await _firebaseAuth.signOut();
    _user = null;
    // Re-enable TTS role flag so login screen is accessible for next user
    AccessibilityService().setRoleEnabled(true);
    notifyListeners();
  }
  
  Future<void> updateLocation(double lat, double lng) async {
    try {
      await _api.put('${ApiConstants.updateLocation}?latitude=$lat&longitude=$lng');
    } catch (e) {
      // Silent fail
    }
  }

  /// Switch between VOLUNTEER and VISUALLY_IMPAIRED roles.
  /// Returns true on success. Updates token, user, and TTS state.
  Future<bool> switchRole() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.put(ApiConstants.switchRole);
      final data = response.data['data'];

      await _api.setToken(data['token']);
      _user = User(
        id: data['userId'],
        name: data['name'],
        phone: data['phone'],
        role: data['role'],
      );

      // Update TTS: enabled for visually impaired, disabled for volunteer
      AccessibilityService().setRoleEnabled(_user!.isVisuallyImpaired);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
