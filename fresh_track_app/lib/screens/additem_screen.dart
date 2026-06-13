import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/shelf_life_data.dart';

class AddItemDialog extends StatefulWidget {
  final Function(String name, String category, DateTime expiry, String qty) onAdd;
  
  // These optional parameters allow the OCR scanner to pre-fill the form
  final String? initialName;
  final DateTime? initialDate;

  const AddItemDialog({
    super.key, 
    required this.onAdd, 
    this.initialName, 
    this.initialDate,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _qtyController;
  String? _selectedCategory;
  DateTime? _selectedDate;
  String? _suggestionText;

  final List<String> _categories = [
    'Dairy',
    'Fruits',
    'Vegetables',
    'Meat & Seafood',
    'Beverages',
    'Bakery',
    'Frozen',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with OCR data if available, otherwise empty
    _nameController = TextEditingController(text: widget.initialName ?? "");
    _qtyController = TextEditingController();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTextStyles.sectionLabel),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView( // Added to prevent overflow when keyboard appears
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add New Item', style: AppTextStyles.dialogTitle),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildLabel('Item Name'),
              _buildTextField(
                controller: _nameController,
                hint: 'e.g., Milk, Chicken, Apples',
                onChanged: (value) {
                  final result = getShelfLifeDays(value);
                  setState(() {
                    if (result != null) {
                      _selectedDate ??= DateTime.now().add(Duration(days: result));
                      _suggestionText = "💡 Suggested: $result days based on typical shelf life";
                    } else {
                      _suggestionText = null;
                    }
                  });
                },
              ),
              if (_suggestionText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _suggestionText!,
                    style: const TextStyle(
                      color: Color(0xFF006D44),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              _buildLabel('Category'),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: const Text('Select category',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Expiry Date'),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'mm/dd/yyyy'
                            : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                        style: TextStyle(
                          color: _selectedDate == null
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Quantity (optional)'),
              _buildTextField(
                  controller: _qtyController,
                  hint: 'e.g., 1L, 500g, 2 pcs'),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty &&
                          _selectedDate != null &&
                          _selectedCategory != null) {
                        widget.onAdd(
                          _nameController.text,
                          _selectedCategory!,
                          _selectedDate!,
                          _qtyController.text.isEmpty
                              ? '1 pc'
                              : _qtyController.text,
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Add Item',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}