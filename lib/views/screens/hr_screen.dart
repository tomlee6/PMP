import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/hr_viewmodel.dart';
import '../../data/models/hr_request_model.dart';

class HrScreen extends StatefulWidget {
  const HrScreen({Key? key}) : super(key: key);

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HrViewModel>(context, listen: false).fetchHrRequests(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        Provider.of<HrViewModel>(context, listen: false).fetchHrRequests();
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
    final hrViewModel = Provider.of<HrViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Custom Header
          Container(
            color: AppColors.primaryColor,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.white), // The left arrow as per design
                const SizedBox(width: 8),
                const Text(
                  'HR & Admin',
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/hr/new');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '+ New HR Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  child: hrViewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: hrViewModel.requests.length + (hrViewModel.isLoadingMore ? 1 : 0),
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            if (index == hrViewModel.requests.length) {
                              return const Center(child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ));
                            }
                            final request = hrViewModel.requests[index];
                            return _buildHrCard(request);
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

  Widget _buildHrCard(HrRequestModel request) {
    Color bgStatusColor = AppColors.pendingBgColor;
    Color textStatusColor = AppColors.pendingTextColor;

    if (request.status.toUpperCase() == 'APPROVED') {
      bgStatusColor = AppColors.approvedBgColor;
      textStatusColor = AppColors.approvedTextColor;
    } else if (request.status.toUpperCase() == 'CLOSED') {
      bgStatusColor = AppColors.closedBgColor;
      textStatusColor = AppColors.closedTextColor;
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (request.status.toUpperCase() == 'PENDING') {
            context.push('/hr/approve/${request.id}', extra: request);
          } else if (request.status.toUpperCase() == 'APPROVED') {
            context.push('/hr/close/${request.id}', extra: request);
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
                    request.status.toUpperCase(),
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
            Row(
              children: [
                Text(
                  request.itemsText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'for ${request.customerName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              request.remarks,
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
                  '04 Apr 2026', // Placeholder for actual format since API response didn't specify date field in list
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                Text(
                  'By: ${request.requesterName ?? 'Unknown'}',
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
