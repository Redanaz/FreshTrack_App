enum ExpiryStatus { safe, expiringSoon, expired }

class FoodItem {
  final String id;
  final String name;
  final String category;
  final DateTime expiryDate;
  final String quantity;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.expiryDate,
    required this.quantity,
  });

  ExpiryStatus get status {
    final now = DateTime.now();
    final diff = expiryDate.difference(now).inDays;
    if (diff < 0) return ExpiryStatus.expired;
    if (diff <= 3) return ExpiryStatus.expiringSoon;
    return ExpiryStatus.safe;
  }

  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;
}