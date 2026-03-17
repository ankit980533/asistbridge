import 'package:flutter/material.dart';
import '../models/help_request.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class RequestProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<HelpRequest> _requests = [];
  bool _isLoading = false;
  String? _error;
  
  List<HelpRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<HelpRequest> get activeRequests => 
      _requests.where((r) => r.isPending || r.isAssigned || r.isInProgress).toList();
  
  List<HelpRequest> get completedRequests => 
      _requests.where((r) => r.isCompleted).toList();
  
  Future<void> fetchUserRequests() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _api.get(ApiConstants.requests);
      _requests = (response.data['data'] as List)
          .map((json) => HelpRequest.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch requests';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> fetchVolunteerRequests() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _api.get(ApiConstants.volunteerRequests);
      _requests = (response.data['data'] as List)
          .map((json) => HelpRequest.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch requests';
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createRequest({
    required String type,
    required String description,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _api.post(ApiConstants.requests, data: {
        'type': type,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      });
      await fetchUserRequests();
      return true;
    } catch (e) {
      _error = 'Failed to create request';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> cancelRequest(String requestId) async {
    try {
      await _api.put('${ApiConstants.requests}/$requestId/cancel');
      await fetchUserRequests();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> acceptRequest(String requestId) async {
    try {
      await _api.put('${ApiConstants.volunteerRequests}/$requestId/accept');
      await fetchVolunteerRequests();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> completeRequest(String requestId, {String? notes}) async {
    try {
      await _api.put('${ApiConstants.volunteerRequests}/$requestId/complete', 
          data: notes != null ? {'notes': notes} : null);
      await fetchVolunteerRequests();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> rateRequest(String requestId, int rating, {String? feedback}) async {
    try {
      await _api.post('${ApiConstants.requests}/$requestId/rate', data: {
        'rating': rating,
        'feedback': feedback,
      });
      await fetchUserRequests();
      return true;
    } catch (e) {
      return false;
    }
  }
}
