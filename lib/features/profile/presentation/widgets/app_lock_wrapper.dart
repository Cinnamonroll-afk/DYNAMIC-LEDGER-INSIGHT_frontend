import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fincontrol/features/auth/bloc/auth_bloc.dart';
import 'package:fincontrol/features/auth/bloc/auth_state.dart';
import 'package:fincontrol/features/profile/presentation/pages/unlock_pin_page.dart';
import 'package:fincontrol/features/profile/presentation/pages/setup_pin_page.dart';
import 'package:fincontrol/l10n/app_localizations.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper>
    with WidgetsBindingObserver {
  bool _isLockScreenShowing = false;
  bool _wasActuallyPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // On app launch — check lock only (no prompt)
      _checkAndShowLockScreen();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _wasActuallyPaused = true;
    }
    if (state == AppLifecycleState.resumed && _wasActuallyPaused) {
      _wasActuallyPaused = false;
      // On foreground resume — check lock only (no prompt)
      _checkAndShowLockScreen();
    }
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '';
  }

  Future<void> _checkAndShowLockScreen({bool showPromptIfNoPIN = false}) async {
    if (_isLockScreenShowing) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) return;

    final userId = await _getUserId();
    if (userId.isEmpty) return;

    final pin = prefs.getString('app_lock_pin_$userId');

    if (pin != null && pin.isNotEmpty && mounted) {
      // Has PIN → show lock screen
      _isLockScreenShowing = true;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UnlockPinPage(correctPin: pin),
          fullscreenDialog: true,
        ),
      );
      _isLockScreenShowing = false;
    } else if (showPromptIfNoPIN && mounted) {
      // No PIN + triggered from login → show setup prompt if not dismissed
      final dismissed =
          prefs.getBool('pin_prompt_dismissed_$userId') ?? false;
      if (!dismissed) {
        await _showPinSetupPrompt(userId);
      }
    }
  }

  Future<void> _showPinSetupPrompt(String userId) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PinSetupPromptSheet(userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.status != AuthStatus.authenticated &&
          curr.status == AuthStatus.authenticated,
      listener: (context, state) {
        // After login/signup → check lock AND show prompt if no PIN
        _checkAndShowLockScreen(showPromptIfNoPIN: true);
      },
      child: widget.child,
    );
  }
}

class _PinSetupPromptSheet extends StatelessWidget {
  final String userId;

  const _PinSetupPromptSheet({required this.userId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B4B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textColor?.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Icon(
            Icons.lock_outline,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.protectYourData,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pinSetupDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: textColor?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SetupPinPage(userId: userId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.setPinNow,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('pin_prompt_dismissed_$userId', true);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              l10n.skipForNow,
              style: TextStyle(
                fontSize: 15,
                color: textColor?.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
