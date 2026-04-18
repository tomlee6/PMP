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
  
  int _selectedPurposeId = 1; // Default to Customer Visit

  final List<Map<String, dynamic>> _purposes = [
    {'id': 1, 'name': 'Customer Visit'},
    {'id': 2, 'name': 'Global Team Visit'},
    {'id': 3, 'name': 'Audit'},
    {'id': 4, 'name': 'Other'},
  ];

  String? _selectedMainDish;
  String? _selectedSideDish;
  String? _selectedJuice;
  String? _selectedSnacks;

  int _mainQty = 1;
  int _sideQty = 1;
  int _juiceQty = 1;
  int _snacksQty = 1;

  final List<String> _mainDishes = ['Chapthi', 'Nan', 'Chicken Biriyani', 'Fride rice', 'Sambar rice', 'Mini meals'];
  final List<String> _sideDishes = ['Gravy', 'Chicken fry', 'Fish fry'];
  final List<String> _juices = ['Fresh juice', 'Bottle juice'];
  final List<String> _snacks = ['Nuts', 'Chocolate', 'Biscuts', 'Others'];

  final List<Map<String, dynamic>> _addedItems = [];

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _remarksController.dispose();
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

  void _addItem() {
    bool addedAny = false;
    setState(() {
      if (_selectedMainDish != null) {
        _addedItems.add({'category': 'Main Dish', 'name': _selectedMainDish, 'quantity': _mainQty});
        _selectedMainDish = null;
        _mainQty = 1;
        addedAny = true;
      }
      if (_selectedSideDish != null) {
        _addedItems.add({'category': 'Side Dish', 'name': _selectedSideDish, 'quantity': _sideQty});
        _selectedSideDish = null;
        _sideQty = 1;
        addedAny = true;
      }
      if (_selectedJuice != null) {
        _addedItems.add({'category': 'Juice', 'name': _selectedJuice, 'quantity': _juiceQty});
        _selectedJuice = null;
        _juiceQty = 1;
        addedAny = true;
      }
      if (_selectedSnacks != null) {
        _addedItems.add({'category': 'Snacks', 'name': _selectedSnacks, 'quantity': _snacksQty});
        _selectedSnacks = null;
        _snacksQty = 1;
        addedAny = true;
      }
    });
    
    if (!addedAny) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item to add.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.orange),
      );
    }
  }

  void _removeItem(int index) {
    setState(() {
      _addedItems.removeAt(index);
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _addedItems.isNotEmpty) {
      final viewModel = Provider.of<HrViewModel>(context, listen: false);

      List<String> items = [];
      for (var item in _addedItems) {
        items.add('${item['category']}: ${item['name']} - ${item['quantity']} qty');
      }
      String finalItemsText = items.join('; ');

      final success = await viewModel.createHrRequest(
        customerName: _nameController.text.trim(),
        visitDate: _dateController.text.trim(),
        remarks: _remarksController.text.trim(),
        itemsText: finalItemsText,
        purposeId: _selectedPurposeId,
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
                        const Text('Purpose', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                        const SizedBox(height: 8),
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
                                    Expanded(child: Text('${item['category']} - ${item['name']}', style: const TextStyle(fontWeight: FontWeight.w500))),
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
                        
                        _buildDropdownRow('Main Dish', _selectedMainDish, _mainDishes, _mainQty, 
                          (val) => setState(() => _selectedMainDish = val),
                          (val) => setState(() => _mainQty = val)
                        ),
                        const SizedBox(height: 8),
                        
                        _buildDropdownRow('Side Dish', _selectedSideDish, _sideDishes, _sideQty, 
                          (val) => setState(() => _selectedSideDish = val),
                          (val) => setState(() => _sideQty = val)
                        ),
                        const SizedBox(height: 8),

                        _buildDropdownRow('Juice', _selectedJuice, _juices, _juiceQty, 
                          (val) => setState(() => _selectedJuice = val),
                          (val) => setState(() => _juiceQty = val)
                        ),
                        const SizedBox(height: 8),

                        _buildDropdownRow('Snacks', _selectedSnacks, _snacks, _snacksQty, 
                          (val) => setState(() => _selectedSnacks = val),
                          (val) => setState(() => _snacksQty = val)
                        ),
                        const SizedBox(height: 24),
                        
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _addItem,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '+ Add Items',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: (_addedItems.isNotEmpty && !viewModel.isSubmitting) ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_addedItems.isNotEmpty && !viewModel.isSubmitting) ? AppColors.primaryColor : Colors.grey,
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

  Widget _buildDropdownRow(String label, String? selectedValue, List<String> items, int quantity, Function(String?) onChanged, Function(int) onQtyChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
              const SizedBox(height: 8),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedValue,
                    hint: const Text('Select...'),
                    items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Qty', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
              const SizedBox(height: 8),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('$quantity', style: const TextStyle(fontSize: 14)),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => onQtyChanged(quantity + 1),
                          child: const Icon(Icons.arrow_drop_up, size: 18),
                        ),
                        GestureDetector(
                          onTap: () => onQtyChanged(quantity > 1 ? quantity - 1 : 1),
                          child: const Icon(Icons.arrow_drop_down, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
