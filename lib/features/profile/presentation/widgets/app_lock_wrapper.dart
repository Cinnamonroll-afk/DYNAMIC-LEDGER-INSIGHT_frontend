import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fincontrol/features/profile/presentation/pages/unlock_pin_page.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;
  
  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> with WidgetsBindingObserver {
  bool _isLockScreenShowing = false;
  bool _wasActuallyPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Check pin when app first launches
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _wasActuallyPaused = true;
    }
    if (state == AppLifecycleState.resumed && _wasActuallyPaused) {
      _wasActuallyPaused = false;
      _checkAndShowLockScreen();
    }
  }

  Future<void> _checkAndShowLockScreen() async {
    // Don't show if it's already showing
    if (_isLockScreenShowing) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) return;

    final pin = prefs.getString('app_lock_pin');

    if (pin != null && pin.isNotEmpty && mounted) {
      _isLockScreenShowing = true;
      
      // Push the unlock page full screen
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UnlockPinPage(correctPin: pin),
          fullscreenDialog: true,
        ),
      );
      
      // When the user successfully unlocks and it pops, we reset the flag
      _isLockScreenShowing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
