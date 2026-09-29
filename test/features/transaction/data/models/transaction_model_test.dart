import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/features/transaction/data/models/transaction_model.dart';

void main() {
  final validMap = <String, dynamic>{
    'user_id': 'user1',
    'type': 'expense',
    'amount': 100.5,
    'category': 'Food & Dining',
    'note': 'lunch',
    'date': '2024-01-15T12:00:00.000',
  };

  group('TransactionModel.fromMap — happy path', () {
    test('maps all fields correctly', () {
      final m = TransactionModel.fromMap(validMap, 'tx1');
      expect(m.id, 'tx1');
      expect(m.userId, 'user1');
      expect(m.type, 'expense');
      expect(m.amount, 100.5);
      expect(m.category, 'Food & Dining');
      expect(m.note, 'lunch');
      expect(m.date, DateTime.parse('2024-01-15T12:00:00.000'));
    });

    test('parses integer amount as double', () {
      final m = TransactionModel.fromMap({...validMap, 'amount': 200}, 'tx1');
      expect(m.amount, 200.0);
      expect(m.amount, isA<double>());
    });

    test('parses income type correctly', () {
      final m = TransactionModel.fromMap({...validMap, 'type': 'income'}, 'tx1');
      expect(m.type, 'income');
    });
  });

  group('TransactionModel.fromMap — null / missing fields', () {
    test('null user_id defaults to empty string', () {
      final m = TransactionModel.fromMap({...validMap, 'user_id': null}, 'tx1');
      expect(m.userId, '');
    });

    test('missing user_id defaults to empty string', () {
      final map = Map<String, dynamic>.from(validMap)..remove('user_id');
      final m = TransactionModel.fromMap(map, 'tx1');
      expect(m.userId, '');
    });

    test('null amount defaults to 0.0', () {
      final m = TransactionModel.fromMap({...validMap, 'amount': null}, 'tx1');
      expect(m.amount, 0.0);
    });

    test('null category defaults to empty string', () {
      final m = TransactionModel.fromMap({...validMap, 'category': null}, 'tx1');
      expect(m.category, '');
    });

    test('null note defaults to empty string', () {
      final m = TransactionModel.fromMap({...validMap, 'note': null}, 'tx1');
      expect(m.note, '');
    });

    test('null date defaults to a DateTime instance', () {
      final before = DateTime.now();
      final m = TransactionModel.fromMap({...validMap, 'date': null}, 'tx1');
      final after = DateTime.now();
      expect(m.date.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(m.date.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('invalid date string defaults to a DateTime instance', () {
      final m = TransactionModel.fromMap({...validMap, 'date': 'not-a-date'}, 'tx1');
      expect(m.date, isA<DateTime>());
    });

    test('empty map creates model with all defaults', () {
      final m = TransactionModel.fromMap({}, 'tx_empty');
      expect(m.id, 'tx_empty');
      expect(m.userId, '');
      expect(m.type, '');
      expect(m.amount, 0.0);
      expect(m.category, '');
      expect(m.note, '');
      expect(m.date, isA<DateTime>());
    });
  });

  group('TransactionModel.toMap', () {
    late TransactionModel model;
    final date = DateTime(2024, 3, 20, 10, 30);

    setUp(() {
      model = TransactionModel(
        id: 'tx99',
        userId: 'user99',
        type: 'income',
        amount: 5000.0,
        category: 'Salary',
        note: 'paycheck',
        date: date,
      );
    });

    test('contains user_id', () => expect(model.toMap()['user_id'], 'user99'));
    test('contains type', () => expect(model.toMap()['type'], 'income'));
    test('contains amount', () => expect(model.toMap()['amount'], 5000.0));
    test('contains category', () => expect(model.toMap()['category'], 'Salary'));
    test('contains note', () => expect(model.toMap()['note'], 'paycheck'));
    test('date is ISO8601 string', () => expect(model.toMap()['date'], date.toIso8601String()));
    test('does NOT contain id key', () => expect(model.toMap().containsKey('id'), isFalse));

    test('roundtrip fromMap → toMap preserves fields', () {
      final map = model.toMap();
      final m2 = TransactionModel.fromMap(map, model.id);
      expect(m2.userId, model.userId);
      expect(m2.type, model.type);
      expect(m2.amount, model.amount);
      expect(m2.category, model.category);
      expect(m2.note, model.note);
    });
  });

  group('TransactionModel type normalisation (Thai-mode bug)', () {
    test('Thai "รายรับ" is read as Income', () {
      final m = TransactionModel.fromMap({...validMap, 'type': 'รายรับ'}, 'tx1');
      expect(m.type.toLowerCase(), 'income');
    });

    test('Thai "รายจ่าย" is read as Expense', () {
      final m = TransactionModel.fromMap({...validMap, 'type': 'รายจ่าย'}, 'tx1');
      expect(m.type.toLowerCase(), 'expense');
    });

    test('English values are kept as they are', () {
      expect(TransactionModel.normalizeType('income'), 'income');
      expect(TransactionModel.normalizeType('Expense'), 'Expense');
    });
  });
}
