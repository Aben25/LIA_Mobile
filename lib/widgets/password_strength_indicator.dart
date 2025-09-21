import 'package:flutter/material.dart';
import '../utils/password_validator.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final PasswordValidationResult? validationResult;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.validationResult,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final result =
        validationResult ?? PasswordValidator.validatePassword(password);
    final strength = result.strength;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(strength).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBackgroundColor(strength).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Strength bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _getStrengthValue(strength),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getBackgroundColor(strength),
                  ),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                result.strengthDescription,
                style: TextStyle(
                  fontFamily: 'Specify',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getBackgroundColor(strength),
                ),
              ),
            ],
          ),

          // Requirements list
          if (password.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Password Requirements:',
              style: TextStyle(
                fontFamily: 'Specify',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            ...PasswordValidator.getPasswordRequirements().map((requirement) {
              final isValid = _isRequirementMet(password, requirement);
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Icon(
                      isValid
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 14,
                      color: isValid ? Colors.green : Colors.grey[400],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        requirement,
                        style: TextStyle(
                          fontFamily: 'Specify',
                          fontSize: 11,
                          color: isValid ? Colors.green[700] : Colors.grey[600],
                          decoration:
                              isValid ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  double _getStrengthValue(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return 0.25;
      case PasswordStrength.weak:
        return 0.5;
      case PasswordStrength.medium:
        return 0.75;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  Color _getBackgroundColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return Colors.red;
      case PasswordStrength.weak:
        return Colors.orange;
      case PasswordStrength.medium:
        return Colors.yellow[700]!;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  bool _isRequirementMet(String password, String requirement) {
    if (requirement.contains('At least 8 characters')) {
      return password.length >= 8;
    }
    if (requirement.contains('uppercase letter')) {
      return password.contains(RegExp(r'[A-Z]'));
    }
    if (requirement.contains('lowercase letter')) {
      return password.contains(RegExp(r'[a-z]'));
    }
    if (requirement.contains('number')) {
      return password.contains(RegExp(r'[0-9]'));
    }
    if (requirement.contains('special character')) {
      return password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    }
    if (requirement.contains('common patterns')) {
      return !PasswordValidator.hasCommonPatterns(password);
    }
    return false;
  }
}
