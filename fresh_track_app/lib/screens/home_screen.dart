import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../core/constants.dart';
import '../models/food_item.dart';
import '../widgets/food_card.dart';
import '../widgets/scan_dialog.dart';
import '../core/receipt_parser.dart'; 
import '../core/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_service.dart';
import 'review_items_screen.dart';
import 'additem_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0; 
  int _bottomNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false; 

  final List<FoodItem> _items = [];
  final List<String> _categories = ['All', 'Expiring Soon', 'Expired'];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await SupabaseService.fetchItems();
    setState(() {
      _items.clear();
      _items.addAll(items);
    });
  }

  void _showEditItemDialog(FoodItem item) {
    showDialog(
      context: context,
      builder: (_) => AddItemDialog(
        initialName: item.name,
        initialDate: item.expiryDate,
        onAdd: (name, category, expiry, qty) async {
          final updatedItem = FoodItem(
            id: item.id,
            name: name,
            category: category,
            expiryDate: expiry,
            quantity: qty,
          );
          await SupabaseService.updateItem(updatedItem);
          setState(() {
            int index = _items.indexWhere((element) => element.id == item.id);
            _items[index] = updatedItem;
          });
          NotificationService().scheduleExpiryAlert(item.id, name, expiry);
          if (updatedItem.daysLeft <= 2) {
            NotificationService().showImmediateExpiryAlert(item.id, name, updatedItem.daysLeft);
          }
        },
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: const Text("This will also cancel the expiry notification."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await SupabaseService.deleteItem(id);
              setState(() => _items.removeWhere((i) => i.id == id));
              Navigator.pop(context);
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Future<void> _handleScan(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo == null) return;

    setState(() => _isProcessing = true);

    try {
      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      final List<String> itemsFound = extractAllItems(recognizedText.text);
      final DateTime expiry = parseDateFromReceipt(recognizedText.text);
      
      await textRecognizer.close();
      
      if (!mounted) return;
      setState(() => _isProcessing = false);

      final List<String>? selectedItems = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewItemsScreen(
            scannedNames: itemsFound, 
            initialDate: expiry
          ),
        ),
      );

      if (selectedItems != null && selectedItems.isNotEmpty) {
        for (var name in selectedItems) {
          _addItem(name, "General", expiry, "1 unit");
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Added ${selectedItems.length} items to FreshTrack!")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Scan failed.")));
    }
  }

  Future<void> _addItem(String name, String category, DateTime expiry, String qty) async {
    final String uniqueId = DateTime.now().microsecondsSinceEpoch.toString();
    final newItem = FoodItem(
      id: uniqueId,
      name: name,
      category: category,
      expiryDate: expiry,
      quantity: qty,
    );

    await SupabaseService.addItem(newItem);
    setState(() => _items.add(newItem));
    NotificationService().scheduleExpiryAlert(uniqueId, name, expiry);
    if (newItem.daysLeft <= 2) {
      NotificationService().showImmediateExpiryAlert(uniqueId, name, newItem.daysLeft);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: _bottomNavIndex == 0 
              ? _buildInventoryScreen() 
              : _buildPlaceholderScreen(),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _bottomNavIndex,
            onTap: (idx) {
              if (idx == 1) {
                _showScanDialog();
              } else if (idx == 2) {
                _showAddItemDialog();
              } else {
                setState(() => _bottomNavIndex = idx);
              }
            },
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Inventory'),
              BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
              BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Add'),
            ],
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text("AI scanning your receipt...", 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderScreen() {
    return const Center(child: Text("Under Construction"));
  }

  Widget _buildInventoryScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildAlertBanners(),
        _buildCategories(),
        Expanded(
          child: _filteredItems.isEmpty 
            ? const Center(child: Text("No items found", style: TextStyle(color: AppColors.textSecondary)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return FoodCard(
                    item: item,
                    onEdit: () => _showEditItemDialog(item),
                    onDelete: () => _confirmDelete(item.id),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    int safeCount = _items.where((i) => i.status == ExpiryStatus.safe).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FreshTrack', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('You have $safeCount items staying fresh.', style: AppTextStyles.appSubtitle),
              ],
            ),
          ),
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 20),
                  ),
                  if (_items.any((i) => i.status != ExpiryStatus.safe))
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.expired, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Sign Out?"),
                      content: const Text("You will be taken back to the login screen."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                        TextButton(
                          onPressed: () async {
                            await Supabase.instance.client.auth.signOut();
                            if (!context.mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          child: const Text("Sign Out", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.logout, color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search inventory...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
        ),
      ),
    );
  }

  Widget _buildAlertBanners() {
    final expiredCount = _items.where((i) => i.status == ExpiryStatus.expired).length;
    final soonCount = _items.where((i) => i.status == ExpiryStatus.expiringSoon).length;
    
    if (expiredCount == 0 && soonCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (expiredCount > 0)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.alertExpiredBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.alertExpiredBorder)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.expired, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('$expiredCount Expired', style: const TextStyle(color: AppColors.expired, fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                ),
              ),
            ),
          if (expiredCount > 0 && soonCount > 0) const SizedBox(width: 12),
          if (soonCount > 0)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.alertExpiringSoonBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.alertExpiringSoonBorder)),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.expiringSoon, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('$soonCount Expiring', style: const TextStyle(color: AppColors.expiringSoon, fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_categories[index]),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCategoryIndex = index);
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showScanDialog() {
    showDialog(
      context: context,
      builder: (_) => ScanDialog(
        onScanCamera: () {
          Navigator.pop(context);
          _handleScan(ImageSource.camera);
        },
        onUploadImage: () {
          Navigator.pop(context);
          _handleScan(ImageSource.gallery);
        },
      ),
    );
  }

  void _showAddItemDialog({String? initialName, DateTime? initialDate}) {
    showDialog(
      context: context,
      builder: (_) => AddItemDialog(
        onAdd: _addItem,
        initialName: initialName,
        initialDate: initialDate,
      ),
    );
  }

  List<FoodItem> get _filteredItems {
    List<FoodItem> result = _items;
    if (_selectedCategoryIndex == 1) {
      result = result.where((i) => i.status == ExpiryStatus.expiringSoon).toList();
    } else if (_selectedCategoryIndex == 2) {
      result = result.where((i) => i.status == ExpiryStatus.expired).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result.where((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return result;
  }
}