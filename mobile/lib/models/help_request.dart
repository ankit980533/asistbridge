class HelpRequest {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String type;
  final String description;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String status;
  final String? assignedVolunteerId;
  final String? assignedVolunteerName;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final String? completionNotes;
  final int? rating;
  final String? feedback;
  final DateTime createdAt;

  HelpRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.type,
    required this.description,
    this.latitude,
    this.longitude,
    this.address,
    required this.status,
    this.assignedVolunteerId,
    this.assignedVolunteerName,
    this.assignedAt,
    this.completedAt,
    this.completionNotes,
    this.rating,
    this.feedback,
    required this.createdAt,
  });

  factory HelpRequest.fromJson(Map<String, dynamic> json) {
    return HelpRequest(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userPhone: json['userPhone'],
      type: json['type'],
      description: json['description'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
      status: json['status'],
      assignedVolunteerId: json['assignedVolunteerId'],
      assignedVolunteerName: json['assignedVolunteerName'],
      assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      completionNotes: json['completionNotes'],
      rating: json['rating'],
      feedback: json['feedback'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  bool get isPending => status == 'PENDING' || status == 'ADMIN_REVIEW';
  bool get isAssigned => status == 'ASSIGNED';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
}
