import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hr_request_model.dart';
import '../../viewmodels/hr_viewmodel.dart';
import '../widgets/approval_action_buttons.dart';
import '../widgets/detail_card_widget.dart';

class HrApproveScreen extends StatefulWidget {
  final int requestId;
  final HrRequestModel? requestModel;

  const HrApproveScreen({
    Key? key,
    required this.requestId,
    this.requestModel,
  }) : super(key: key);

  @override
  State<HrApproveScreen> createState() => _HrApproveScreenState();
}

class _HrApproveScreenState extends State<HrApproveScreen> {
  final TextEditingController _commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<HrViewModel>(context, listen: false);
      vm.setSelectedRequestFallback(widget.requestModel);
      vm.fetchHrRequestDetail(widget.requestId);
    });
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _handleApprove() async {
    final vm = Provider.of<HrViewModel>(context, listen: false);
    final success = await vm.approveRequest(widget.requestId, _commentsController.text);
    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request approved successfully'), backgroundColor: AppColors.successColor),
      );
      context.pop(true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.submitErrorMessage), backgroundColor: AppColors.errorColor),
      );
    }
  }

  void _handleReject() async {
    final vm = Provider.of<HrViewModel>(context, listen: false);
    final success = await vm.rejectRequest(widget.requestId, _commentsController.text);
    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request rejected successfully'), backgroundColor: AppColors.successColor),
      );
      context.pop(true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.submitErrorMessage), backgroundColor: AppColors.errorColor),
      );
    }
  }

  Widget _buildStatusChip(String status) {
    Color bgColor = AppColors.pendingBgColor;
    Color textColor = AppColors.pendingTextColor;

    if (status.toUpperCase() == 'APPROVED') {
      bgColor = AppColors.approvedBgColor;
      textColor = AppColors.approvedTextColor;
    } else if (status.toUpperCase() == 'CLOSED') {
      bgColor = AppColors.closedBgColor;
      textColor = AppColors.closedTextColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HrViewModel>(
      builder: (context, vm, child) {
        final request = vm.selectedRequest ?? widget.requestModel;
        
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    request?.ticketNumber.isNotEmpty == true ? request!.ticketNumber : 'HR-${widget.requestId.toString().padLeft(4, '0')}',
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (request != null) _buildStatusChip(request.status),
              ],
            ),
          ),
          body: vm.isLoadingDetail && request == null
              ? const Center(child: CircularProgressIndicator())
              : request == null
                  ? Center(child: Text(vm.errorMessage.isNotEmpty ? vm.errorMessage : 'Request not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DetailCardWidget(
                            title: 'Request Details',
                            child: Column(
                              children: [
                                DetailRowWidget(label: 'Customer', value: request.customerName),
                                if (request.visitDate != null && request.visitDate!.isNotEmpty)
                                  DetailRowWidget(label: 'Visit Date', value: request.visitDate!),
                                if (request.purposeName != null && request.purposeName!.isNotEmpty)
                                  DetailRowWidget(label: 'Purpose', value: request.purposeName!),
                                DetailRowWidget(label: 'Requested By', value: request.requesterName ?? 'Unknown'),
                                DetailRowWidget(label: 'Status', value: request.status, isLast: true),
                              ],
                            ),
                          ),
                          if (request.remarks.isNotEmpty)
                            DetailCardWidget(
                              title: 'Remarks',
                              child: Text(
                                request.remarks,
                                style: const TextStyle(color: AppColors.textPrimaryColor, height: 1.5),
                              ),
                            ),
                          if (request.itemsText.isNotEmpty)
                            DetailCardWidget(
                              title: 'Items Required',
                              child: Text(
                                request.itemsText,
                                style: const TextStyle(color: AppColors.textPrimaryColor, height: 1.5),
                              ),
                            ),
                          
                          // Comments box
                          if (request.status.toUpperCase() == 'PENDING')
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Comments (optional)',
                                    style: TextStyle(color: AppColors.textSecondaryColor, fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _commentsController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      hintText: 'Add comments...',
                                      hintStyle: TextStyle(color: Colors.grey.shade400),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (request.status.toUpperCase() == 'PENDING')
                            ApprovalActionButtons(
                              primaryLabel: 'Approve',
                              secondaryLabel: 'Reject',
                              primaryIcon: Icons.check_box,
                              secondaryIcon: Icons.cancel,
                              onPrimaryPressed: _handleApprove,
                              onSecondaryPressed: _handleReject,
                              isLoading: vm.isSubmitting,
                            ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}
