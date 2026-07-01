import 'package:flutter/material.dart';

class PinDialog extends StatefulWidget {
  const PinDialog({super.key});

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final pin = _controller.text.trim();

    if (pin.length != 6) {
      setState(() {
        _errorText = 'رمز PIN يجب أن يتكون من 6 أرقام';
      });
      return;
    }

    Navigator.of(context).pop(pin);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إدخال رمز PIN'),
        content: TextField(
          controller: _controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: 'رمز PIN',
            border: const OutlineInputBorder(),
            errorText: _errorText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }
}