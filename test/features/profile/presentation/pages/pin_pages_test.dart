// Coverage: URS-06-02 (set PIN), URS-06-03 (change PIN requires current PIN),
//           URS-06-04 (PIN mismatch error), URS-06-05 (unlock with PIN)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fincontrol/features/profile/presentation/pages/setup_pin_page.dart';
import 'package:fincontrol/features/profile/presentation/pages/unlock_pin_page.dart';

// ── Helpers ────────────────────────────────────────────────────────────────

Widget _wrapSetup() => const MaterialApp(home: SetupPinPage());

Widget _wrapUnlock(String pin) => MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => UnlockPinPage(correctPin: pin)),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

/// Tap a number button on the PIN pad.
Future<void> _tap(WidgetTester t, String digit) async {
  await t.tap(find.widgetWithText(TextButton, digit).first);
  await t.pump();
}

/// Enter a full 6-digit PIN and wait for [_processCompletedPin] delay.
Future<void> _enterPin(WidgetTester t, String pin) async {
  for (final d in pin.split('')) {
    await _tap(t, d);
  }
  await t.pump(const Duration(milliseconds: 300)); // await Future.delayed(200ms)
  await t.pump();
}

// ── SetupPinPage ───────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SetupPinPage — initial state (URS-06-02 / URS-06-03)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('shows "Enter New PIN" when no existing PIN is set', (t) async {
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      expect(find.text('Enter New PIN'), findsOneWidget);
    });

    testWidgets('shows "Enter Current PIN" when existing PIN exists in prefs', (t) async {
      SharedPreferences.setMockInitialValues({'app_lock_pin': '111111'});
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      expect(find.text('Enter Current PIN'), findsOneWidget);
    });

    testWidgets('number pad has digits 0–9 and delete button', (t) async {
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      for (final d in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
        expect(find.widgetWithText(TextButton, d), findsOneWidget);
      }
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });
  });

  group('SetupPinPage — enterNew → confirmNew flow (URS-06-02)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('entering 6 digits advances to "Confirm New PIN"', (t) async {
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      await _enterPin(t, '123456');
      expect(find.text('Confirm New PIN'), findsOneWidget);
    });

    testWidgets('only 6 digits trigger auto-submit (5 digits stays on Enter New PIN)', (t) async {
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      for (final d in '12345'.split('')) {
        await _tap(t, d);
      }
      await t.pump();
      expect(find.text('Enter New PIN'), findsOneWidget); // not advanced yet
    });
  });

  group('SetupPinPage — PIN mismatch error (URS-06-04)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('mismatched confirm PIN shows "PINs do not match. Try again."', (t) async {
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      await _enterPin(t, '123456'); // enter new
      await _enterPin(t, '999999'); // wrong confirm
      expect(find.text('PINs do not match. Try again.'), findsOneWidget);
    });

    testWidgets('after mismatch, page stays on Confirm New PIN', (t) async {
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      await _enterPin(t, '123456');
      await _enterPin(t, '999999');
      expect(find.text('Confirm New PIN'), findsOneWidget);
    });

    testWidgets('error message clears when a new digit is pressed after mismatch', (t) async {
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      await _enterPin(t, '123456');
      await _enterPin(t, '999999'); // mismatch — shows error
      await _tap(t, '1'); // start typing again
      expect(find.text('PINs do not match. Try again.'), findsNothing);
    });
  });

  group('SetupPinPage — save PIN to SharedPreferences (URS-06-02)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('matching confirm PIN saves to SharedPreferences', (t) async {
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      await _enterPin(t, '654321'); // enter new
      try {
        await _enterPin(t, '654321'); // confirm — matches → Navigator.pop
        await t.pumpAndSettle();
      } catch (_) {
        // Navigator.pop on root route can throw in test — that's expected
      }
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_lock_pin'), '654321');
    });
  });

  group('SetupPinPage — change PIN requires current PIN (URS-06-03)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'app_lock_pin': '111111'});
    });

    testWidgets('wrong current PIN shows "Incorrect PIN. Try again."', (t) async {
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      await _enterPin(t, '999999'); // wrong current PIN
      expect(find.text('Incorrect PIN. Try again.'), findsOneWidget);
    });

    testWidgets('correct current PIN advances to "Enter New PIN"', (t) async {
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      await _enterPin(t, '111111'); // correct current PIN
      expect(find.text('Enter New PIN'), findsOneWidget);
    });

    testWidgets('wrong current PIN clears input for retry', (t) async {
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      await _enterPin(t, '999999'); // wrong
      // Can type again after clearing
      await _tap(t, '1');
      expect(find.text('Incorrect PIN. Try again.'), findsNothing);
    });
  });

  group('SetupPinPage — delete button', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('delete button does not crash when input is empty', (t) async {
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.backspace_outlined));
      await t.pump();
      // No exception thrown — page still shows Enter New PIN
      expect(find.text('Enter New PIN'), findsOneWidget);
    });

    testWidgets('delete button removes last digit (prevents 6-digit auto-submit)', (t) async {
      await t.pumpWidget(_wrapSetup());
      await t.pumpAndSettle();
      for (final d in '12345'.split('')) {
        await _tap(t, d);
      }
      await t.tap(find.byIcon(Icons.backspace_outlined)); // remove '5'
      await t.pump();
      await _tap(t, '9'); // now has '12349' — 5 digits, still no submit
      await t.pump();
      expect(find.text('Enter New PIN'), findsOneWidget); // not advanced
    });
  });

  // ── UnlockPinPage ──────────────────────────────────────────────────────────

  group('UnlockPinPage — UI (URS-06-05)', () {
    testWidgets('shows "Enter App Lock PIN" heading', (t) async {
      await t.pumpWidget(
        const MaterialApp(home: UnlockPinPage(correctPin: '123456')),
      );
      await t.pump();
      expect(find.text('Enter App Lock PIN'), findsOneWidget);
    });

    testWidgets('lock icon is displayed', (t) async {
      await t.pumpWidget(
        const MaterialApp(home: UnlockPinPage(correctPin: '123456')),
      );
      await t.pump();
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });
  });

  group('UnlockPinPage — wrong PIN (URS-06-05)', () {
    testWidgets('incorrect PIN shows "Incorrect PIN. Try again."', (t) async {
      await t.pumpWidget(
        const MaterialApp(home: UnlockPinPage(correctPin: '123456')),
      );
      await t.pump();
      await _enterPin(t, '000000');
      expect(find.text('Incorrect PIN. Try again.'), findsOneWidget);
    });

    testWidgets('incorrect PIN clears input so user can retry', (t) async {
      await t.pumpWidget(
        const MaterialApp(home: UnlockPinPage(correctPin: '123456')),
      );
      await t.pump();
      await _enterPin(t, '000000'); // wrong
      await _tap(t, '1'); // starts new input
      expect(find.text('Incorrect PIN. Try again.'), findsNothing); // error clears
    });

    testWidgets('multiple wrong attempts keep showing error each time', (t) async {
      await t.pumpWidget(
        const MaterialApp(home: UnlockPinPage(correctPin: '123456')),
      );
      await t.pump();
      await _enterPin(t, '000000'); // wrong 1
      expect(find.text('Incorrect PIN. Try again.'), findsOneWidget);
      await _enterPin(t, '111111'); // wrong 2
      expect(find.text('Incorrect PIN. Try again.'), findsOneWidget);
    });
  });

  group('UnlockPinPage — PopScope (URS-06-05)', () {
    testWidgets('PopScope(canPop: false) — back press does not dismiss unlock page', (t) async {
      // Push from a parent so there is a route to pop to
      await t.pumpWidget(_wrapUnlock('123456'));
      await t.pump();
      await t.tap(find.text('Open'));
      await t.pumpAndSettle();
      expect(find.text('Enter App Lock PIN'), findsOneWidget);

      // Simulate back-button press — PopScope canPop:false should block it
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      // Still on unlock page
      expect(find.text('Enter App Lock PIN'), findsOneWidget);
    });
  });

  group('UnlockPinPage — delete button', () {
    testWidgets('delete button does not crash on empty input', (t) async {
      await t.pumpWidget(
        const MaterialApp(home: UnlockPinPage(correctPin: '123456')),
      );
      await t.pump();
      await t.tap(find.byIcon(Icons.backspace_outlined));
      await t.pump();
      expect(find.text('Enter App Lock PIN'), findsOneWidget);
    });
  });
}
