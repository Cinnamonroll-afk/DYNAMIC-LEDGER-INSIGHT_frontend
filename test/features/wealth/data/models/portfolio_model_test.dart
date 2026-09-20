import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/features/wealth/data/models/portfolio_model.dart';

void main() {
  final validMap = <String, dynamic>{
    'user_id': 'user1',
    'name': 'My Portfolio',
    'icon': 128204,
    'note': 'Long term',
    'target_goal': 1000000.0,
    'created_at': '2024-01-01T00:00:00.000',
    'total_value': 50000.0,
    'change': 500.0,
    'change_percent': 1.0,
    'current_trend': 'up',
  };

  group('PortfolioModel.fromMap — happy path', () {
    test('maps all fields correctly', () {
      final m = PortfolioModel.fromMap(validMap, 'port1');
      expect(m.id, 'port1');
      expect(m.userId, 'user1');
      expect(m.name, 'My Portfolio');
      expect(m.icon, 128204);
      expect(m.note, 'Long term');
      expect(m.targetGoal, 1000000.0);
      expect(m.totalValue, 50000.0);
      expect(m.change, 500.0);
      expect(m.changePercent, 1.0);
      expect(m.currentTrend, 'up');
    });

    test('parses created_at as DateTime', () {
      final m = PortfolioModel.fromMap(validMap, 'port1');
      expect(m.createdAt, DateTime.parse('2024-01-01T00:00:00.000'));
    });

    test('integer total_value parses as double', () {
      final m = PortfolioModel.fromMap({...validMap, 'total_value': 1000}, 'port1');
      expect(m.totalValue, 1000.0);
    });
  });

  group('PortfolioModel.fromMap — null / missing fields', () {
    test('null targetGoal is null (nullable field)', () {
      final m = PortfolioModel.fromMap({...validMap, 'target_goal': null}, 'port1');
      expect(m.targetGoal, isNull);
    });

    test('missing targetGoal is null', () {
      final map = Map<String, dynamic>.from(validMap)..remove('target_goal');
      final m = PortfolioModel.fromMap(map, 'port1');
      expect(m.targetGoal, isNull);
    });

    test('null user_id defaults to empty string', () {
      expect(PortfolioModel.fromMap({...validMap, 'user_id': null}, 'p1').userId, '');
    });

    test('null name defaults to empty string', () {
      expect(PortfolioModel.fromMap({...validMap, 'name': null}, 'p1').name, '');
    });

    test('null note defaults to empty string', () {
      expect(PortfolioModel.fromMap({...validMap, 'note': null}, 'p1').note, '');
    });

    test('null icon defaults to 0', () {
      expect(PortfolioModel.fromMap({...validMap, 'icon': null}, 'p1').icon, 0);
    });

    test('null total_value defaults to 0.0', () {
      expect(PortfolioModel.fromMap({...validMap, 'total_value': null}, 'p1').totalValue, 0.0);
    });

    test('null change defaults to 0.0', () {
      expect(PortfolioModel.fromMap({...validMap, 'change': null}, 'p1').change, 0.0);
    });

    test('null current_trend defaults to "up"', () {
      expect(PortfolioModel.fromMap({...validMap, 'current_trend': null}, 'p1').currentTrend, 'up');
    });

    test('null created_at defaults to a DateTime', () {
      final m = PortfolioModel.fromMap({...validMap, 'created_at': null}, 'p1');
      expect(m.createdAt, isA<DateTime>());
    });

    test('invalid created_at defaults to a DateTime', () {
      final m = PortfolioModel.fromMap({...validMap, 'created_at': 'bad'}, 'p1');
      expect(m.createdAt, isA<DateTime>());
    });

    test('empty map creates model with all defaults', () {
      final m = PortfolioModel.fromMap({}, 'port_empty');
      expect(m.id, 'port_empty');
      expect(m.userId, '');
      expect(m.name, '');
      expect(m.targetGoal, isNull);
      expect(m.totalValue, 0.0);
    });
  });

  group('PortfolioModel.toMap', () {
    final model = PortfolioModel.fromMap(validMap, 'port1');
    final map = model.toMap();

    test('contains user_id', () => expect(map['user_id'], 'user1'));
    test('contains name', () => expect(map['name'], 'My Portfolio'));
    test('contains icon', () => expect(map['icon'], 128204));
    test('contains note', () => expect(map['note'], 'Long term'));
    test('contains target_goal', () => expect(map['target_goal'], 1000000.0));
    test('contains created_at as string', () => expect(map['created_at'], isA<String>()));
    test('does NOT contain total_value (computed)', () => expect(map.containsKey('total_value'), isFalse));
    test('does NOT contain change (computed)', () => expect(map.containsKey('change'), isFalse));
    test('does NOT contain change_percent (computed)', () => expect(map.containsKey('change_percent'), isFalse));
    test('does NOT contain id key', () => expect(map.containsKey('id'), isFalse));
  });

  group('PortfolioModel.copyWith', () {
    final original = PortfolioModel.fromMap(validMap, 'port1');

    test('updates name only', () {
      final updated = original.copyWith(name: 'Growth');
      expect(updated.name, 'Growth');
      expect(updated.id, 'port1');
      expect(updated.userId, 'user1');
    });

    test('updates totalValue only', () {
      final updated = original.copyWith(totalValue: 99999.0);
      expect(updated.totalValue, 99999.0);
      expect(updated.name, 'My Portfolio');
    });

    test('no args returns equivalent model', () {
      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.targetGoal, original.targetGoal);
      expect(copy.totalValue, original.totalValue);
    });
  });
}
