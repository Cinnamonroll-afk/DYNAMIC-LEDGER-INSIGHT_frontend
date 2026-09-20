import 'package:flutter/material.dart';

class UnlockPinPage extends StatefulWidget {
  final String correctPin;

  const UnlockPinPage({super.key, required this.correctPin});

  @override
  State<UnlockPinPage> createState() => _UnlockPinPageState();
}

class _UnlockPinPageState extends State<UnlockPinPage> {
  String _enteredPin = '';
  String _errorMessage = '';

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 6) {
      setState(() {
        _enteredPin += number;
        _errorMessage = '';
      });
      if (_enteredPin.length == 6) {
        _verifyPin();
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

  void _verifyPin() async {
    // Delay slightly to let the user see the 6th dot fill up
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    if (_enteredPin == widget.correctPin) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _enteredPin = '';
        _errorMessage = 'Incorrect PIN. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    // PopScope prevents dismissing with back button
    return PopScope(
      canPop: false, 
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.lock_outline, size: 64, color: textColor),
              const SizedBox(height: 24),
              Text(
                'Enter App Lock PIN',
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
                const SizedBox(height: 19),
              const SizedBox(height: 32),
              _buildPinIndicators(textColor),
              const Spacer(),
              _buildNumberPad(textColor),
              const SizedBox(height: 32),
            ],
          ),
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
