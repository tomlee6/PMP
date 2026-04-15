import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';
import '../core/services/secure_storage_service.dart';
import '../data/models/profile_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final SecureStorageService _storageService = SecureStorageService();

  bool _isLoading = false;
  String _errorMessage = '';

  ProfileModel? _profileData;
  bool _isProfileLoading = false;
  String _profileError = '';
  
  bool _isPasswordChanging = false;
  String _passwordChangeError = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  ProfileModel? get profileData => _profileData;
  bool get isProfileLoading => _isProfileLoading;
  String get profileError => _profileError;

  bool get isPasswordChanging => _isPasswordChanging;
  String get passwordChangeError => _passwordChangeError;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _authRepository.login(email, password);
      
      if (response.success) {
        await _storageService.saveToken(response.data.token);
        
        final userDataJson = jsonEncode(response.data.toJson());
        await _storageService.saveUserData(userDataJson);
        
        print('--- Secure Storage Data Saved ---');
        print('Token: ${await _storageService.getToken()}');
        print('UserData: ${await _storageService.getUserData()}');
        print('---------------------------------');
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Login failed.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    _profileData = null;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    _isProfileLoading = true;
    _profileError = '';
    notifyListeners();

    try {
      _profileData = await _authRepository.fetchProfile();
    } catch (e) {
      _profileError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isPasswordChanging = true;
    _passwordChangeError = '';
    notifyListeners();

    try {
      final success = await _authRepository.changePassword(currentPassword, newPassword);
      _isPasswordChanging = false;
      notifyListeners();
      return success;
    } catch (e) {
      _passwordChangeError = e.toString().replaceAll('Exception: ', '');
      _isPasswordChanging = false;
      notifyListeners();
      return false;
    }
  }
}
