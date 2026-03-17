class User {
  final String id;
  final String name;
  final String phone;
  final String role;
  final String? email;
  final String? fcmToken;
  final double? latitude;
  final double? longitude;
  final bool active;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.fcmToken,
    this.latitude,
    this.longitude,
    this.active = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
      email: json['email'],
      fcmToken: json['fcmToken'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      active: json['active'] ?? true,
    );
  }

  bool get isVisuallyImpaired => role == 'VISUALLY_IMPAIRED';
  bool get isVolunteer => role == 'VOLUNTEER';
  bool get isAdmin => role == 'ADMIN';
}
