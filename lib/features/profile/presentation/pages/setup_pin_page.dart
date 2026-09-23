import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fincontrol/l10n/app_localizations.dart';

enum PinSetupState { enterCurrent, enterNew, confirmNew, disable }

class SetupPinPage extends StatefulWidget {
  final String? userId;

  const SetupPinPage({super.key, this.userId});

  @override
  State<SetupPinPage> createState() => _SetupPinPageState();
}

class _SetupPinPageState extends State<SetupPinPage> {
  String _userId = '';
  String _currentPin = '';
  String _enteredPin = '';
  String _newPin = '';

  PinSetupState _state = PinSetupState.enterNew;
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = widget.userId ?? prefs.getString('user_id') ?? '';
    final existingPin = prefs.getString('app_lock_pin_$_userId');
    if (mounted) {
      setState(() {
        if (existingPin != null && existingPin.isNotEmpty) {
          _currentPin = existingPin;
          _state = PinSetupState.enterCurrent;
        }
        _isLoading = false;
      });
    }
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 6) {
      setState(() {
        _enteredPin += number;
        _errorMessage = '';
      });
      if (_enteredPin.length == 6) {
        _processCompletedPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = '';
      });
    }
  }

  void _processCompletedPin() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    switch (_state) {
      case PinSetupState.enterCurrent:
        if (_enteredPin == _currentPin) {
          setState(() {
            _enteredPin = '';
            _state = PinSetupState.enterNew;
          });
        } else {
          setState(() {
            _enteredPin = '';
            _errorMessage = AppLocalizations.of(context)!.incorrectPin;
          });
        }
        break;

      case PinSetupState.enterNew:
        setState(() {
          _newPin = _enteredPin;
          _enteredPin = '';
          _state = PinSetupState.confirmNew;
        });
        break;

      case PinSetupState.confirmNew:
        if (_enteredPin == _newPin) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('app_lock_pin_$_userId', _newPin);
          // Mark prompt as seen so it doesn't show again
          await prefs.setBool('pin_prompt_dismissed_$_userId', true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.pinSavedSuccessfully)),
            );
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _enteredPin = '';
            _errorMessage = AppLocalizations.of(context)!.pinsDoNotMatch;
          });
        }
        break;

      case PinSetupState.disable:
        if (_enteredPin == _currentPin) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('app_lock_pin_$_userId');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.appLockDisabled)),
            );
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _enteredPin = '';
            _errorMessage = AppLocalizations.of(context)!.incorrectPin;
          });
        }
        break;
    }
  }

  String _getTitle(AppLocalizations l10n) {
    switch (_state) {
      case PinSetupState.enterCurrent:
        return l10n.enterCurrentPin;
      case PinSetupState.enterNew:
        return l10n.enterNewPin;
      case PinSetupState.confirmNew:
        return l10n.confirmNewPin;
      case PinSetupState.disable:
        return l10n.enterPinToDisable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appLockPin),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              _getTitle(l10n),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style:
                    const TextStyle(color: Colors.redAccent, fontSize: 16),
              )
            else
              const SizedBox(height: 19),
            const SizedBox(height: 32),
            _buildPinIndicators(textColor),
            const Spacer(),
            _buildNumberPad(textColor),
            // ปุ่ม "ปิด App Lock" — แสดงเมื่อมี PIN อยู่แล้ว และไม่ได้อยู่ใน disable mode
            if (_currentPin.isNotEmpty && _state != PinSetupState.disable) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _state = PinSetupState.disable;
                    _enteredPin = '';
                    _errorMessage = '';
                  });
                },
                child: Text(
                  l10n.disableAppLock,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPinIndicators(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isFilled = index < _enteredPin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? textColor
                : textColor.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }

  Widget _buildNumberPad(Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1', textColor),
              _buildNumberButton('2', textColor),
              _buildNumberButton('3', textColor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4', textColor),
              _buildNumberButton('5', textColor),
              _buildNumberButton('6', textColor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7', textColor),
              _buildNumberButton('8', textColor),
              _buildNumberButton('9', textColor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 80, height: 80),
              _buildNumberButton('0', textColor),
              _buildDeleteButton(textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number, Color textColor) {
    return SizedBox(
      width: 80,
      height: 80,
      child: TextButton(
        onPressed: () => _onNumberPressed(number),
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: textColor.withValues(alpha: 0.05),
        ),
        child: Text(
          number,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(Color textColor) {
    return SizedBox(
      width: 80,
      height: 80,
      child: IconButton(
        onPressed: _onDeletePressed,
        icon: Icon(Icons.backspace_outlined, size: 28, color: textColor),
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: textColor.withValues(alpha: 0.05),
        ),
      ),
    );
  }
}
