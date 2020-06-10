import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/firebase/authentication_service.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/common/ui/colour_picker_dialog.dart';
import 'package:twig/screens/login/register.dart';

import '../home/home.dart';
import 'forgot_password_dialog.dart';

class BaseLoginOrRegisterScreen extends StatefulWidget {
  final bool isLogin;

  const BaseLoginOrRegisterScreen({@required this.isLogin});

  @override
  _BaseLoginOrRegisterScreenState createState() =>
      _BaseLoginOrRegisterScreenState();
}

class _BaseLoginOrRegisterScreenState extends State<BaseLoginOrRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String email;
  String password;
  String error = "";
  String name;
  Color colour;

  @override
  //initialises the first colour as white
  void initState() {
    super.initState();
    //int represented as a hexidecimal
    colour = initialRegistrationColour;
  }

  @override
  Widget build(BuildContext context) {
    AuthenticationService auth = Provider.of<AuthenticationService>(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("images/loginbackground.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          new Center(
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                children: <Widget>[
                  _logo(),
                  SizedBox(height: 43.0),
                  widget.isLogin ? Container() : _nameTextField(),
                  SizedBox(height: 8.0),
                  widget.isLogin ? Container() : _colourPicker(),
                  SizedBox(height: 8.0),
                  _emailTextField(),
                  widget.isLogin
                      ? SizedBox(height: 8.0)
                      : SizedBox(height: 22.0),
                  _passwordTextField(),
                  SizedBox(height: 0.0),
                  widget.isLogin
                      ? Container(
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: _forgotPassword()))
                      : Container(),
                  SizedBox(height: 34.0),
                  _loginOrRegisterButton(auth),
                  Center(
                    child: Text(
                      error,
                      style: textStyle2Bold(13.0, colour: textColour4),
                    ),
                  ),
                  SizedBox(height: 84.0),
                  _navigateToSignUpOrLoginButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return CircleAvatar(
      radius: 85.0,
      backgroundColor: greenDecoration2,
      child: CircleAvatar(
        backgroundColor: logoColour,
        radius: 80.0,
        child: Image.asset('images/biglogo.png'),
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      key: Key(signUpNameFieldKey),
      onChanged: (value) {
        name = value;
      },
      validator: (String value) {
        if (value.isEmpty) {
          return "Please enter your name";
        }
        return null;
      },
      keyboardType: TextInputType.text,
      autofocus: true,
      decoration: new InputDecoration(
        fillColor: fillColour,
        filled: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            'images/name.png',
            width: 20,
            height: 20,
            fit: BoxFit.fill,
          ),
        ),
        hintText: 'Name',
        hintStyle: hintStyle,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: _borderStyle,
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      key: Key(loginOrSignUpEmailFieldKey),
      onChanged: (value) {
        email = value;
      },
      // Matches the email value with the regular expression. If there is a match then it is a va lid email, else it is not
      validator: (value) =>
          RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+.[a-zA-Z]+")
                  .hasMatch(value)
              ? null
              : 'Must be a valid email',
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: new InputDecoration(
        fillColor: fillColour,
        filled: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            'images/email.png',
            width: 20,
            height: 20,
            fit: BoxFit.fill,
          ),
        ),
        hintText: 'Email',
        hintStyle: hintStyle,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: _borderStyle,
      ),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      key: Key(loginOrSignUpPasswordFieldKey),
      onChanged: (value) {
        password = value;
      },
      validator: (String value) {
        if (value.length < 6) {
          return "Password must be 6 or more characters";
        }
        return null;
      },
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        fillColor: textColour3.withOpacity(0.9),
        filled: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            'images/password.png',
            width: 20,
            height: 20,
            fit: BoxFit.fill,
          ),
        ),
        hintText: 'Password',
        hintStyle: textStyleColour(whiteColour),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: _borderStyle,
      ),
    );
  }

  Widget _loginOrRegisterButton(AuthenticationService auth) {
    return Padding(
      key: Key(loginOrRegisterButtonKey),
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        child: MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(28.0),
          ),
          minWidth: 200.0,
          height: 50.0,
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              if (widget.isLogin) {
                try {
                  await auth.login(email, password);
                  //push replacement means it replaces the stack, so pressing back wont go back to login page, (from home it will close it app)
                  Navigator.pushReplacement(
                    context,
                    //page transition
                    MaterialPageRoute(builder: (context) {
                      return Home();
                    }),
                  );
                } on PlatformException catch (exception) {
                  setState(() {
                    translateLoginException(exception.code);
                  });
                }
              } else {
                try {
                  await auth.signUp(email, password, name, colour.value);
                  Navigator.pop(context);
                } on PlatformException catch (exception) {
                  setState(() {
                    translateSignUpException(exception.code);
                  });
                }
              }
            }
          },
          color: greenDecoration2,
          child: Text(
            widget.isLogin ? 'Log In' : 'Register',
            style: textStyleColour(whiteColour),
          ),
        ),
      ),
    );
  }

  Widget _forgotPassword() {
    return FlatButton(
      key: Key(forgotPasswordButtonKey),
      child: Text(
        "Forgot password?",
        style: hintStyle,
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ForgotPasswordDialog();
            });
      },
    );
  }

  Widget _colourPicker() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        child: MaterialButton(
          color: colour,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(
              28.0,
            ),
          ),
          minWidth: 200.0,
          height: 50.0,
          onPressed: () async {
            // showDialog is a wrapper for ColourPickerDialog, which basically Navigator.pushes
            //ColourPickerDialog onto the stack.
            //The colourpicked variable is the result returned in the pop of the ColourPickerDialog widget
            Color colourPicked = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ColourPickerDialog(colour);
                });
            setState(() {
              //if clicked off the dialog instead of hitting submit, colour picked returns null so
              //if it is checked to be null, and dont update the colour if it is (and change it back to default white)
              if (colourPicked != null) {
                colour = colourPicked;
              }
            });
          },
          child: Row(
            children: [
              Container(
                child: new Image.asset(
                  'images/colours.png',
                  height: 27.0,
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                ' Colour',
                style: hintStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navigateToSignUpOrLoginButton() {
    return FlatButton(
      key: Key(navigateToSignUpOrLoginButtonKey),
      child: Text(
        widget.isLogin ? "Sign up" : "Log in",
        style: textStyleLoginOrSignUp,
      ),
      onPressed: () {
        if (widget.isLogin) {
          Navigator.push(
            context,
            //page transition
            MaterialPageRoute(
              builder: (context) {
                return Register();
              },
            ),
          );
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  void translateLoginException(String code) {
    switch (code) {
      case "ERROR_INVALID_EMAIL":
        error = "Invalid email";
        break;
      case "ERROR_WRONG_PASSWORD":
        error = "Incorrect password";
        break;
      case "ERROR_USER_NOT_FOUND":
        error = "User not found";
        break;
      case "ERROR_USER_DISABLED":
        error = "This user has been disabled";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        error = "There have been too many attempts to sign in as this user";
        break;
      default:
        error = "An undefined error happened, please try again";
        break;
    }
  }

  void translateSignUpException(String code) {
    switch (code) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
        error = "Email is already in use";
        break;
      case "ERROR_WEAK_PASSWORD":
        error = "Password must be 6 or more characters";
        break;
      case "ERROR_INVALID_EMAIL":
        error = "Please enter a valid email";
        break;
      default:
        error = "An undefined error happened, please try again";
        break;
    }
  }

  final _borderStyle = OutlineInputBorder(
    borderSide: BorderSide(color: whiteColour),
    borderRadius: BorderRadius.circular(32.0),
  );
}
