import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/food_item.dart';
import 'package:intl/intl.dart';

class FoodCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FoodCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildBadge() {
    switch (item.status) {
      case ExpiryStatus.expired:
        return _badge('Expired', AppColors.expired, AppColors.alertExpiredBg);
      case ExpiryStatus.expiringSoon:
        return _badge('Expires Soon', AppColors.expiringSoon, AppColors.alertExpiringSoonBg);
      case ExpiryStatus.safe:
        return _badge('${item.daysLeft} days left', AppColors.safe, const Color(0xFFD1FAE5));
    }
  }

  Widget _badge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  IconData _getIconForCategory() {
    final cat = item.category.toLowerCase();
    if (cat.contains('dairy') || cat.contains('milk') || cat.contains('cheese')) return Icons.water_drop;
    if (cat.contains('meat') || cat.contains('chicken') || cat.contains('beef')) return Icons.set_meal;
    if (cat.contains('fruit') || cat.contains('veg')) return Icons.apple;
    if (cat.contains('bakery') || cat.contains('bread')) return Icons.bakery_dining;
    return Icons.fastfood;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIconForCategory(), size: 32, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildBadge(),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${item.category} • Qty: ${item.quantity}', style: AppTextStyles.itemMeta),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Exp: ${DateFormat('MMM d, yyyy').format(item.expiryDate)}',
                          style: AppTextStyles.itemMeta.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onEdit,
                          child: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: onDelete,
                          child: const Icon(Icons.delete_outline, size: 20, color: AppColors.expired),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}