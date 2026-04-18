import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/secure_storage_service.dart';
import 'dart:io';
import '../models/hr_request_model.dart';
class HrRepository {
  final SecureStorageService _storageService = SecureStorageService();

  Future<HrRequestResponse> getHrRequests() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.hrRequestsEndpoint}');
    final token = await _storageService.getToken();

    try {
      print('--- GET HR REQUESTS ---');
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
      print('-----------------------');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          return HrRequestResponse.fromJson(responseBody);
        } else {
          throw Exception('Failed to load HR requests.');
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<HrSingleRequestResponse> createHrRequest({
    required String customerName,
    required String visitDate,
    required String remarks,
    required String itemsText,
    required int purposeId,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.hrRequestsEndpoint}');
    final token = await _storageService.getToken();

    try {
      final requestBody = jsonEncode({
        'customer_name': customerName,
        'visit_date': visitDate,
        'purpose_id': purposeId,
        'remarks': remarks,
        'items_text': itemsText,
      });

      print('--- HR REQUEST API CALL ---');
      print('URL: $url');
      print('Payload: $requestBody');
      print('---------------------------');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      print('--- HR REQUEST API RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('-------------------------------');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      
      if ((response.statusCode == 200 || response.statusCode == 201) && responseBody['success'] == true) {
        return HrSingleRequestResponse.fromJson(responseBody);
      } else {
        String errorDesc = responseBody['message'] ?? 'Failed to submit request.';
        throw Exception(errorDesc);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<HrRequestModel> getHrRequestDetail(int id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.hrRequestsEndpoint}/$id');
    final token = await _storageService.getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('--- HR REQUEST DETAIL ---');
      print('URL: $url');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          return HrRequestModel.fromJson(responseBody['data']);
        } else {
          throw Exception('Failed to load HR request detail.');
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> approveHrRequest(int id, String comments) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.hrRequestsEndpoint}/$id/approve');
    return _sendAction(url, comments);
  }

  Future<bool> rejectHrRequest(int id, String comments) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.hrRequestsEndpoint}/$id/reject');
    return _sendAction(url, comments);
  }

  Future<bool> _sendAction(Uri url, String comments) async {
    final token = await _storageService.getToken();
    try {
      final requestBody = jsonEncode({'comments': comments});
      print('--- HR ACTION API ---');
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

  Future<bool> closeHrTicket(int id, String actualAmount, XFile? bill) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.hrRequestsEndpoint}/$id/close');
    final token = await _storageService.getToken();

    try {
      print('--- HR TICKET CLOSE API ---');
      print('URL: $url');
      print('actual_amount: $actualAmount');

      var request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['actual_amount'] = actualAmount;

      if (bill != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'bill',
            await bill.readAsBytes(),
            filename: bill.name,
          ),
        );
        print('Bill attached: ${bill.name}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return responseBody['success'] == true;
      }
      return false;
    } catch (e) {
      print('HTTP error during close ticket: $e');
      return false;
    }
  }
}
