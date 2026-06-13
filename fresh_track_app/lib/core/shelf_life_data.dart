const Map<String, int> _shelfLife = {
  // Dairy
  'milk': 7,
  'yogurt': 14,
  'cheese': 30,
  'butter': 30,
  'eggs': 21,
  'cream': 7,
  'cottage cheese': 7,

  // Meat & Seafood
  'chicken': 2,
  'beef': 3,
  'pork': 3,
  'fish': 2,
  'shrimp': 2,
  'salmon': 2,
  'tuna': 2,
  'lamb': 3,

  // Fruits
  'apple': 30,
  'banana': 5,
  'orange': 14,
  'grapes': 7,
  'strawberry': 5,
  'mango': 5,
  'watermelon': 7,
  'lemon': 14,
  'avocado': 4,
  'pineapple': 5,

  // Vegetables
  'carrot': 21,
  'spinach': 5,
  'tomato': 7,
  'potato': 30,
  'onion': 30,
  'broccoli': 7,
  'lettuce': 7,
  'cucumber': 7,
  'garlic': 30,
  'pepper': 14,

  // Bakery
  'bread': 7,
  'cake': 4,
  'muffin': 5,
  'bagel': 5,

  // Beverages
  'juice': 7,
  'coffee': 30,
  'tea': 730,

  // Frozen
  'ice cream': 60,
  'frozen chicken': 90,
  'frozen fish': 90,

  // Other
  'tofu': 5,
  'hummus': 7,
  'jam': 180,
  'sauce': 30,
};

int? getShelfLifeDays(String itemName) {
  final query = itemName.toLowerCase();
  String? bestMatch;
  int? bestDays;

  for (final entry in _shelfLife.entries) {
    final key = entry.key;
    if (query.contains(key)) {
      if (bestMatch == null || key.length > bestMatch.length) {
        bestMatch = key;
        bestDays = entry.value;
      }
    }
  }

  return bestDays;
}