import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/nrm_viewmodel.dart';
import '../../data/models/nrm_request_model.dart';

class NewNrmRequestScreen extends StatefulWidget {
  const NewNrmRequestScreen({Key? key}) : super(key: key);

  @override
  State<NewNrmRequestScreen> createState() => _NewNrmRequestScreenState();
}

class _NewNrmRequestScreenState extends State<NewNrmRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  
  int _selectedDeptId = 2; // Default Maintenance
  int _selectedItemId = 0; // 0 = default prompt '-- Select Item --'
  int _quantity = 1;

  final List<Map<String, dynamic>> _departments = [
    {'id': 1, 'name': 'Production'},
    {'id': 2, 'name': 'Maintenance'},
    {'id': 3, 'name': 'Quality'},
    {'id': 4, 'name': 'HR & Admin'},
  ];

  final List<Map<String, dynamic>> _masterItems = [
    {'id': 1, 'name': 'Bearing 6205-2RS'},
    {'id': 2, 'name': 'Safety Gloves (Pair)'},
    {'id': 3, 'name': 'Safety Shoes'},
    {'id': 4, 'name': 'Seat Belt'},
    {'id': 5, 'name': 'Allen Key Set'},
  ];

  final List<Map<String, dynamic>> _addedItems = [];

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_selectedItemId != 0 && _quantity > 0) {
      final selectedItemInfo = _masterItems.firstWhere((element) => element['id'] == _selectedItemId);
      setState(() {
        _addedItems.add({
          'item_id': _selectedItemId,
          'item_name': selectedItemInfo['name'],
          'quantity': _quantity,
        });
        
        // Reset selection inputs
        _selectedItemId = 0;
        _quantity = 1;
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _addedItems.removeAt(index);
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _addedItems.isNotEmpty) {
      final viewModel = Provider.of<NrmViewModel>(context, listen: false);
      
      // format items to list of { item_id, quantity }
      final itemsPayload = _addedItems.map((e) => {
        'item_id': e['item_id'],
        'quantity': e['quantity'],
      }).toList();

      final success = await viewModel.createNrmRequest(
        departmentId: _selectedDeptId,
        purpose: _purposeController.text.trim(),
        items: itemsPayload,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NRM request submitted')),
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
    final viewModel = Provider.of<NrmViewModel>(context);
    final isAddItemEnabled = _selectedItemId != 0 && _quantity > 0;
    final isSubmitEnabled = _addedItems.isNotEmpty && !viewModel.isSubmitting;

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
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Text(
                  'New NRM Request',
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
                      title: 'Request Info',
                      children: [
                        const Text('Department', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _selectedDeptId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: _departments.map((dept) {
                            return DropdownMenuItem<int>(
                              value: dept['id'],
                              child: Text(dept['name']),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedDeptId = val!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text('Purpose', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _purposeController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          validator: (value) => value!.isEmpty ? 'Please enter purpose' : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildSectionCard(
                      title: 'Items',
                      children: [
                        if (_addedItems.isNotEmpty) ...[
                          Column(
                            children: _addedItems.asMap().entries.map((entry) {
                              int index = entry.key;
                              var item = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.shade100),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(item['item_name'], style: const TextStyle(fontWeight: FontWeight.w500))),
                                    Text('Qty: ${item['quantity']}', style: const TextStyle(color: AppColors.textSecondaryColor)),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _removeItem(index),
                                      child: const Icon(Icons.close, color: Colors.blueGrey, size: 20),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                        ],

                        const Text('Item', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _selectedItemId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                              value: 0,
                              child: Text('-- Select Item --'),
                            ),
                            ..._masterItems.map((item) {
                              return DropdownMenuItem<int>(
                                value: item['id'],
                                child: Text(item['name']),
                              );
                            }).toList(),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedItemId = val!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text('Quantity', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Text('$_quantity', style: const TextStyle(fontSize: 16)),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () => setState(() => _quantity++),
                                          child: const Icon(Icons.arrow_drop_up, size: 20),
                                        ),
                                        GestureDetector(
                                          onTap: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
                                          child: const Icon(Icons.arrow_drop_down, size: 20),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: isAddItemEnabled ? _addItem : null,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: isAddItemEnabled ? AppColors.primaryColor : Colors.grey),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '+ Add Item',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isAddItemEnabled ? AppColors.primaryColor : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: isSubmitEnabled ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSubmitEnabled ? AppColors.primaryColor : Colors.grey,
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
