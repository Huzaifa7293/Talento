class TalentoUser {
  final String id;
  final String fullName;
  final String username;
  final String phone;
  final String email;
  final bool notification;

  TalentoUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.phone,
    required this.email,
    required this.notification,
  });

  factory TalentoUser.fromJson(Map<String, dynamic> json) {
    return TalentoUser(
      id: json['id'],
      fullName: json['fullName'],
      username: json['username'],
      phone: json['phone'],
      email: json['email'],
      notification: json['notification'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'phone': phone,
      'email': email,
      'notification': notification,
    };
  }

  TalentoUser copyWith({
    String? id,
    String? fullName,
    String? username,
    String? phone,
    String? email,
    bool? notification,
  }) {
    return TalentoUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notification: notification ?? this.notification,
    );
  }
}
