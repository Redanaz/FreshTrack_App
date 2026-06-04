import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_track_app/main.dart';

void main() {
  testWidgets('App renders FreshTrack title', (WidgetTester tester) async {
    await tester.pumpWidget(const FreshTrackApp());

    expect(find.text('FreshTrack'), findsOneWidget);
    expect(find.text('Track your food expiry dates'), findsOneWidget);
  });

  testWidgets('Home screen shows Scan Receipt and Add Item buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FreshTrackApp());

    expect(find.text('Scan Receipt'), findsOneWidget);
    expect(find.text('Add Item'), findsOneWidget);
  });

  testWidgets('Home screen shows All/Expiring/Expired tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FreshTrackApp());

    expect(find.textContaining('All'), findsOneWidget);
    expect(find.textContaining('Expiring'), findsOneWidget);
    expect(find.textContaining('Expired'), findsOneWidget);
  });

  testWidgets('Add Item dialog opens on button tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FreshTrackApp());

    await tester.tap(find.text('Add Item'));
    await tester.pumpAndSettle();

    expect(find.text('Add New Item'), findsOneWidget);
    expect(find.text('Item Name'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Expiry Date'), findsOneWidget);
  });

  testWidgets('Scan Receipt dialog opens on button tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FreshTrackApp());

    await tester.tap(find.text('Scan Receipt'));
    await tester.pumpAndSettle();

    expect(find.text('Scan Receipt'), findsWidgets);
    expect(find.text('Scan with Camera'), findsOneWidget);
    expect(find.text('Upload Image'), findsOneWidget);
  });

  testWidgets('Add Item dialog closes on Cancel tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FreshTrackApp());

    await tester.tap(find.text('Add Item'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Add New Item'), findsNothing);
  });

  testWidgets('Food items are displayed on home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FreshTrackApp());

    expect(find.text('Fresh Milk'), findsOneWidget);
    expect(find.text('Strawberries'), findsOneWidget);
    expect(find.text('Orange Juice'), findsOneWidget);
  });

  testWidgets('Search filters food items', (WidgetTester tester) async {
    await tester.pumpWidget(const FreshTrackApp());

    await tester.enterText(find.byType(TextField).first, 'Milk');
    await tester.pump();

    expect(find.text('Fresh Milk'), findsOneWidget);
    expect(find.text('Strawberries'), findsNothing);
  });
}