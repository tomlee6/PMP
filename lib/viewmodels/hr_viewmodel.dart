import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/hr_request_model.dart';
import '../data/repositories/hr_repository.dart';

class HrViewModel extends ChangeNotifier {
  final HrRepository _repository = HrRepository();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  List<HrRequestModel> _requests = [];
  
  int _currentPage = 1;
  bool _hasMore = true;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get errorMessage => _errorMessage;
  List<HrRequestModel> get requests => _requests;
  bool get hasMore => _hasMore;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;
  String _submitErrorMessage = '';
  String get submitErrorMessage => _submitErrorMessage;

  Future<void> fetchHrRequests({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _isLoading = true;
      _requests.clear();
      notifyListeners();
    } else {
      if (!_hasMore || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      // In a real API we would pass _currentPage down to repository.
      // E.g., await _repository.getHrRequests(page: _currentPage);
      final response = await _repository.getHrRequests();
      
      // We append data based on API response
      // For this implementation assuming response.data gives the list for current page
      _requests.addAll(response.data);
      
      // Update pagination logic
      // if (response.pagination != null) {
      //    _hasMore = _requests.length < response.pagination!.total;
      // } else {
      //    _hasMore = response.data.isNotEmpty;
      // }
      _hasMore = false; // Setting false for now or until API pagination is passed correctly
      
    } catch (e) {
      // Fallback
      if (refresh) {
        _requests = [
          HrRequestModel(id: 47, ticketNumber: 'HR-0047', requesterName: 'Anitha R.', customerName: 'Mr. John Smith', remarks: 'VIP guest from US headquarters', itemsText: 'Food & Snacks', status: 'PENDING'),
          HrRequestModel(id: 46, ticketNumber: 'HR-0046', requesterName: 'Priya K.', customerName: 'Ms. Sarah Lee', remarks: 'Client meeting - premium quality required', itemsText: 'Beverages & Snacks', status: 'APPROVED'),
          HrRequestModel(id: 45, ticketNumber: 'HR-0045', requesterName: 'Rajesh K.', customerName: 'Mr. Tanaka', remarks: 'Japan team quarterly review visit', itemsText: 'Lunch + Vehicle', status: 'CLOSED'),
        ];
        _hasMore = true; 
      } else {
        // Appending more dummy data
        _requests.addAll([
          HrRequestModel(id: 44, ticketNumber: 'HR-0044', requesterName: 'Anitha R.', customerName: 'Local Guests', remarks: 'Normal meeting', itemsText: 'Tea', status: 'CLOSED'),
        ]);
        _hasMore = false; // Stop after 1 extra page of dummy data
      }
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (refresh) {
        _isLoading = false;
      } else {
        _isLoadingMore = false;
        _currentPage++;
      }
      notifyListeners();
    }
  }

  Future<bool> createHrRequest({
    required String customerName,
    required String visitDate,
    required String remarks,
    required String itemsText,
    required int purposeId,
  }) async {
    _isSubmitting = true;
    _submitErrorMessage = '';
    notifyListeners();

    try {
      final response = await _repository.createHrRequest(
        customerName: customerName,
        visitDate: visitDate,
        purposeId: purposeId,
        remarks: remarks,
        itemsText: itemsText,
      );

      _isSubmitting = false;
      if (response.success) {
        // Optimistically reload list or add to list, for now reload
        await fetchHrRequests(refresh: true);
        return true;
      }
      return false;
    } catch (e) {
      _submitErrorMessage = e.toString().replaceAll('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;
  HrRequestModel? _selectedRequest;
  HrRequestModel? get selectedRequest => _selectedRequest;

  // We can pass fallback model from navigation if API fails or while loading
  void setSelectedRequestFallback(HrRequestModel? model) {
    _selectedRequest = model;
    notifyListeners();
  }

  Future<void> fetchHrRequestDetail(int id) async {
    _isLoadingDetail = true;
    _errorMessage = '';
    // Only clear if the new id doesn't match the current request id
    if (_selectedRequest?.id != id) {
      _selectedRequest = null;
    }
    notifyListeners();

    try {
      final response = await _repository.getHrRequestDetail(id);
      _selectedRequest = response;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      // If we already set fallback, we can keep it. Otherwise we will show error.
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<bool> approveRequest(int id, String comments) async {
    _isSubmitting = true;
    _submitErrorMessage = '';
    notifyListeners();

    try {
      final success = await _repository.approveHrRequest(id, comments);
      _isSubmitting = false;
      if (success) {
        await fetchHrRequests(refresh: true);
      }
      notifyListeners();
      return success;
    } catch (e) {
      _submitErrorMessage = e.toString().replaceAll('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectRequest(int id, String comments) async {
    _isSubmitting = true;
    _submitErrorMessage = '';
    notifyListeners();

    try {
      final success = await _repository.rejectHrRequest(id, comments);
      _isSubmitting = false;
      if (success) {
        await fetchHrRequests(refresh: true);
      }
      notifyListeners();
      return success;
    } catch (e) {
      _submitErrorMessage = e.toString().replaceAll('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> closeTicket(int id, String actualAmount, XFile? bill) async {
    _isSubmitting = true;
    _submitErrorMessage = '';
    notifyListeners();

    try {
      final success = await _repository.closeHrTicket(id, actualAmount, bill);
      _isSubmitting = false;
      if (success) {
        await fetchHrRequests(refresh: true);
      } else {
        _submitErrorMessage = 'Failed to close ticket';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _submitErrorMessage = e.toString().replaceAll('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
