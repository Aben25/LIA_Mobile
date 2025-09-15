import 'package:flutter_test/flutter_test.dart';
import 'package:love_in_action/utils/password_validator.dart';

void main() {
  group('PasswordValidator Tests', () {
    test('should accept strong password', () {
      final result = PasswordValidator.validatePassword('MyStr0ng!Pass');
      expect(result.isValid, true);
      expect(result.strength, PasswordStrength.strong);
      expect(result.errors, isEmpty);
    });

    test('should reject password that is too short', () {
      final result = PasswordValidator.validatePassword('Short1!');
      expect(result.isValid, false);
      expect(result.errors,
          contains('Password must be at least 8 characters long'));
    });

    test('should reject password without uppercase letter', () {
      final result = PasswordValidator.validatePassword('mystrong1!pass');
      expect(result.isValid, false);
      expect(result.errors,
          contains('Password must contain at least one uppercase letter'));
    });

    test('should reject password without lowercase letter', () {
      final result = PasswordValidator.validatePassword('MYSTRONG1!PASS');
      expect(result.isValid, false);
      expect(result.errors,
          contains('Password must contain at least one lowercase letter'));
    });

    test('should reject password without number', () {
      final result = PasswordValidator.validatePassword('MyStrong!Pass');
      expect(result.isValid, false);
      expect(
          result.errors, contains('Password must contain at least one number'));
    });

    test('should reject password without special character', () {
      final result = PasswordValidator.validatePassword('MyStrong1Pass');
      expect(result.isValid, false);
      expect(
          result.errors,
          contains(
              'Password must contain at least one special character (!@#\$%^&*(),.?":{}|<>)'));
    });

    test('should reject common patterns like qwerty', () {
      final result = PasswordValidator.validatePassword('Qwerty123!');
      expect(result.isValid, false);
      expect(
          result.errors,
          contains(
              'Password contains common patterns that make it easy to guess'));
    });

    test('should reject repeated characters', () {
      final result = PasswordValidator.validatePassword('AAA123!aaa');
      expect(result.isValid, false);
      expect(
          result.errors,
          contains(
              'Password contains common patterns that make it easy to guess'));
    });

    test('should calculate password strength correctly', () {
      expect(PasswordValidator.validatePassword('weak').strength,
          PasswordStrength.veryWeak);
      expect(PasswordValidator.validatePassword('weak123').strength,
          PasswordStrength.weak);
      expect(PasswordValidator.validatePassword('Weak123').strength,
          PasswordStrength.medium);
      expect(PasswordValidator.validatePassword('Weak123!').strength,
          PasswordStrength.strong);
    });

    test('should provide correct password requirements', () {
      final requirements = PasswordValidator.getPasswordRequirements();
      expect(requirements, isNotEmpty);
      expect(requirements, contains('At least 8 characters'));
      expect(requirements, contains('At least one uppercase letter (A-Z)'));
      expect(requirements, contains('At least one lowercase letter (a-z)'));
      expect(requirements, contains('At least one number (0-9)'));
      expect(requirements,
          contains('At least one special character (!@#\$%^&*(),.?":{}|<>)'));
    });

    test('should provide password policy description', () {
      final description = PasswordValidator.getPasswordPolicyDescription();
      expect(description, isNotEmpty);
      expect(description, contains('8-128 characters'));
      expect(description, contains('uppercase letter'));
      expect(description, contains('lowercase letter'));
      expect(description, contains('number'));
      expect(description, contains('special character'));
    });
  });
}
