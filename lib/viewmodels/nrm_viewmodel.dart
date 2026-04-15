import 'package:flutter/material.dart';
import '../data/models/nrm_request_model.dart';
import '../data/repositories/nrm_repository.dart';

class NrmViewModel extends ChangeNotifier {
  final NrmRepository _repository = NrmRepository();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  List<NrmRequestModel> _requests = [];
  
  int _currentPage = 1;
  bool _hasMore = true;
  String _currentFilter = 'All'; // All, Pending, Approved, Closed

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get errorMessage => _errorMessage;
  List<NrmRequestModel> get requests => _requests;
  bool get hasMore => _hasMore;
  String get currentFilter => _currentFilter;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;
  String _submitErrorMessage = '';
  String get submitErrorMessage => _submitErrorMessage;

  void setFilter(String filter) {
    _currentFilter = filter;
    fetchNrmRequests(refresh: true);
  }

  Future<void> fetchNrmRequests({bool refresh = false}) async {
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
      final response = await _repository.getNrmRequests(page: _currentPage);
      
      var newItems = response.data;
      
      // Local filtering if API does not support filter query parameter yet
      if (_currentFilter != 'All') {
        newItems = newItems.where((element) => element.status.toLowerCase() == _currentFilter.toLowerCase()).toList();
      }

      _requests.addAll(newItems);
      
      if (response.pagination != null) {
         _hasMore = _requests.length < response.pagination!.total;
      } else {
         _hasMore = response.data.isNotEmpty;
      }
      
    } catch (e) {
      // Fallback
      var allDummies = [
        NrmRequestModel(id: 123, ticketNumber: 'NRM-0123', requesterName: 'Rajesh K.', departmentName: 'Maintenance', status: 'PENDING', items: [NrmItemModel(itemName: 'Bearing 6205-2RS', requestedQty: 4), NrmItemModel(itemName: 'Safety Gloves', requestedQty: 1)]),
        NrmRequestModel(id: 122, ticketNumber: 'NRM-0122', requesterName: 'Suresh M.', departmentName: 'Production', status: 'ISSUANCE', items: [NrmItemModel(itemName: 'Safety Shoes', requestedQty: 1), NrmItemModel(itemName: 'Safety Gloves', requestedQty: 1)]),
        NrmRequestModel(id: 121, ticketNumber: 'NRM-0121', requesterName: 'Arun P.', departmentName: 'Quality', status: 'CLOSED', items: [NrmItemModel(itemName: 'Allen Key Set', requestedQty: 1), NrmItemModel(itemName: 'Drive Belt', requestedQty: 2)]),
        NrmRequestModel(id: 120, ticketNumber: 'NRM-0120', requesterName: 'Test Q.', departmentName: 'HR & Admin', status: 'APPROVED', items: [NrmItemModel(itemName: 'Keyboard', requestedQty: 1)]),
      ];

      var filtered = allDummies;
      if (_currentFilter != 'All') {
        filtered = allDummies.where((element) => element.status.toLowerCase() == _currentFilter.toLowerCase() || (element.status.toLowerCase() == 'issuance' && _currentFilter.toLowerCase() == 'approved')).toList();
      }

      if (refresh) {
        _requests = filtered;
        _hasMore = true; 
      } else {
        _requests.addAll([
          NrmRequestModel(id: 119, ticketNumber: 'NRM-0119', requesterName: 'John', departmentName: 'Maintenance', status: 'PENDING', items: []),
        ]);
        _hasMore = false;
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

  Future<bool> createNrmRequest({
    required int departmentId,
    required String purpose,
    required List<Map<String, dynamic>> items,
  }) async {
    _isSubmitting = true;
    _submitErrorMessage = '';
    notifyListeners();

    try {
      final response = await _repository.createNrmRequest(
        departmentId: departmentId,
        purpose: purpose,
        items: items,
      );

      _isSubmitting = false;
      if (response.success) {
        await fetchNrmRequests(refresh: true);
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
  NrmRequestModel? _selectedRequest;
  NrmRequestModel? get selectedRequest => _selectedRequest;

  // Set fallback model from navigation
  void setSelectedRequestFallback(NrmRequestModel? model) {
    _selectedRequest = model;
    notifyListeners();
  }

  Future<void> fetchNrmRequestDetail(int id) async {
    _isLoadingDetail = true;
    _errorMessage = '';
    if (_selectedRequest?.id != id) {
      _selectedRequest = null;
    }
    notifyListeners();

    try {
      final response = await _repository.getNrmRequestDetail(id);
      _selectedRequest = response;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<bool> approveRequest(int id, String comments) async {
    return _performAction(() => _repository.approveNrmRequest(id, comments));
  }

  Future<bool> rejectRequest(int id, String comments) async {
    return _performAction(() => _repository.rejectNrmRequest(id, comments));
  }

  Future<bool> issueRequest(int id, String comments) async {
    return _performAction(() => _repository.issueNrmRequest(id, comments));
  }

  Future<bool> cancelRequest(int id, String comments) async {
    return _performAction(() => _repository.cancelNrmRequest(id, comments));
  }

  Future<bool> _performAction(Future<bool> Function() action) async {
    _isSubmitting = true;
    _submitErrorMessage = '';
    notifyListeners();

    try {
      final success = await action();
      _isSubmitting = false;
      if (success) {
        await fetchNrmRequests(refresh: true);
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
