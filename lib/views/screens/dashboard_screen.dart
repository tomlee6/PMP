import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/secure_storage_service.dart';
import '../../viewmodels/hr_viewmodel.dart';
import '../../viewmodels/nrm_viewmodel.dart';
import '../../viewmodels/maintenance_viewmodel.dart';
import 'hr_screen.dart';
import 'nrm_screen.dart';
import 'maintenance_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HrViewModel>(context, listen: false).fetchHrRequests(refresh: true);
      Provider.of<NrmViewModel>(context, listen: false).fetchNrmRequests(refresh: true);
      Provider.of<MaintenanceViewModel>(context, listen: false).fetchBreakdowns(refresh: true);
    });
  }

  Future<void> _loadUserData() async {
    final userDataStr = await SecureStorageService().getUserData();
    if (userDataStr != null && userDataStr.isNotEmpty) {
      try {
        final map = jsonDecode(userDataStr);
        String name = 'User';
        if (map.containsKey('user') && map['user'] != null) {
          name = map['user']['full_name'] ?? 'User';
        } else if (map.containsKey('full_name')) {
          name = map['full_name'] ?? 'User';
        }
        if (mounted) {
          setState(() {
            _userName = name;
          });
        }
      } catch (e) {
        debugPrint('Error parsing user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          const HrScreen(),
          const NrmScreen(),
          // const MaintenanceScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondaryColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lunch_dining), // Approximating the burger icon
            label: 'HR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined), // Approximating NRM box icon
            label: 'NRM',
          ),
          /* BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            label: 'Maint.',
          ), */
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        // Custom Header
        Container(
          color: AppColors.primaryColor,
          padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
          child: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 32,
              ),
              const SizedBox(width: 8),
              Text(
                'Amphenol Plant',
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning, $_userName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Welcome to the Plant Management Platform',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('HR & ADMIN', onTapViewAll: () => setState(() => _currentIndex = 1)),
                  Consumer<HrViewModel>(
                    builder: (context, hrViewModel, _) {
                      if (hrViewModel.isLoading && hrViewModel.requests.isEmpty) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      if (hrViewModel.requests.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text('No HR requests.'),
                        );
                      }
                      final req = hrViewModel.requests.first;
                      Color bgStatusColor = AppColors.pendingBgColor;
                      Color textStatusColor = AppColors.pendingTextColor;
                      if (req.status.toUpperCase() == 'APPROVED') {
                        bgStatusColor = AppColors.approvedBgColor;
                        textStatusColor = AppColors.approvedTextColor;
                      } else if (req.status.toUpperCase() == 'CLOSED') {
                        bgStatusColor = AppColors.closedBgColor;
                        textStatusColor = AppColors.closedTextColor;
                      }

                      return InkWell(
                        onTap: () async {
                           final storage = SecureStorageService();
                           final rawData = await storage.getUserData();
                           bool canApprove = false;
                           bool canExecute = false;
                           if (rawData != null) {
                               try {
                                   final map = jsonDecode(rawData);
                                   final permsMap = map['permissions'] ?? {};
                                   canApprove = permsMap['hr_approve'] == true;
                                   canExecute = permsMap['hr_execute'] == true;
                               } catch (e) {
                                   debugPrint('Error: $e');
                               }
                           }

                           if (req.status.toUpperCase() == 'PENDING') {
                               if (canApprove) {
                                   if (context.mounted) context.push('/hr/approve/${req.id}', extra: req);
                               } else {
                                   if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You do not have permission to approve this request.'), backgroundColor: Colors.orange));
                               }
                           } else if (req.status.toUpperCase() == 'APPROVED') {
                               if (canExecute) {
                                   if (context.mounted) context.push('/hr/close/${req.id}', extra: req);
                               } else {
                                   if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You do not have permission to close this request.'), backgroundColor: Colors.orange));
                               }
                           } else {
                               if (context.mounted) setState(() => _currentIndex = 1);
                           }
                        },
                        child: _buildTaskCard(
                          id: req.ticketNumber,
                          status: req.status.toUpperCase(),
                          statusColor: textStatusColor,
                          statusBgColor: bgStatusColor,
                          title: req.itemsText,
                          subtitle1: req.customerName.isNotEmpty ? 'for ${req.customerName}' : '',
                          subtitle2: req.remarks,
                          timeText: 'Recently',
                          assignee: 'By: ${req.requesterName}',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('NRM STORE', onTapViewAll: () => setState(() => _currentIndex = 2)),
                  Consumer<NrmViewModel>(
                    builder: (context, nrmViewModel, _) {
                      if (nrmViewModel.isLoading && nrmViewModel.requests.isEmpty) {
                         return const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      if (nrmViewModel.requests.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text('No NRM requests.'),
                        );
                      }
                      final req = nrmViewModel.requests.first;
                      Color bgStatusColor = AppColors.pendingBgColor;
                      Color textStatusColor = AppColors.pendingTextColor;
                      if (req.status.toUpperCase() == 'APPROVED') {
                        bgStatusColor = AppColors.approvedBgColor;
                        textStatusColor = AppColors.approvedTextColor;
                      } else if (req.status.toUpperCase() == 'CLOSED') {
                        bgStatusColor = AppColors.closedBgColor;
                        textStatusColor = AppColors.closedTextColor;
                      } else if (req.status.toUpperCase() == 'ISSUANCE') {
                        bgStatusColor = AppColors.approvedBgColor; 
                        textStatusColor = AppColors.approvedTextColor;
                      }

                      return InkWell(
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
                                   debugPrint('Error: $e');
                               }
                           }

                           if (req.status.toUpperCase() == 'PENDING') {
                               if (canApprove) {
                                   if (context.mounted) context.push('/nrm/approve/${req.id}', extra: req);
                               } else {
                                   if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You do not have permission to approve this request.'), backgroundColor: Colors.orange));
                               }
                           } else if (req.status.toUpperCase() == 'ISSUANCE') {
                               if (canExecute) {
                                   if (context.mounted) context.push('/nrm/approve/${req.id}', extra: req);
                               } else {
                                   if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You do not have permission to issue this request.'), backgroundColor: Colors.orange));
                               }
                           } else {
                               // Just navigate to view details or do nothing
                               if (context.mounted) context.push('/nrm/approve/${req.id}', extra: req);
                           }
                        },
                        child: _buildTaskCard(
                          id: req.ticketNumber,
                          status: req.status.toUpperCase(),
                          statusColor: textStatusColor,
                          statusBgColor: bgStatusColor,
                          title: req.items.isNotEmpty ? req.items.map((e) => e.itemName).join(', ') : 'No items',
                          subtitle1: '',
                          subtitle2: '${req.items.length} items • Dept: ${req.departmentName}',
                          timeText: 'Recently',
                          assignee: 'By: ${req.requesterName}',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Temporarily hiding Maintenance part
                  /*
                  _buildSectionHeader('MAINTENANCE', onTapViewAll: () => setState(() => _currentIndex = 3)),
                  Consumer<MaintenanceViewModel>(
                    builder: (context, maintViewModel, _) {
                      if (maintViewModel.isLoading && maintViewModel.breakdowns.isEmpty) {
                         return const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      if (maintViewModel.breakdowns.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text('No maintenance reports.'),
                        );
                      }
                      final req = maintViewModel.breakdowns.first;
                      Color bgStatusColor = AppColors.openBgColor;
                      Color textStatusColor = AppColors.openTextColor;
                      if (req.status.toUpperCase() == 'CLOSED') {
                        bgStatusColor = AppColors.closedBgColor;
                        textStatusColor = AppColors.closedTextColor;
                      }
                      return InkWell(
                        onTap: () {
                           setState(() => _currentIndex = 3);
                        },
                        child: _buildTaskCard(
                          id: req.ticketNumber,
                          status: req.status.toUpperCase(),
                          statusColor: textStatusColor,
                          statusBgColor: bgStatusColor,
                          title: '${req.lineName} - ${req.machineName}',
                          subtitle1: '',
                          subtitle2: req.problemName,
                          timeText: 'Recently',
                          assignee: 'By: ${req.reportedByName}',
                        ),
                      );
                    },
                  ),
                  */
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTapViewAll}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondaryColor,
            ),
          ),
          GestureDetector(
            onTap: onTapViewAll ?? () {},
            child: const Text(
              'View All >',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard({
    required String id,
    required String status,
    required Color statusColor,
    required Color statusBgColor,
    required String title,
    required String subtitle1,
    required String subtitle2,
    required String timeText,
    required String assignee,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
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
                  id,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                ),
                if (subtitle1.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    subtitle1,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
            if (subtitle2.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle2,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                Text(
                  assignee,
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
    );
  }
}
