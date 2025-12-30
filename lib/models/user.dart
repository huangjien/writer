/// User model representing a user in the system
class User {
  final String id;
  final String? email;
  final bool isApproved;
  final bool isAdmin;

  User({
    required this.id,
    this.email,
    this.isApproved = false,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      isApproved: json['is_approved'] ?? false,
      isAdmin: json['is_admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'is_approved': isApproved,
      'is_admin': isAdmin,
    };
  }

  User copyWith({String? id, String? email, bool? isApproved, bool? isAdmin}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      isApproved: isApproved ?? this.isApproved,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
