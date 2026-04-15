class MaintenanceResponse {
  final bool success;
  final List<MaintenanceModel> data;
  final Pagination? pagination;

  MaintenanceResponse({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory MaintenanceResponse.fromJson(Map<String, dynamic> json) {
    return MaintenanceResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List?)?.map((i) => MaintenanceModel.fromJson(i)).toList() ?? [],
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
    );
  }
}

class MaintenanceModel {
  final int id;
  final String ticketNumber;
  final String reportedByName;
  final String lineName;
  final String machineName;
  final String problemName;
  final String status;

  MaintenanceModel({
    required this.id,
    required this.ticketNumber,
    required this.reportedByName,
    required this.lineName,
    required this.machineName,
    required this.problemName,
    required this.status,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: json['id'] ?? 0,
      ticketNumber: json['ticket_number'] ?? '',
      reportedByName: json['reported_by_name'] ?? '',
      lineName: json['line_name'] ?? '',
      machineName: json['machine_name'] ?? '',
      problemName: json['problem_name'] ?? '',
      status: json['status'] ?? 'open',
    );
  }
}

class DropdownResponse {
  final bool success;
  final DropdownData? data;

  DropdownResponse({
    required this.success,
    this.data,
  });

  factory DropdownResponse.fromJson(Map<String, dynamic> json) {
    return DropdownResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? DropdownData.fromJson(json['data']) : null,
    );
  }
}

class DropdownData {
  final List<LineModel> lines;
  final List<MachineModel> machines;
  final List<ProblemModel> problems;

  DropdownData({
    required this.lines,
    required this.machines,
    required this.problems,
  });

  factory DropdownData.fromJson(Map<String, dynamic> json) {
    return DropdownData(
      lines: (json['lines'] as List?)?.map((i) => LineModel.fromJson(i)).toList() ?? [],
      machines: (json['machines'] as List?)?.map((i) => MachineModel.fromJson(i)).toList() ?? [],
      problems: (json['problems'] as List?)?.map((i) => ProblemModel.fromJson(i)).toList() ?? [],
    );
  }
}

class LineModel {
  final int id;
  final String lineName;
  LineModel({required this.id, required this.lineName});
  factory LineModel.fromJson(Map<String, dynamic> json) => LineModel(id: json['id'] ?? 0, lineName: json['line_name'] ?? '');
}

class MachineModel {
  final int id;
  final String machineName;
  final int productionLineId;
  MachineModel({required this.id, required this.machineName, required this.productionLineId});
  factory MachineModel.fromJson(Map<String, dynamic> json) => MachineModel(id: json['id'] ?? 0, machineName: json['machine_name'] ?? '', productionLineId: json['production_line_id'] ?? 0);
}

class ProblemModel {
  final int id;
  final String problemName;
  ProblemModel({required this.id, required this.problemName});
  factory ProblemModel.fromJson(Map<String, dynamic> json) => ProblemModel(id: json['id'] ?? 0, problemName: json['problem_name'] ?? '');
}

class Pagination {
  final int page;
  final int total;

  Pagination({required this.page, required this.total});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}
