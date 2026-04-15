import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/maintenance_viewmodel.dart';
import '../../data/models/maintenance_model.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MaintenanceViewModel>(context, listen: false).fetchBreakdowns(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        Provider.of<MaintenanceViewModel>(context, listen: false).fetchBreakdowns();
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
    final viewModel = Provider.of<MaintenanceViewModel>(context);

    // Filter to show OPEN vs CLOSED based on user screenshot visually
    final activeBreakdowns = viewModel.breakdowns.where((e) => e.status.toUpperCase() == 'OPEN').toList();
    final closedBreakdowns = viewModel.breakdowns.where((e) => e.status.toUpperCase() == 'CLOSED').toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.deepOrange.shade600, // Matching the orange theme in the visual
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.white),
                const SizedBox(width: 16),
                const Text(
                  'Maintenance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => viewModel.fetchBreakdowns(refresh: true),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/maintenance/new');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '+ Report Breakdown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (viewModel.isLoading && activeBreakdowns.isEmpty && closedBreakdowns.isEmpty)
                    const SliverToBoxAdapter(
                      child: Center(child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      )),
                    )
                  else ...[
                    // ACTIVE BREAKDOWNS SECTION
                    if (activeBreakdowns.isNotEmpty) ...[
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 12.0),
                          child: Text(
                            'ACTIVE BREAKDOWNS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondaryColor,
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: _buildBreakdownCard(activeBreakdowns[index]),
                            );
                          },
                          childCount: activeBreakdowns.length,
                        ),
                      ),
                    ],

                    // RECENTLY CLOSED SECTION
                    if (closedBreakdowns.isNotEmpty) ...[
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.0, top: 24.0, bottom: 12.0),
                          child: Text(
                            'RECENTLY CLOSED',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondaryColor,
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: _buildBreakdownCard(closedBreakdowns[index]),
                            );
                          },
                          childCount: closedBreakdowns.length,
                        ),
                      ),
                    ],

                    // Loading indicator for pagination at bottom
                    if (viewModel.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        )),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(MaintenanceModel breakdown) {
    Color bgStatusColor = breakdown.status.toUpperCase() == 'OPEN' ? AppColors.openBgColor : AppColors.closedBgColor;
    Color textStatusColor = breakdown.status.toUpperCase() == 'OPEN' ? AppColors.openTextColor : AppColors.closedTextColor;
    
    // UI styling uses a red left border
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.red, width: 4), // The red indicator on the left side
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      breakdown.ticketNumber,
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
                        breakdown.status.toUpperCase(),
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
                  '${breakdown.lineName} - ${breakdown.machineName}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  breakdown.problemName,
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
                      'Today, 9:15 AM', // Dummy display, typically uses createdAt
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                    Text(
                      'By: ${breakdown.reportedByName}',
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
        ),
      ),
    );
  }
}
