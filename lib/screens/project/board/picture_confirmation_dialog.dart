import 'package:flutter/material.dart';
import 'package:twig/common/ui/theme.dart';

showPictureConfirmationDialog(
    BuildContext context, VoidCallback onConfirmedFunction) {
  Widget noButton = FlatButton(
    child: Text("No"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget yesButton = FlatButton(
    child: Text("Yes"),
    onPressed: onConfirmedFunction,
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        backgroundColor: buttonBackgroundColour,
        title: Center(
          child: Container(
            color: lightGreenDecoration,
            padding: EdgeInsets.symmetric(horizontal: 50.0),
            child: Center(
              child: Text(
                "Task complete!",
                style: textStyle(23.0),
              ),
            ),
          ),
        ),
        content: Container(
          height: 50,
          child: Center(
            child: Text(
              "Photograph completed task?",
              style: textStyle(20.0),
            ),
          ),
        ),
        actions: [
          noButton,
          yesButton,
        ],
      );
    },
  );
}
