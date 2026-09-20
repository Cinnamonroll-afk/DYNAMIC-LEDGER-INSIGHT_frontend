import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PinSetupState { enterCurrent, enterNew, confirmNew }

class SetupPinPage extends StatefulWidget {
  const SetupPinPage({super.key});

  @override
  State<SetupPinPage> createState() => _SetupPinPageState();
}

class _SetupPinPageState extends State<SetupPinPage> {
  String _currentPin = '';
  String _enteredPin = '';
  String _newPin = '';
  
  PinSetupState _state = PinSetupState.enterNew;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkExistingPin();
  }

  Future<void> _checkExistingPin() async {
    final prefs = await SharedPreferences.getInstance();
    final existingPin = prefs.getString('app_lock_pin');
    if (existingPin != null && existingPin.isNotEmpty) {
      setState(() {
        _currentPin = existingPin;
        _state = PinSetupState.enterCurrent;
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
    // Delay slightly to let the user see the 6th dot fill up
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
            _errorMessage = 'Incorrect PIN. Try again.';
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
          await prefs.setString('app_lock_pin', _newPin);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('App Lock PIN saved successfully')),
            );
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _enteredPin = '';
            _errorMessage = 'PINs do not match. Try again.';
          });
        }
        break;
    }
  }

  String _getTitle() {
    switch (_state) {
      case PinSetupState.enterCurrent:
        return 'Enter Current PIN';
      case PinSetupState.enterNew:
        return 'Enter New PIN';
      case PinSetupState.confirmNew:
        return 'Confirm New PIN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Lock PIN'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              _getTitle(),
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
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              )
            else
              const SizedBox(height: 19), // placeholder for error text height
            const SizedBox(height: 32),
            _buildPinIndicators(textColor),
            const Spacer(),
            _buildNumberPad(textColor),
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
            color: isFilled ? textColor : textColor.withValues(alpha: 0.2),
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
              const SizedBox(width: 80, height: 80), // Empty space
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
