# 🥦 FreshTrack — Food Expiry Tracker

> Track your food. Reduce waste.

FreshTrack is a cross-platform mobile application built with Flutter that helps households monitor food expiry dates, reduce waste, and get notified before items go bad.

---

## 📱 Screenshots

<img width="350" alt="Login Screen" src="https://github.com/user-attachments/assets/d177fba8-2fe7-4a7c-97b6-4b33407895de" />
<img width="350" alt="Home Screen" src="https://github.com/user-attachments/assets/082a44b9-95c0-4c9c-bb55-df7d0d6a08ab" />
<img width="350" alt="Inventory" src="https://github.com/user-attachments/assets/25bd1f32-5677-4eaa-8ad8-e26f633ea3c9" />
<img width="350" alt="Expiring Soon" src="https://github.com/user-attachments/assets/132bdbec-8821-429f-9815-49b257f212ca" />
<img width="350" alt="Scan Receipt" src="https://github.com/user-attachments/assets/25fb872c-4e48-49a7-b1cb-822df600bcf7" />
<img width="350" alt="Notification" src="https://github.com/user-attachments/assets/8a1f00e7-42d0-4dfc-b84b-dd5197c1e92d" />


---

## ✨ Features

- **Inventory Management** — Add, edit, and delete food items with name, category, quantity, and expiry date
- **Receipt Scanner** — Scan grocery receipts using your camera to auto-extract item names and dates via Google ML Kit OCR
- **Smart Date Suggestions** — Automatically suggests expiry dates based on a built-in shelf life dataset (milk, eggs, chicken, fruits, vegetables, and more)
- **Expiry Status Tracking** — Color-coded badges for Safe 🟢, Expiring Soon 🟡, and Expired 🔴
- **Push Notifications** — Get alerted 2 days before an item expires, and instantly when adding items that are already expiring soon
- **Cloud Sync** — All data synced to Supabase so your inventory persists across sessions
- **Authentication** — Secure email and password sign-in via Supabase Auth
- **Search & Filter** — Search by name and filter by All, Expiring Soon, or Expired
- **Select All in Scan Review** — After scanning, review all extracted items and select/deselect what to add

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Backend & Database | Supabase (PostgreSQL) |
| Authentication | Supabase Auth (Email/Password) |
| OCR / Text Recognition | Google ML Kit |
| Notifications | Flutter Local Notifications |
| Image Picker | image_picker |
| Date Formatting | intl |

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants.dart          # App colors and text styles
│   ├── logic.dart              # Expiry status and color logic
│   ├── notification_service.dart  # Local notification scheduling
│   ├── receipt_parser.dart     # OCR text parsing logic
│   ├── shelf_life_data.dart    # Local shelf life dataset
│   └── supabase_service.dart   # Supabase CRUD operations
├── models/
│   └── food_item.dart          # FoodItem model and ExpiryStatus enum
├── screens/
│   ├── additem_screen.dart     # Add/Edit item dialog
│   ├── home_screen.dart        # Main inventory screen
│   ├── login_screen.dart       # Auth screen
│   └── review_items_screen.dart  # Post-scan item review checklist
├── widgets/
│   ├── action_button.dart      # Reusable action button
│   ├── food_card.dart          # Food item card widget
│   └── scan_dialog.dart        # Camera/upload scan dialog
└── main.dart                   # App entry point and auth gate
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Android Studio or VS Code
- A Supabase account ([supabase.com](https://supabase.com))

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/fresh_track_app.git
cd fresh_track_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Set up Supabase**

   - Create a new project on [supabase.com](https://supabase.com)
   - Run this SQL in the Supabase SQL Editor:

```sql
create table food_items (
  id text primary key,
  name text not null,
  category text not null,
  expiry_date timestamptz not null,
  quantity text not null,
  user_id uuid references auth.users(id) on delete cascade
);

alter table food_items enable row level security;

create policy "Users manage own items"
  on food_items for all
  using (auth.uid() = user_id);
```

   - Go to **Authentication → Providers → Email** and disable "Confirm email"

4. **Add your Supabase credentials**

   In `lib/main.dart`, replace:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

5. **Run the app**
```bash
flutter run
```

---

## 🔔 Notifications

- Scheduled 2 days before expiry at **9:00 AM**
- Immediate notification when adding or editing an item with **≤ 2 days** left
- Notification actions: **Snooze** and **I ate this**

> Requires `SCHEDULE_EXACT_ALARM` and `POST_NOTIFICATIONS` permissions on Android 12+

---

## 🗄️ Database Schema

| Column | Type | Description |
|---|---|---|
| `id` | text | Unique item ID |
| `name` | text | Food item name |
| `category` | text | Category (Dairy, Fruits, etc.) |
| `expiry_date` | timestamptz | Expiry date and time |
| `quantity` | text | Quantity string (e.g. 1L, 500g) |
| `user_id` | uuid | References auth.users |

---

## 📦 Dependencies

```yaml
supabase_flutter: ^2.5.0
flutter_local_notifications: ^17.0.0
timezone: ^0.9.4
google_mlkit_text_recognition: ^0.13.0
image_picker: ^1.0.7
google_sign_in: ^6.2.1
intl: ^0.19.0
```

---

## 🙋 Author

Developed as a Mini Project for academic submission.

---

## 📄 License

This project is for educational purposes only.
