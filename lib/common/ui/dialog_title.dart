import 'package:flutter/material.dart';
import 'package:twig/common/ui/theme.dart';

class DialogTitle extends StatelessWidget {
  final String title;
  const DialogTitle({
    this.title,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10.0, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              color: lightGreenDecoration,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: textStyle(22.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
