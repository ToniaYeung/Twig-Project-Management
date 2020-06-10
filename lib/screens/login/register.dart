import 'package:flutter/material.dart';
import 'package:twig/screens/login/base_login_or_register_screen.dart';

class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Calls the BaseLoginPage with isLogin set to false, so that it shows the register UI
    return BaseLoginOrRegisterScreen(isLogin: false);
  }
}
