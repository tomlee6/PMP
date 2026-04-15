import 'package:flutter/material.dart';
import '../data/models/maintenance_model.dart';
import '../data/repositories/maintenance_repository.dart';

class MaintenanceViewModel extends ChangeNotifier {
  final MaintenanceRepository _repository = MaintenanceRepository();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  List<MaintenanceModel> _breakdowns = [];
  
  int _currentPage = 1;
  bool _hasMore = true;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get errorMessage => _errorMessage;
  List<MaintenanceModel> get breakdowns => _breakdowns;
  bool get hasMore => _hasMore;

  // Dropdown data
  bool _isDropdownsLoading = false;
  bool get isDropdownsLoading => _isDropdownsLoading;
  DropdownData? _dropdownData;
  DropdownData? get dropdownData => _dropdownData;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;
  String _submitErrorMessage = '';
  String get submitErrorMessage => _submitErrorMessage;

  Future<void> fetchDropdowns() async {
    _isDropdownsLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getDropdownData();
      _dropdownData = response.data;
    } catch (e) {
      // Setup Fallback Dummy Dropdown Data
      _dropdownData = DropdownData(
        lines: [LineModel(id: 3, lineName: 'Line 3 - Crimping'), LineModel(id: 1, lineName: 'Line 1 - Injection')],
        machines: [MachineModel(id: 7, machineName: 'Crimping Machine #7', productionLineId: 3), MachineModel(id: 8, machineName: 'Crimping Machine #8', productionLineId: 3), MachineModel(id: 2, machineName: 'Injection Mold Press #2', productionLineId: 1)],
        problems: [
          ProblemModel(id: 3, problemName: 'Motor Overheating'),
          ProblemModel(id: 4, problemName: 'Mechanical Failure'),
          ProblemModel(id: 5, problemName: 'Electrical Issue'),
          ProblemModel(id: 6, problemName: 'Hydraulic Failure'),
          ProblemModel(id: 7, problemName: 'Sensor Fault'),
        ],
      );
    } finally {
      _isDropdownsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBreakdowns({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _isLoading = true;
      _breakdowns.clear();
      notifyListeners();
    } else {
      if (!_hasMore || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final response = await _repository.getBreakdowns(page: _currentPage);
      _breakdowns.addAll(response.data);
      if (response.pagination != null) {
         _hasMore = _breakdowns.length < response.pagination!.total;
      } else {
         _hasMore = response.data.isNotEmpty;
      }
    } catch (e) {
      if (refresh) {
        _breakdowns = [
          MaintenanceModel(id: 91, ticketNumber: 'MNT-0091', reportedByName: 'Suresh M.', lineName: 'Line 3', machineName: 'Crimping Machine #7', problemName: 'Motor overheating', status: 'OPEN'),
          MaintenanceModel(id: 90, ticketNumber: 'MNT-0090', reportedByName: 'Ganesh R.', lineName: 'Line 1', machineName: 'Injection Mold Press #2', problemName: 'Hydraulic leak', status: 'OPEN'),
          MaintenanceModel(id: 88, ticketNumber: 'MNT-0088', reportedByName: 'Vijay T.', lineName: 'Line 4', machineName: 'Soldering Station #1', problemName: 'Temperature control failure', status: 'CLOSED'),
        ];
        _hasMore = true; 
      } else {
        _breakdowns.addAll([
          MaintenanceModel(id: 87, ticketNumber: 'MNT-0087', reportedByName: 'Admin', lineName: 'Line 2', machineName: 'Robot Arm', problemName: 'Sensor Error', status: 'CLOSED'),
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

  Future<bool> reportBreakdown({
    required int lineId,
    required int machineId,
    required int problemId,
    required String breakdownStartTime,
    required String description,
  }) async {
    _isSubmitting = true;
    _submitErrorMessage = '';
    notifyListeners();

    try {
      final success = await _repository.reportBreakdown(
        lineId: lineId,
        machineId: machineId,
        problemId: problemId,
        breakdownStartTime: breakdownStartTime,
        description: description,
      );

      _isSubmitting = false;
      if (success) {
        await fetchBreakdowns(refresh: true);
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
}
