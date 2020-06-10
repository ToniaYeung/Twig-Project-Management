import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/firebase/authentication_service.dart';

class ForgotPasswordDialog extends StatefulWidget {
  @override
  _ForgotPasswordDialogState createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  String email;
  String error = "";
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      key: Key(forgotPasswordDialogKey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      title: Text(
        "Please enter email linked to account",
        style: baseTextStyle2(19.0, colour: textColour3),
        textAlign: TextAlign.center,
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
          child: Form(
            // Link the key to this form, so that everything inside this form is validated when we call _formKey.validate()
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  key: Key(forgotPasswordEmailKey),
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
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: whiteColour,
                      ),
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Material(
            borderRadius: BorderRadius.circular(30.0),
            child: Padding(
              padding: EdgeInsets.fromLTRB(100.0, 0, 100.0, 0.0),
              child: MaterialButton(
                key: Key(forgotPasswordSubmitKey),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(28.0),
                ),
                minWidth: 200.0,
                height: 50.0,
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    try {
                      AuthenticationService auth =
                          Provider.of<AuthenticationService>(context);
                      await auth.passwordReset(email);
                      Navigator.pop(context);
                    } on PlatformException catch (exception) {
                      setState(() {
                        translateForgotPasswordException(exception.code);
                      });
                    }
                  }
                },
                color: greenDecoration2,
                child: Text(
                  'Submit',
                  style: textStyleColour(whiteColour),
                ),
              ),
            ),
          ),
        ),
        Text(
          error,
          style: textStyle2Bold(13.0, colour: textColour4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void translateForgotPasswordException(String code) {
    switch (code) {
      case "ERROR_USER_NOT_FOUND":
        error = "User not found";
        break;
      case "ERROR_INVALID_EMAIL":
        error = "Please enter a valid email";
        break;
      default:
        error = "An undefined error happened, please try again";
        break;
    }
  }
}
