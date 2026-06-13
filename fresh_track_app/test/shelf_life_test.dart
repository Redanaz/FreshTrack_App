import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_track_app/core/shelf_life_data.dart';

void main() {
  group('getShelfLifeDays Tests', () {
    test('Exact matches', () {
      expect(getShelfLifeDays('milk'), 7);
      expect(getShelfLifeDays('banana'), 5);
      expect(getShelfLifeDays('eggs'), 21);
      expect(getShelfLifeDays('tofu'), 5);
    });

    test('Case insensitivity and partial matches', () {
      expect(getShelfLifeDays('Organic Milk'), 7);
      expect(getShelfLifeDays('fresh banana slice'), 5);
      expect(getShelfLifeDays('Large Eggs'), 21);
    });

    test('Overlap matches (longer match prioritisation)', () {
      expect(getShelfLifeDays('frozen chicken'), 90);
      expect(getShelfLifeDays('chicken'), 2);
      expect(getShelfLifeDays('frozen fish'), 90);
      expect(getShelfLifeDays('fish'), 2);
      expect(getShelfLifeDays('cottage cheese'), 7);
      expect(getShelfLifeDays('cheese'), 30);
      expect(getShelfLifeDays('ice cream'), 60);
      expect(getShelfLifeDays('cream'), 7);
    });

    test('No match', () {
      expect(getShelfLifeDays('xyz'), null);
      expect(getShelfLifeDays('unknown product'), null);
    });
  });
}
