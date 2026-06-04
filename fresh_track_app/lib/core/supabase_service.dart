import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_item.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  static Future<List<FoodItem>> fetchItems() async {
    final response = await _client
        .from('food_items')
        .select()
        .order('expiry_date', ascending: true);

    return (response as List).map((row) {
      return FoodItem(
        id: row['id'] as String,
        name: row['name'] as String,
        category: row['category'] as String,
        expiryDate: DateTime.parse(row['expiry_date'] as String),
        quantity: row['quantity'] as String,
      );
    }).toList();
  }

  static Future<void> addItem(FoodItem item) async {
    final userId = _client.auth.currentUser?.id;
    await _client.from('food_items').insert({
      'id': item.id,
      'name': item.name,
      'category': item.category,
      'expiry_date': item.expiryDate.toIso8601String(),
      'quantity': item.quantity,
      'user_id': userId,
    });
  }

  static Future<void> updateItem(FoodItem item) async {
    await _client.from('food_items').update({
      'name': item.name,
      'category': item.category,
      'expiry_date': item.expiryDate.toIso8601String(),
      'quantity': item.quantity,
    }).eq('id', item.id);
  }

  static Future<void> deleteItem(String id) async {
    await _client.from('food_items').delete().eq('id', id);
  }
}
