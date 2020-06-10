import 'package:flutter/material.dart';
import 'package:twig/common/ui/dialog_title.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/keys.dart';

showDeleteConfirmationDialog(
    BuildContext context, VoidCallback onPressedDeleteFunction) {
  Widget cancelButton = FlatButton(
    key: Key(deleteCancelButtonKey),
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget yesButton = FlatButton(
    key: Key(deleteYesButtonKey),
    child: Text("Yes"),
    onPressed: onPressedDeleteFunction,
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        backgroundColor: buttonBackgroundColour,
        title: DialogTitle(title: "Delete"),
        content: Padding(
          padding: const EdgeInsets.fromLTRB(45.0, 0, 0, 0),
          child: Text(
            "Permanently remove?",
            style: textStyle(20.0),
          ),
        ),
        actions: [
          cancelButton,
          yesButton,
        ],
      );
    },
  );
}
