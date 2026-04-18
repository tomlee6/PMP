import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/nrm_viewmodel.dart';
import '../../core/services/secure_storage_service.dart';
import 'dart:convert';
import '../../data/models/nrm_request_model.dart';

class NrmScreen extends StatefulWidget {
  const NrmScreen({Key? key}) : super(key: key);

  @override
  State<NrmScreen> createState() => _NrmScreenState();
}

class _NrmScreenState extends State<NrmScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NrmViewModel>(context, listen: false).fetchNrmRequests(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        Provider.of<NrmViewModel>(context, listen: false).fetchNrmRequests();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NrmViewModel>(context);
    final filters = ['All', 'Pending', 'Issued', 'Cancelled'];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.primaryColor,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'NRM Store',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Action Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final storage = SecureStorageService();
                      final rawData = await storage.getUserData();
                      bool canRequest = false;
                      
                      if (rawData != null) {
                        try {
                          final map = jsonDecode(rawData);
                          final permsMap = map['permissions'] ?? {};
                          canRequest = permsMap['nrm_request'] == true;
                        } catch (e) {
                          debugPrint('Error: $e');
                        }
                      }

                      if (canRequest) {
                        if (context.mounted) context.push('/nrm/new');
                      } else {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You do not have permission to create NRM requests.'), backgroundColor: Colors.orange));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '+ New NRM Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filters.map((filter) {
                        final isSelected = viewModel.currentFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                viewModel.setFilter(filter);
                              }
                            },
                            selectedColor: Colors.green.shade700,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
                  child: Text(
                    'REQUESTS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ),

                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: viewModel.requests.length + (viewModel.isLoadingMore ? 1 : 0),
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            if (index == viewModel.requests.length) {
                              return const Center(child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ));
                            }
                            return _buildNrmCard(viewModel.requests[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNrmCard(NrmRequestModel request) {
    Color bgStatusColor = AppColors.pendingBgColor;
    Color textStatusColor = AppColors.pendingTextColor;
    String status = request.status.toUpperCase();

    if (status == 'APPROVED') {
      bgStatusColor = AppColors.approvedBgColor;
      textStatusColor = AppColors.approvedTextColor;
    } else if (status == 'CLOSED') {
      bgStatusColor = AppColors.closedBgColor;
      textStatusColor = AppColors.closedTextColor;
    } else if (status == 'ISSUANCE') {
      bgStatusColor = AppColors.openBgColor;
      textStatusColor = AppColors.openTextColor;
    }

    String itemsStr = request.items.map((e) => e.itemName).join(', ');
    
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final storage = SecureStorageService();
          final rawData = await storage.getUserData();
          bool canApprove = false;
          bool canExecute = false;
          
          if (rawData != null) {
            try {
              final map = jsonDecode(rawData);
              final permsMap = map['permissions'] ?? {};
              canApprove = permsMap['nrm_approve'] == true;
              canExecute = permsMap['nrm_execute'] == true;
            } catch (e) {
              debugPrint('Error parsing permissions: $e');
            }
          }

          if (request.status.toUpperCase() == 'PENDING') {
            if (canApprove) {
              if (context.mounted) context.push('/nrm/approve/${request.id}', extra: request);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You do not have permission to approve this request.'), backgroundColor: Colors.orange));
              }
            }
          } else if (request.status.toUpperCase() == 'ISSUANCE') {
            if (canExecute) {
               if (context.mounted) context.push('/nrm/approve/${request.id}', extra: request);
            } else {
               if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You do not have permission to issue this request.'), backgroundColor: Colors.orange));
               }
            }
          } else {
            // For CLOSED or CANCELLED, allow view only mode or block
            // For now, let's just push so they can see the details in read-only.
            if (context.mounted) context.push('/nrm/approve/${request.id}', extra: request);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.ticketNumber,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgStatusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textStatusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              itemsStr.isNotEmpty ? itemsStr : 'No items',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dept: ${request.departmentName}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '04 Apr 2026', // Placeholder
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                Text(
                  'By: ${request.requesterName}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
