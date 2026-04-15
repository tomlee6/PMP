import 'dart:convert';

class LoginResponseModel {
  final bool success;
  final LoginData data;

  LoginResponseModel({required this.success, required this.data});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      data: LoginData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class LoginData {
  final String token;
  final User user;
  final List<Role> roles;
  final Permissions permissions;

  LoginData({
    required this.token,
    required this.user,
    required this.roles,
    required this.permissions,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    var rolesList = json['roles'] as List? ?? [];
    List<Role> parsedRoles = rolesList.map((i) => Role.fromJson(i)).toList();

    return LoginData(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      roles: parsedRoles,
      permissions: Permissions.fromJson(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'roles': roles.map((e) => e.toJson()).toList(),
      'permissions': permissions.toJson(),
    };
  }
}

class User {
  final int id;
  final String email;
  final String fullName;
  final String department;
  final int isFirstLogin;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.department,
    required this.isFirstLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      department: json['department'] ?? '',
      isFirstLogin: json['is_first_login'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'department': department,
      'is_first_login': isFirstLogin,
    };
  }
}

class Role {
  final int id;
  final String roleName;
  final String roleCode;

  Role({required this.id, required this.roleName, required this.roleCode});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? 0,
      roleName: json['role_name'] ?? '',
      roleCode: json['role_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_name': roleName,
      'role_code': roleCode,
    };
  }
}

class Permissions {
  final bool mobileAccess;
  final bool webAdminAccess;
  final bool webSettingsAccess;
  final bool hrRequest;
  final bool hrApprove;
  final bool hrExecute;
  final bool nrmRequest;
  final bool nrmApprove;
  final bool nrmExecute;
  final bool mntRequest;
  final bool mntApprove;
  final bool mntExecute;
  final bool canViewHrDashboard;
  final bool canViewNrmDashboard;
  final bool canViewMntDashboard;
  final bool settingsView;
  final bool settingsUpload;

  Permissions({
    required this.mobileAccess,
    required this.webAdminAccess,
    required this.webSettingsAccess,
    required this.hrRequest,
    required this.hrApprove,
    required this.hrExecute,
    required this.nrmRequest,
    required this.nrmApprove,
    required this.nrmExecute,
    required this.mntRequest,
    required this.mntApprove,
    required this.mntExecute,
    required this.canViewHrDashboard,
    required this.canViewNrmDashboard,
    required this.canViewMntDashboard,
    required this.settingsView,
    required this.settingsUpload,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) {
    return Permissions(
      mobileAccess: json['mobile_access'] ?? false,
      webAdminAccess: json['web_admin_access'] ?? false,
      webSettingsAccess: json['web_settings_access'] ?? false,
      hrRequest: json['hr_request'] ?? false,
      hrApprove: json['hr_approve'] ?? false,
      hrExecute: json['hr_execute'] ?? false,
      nrmRequest: json['nrm_request'] ?? false,
      nrmApprove: json['nrm_approve'] ?? false,
      nrmExecute: json['nrm_execute'] ?? false,
      mntRequest: json['mnt_request'] ?? false,
      mntApprove: json['mnt_approve'] ?? false,
      mntExecute: json['mnt_execute'] ?? false,
      canViewHrDashboard: json['can_view_hr_dashboard'] ?? false,
      canViewNrmDashboard: json['can_view_nrm_dashboard'] ?? false,
      canViewMntDashboard: json['can_view_mnt_dashboard'] ?? false,
      settingsView: json['settings_view'] ?? false,
      settingsUpload: json['settings_upload'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobile_access': mobileAccess,
      'web_admin_access': webAdminAccess,
      'web_settings_access': webSettingsAccess,
      'hr_request': hrRequest,
      'hr_approve': hrApprove,
      'hr_execute': hrExecute,
      'nrm_request': nrmRequest,
      'nrm_approve': nrmApprove,
      'nrm_execute': nrmExecute,
      'mnt_request': mntRequest,
      'mnt_approve': mntApprove,
      'mnt_execute': mntExecute,
      'can_view_hr_dashboard': canViewHrDashboard,
      'can_view_nrm_dashboard': canViewNrmDashboard,
      'can_view_mnt_dashboard': canViewMntDashboard,
      'settings_view': settingsView,
      'settings_upload': settingsUpload,
    };
  }
}
