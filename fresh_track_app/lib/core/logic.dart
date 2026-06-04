import 'package:flutter/material.dart';
import '../models/food_item.dart'; // Ensure this points to your model

ExpiryStatus getExpiryStatus(DateTime expiryDate) {
  final now = DateTime.now();
  final difference = expiryDate.difference(now).inDays;

  if (difference < 0) return ExpiryStatus.expired;
  if (difference <= 3) return ExpiryStatus.expiringSoon;
  return ExpiryStatus.safe;
}

// Logic to provide the UI with the right color based on the Enum
Color getStatusColor(ExpiryStatus status) {
  switch (status) {
    case ExpiryStatus.expired:
      return const Color(0xFFFF3B30); // Red
    case ExpiryStatus.expiringSoon:
      return const Color(0xFFFF9500); // Orange
    case ExpiryStatus.safe:
      return const Color(0xFF34C759); // Green
  }
}