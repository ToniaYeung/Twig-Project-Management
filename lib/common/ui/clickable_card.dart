import 'package:flutter/material.dart';
import 'package:twig/common/ui/theme.dart';

class ClickableCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double padding;
  final VoidCallback onLongPress;

  //We pass in the key, but we do not have a property key in this widget.
  // so we pass it to the super class (StatelessWidget)'s constructor
  const ClickableCard({
    Key key,
    this.child,
    this.onTap,
    this.onLongPress,
    this.padding = 30.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Translucent so that  they are able to tap anywhere on the card and it will trigger the onTap
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      onLongPress: onLongPress,

      child: Card(
        color: buttonBackgroundColour,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: greenDecoration, width: 3.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Center(child: child),
        ),
      ),
    );
  }
}
