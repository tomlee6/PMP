import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hr_request_model.dart';
import '../../viewmodels/hr_viewmodel.dart';

class HrCloseTicketScreen extends StatefulWidget {
  final int requestId;
  final HrRequestModel? requestModel;

  const HrCloseTicketScreen({
    Key? key,
    required this.requestId,
    this.requestModel,
  }) : super(key: key);

  @override
  _HrCloseTicketScreenState createState() => _HrCloseTicketScreenState();
}

class _HrCloseTicketScreenState extends State<HrCloseTicketScreen> {
  final _amountController = TextEditingController();
  XFile? _billPhoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.requestModel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<HrViewModel>(context, listen: false)
            .fetchHrRequestDetail(widget.requestId);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        setState(() {
          _billPhoto = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _closeTicket() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter actual amount spent')),
      );
      return;
    }

    final sanitizedAmount = amountText.replaceAll(',', '');

    final hrViewModel = Provider.of<HrViewModel>(context, listen: false);
    final success = await hrViewModel.closeTicket(
        widget.requestId, sanitizedAmount, _billPhoto);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket closed successfully')),
        );
        context.pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(hrViewModel.submitErrorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<HrViewModel>(
        builder: (context, hrViewModel, child) {
          final isDetailLoading = hrViewModel.isLoadingDetail;
          final request = widget.requestModel ?? hrViewModel.selectedRequest;

          if (isDetailLoading && request == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (request == null) {
            return const Center(child: Text('Failed to load request.'));
          }

          return Column(
            children: [
              // Custom Header
              Container(
                color: AppColors.primaryColor,
                padding: const EdgeInsets.only(
                    top: 50, bottom: 20, left: 16, right: 16),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        request.ticketNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.approvedBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request.status.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.approvedTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Ordered Items
                      _buildSectionContainer(
                        title: 'Ordered Items',
                        child: Text(
                          request.itemsText,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Actual Amount
                      _buildSectionContainer(
                        title: 'Actual Amount',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Amount Spent (₹)',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [IndianCurrencyFormatter()],
                              decoration: InputDecoration(
                                hintText: '0.00',
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade400),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Attach Bill / Receipt
                      _buildSectionContainer(
                        title: 'Attach Bill / Receipt',
                        child: InkWell(
                          onTap: _showPickerOptions,
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                // Dashed border replacement via simple dotted/dashed effect
                                // For simplicity, we just use a small customized border
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 2,
                                        style: BorderStyle.none, // Can use dotted_border package for real dashes, here simulated or plain
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                if (_billPhoto != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: kIsWeb 
                                        ? Image.network(
                                            _billPhoto!.path,
                                            width: double.infinity,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(_billPhoto!.path),
                                            width: double.infinity,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                  )
                                else
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 36,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to take photo or upload bill',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      ElevatedButton(
                        onPressed:
                            hrViewModel.isSubmitting ? null : _closeTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: hrViewModel.isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Close Ticket',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class IndianCurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    
    int decimalIndex = newText.indexOf('.');
    if (decimalIndex != -1) {
      if (newText.indexOf('.', decimalIndex + 1) != -1) return oldValue;
      if (newText.length - decimalIndex - 1 > 2) return oldValue;
    }

    try {
      if (newText.isEmpty || newText == '.') return newValue.copyWith(text: newText);
      if (newText.endsWith('.')) return newValue.copyWith(text: newText);
      
      List<String> parts = newText.split('.');
      String wholePart = parts[0];
      String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
      
      final numberFormat = NumberFormat.decimalPattern('en_IN');
      String formattedWholePart = numberFormat.format(int.parse(wholePart));
      String formattedValue = formattedWholePart + decimalPart;

      return TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    } catch (e) {
      return oldValue;
    }
  }
}
