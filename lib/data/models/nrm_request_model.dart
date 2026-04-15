import 'dart:convert';

class NrmRequestResponse {
  final bool success;
  final List<NrmRequestModel> data;
  final Pagination? pagination;

  NrmRequestResponse({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory NrmRequestResponse.fromJson(Map<String, dynamic> json) {
    return NrmRequestResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List?)?.map((i) => NrmRequestModel.fromJson(i)).toList() ?? [],
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
    );
  }
}

class NrmSingleRequestResponse {
  final bool success;
  final NrmSingleRequestData? data;

  NrmSingleRequestResponse({
    required this.success,
    this.data,
  });

  factory NrmSingleRequestResponse.fromJson(Map<String, dynamic> json) {
    return NrmSingleRequestResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? NrmSingleRequestData.fromJson(json['data']) : null,
    );
  }
}

class NrmSingleRequestData {
  final int id;
  final String ticketNumber;

  NrmSingleRequestData({required this.id, required this.ticketNumber});

  factory NrmSingleRequestData.fromJson(Map<String, dynamic> json) {
    return NrmSingleRequestData(
      id: json['id'] ?? 0,
      ticketNumber: json['ticket_number'] ?? '',
    );
  }
}

class NrmRequestModel {
  final int id;
  final String ticketNumber;
  final String requesterName;
  final String departmentName;
  final String status;
  final String? purpose;
  final String? requestDate;
  final List<NrmItemModel> items;

  NrmRequestModel({
    required this.id,
    required this.ticketNumber,
    required this.requesterName,
    required this.departmentName,
    required this.status,
    this.purpose,
    this.requestDate,
    required this.items,
  });

  factory NrmRequestModel.fromJson(Map<String, dynamic> json) {
    return NrmRequestModel(
      id: json['id'] ?? 0,
      ticketNumber: json['ticket_number'] ?? '',
      requesterName: json['requester_name'] ?? '',
      departmentName: json['department_name'] ?? '',
      status: json['status'] ?? 'pending',
      purpose: json['purpose'],
      requestDate: json['request_date'],
      items: (json['items'] as List?)?.map((i) => NrmItemModel.fromJson(i)).toList() ?? [],
    );
  }
}

class NrmItemModel {
  final String itemName;
  final int requestedQty;

  NrmItemModel({required this.itemName, required this.requestedQty});

  factory NrmItemModel.fromJson(Map<String, dynamic> json) {
    return NrmItemModel(
      itemName: json['item_name'] ?? '',
      requestedQty: json['requested_qty'] ?? 0,
    );
  }
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
