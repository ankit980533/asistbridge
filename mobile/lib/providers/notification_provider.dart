import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  
  Future<void> fetchNotifications() async {
    try {
      final response = await _api.get(ApiConstants.notifications);
      _notifications = (response.data['data'] as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
      _unreadCount = _notifications.where((n) => !n.read).length;
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }
  
  Future<void> markAsRead(String notificationId) async {
    try {
      await _api.put('${ApiConstants.notifications}/$notificationId/read');
      await fetchNotifications();
    } catch (e) {
      // Silent fail
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      await _api.put('${ApiConstants.notifications}/read-all');
      await fetchNotifications();
    } catch (e) {
      // Silent fail
    }
  }
}
