import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/secure_storage_service.dart';
import '../models/maintenance_model.dart';

class MaintenanceRepository {
  final SecureStorageService _storageService = SecureStorageService();

  Future<MaintenanceResponse> getBreakdowns({int page = 1}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.maintenanceBreakdownsEndpoint}?page=$page');
    final token = await _storageService.getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          return MaintenanceResponse.fromJson(responseBody);
        } else {
          throw Exception('Failed to load breakdowns.');
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<DropdownResponse> getDropdownData() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.maintenanceDropdownsEndpoint}');
    final token = await _storageService.getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          return DropdownResponse.fromJson(responseBody);
        } else {
          throw Exception('Failed to load dropdown data.');
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> reportBreakdown({
    required int lineId,
    required int machineId,
    required int problemId,
    required String breakdownStartTime,
    required String description,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.maintenanceBreakdownsEndpoint}');
    final token = await _storageService.getToken();

    try {
      final requestBody = jsonEncode({
        'line_id': lineId,
        'machine_id': machineId,
        'problem_id': problemId,
        'breakdown_start_time': breakdownStartTime,
        'description': description,
      });

      print('--- REPORT BREAKDOWN CALL ---');
      print('URL: $url');
      print('Body: $requestBody');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('---------------------------');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseBody['success'] == true) {
        return true;
      } else {
        String errorDesc = responseBody['message'] ?? 'Failed to report breakdown.';
        throw Exception(errorDesc);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
