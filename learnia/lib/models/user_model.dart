class UserModel {
  final int id;
  final String email;
  final String username;
  final String? fullName;
  final String? gradeLevel;
  final String? school;
  final String? phone;
  final bool isActive;
  final bool isTeacher;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;
  final String? birthDate;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.gradeLevel,
    this.school,
    this.phone,
    this.isActive = true,
    this.isTeacher = false,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
    this.birthDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'],
      gradeLevel: json['grade_level'],
      school: json['school'],
      phone: json['phone'],
      isActive: json['is_active'] ?? true,
      isTeacher: json['is_teacher'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      birthDate: json['birth_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'grade_level': gradeLevel,
      'school': school,
      'phone': phone,
      'is_active': isActive,
      'is_teacher': isTeacher,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'birth_date': birthDate,
    };
  }
} 