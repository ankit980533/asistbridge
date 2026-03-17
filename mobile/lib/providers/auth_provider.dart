import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _api.post(ApiConstants.sendOtp, data: {'phone': phone});
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to send OTP';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> verifyOtp(String phone, String otp, {String? name, String? role, String? fcmToken}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _api.post(ApiConstants.verifyOtp, data: {
        'phone': phone,
        'otp': otp,
        'name': name,
        'role': role,
        'fcmToken': fcmToken,
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
      return true;
    } catch (e) {
      _error = 'Invalid OTP';
      _isLoading = false;
      notifyListeners();
      return false;
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
      // Clear token on any error (timeout, network, auth failure)
      await _api.clearToken();
      return false;
    }
  }
  
  Future<void> logout() async {
    await _api.clearToken();
    _user = null;
    notifyListeners();
  }
  
  Future<void> updateLocation(double lat, double lng) async {
    try {
      await _api.put('${ApiConstants.updateLocation}?latitude=$lat&longitude=$lng');
    } catch (e) {
      // Silent fail
    }
  }
}
