// Coverage: NotificationModel serialisation (supports URS-05-01..05-05 notification feature)

import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/features/notifications/data/models/notification_model.dart';

void main() {
  final fixedDate = DateTime(2024, 6, 15, 10, 30);

  // ── fromMap ────────────────────────────────────────────────────────────────

  group('NotificationModel.fromMap — happy path', () {
    test('maps all fields correctly', () {
      final map = {
        'userId': 'user1',
        'title': 'Market Alert',
        'message': 'AAPL is up 5%',
        'type': 'market',
        'isRead': false,
        'createdAt': fixedDate.toIso8601String(),
      };
      final model = NotificationModel.fromMap(map, 'notif-1');

      expect(model.id, 'notif-1');
      expect(model.userId, 'user1');
      expect(model.title, 'Market Alert');
      expect(model.message, 'AAPL is up 5%');
      expect(model.type, 'market');
      expect(model.isRead, isFalse);
      expect(model.createdAt, fixedDate);
    });

    test('maps isRead = true correctly', () {
      final map = {
        'userId': 'u2', 'title': 'Goal', 'message': 'Goal reached',
        'type': 'goal', 'isRead': true, 'createdAt': fixedDate.toIso8601String(),
      };
      expect(NotificationModel.fromMap(map, 'n2').isRead, isTrue);
    });

    test('maps all valid notification types without error', () {
      for (final type in ['market', 'goal', 'ai', 'budget', 'bill']) {
        final map = {'userId': 'u', 'title': 't', 'message': 'm', 'type': type, 'isRead': false, 'createdAt': fixedDate.toIso8601String()};
        expect(NotificationModel.fromMap(map, 'id').type, type);
      }
    });
  });

  group('NotificationModel.fromMap — null / missing fields', () {
    test('null userId defaults to empty string', () {
      final m = {'userId': null, 'title': 't', 'message': 'm', 'type': 'ai', 'isRead': false, 'createdAt': fixedDate.toIso8601String()};
      expect(NotificationModel.fromMap(m, 'id').userId, '');
    });

    test('missing title defaults to empty string', () {
      final m = {'userId': 'u', 'message': 'm', 'type': 'ai', 'isRead': false, 'createdAt': fixedDate.toIso8601String()};
      expect(NotificationModel.fromMap(m, 'id').title, '');
    });

    test('missing message defaults to empty string', () {
      final m = {'userId': 'u', 'title': 't', 'type': 'ai', 'isRead': false, 'createdAt': fixedDate.toIso8601String()};
      expect(NotificationModel.fromMap(m, 'id').message, '');
    });

    test('missing type defaults to "market"', () {
      final m = {'userId': 'u', 'title': 't', 'message': 'm', 'isRead': false, 'createdAt': fixedDate.toIso8601String()};
      expect(NotificationModel.fromMap(m, 'id').type, 'market');
    });

    test('missing isRead defaults to false', () {
      final m = {'userId': 'u', 'title': 't', 'message': 'm', 'type': 'goal', 'createdAt': fixedDate.toIso8601String()};
      expect(NotificationModel.fromMap(m, 'id').isRead, isFalse);
    });

    test('null createdAt uses DateTime.now() (does not throw)', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final m = {'userId': 'u', 'title': 't', 'message': 'm', 'type': 'goal', 'isRead': false, 'createdAt': null};
      expect(NotificationModel.fromMap(m, 'id').createdAt.isAfter(before), isTrue);
    });

    test('invalid createdAt string uses DateTime.now() (does not throw)', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final m = {'userId': 'u', 'title': 't', 'message': 'm', 'type': 'goal', 'isRead': false, 'createdAt': 'NOT_A_DATE'};
      expect(NotificationModel.fromMap(m, 'id').createdAt.isAfter(before), isTrue);
    });

    test('completely empty map uses all defaults without throwing', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final model = NotificationModel.fromMap({}, 'empty-id');
      expect(model.id, 'empty-id');
      expect(model.userId, '');
      expect(model.title, '');
      expect(model.message, '');
      expect(model.type, 'market');
      expect(model.isRead, isFalse);
      expect(model.createdAt.isAfter(before), isTrue);
    });
  });

  // ── toMap ──────────────────────────────────────────────────────────────────

  group('NotificationModel.toMap', () {
    test('serialises all fields correctly', () {
      final model = NotificationModel(
        id: 'notif-1', userId: 'user1', title: 'Budget Warning',
        message: 'You have exceeded your budget', type: 'budget',
        isRead: false, createdAt: fixedDate,
      );
      final map = model.toMap();
      expect(map['userId'], 'user1');
      expect(map['title'], 'Budget Warning');
      expect(map['message'], 'You have exceeded your budget');
      expect(map['type'], 'budget');
      expect(map['isRead'], isFalse);
      expect(map['createdAt'], fixedDate.toIso8601String());
    });

    test('id is NOT included in toMap (stored as document key separately)', () {
      final model = NotificationModel(id: 'notif-1', userId: 'u', title: 't', message: 'm', type: 'ai', isRead: false, createdAt: fixedDate);
      expect(model.toMap().containsKey('id'), isFalse);
    });

    test('isRead = true is preserved in toMap', () {
      final model = NotificationModel(id: 'n', userId: 'u', title: 't', message: 'm', type: 'bill', isRead: true, createdAt: fixedDate);
      expect(model.toMap()['isRead'], isTrue);
    });

    test('createdAt is stored as valid ISO 8601 string', () {
      final model = NotificationModel(id: 'n', userId: 'u', title: 't', message: 'm', type: 'market', isRead: false, createdAt: fixedDate);
      final stored = model.toMap()['createdAt'] as String;
      expect(DateTime.tryParse(stored), isNotNull);
      expect(DateTime.parse(stored), fixedDate);
    });
  });

  // ── roundtrip ──────────────────────────────────────────────────────────────

  group('NotificationModel — fromMap → toMap roundtrip', () {
    test('roundtrip preserves all fields', () {
      final original = NotificationModel(
        id: 'rt-1', userId: 'user-rt', title: 'AI Insight',
        message: 'Your spending is under control', type: 'ai',
        isRead: true, createdAt: fixedDate,
      );
      final restored = NotificationModel.fromMap(original.toMap(), original.id);
      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.title, original.title);
      expect(restored.message, original.message);
      expect(restored.type, original.type);
      expect(restored.isRead, original.isRead);
      expect(restored.createdAt.toIso8601String(), original.createdAt.toIso8601String());
    });
  });
}
