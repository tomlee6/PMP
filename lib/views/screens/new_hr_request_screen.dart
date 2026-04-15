import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/hr_viewmodel.dart';
import '../widgets/custom_date_picker_field.dart';

class NewHrRequestScreen extends StatefulWidget {
  const NewHrRequestScreen({Key? key}) : super(key: key);

  @override
  State<NewHrRequestScreen> createState() => _NewHrRequestScreenState();
}

class _NewHrRequestScreenState extends State<NewHrRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _remarksController = TextEditingController();
  final _itemsController = TextEditingController();
  
  int _selectedPurposeId = 1; // Default to Customer Visit

  final List<Map<String, dynamic>> _purposes = [
    {'id': 1, 'name': 'Customer Visit'},
    {'id': 2, 'name': 'Global Team Visit'},
    {'id': 3, 'name': 'Audit'},
    {'id': 4, 'name': 'Other'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _remarksController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<HrViewModel>(context, listen: false);


      final success = await viewModel.createHrRequest(
        customerName: _nameController.text.trim(),
        visitDate: _dateController.text.trim(),
        purposeId: _selectedPurposeId,
        remarks: _remarksController.text.trim(),
        itemsText: _itemsController.text.trim(),
      );


      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully')),
        );
        context.pop();
      } else {
        print("Thomas${viewModel.submitErrorMessage}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.submitErrorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HrViewModel>(context);

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
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Text(
                  'New Request',
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
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionCard(
                      title: 'Visitor Details',
                      children: [
                        const Text('Customer / Visitor Name', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        const Text('Visit Date', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                        const SizedBox(height: 8),
                        CustomDatePickerField(
                          controller: _dateController,
                          hintText: 'Select date',
                          onTap: () => _selectDate(context),
                          validator: (value) => value!.isEmpty ? 'Please select a date' : null,
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<int>(
                          value: _selectedPurposeId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: _purposes.map((purpose) {
                            return DropdownMenuItem<int>(
                              value: purpose['id'],
                              child: Text(purpose['name']),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPurposeId = val!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text('Remarks', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _remarksController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          validator: (value) => value!.isEmpty ? 'Please enter remarks' : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildSectionCard(
                      title: 'Order Items',
                      children: [
                        const Text('Items Required', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _itemsController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          validator: (value) => value!.isEmpty ? 'Please enter required items' : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: viewModel.isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
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
                              'Submit Request',
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

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
