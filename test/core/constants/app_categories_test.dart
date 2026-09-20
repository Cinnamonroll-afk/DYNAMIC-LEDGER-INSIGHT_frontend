import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/core/constants/app_categories.dart';

void main() {
  group('AppCategories — counts', () {
    test('income has exactly 9 items', () {
      expect(AppCategories.income.length, 9);
    });

    test('expense has exactly 28 items', () {
      expect(AppCategories.expense.length, 28);
    });

    test('incomeLabels length matches income list', () {
      expect(AppCategories.incomeLabels.length, AppCategories.income.length);
    });

    test('expenseLabels length matches expense list', () {
      expect(AppCategories.expenseLabels.length, AppCategories.expense.length);
    });
  });

  group('AppCategories — forType', () {
    test('forType(true) returns income list', () {
      expect(AppCategories.forType(true), AppCategories.income);
    });

    test('forType(false) returns expense list', () {
      expect(AppCategories.forType(false), AppCategories.expense);
    });
  });

  group('AppCategories — uniqueness', () {
    test('all income ids are unique', () {
      final ids = AppCategories.income.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('all expense ids are unique', () {
      final ids = AppCategories.expense.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('all income labels are unique', () {
      final labels = AppCategories.incomeLabels;
      expect(labels.toSet().length, labels.length);
    });

    test('all expense labels are unique', () {
      final labels = AppCategories.expenseLabels;
      expect(labels.toSet().length, labels.length);
    });
  });

  group('AppCategories — label content', () {
    test('incomeLabels contains Salary', () {
      expect(AppCategories.incomeLabels, contains('Salary'));
    });

    test('incomeLabels contains Bonus', () {
      expect(AppCategories.incomeLabels, contains('Bonus'));
    });

    test('expenseLabels contains Food & Dining', () {
      expect(AppCategories.expenseLabels, contains('Food & Dining'));
    });

    test('expenseLabels contains Grocery', () {
      expect(AppCategories.expenseLabels, contains('Grocery'));
    });

    test('expenseLabels contains Healthcare', () {
      expect(AppCategories.expenseLabels, contains('Healthcare'));
    });
  });

  group('AppCategories — groups', () {
    test('Salary is in Active Income group', () {
      final item = AppCategories.income.firstWhere((c) => c.id == 'salary');
      expect(item.group, 'Active Income');
    });

    test('Bonus is in Active Income group', () {
      final item = AppCategories.income.firstWhere((c) => c.id == 'bonus');
      expect(item.group, 'Active Income');
    });

    test('Rental Income is in Passive Income group', () {
      final item = AppCategories.income.firstWhere((c) => c.id == 'rental');
      expect(item.group, 'Passive Income');
    });

    test('Food & Dining is in Variable group', () {
      final item = AppCategories.expense.firstWhere((c) => c.id == 'food');
      expect(item.group, 'Variable');
    });

    test('Home Loan is in Installment group', () {
      final item = AppCategories.expense.firstWhere((c) => c.id == 'home_loan');
      expect(item.group, 'Installment');
    });

    test('Life Insurance is in Fixed group', () {
      final item = AppCategories.expense.firstWhere((c) => c.id == 'life_insurance');
      expect(item.group, 'Fixed');
    });

    test('Investment Saving is in Saving group', () {
      final item = AppCategories.expense.firstWhere((c) => c.id == 'saving_invest');
      expect(item.group, 'Saving');
    });
  });

  group('AppCategories — localizedLabel', () {
    test('returns Thai for Salary with th locale', () {
      expect(AppCategories.localizedLabel('Salary', 'th'), 'เงินเดือน');
    });

    test('returns Thai for Food & Dining with th locale', () {
      expect(AppCategories.localizedLabel('Food & Dining', 'th'), 'อาหารและร้านอาหาร');
    });

    test('returns Thai for Grocery with th locale', () {
      expect(AppCategories.localizedLabel('Grocery', 'th'), 'ของชำ');
    });

    test('returns English for en locale', () {
      expect(AppCategories.localizedLabel('Salary', 'en'), 'Salary');
    });

    test('returns original label if not in Thai map', () {
      expect(AppCategories.localizedLabel('UnknownCategory', 'th'), 'UnknownCategory');
    });

    test('returns label unchanged for other locale codes', () {
      expect(AppCategories.localizedLabel('Bonus', 'fr'), 'Bonus');
    });
  });

  group('AppCategories — CategoryItem fields', () {
    test('every income item has non-empty id', () {
      for (final item in AppCategories.income) {
        expect(item.id, isNotEmpty, reason: '${item.label} has empty id');
      }
    });

    test('every income item has non-empty label', () {
      for (final item in AppCategories.income) {
        expect(item.label, isNotEmpty, reason: '${item.id} has empty label');
      }
    });

    test('every expense item has non-empty id', () {
      for (final item in AppCategories.expense) {
        expect(item.id, isNotEmpty, reason: '${item.label} has empty id');
      }
    });

    test('every expense item has non-empty label', () {
      for (final item in AppCategories.expense) {
        expect(item.label, isNotEmpty, reason: '${item.id} has empty label');
      }
    });
  });
}
