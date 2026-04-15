import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/secure_storage_service.dart';
import '../models/login_response_model.dart';
import '../models/profile_model.dart';

class AuthRepository {
  final SecureStorageService _storageService = SecureStorageService();
  Future<LoginResponseModel> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        print('--- API Response ---');
        print(jsonEncode(responseBody));
        print('--------------------');
        return LoginResponseModel.fromJson(responseBody);
      } else {
        // Handle specific API errors
        String errorDesc = responseBody['Description'] ?? 'Login failed. Please try again.';
        throw Exception(errorDesc);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<ProfileModel> fetchProfile() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profileEndpoint}');
    final token = await _storageService.getToken();
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        return ProfileModel.fromJson(responseBody);
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.changePasswordEndpoint}');
    final token = await _storageService.getToken();
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        return true;
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
