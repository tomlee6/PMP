import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/maintenance_viewmodel.dart';
import '../../data/models/maintenance_model.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_time_picker.dart';

class ReportBreakdownScreen extends StatefulWidget {
  const ReportBreakdownScreen({Key? key}) : super(key: key);

  @override
  State<ReportBreakdownScreen> createState() => _ReportBreakdownScreenState();
}

class _ReportBreakdownScreenState extends State<ReportBreakdownScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();

  int? _selectedLineId;
  int? _selectedMachineId;
  int? _selectedProblemId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MaintenanceViewModel>(context, listen: false).fetchDropdowns();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<MaintenanceViewModel>(context, listen: false);
      
      final success = await viewModel.reportBreakdown(
        lineId: _selectedLineId!,
        machineId: _selectedMachineId!,
        problemId: _selectedProblemId!,
        breakdownStartTime: _timeController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Breakdown reported successfully')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.submitErrorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MaintenanceViewModel>(context);

    // Filter available machines based on currently selected line
    List<MachineModel> availableMachines = [];
    if (viewModel.dropdownData != null && _selectedLineId != null) {
      availableMachines = viewModel.dropdownData!.machines.where((m) => m.productionLineId == _selectedLineId).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.deepOrange.shade600,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Report Breakdown',
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
            child: viewModel.isDropdownsLoading 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
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
                                const Text(
                                  'Machine Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 12),
                                
                                const Text('Production Line', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                                const SizedBox(height: 8),
                                CustomDropdownButton<int>(
                                  value: _selectedLineId,
                                  hintText: '-- Select Line --',
                                  items: (viewModel.dropdownData?.lines ?? []).map((l) {
                                    return DropdownMenuItem<int>(
                                      value: l.id,
                                      child: Text(l.lineName),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedLineId = val;
                                      // Reset dependent value when line changes
                                      _selectedMachineId = null;
                                    });
                                  },
                                  validator: (val) => val == null ? 'Please select a line' : null,
                                ),
                                const SizedBox(height: 16),

                                const Text('Machine', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                                const SizedBox(height: 8),
                                CustomDropdownButton<int>(
                                  value: _selectedMachineId,
                                  hintText: '-- Select Machine --',
                                  items: availableMachines.map((m) {
                                    return DropdownMenuItem<int>(
                                      value: m.id,
                                      child: Text(m.machineName),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedMachineId = val;
                                    });
                                  },
                                  validator: (val) => val == null ? 'Please select a machine' : null,
                                ),
                                const SizedBox(height: 16),

                                const Text('Problem Type', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                                const SizedBox(height: 8),
                                CustomDropdownButton<int>(
                                  value: _selectedProblemId,
                                  hintText: '-- Select Problem --',
                                  items: (viewModel.dropdownData?.problems ?? []).map((p) {
                                    return DropdownMenuItem<int>(
                                      value: p.id,
                                      child: Text(p.problemName),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedProblemId = val;
                                    });
                                  },
                                  validator: (val) => val == null ? 'Please select a problem type' : null,
                                ),
                                const SizedBox(height: 16),

                                const Text('Breakdown Start Time', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                                const SizedBox(height: 8),
                                CustomTimePickerField(
                                  controller: _timeController,
                                  labelText: '-- Select Time --',
                                ),
                                const SizedBox(height: 16),

                                const Text('Description', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: 'Enter more details...',
                                    hintStyle: const TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  validator: (val) => (val == null || val.isEmpty) ? 'Please enter a description' : null,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: viewModel.isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: viewModel.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Report Breakdown',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
