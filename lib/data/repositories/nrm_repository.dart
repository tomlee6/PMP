import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/secure_storage_service.dart';
import '../models/nrm_request_model.dart';

class NrmRepository {
  final SecureStorageService _storageService = SecureStorageService();

  Future<NrmRequestResponse> getNrmRequests({int page = 1}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.nrmRequestsEndpoint}?page=$page');
    final token = await _storageService.getToken();

    try {
      print('--- GET NRM REQUESTS ---');
      print('URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('------------------------');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          return NrmRequestResponse.fromJson(responseBody);
        } else {
          throw Exception('Failed to load NRM requests.');
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<NrmSingleRequestResponse> createNrmRequest({
    required int departmentId,
    required String purpose,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.nrmRequestsEndpoint}');
    final token = await _storageService.getToken();

    try {
      final requestBody = jsonEncode({
        'department_id': departmentId,
        'purpose': purpose,
        'items': items,
      });
      
      print('--- POST REQUEST TO NRM ---');
      print('URL: $url');
      print('Body: $requestBody');
      print('---------------------------');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      print('--- NRM REQUEST API RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('-------------------------------');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      
      if ((response.statusCode == 200 || response.statusCode == 201) && responseBody['success'] == true) {
        return NrmSingleRequestResponse.fromJson(responseBody);
      } else {
        String errorDesc = responseBody['message'] ?? 'Failed to submit NRM request.';
        throw Exception(errorDesc);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<NrmRequestModel> getNrmRequestDetail(int id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.nrmRequestsEndpoint}/$id');
    final token = await _storageService.getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('--- NRM REQUEST DETAIL ---');
      print('URL: $url');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          return NrmRequestModel.fromJson(responseBody['data']);
        } else {
          throw Exception('Failed to load NRM request detail.');
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> approveNrmRequest(int id, String comments) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.nrmRequestsEndpoint}/$id/approve');
    return _sendAction(url, comments);
  }

  Future<bool> rejectNrmRequest(int id, String comments) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.nrmRequestsEndpoint}/$id/reject');
    return _sendAction(url, comments);
  }

  Future<bool> issueNrmRequest(int id, String comments) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.nrmRequestsEndpoint}/$id/issue');
    return _sendAction(url, comments);
  }

  Future<bool> cancelNrmRequest(int id, String comments) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.nrmRequestsEndpoint}/$id/cancel');
    return _sendAction(url, comments);
  }

  Future<bool> _sendAction(Uri url, String comments) async {
    final token = await _storageService.getToken();
    try {
      final requestBody = jsonEncode({'comments': comments});
      print('--- NRM ACTION API ---');
      print('URL: $url');
      print('Body: $requestBody');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          return true;
        } else {
          throw Exception(responseBody['message'] ?? 'Action failed.');
        }
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print('HTTP error: $e');
      throw Exception(e.toString());
    }
  }
}
