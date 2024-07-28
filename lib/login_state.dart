import 'package:flutter/material.dart';

enum PasswordRule {
  minCharacters,
  uppercase,
  lowercase,
  digit,
  specialChar,
}

class LoginState extends ChangeNotifier {
  bool wrongUsernameOrPhone = false;
  bool wrongPassword = false;
  bool showSpinner = false;
  Set<PasswordRule> passwordRules = {};

  bool get hasUppercase => passwordRules.contains(PasswordRule.uppercase);
  bool get hasLowercase => passwordRules.contains(PasswordRule.lowercase);
  bool get hasDigits => passwordRules.contains(PasswordRule.digit);
  bool get hasSpecialCharacters => passwordRules.contains(PasswordRule.specialChar);
  bool get passwordLength => passwordRules.contains(PasswordRule.minCharacters);
  bool get showPasswordRules => passwordRules.isNotEmpty;

  void toggleWrongUsernameOrPhone(bool value) {
    wrongUsernameOrPhone = value;
    notifyListeners();
  }

  void toggleWrongPassword(bool value) {
    wrongPassword = value;
    notifyListeners();
  }

  void toggleSpinner(bool value) {
    showSpinner = value;
    notifyListeners();
  }

  void updatePasswordRules(String password) {
    passwordRules = {};
    if (password.length >= 8) {
      passwordRules.add(PasswordRule.minCharacters);
    }
    if (password.contains(RegExp(r'[A-Z]'))) {
      passwordRules.add(PasswordRule.uppercase);
    }
    if (password.contains(RegExp(r'[a-z]'))) {
      passwordRules.add(PasswordRule.lowercase);
    }
    if (password.contains(RegExp(r'[0-9]'))) {
      passwordRules.add(PasswordRule.digit);
    }
    if (password.contains(RegExp(r'[!@#\$&*~]'))) {
      passwordRules.add(PasswordRule.specialChar);
    }
    notifyListeners();
  }
}
