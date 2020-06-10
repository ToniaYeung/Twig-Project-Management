import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:twig/common/ui/theme.dart';

class ColourPickerDialog extends StatefulWidget {
  final Color initialColour;

  const ColourPickerDialog(this.initialColour);
  @override
  _ColourPickerDialogState createState() => _ColourPickerDialogState();
}

class _ColourPickerDialogState extends State<ColourPickerDialog> {
  Color colour;

  @override
  void initState() {
    //still want parent class to run initState
    super.initState();

    colour = widget.initialColour;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      title: Text(
        "Please pick your user colour",
        style: baseTextStyle2(19.0, colour: textColour3),
        textAlign: TextAlign.center,
      ),
      content: Container(
        height: 200.0,
        child: MaterialColorPicker(
            onColorChange: (Color newColour) {
              colour = newColour;
              // Handle color changes
            },
            selectedColor: colour),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 25, 5),
          child: MaterialButton(
            color: fillColour,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(28.0),
            ),
            child: Text(
              'Submit',
            ),
            onPressed: () {
              Navigator.of(context).pop(colour);
            },
          ),
        ),
      ],
    );
  }
}
