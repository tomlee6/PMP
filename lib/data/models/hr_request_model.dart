import 'dart:convert';

class HrRequestResponse {
  final bool success;
  final List<HrRequestModel> data;
  final Pagination? pagination;

  HrRequestResponse({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory HrRequestResponse.fromJson(Map<String, dynamic> json) {
    return HrRequestResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List?)?.map((i) => HrRequestModel.fromJson(i)).toList() ?? [],
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
    );
  }
}

class HrSingleRequestResponse {
  final bool success;
  final SingleRequestData? data;

  HrSingleRequestResponse({
    required this.success,
    this.data,
  });

  factory HrSingleRequestResponse.fromJson(Map<String, dynamic> json) {
    return HrSingleRequestResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? SingleRequestData.fromJson(json['data']) : null,
    );
  }
}

class SingleRequestData {
  final int id;
  final String ticketNumber;

  SingleRequestData({required this.id, required this.ticketNumber});

  factory SingleRequestData.fromJson(Map<String, dynamic> json) {
    return SingleRequestData(
      id: json['id'] ?? 0,
      ticketNumber: json['ticket_number'] ?? '',
    );
  }
}

class HrRequestModel {
  final int id;
  final String ticketNumber;
  final String? requesterName;
  final String customerName;
  final String remarks;
  final String itemsText;
  final String status;
  final String? purposeName;
  final String? visitDate;

  HrRequestModel({
    required this.id,
    required this.ticketNumber,
    this.requesterName,
    required this.customerName,
    required this.remarks,
    required this.itemsText,
    required this.status,
    this.purposeName,
    this.visitDate,
  });

  factory HrRequestModel.fromJson(Map<String, dynamic> json) {
    return HrRequestModel(
      id: json['id'] ?? 0,
      ticketNumber: json['ticket_number'] ?? '',
      requesterName: json['requester_name'],
      customerName: json['customer_name'] ?? '',
      remarks: json['remarks'] ?? '',
      itemsText: json['items_text'] ?? '',
      status: json['status'] ?? 'pending',
      purposeName: json['purpose_name'],
      visitDate: json['visit_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'requester_name': requesterName,
      'customer_name': customerName,
      'remarks': remarks,
      'items_text': itemsText,
      'status': status,
      'purpose_name': purposeName,
      'visit_date': visitDate,
    };
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;

  Pagination({required this.page, required this.limit, required this.total});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}
