class PasswordValidator {
  // Password policy requirements
  static const int minLength = 8;
  static const int maxLength = 128;
  static const bool requireUppercase = true;
  static const bool requireLowercase = true;
  static const bool requireNumbers = true;
  static const bool requireSpecialChars = true;

  /// Validates a password according to the password policy
  static PasswordValidationResult validatePassword(String password) {
    final errors = <String>[];

    // Check minimum length
    if (password.length < minLength) {
      errors.add('Password must be at least $minLength characters long');
    }

    // Check maximum length
    if (password.length > maxLength) {
      errors.add('Password must be no more than $maxLength characters long');
    }

    // Check for uppercase letter
    if (requireUppercase && !password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Password must contain at least one uppercase letter');
    }

    // Check for lowercase letter
    if (requireLowercase && !password.contains(RegExp(r'[a-z]'))) {
      errors.add('Password must contain at least one lowercase letter');
    }

    // Check for numbers
    if (requireNumbers && !password.contains(RegExp(r'[0-9]'))) {
      errors.add('Password must contain at least one number');
    }

    // Check for special characters
    if (requireSpecialChars &&
        !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add(
          'Password must contain at least one special character (!@#\$%^&*(),.?":{}|<>)');
    }

    // Check for common weak patterns
    if (hasCommonPatterns(password)) {
      errors
          .add('Password contains common patterns that make it easy to guess');
    }

    return PasswordValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      strength: _calculateStrength(password),
    );
  }

  /// Calculates password strength (0-4 scale)
  static PasswordStrength _calculateStrength(String password) {
    int score = 0;

    // Length scoring
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;

    // Character variety scoring
    if (password.contains(RegExp(r'[a-z]'))) score += 1;
    if (password.contains(RegExp(r'[A-Z]'))) score += 1;
    if (password.contains(RegExp(r'[0-9]'))) score += 1;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 1;

    // Deduct for common patterns
    if (hasCommonPatterns(password)) score -= 2;

    // Ensure score is within bounds
    score = score.clamp(0, 4);

    switch (score) {
      case 0:
      case 1:
        return PasswordStrength.veryWeak;
      case 2:
        return PasswordStrength.weak;
      case 3:
        return PasswordStrength.medium;
      case 4:
        return PasswordStrength.strong;
      default:
        return PasswordStrength.veryWeak;
    }
  }

  /// Checks for common weak patterns
  static bool hasCommonPatterns(String password) {
    final lowerPassword = password.toLowerCase();

    // Sequential patterns
    final sequentialPatterns = [
      '123456',
      'abcdef',
      'qwerty',
      'password',
      'admin',
      '123456789',
      'qwertyuiop',
      'asdfghjkl',
      'zxcvbnm'
    ];

    for (final pattern in sequentialPatterns) {
      if (lowerPassword.contains(pattern)) {
        return true;
      }
    }

    // Repeated characters
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      return true;
    }

    // Common substitutions
    final commonSubstitutions = {
      'password': ['p@ssw0rd', 'passw0rd', 'p@ssword'],
      'admin': ['@dmin', '4dmin', '4dm1n'],
      'qwerty': ['qw3rty', 'qwerty123']
    };

    for (final entry in commonSubstitutions.entries) {
      if (lowerPassword.contains(entry.key)) {
        for (final substitution in entry.value) {
          if (lowerPassword.contains(substitution)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Gets password policy description for UI
  static String getPasswordPolicyDescription() {
    return 'Password must be $minLength-$maxLength characters and contain at least one uppercase letter, lowercase letter, number, and special character.';
  }

  /// Gets password requirements list for UI
  static List<String> getPasswordRequirements() {
    return [
      'At least $minLength characters',
      'At least one uppercase letter (A-Z)',
      'At least one lowercase letter (a-z)',
      'At least one number (0-9)',
      'At least one special character (!@#\$%^&*(),.?":{}|<>)',
      'No common patterns or repeated characters',
    ];
  }
}

class PasswordValidationResult {
  final bool isValid;
  final List<String> errors;
  final PasswordStrength strength;

  const PasswordValidationResult({
    required this.isValid,
    required this.errors,
    required this.strength,
  });

  String get primaryError => errors.isNotEmpty ? errors.first : '';

  String get strengthDescription {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return 'Very Weak';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }
}

enum PasswordStrength {
  veryWeak,
  weak,
  medium,
  strong,
}
