import 'login_response_model.dart';

class ProfileModel {
  final bool success;
  final ProfileData data;

  ProfileModel({required this.success, required this.data});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      success: json['success'] ?? false,
      data: ProfileData.fromJson(json['data'] ?? {}),
    );
  }
}

class ProfileData {
  final int id;
  final String email;
  final String fullName;
  final String department;
  final int isActive;
  final List<Role> roles;
  final Permissions permissions;

  ProfileData({
    required this.id,
    required this.email,
    required this.fullName,
    required this.department,
    required this.isActive,
    required this.roles,
    required this.permissions,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    var rolesList = json['roles'] as List? ?? [];
    List<Role> parsedRoles = rolesList.map((i) => Role.fromJson(i)).toList();

    return ProfileData(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      department: json['department'] ?? '',
      isActive: json['is_active'] ?? 0,
      roles: parsedRoles,
      permissions: Permissions.fromJson(json['permissions'] ?? {}),
    );
  }
}
