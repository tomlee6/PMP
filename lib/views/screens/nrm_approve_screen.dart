import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/nrm_request_model.dart';
import '../../viewmodels/nrm_viewmodel.dart';
import '../widgets/approval_action_buttons.dart';
import '../widgets/detail_card_widget.dart';

class NrmApproveScreen extends StatefulWidget {
  final int requestId;
  final NrmRequestModel? requestModel;

  const NrmApproveScreen({
    Key? key,
    required this.requestId,
    this.requestModel,
  }) : super(key: key);

  @override
  State<NrmApproveScreen> createState() => _NrmApproveScreenState();
}

class _NrmApproveScreenState extends State<NrmApproveScreen> {
  final TextEditingController _commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<NrmViewModel>(context, listen: false);
      vm.setSelectedRequestFallback(widget.requestModel);
      vm.fetchNrmRequestDetail(widget.requestId);
    });
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _handlePrimaryAction() async {
    final vm = Provider.of<NrmViewModel>(context, listen: false);
    final request = vm.selectedRequest ?? widget.requestModel;
    if (request == null) return;

    bool success = false;
    String actionLabel = '';

    if (request.status.toUpperCase() == 'PENDING') {
      success = await vm.approveRequest(widget.requestId, _commentsController.text);
      actionLabel = 'approved';
    } else if (request.status.toUpperCase() == 'ISSUANCE') {
      success = await vm.issueRequest(widget.requestId, _commentsController.text);
      actionLabel = 'issued';
    }

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $actionLabel successfully'), backgroundColor: AppColors.successColor),
      );
      context.pop(true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.submitErrorMessage), backgroundColor: AppColors.errorColor),
      );
    }
  }

  void _handleSecondaryAction() async {
    final vm = Provider.of<NrmViewModel>(context, listen: false);
    final request = vm.selectedRequest ?? widget.requestModel;
    if (request == null) return;

    bool success = false;
    String actionLabel = '';

    if (request.status.toUpperCase() == 'PENDING') {
      success = await vm.rejectRequest(widget.requestId, _commentsController.text);
      actionLabel = 'rejected';
    } else if (request.status.toUpperCase() == 'ISSUANCE') {
      success = await vm.cancelRequest(widget.requestId, _commentsController.text);
      actionLabel = 'cancelled';
    }

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $actionLabel successfully'), backgroundColor: AppColors.successColor),
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

    if (status.toUpperCase() == 'APPROVED' || status.toUpperCase() == 'ISSUANCE') {
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
    return Consumer<NrmViewModel>(
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
                    request?.ticketNumber.isNotEmpty == true ? request!.ticketNumber : 'NRM-${widget.requestId.toString().padLeft(4, '0')}',
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
                                DetailRowWidget(label: 'Requested By', value: request.requesterName),
                                if (request.requestDate != null && request.requestDate!.isNotEmpty)
                                  DetailRowWidget(label: 'Date', value: request.requestDate!),
                                DetailRowWidget(label: 'Department', value: request.departmentName),
                                if (request.purpose != null && request.purpose!.isNotEmpty)
                                  DetailRowWidget(label: 'Purpose', value: request.purpose!),
                                DetailRowWidget(label: 'Status', value: request.status, isLast: true),
                              ],
                            ),
                          ),
                          if (request.items.isNotEmpty)
                            DetailCardWidget(
                              title: 'Items (${request.items.length})',
                              child: Column(
                                children: request.items.asMap().entries.map((entry) {
                                  final item = entry.value;
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: entry.key == request.items.length - 1 ? 0 : 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.itemName,
                                            style: const TextStyle(color: AppColors.textPrimaryColor),
                                          ),
                                        ),
                                        Text(
                                          'x ${item.requestedQty}',
                                          style: const TextStyle(
                                            color: AppColors.textSecondaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          
                          // Comments box
                          if (request.status.toUpperCase() == 'PENDING' || request.status.toUpperCase() == 'ISSUANCE')
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
                              onPrimaryPressed: _handlePrimaryAction,
                              onSecondaryPressed: _handleSecondaryAction,
                              isLoading: vm.isSubmitting,
                            )
                          else if (request.status.toUpperCase() == 'ISSUANCE')
                            ApprovalActionButtons(
                              primaryLabel: 'Issue',
                              secondaryLabel: 'Cancel',
                              primaryIcon: Icons.outbox,
                              secondaryIcon: Icons.cancel_presentation,
                              onPrimaryPressed: _handlePrimaryAction,
                              onSecondaryPressed: _handleSecondaryAction,
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
