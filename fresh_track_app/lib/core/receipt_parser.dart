DateTime parseDateFromReceipt(String receiptText) {
  // Regex to find dates with /, -, or . separators
  final datePattern = RegExp(r'(\b\d{2}[\/\-.]\d{2}[\/\-.](\d{4}|\d{2})\b)');
  
  // Search after "TOTAL" first for accuracy, then fallback to whole text
  String textToSearch = receiptText;
  if (receiptText.toUpperCase().contains("TOTAL")) {
    textToSearch = receiptText.substring(receiptText.toUpperCase().indexOf("TOTAL"));
  }

  final match = datePattern.firstMatch(textToSearch) ?? datePattern.firstMatch(receiptText);

  if (match != null) {
    String dateString = match.group(0)!;
    List<String> parts = dateString.split(RegExp(r'[\/\-.]'));
    
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    if (year < 100) year += 2000;

    // Basic Indian/US format swap protection
    if (month > 12) {
      int temp = day;
      day = month;
      month = temp;
    }

    return DateTime(year, month, day);
  } else {
    // Default to 7 days if no date found
    return DateTime.now().add(const Duration(days: 7));
  }
}

String cleanItemName(String rawText) {
  // 1. Split text into lines
  List<String> lines = rawText.split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  
  // 2. The Blacklist: Skip these common receipt headers
  final blacklist = RegExp(
    r'(SUPERMARKET|GROCERY|MART|STORE|STREET|ROAD|TEL:|PH:|WELCOME|INVOICE|CASHIER|DATE|TIME|RECEIPT|ORDER|#|WWW\.)',
    caseSensitive: false,
  );

  String bestLine = "";

  // FIXED: Changed 'line' to 'lines' here
  for (String line in lines) {
    // Skip if it matches our header blacklist (like "Green Supermarket")
    if (blacklist.hasMatch(line)) continue;

    // Skip if it's just a price/number (e.g., "15.00" or "2026")
    if (double.tryParse(line.replaceAll(RegExp(r'[^\d.]'), '')) != null && 
        !line.contains(RegExp(r'[a-zA-Z]'))) {
      continue;
    }

    // Skip lines that are too short to be a product name
    if (line.length < 3) continue;

    // If we get here, this is the first real product!
    bestLine = line;
    break; 
  }

  // 3. Final Cleaning: Remove any prices attached to the name (e.g., "BREAD 2.50")
  String cleaned = (bestLine.isEmpty ? "New Item" : bestLine).toUpperCase()
      .replaceAll(RegExp(r'\d+\.\d{2}'), '') // Remove prices like 4.99
      .replaceAll(RegExp(r'\b(TAX|TOTAL|SUBTOTAL|CASH)\b'), '')
      .replaceAll(RegExp(r'[^\w\s%.]'), '') 
      .trim();

  return cleaned.isNotEmpty ? cleaned : "Unknown Item";
}

List<String> extractAllItems(String rawText) {
  List<String> lines = rawText.split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
      
  final blacklist = RegExp(
    r'(SUPERMARKET|GROCERY|MART|STORE|STREET|ROAD|TEL:|PH:|WELCOME|INVOICE|CASHIER|DATE|TIME|RECEIPT|ORDER|#|WWW\.|TOTAL|SUBTOTAL|TAX|CASH|CHANGE|VISA|MASTERCARD|CARD)',
    caseSensitive: false,
  );

  List<String> items = [];
  for (String line in lines) {
    if (blacklist.hasMatch(line)) continue;
    if (double.tryParse(line.replaceAll(RegExp(r'[^\d.]'), '')) != null && 
        !line.contains(RegExp(r'[a-zA-Z]'))) {
      continue;
    }
    if (line.length < 3) continue;

    String cleaned = line.toUpperCase()
        .replaceAll(RegExp(r'\d+\.\d{2}'), '')
        .replaceAll(RegExp(r'[^\w\s%.]'), '') 
        .trim();
        
    if (cleaned.isNotEmpty && !items.contains(cleaned)) {
      items.add(cleaned);
    }
  }

  if (items.isEmpty) return ["Unknown Item"];
  return items;
}