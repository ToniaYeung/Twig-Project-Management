import 'package:flutter/material.dart';
import 'package:twig/screens/login/base_login_or_register_screen.dart';

class Login extends StatelessWidget {
  static const String id = 'login_screen';
  @override
  Widget build(BuildContext context) {
    // Calls the BaseLoginPage with isLogin set to true, so it shows the login UI
    return BaseLoginOrRegisterScreen(
      isLogin: true,
    );
  }
}
