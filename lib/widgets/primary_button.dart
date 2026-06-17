import 'package:flutter/material.dart';
import 'package:kotabi/theme/kotabi_colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 20),
          ],
        ],
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(onPressed: onPressed, child: Text(label));
    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class AddToPlanButton extends StatelessWidget {
  const AddToPlanButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: KotabiColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      child: const Text('プランに追加'),
    );
  }
}
