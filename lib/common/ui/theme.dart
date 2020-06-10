import 'package:flutter/material.dart';

//all the colours used for UI
Color transparent = Colors.transparent;
Color logoColour = Color(0XFFFBFAF7);
Color whiteColour = Colors.white;
Color initialRegistrationColour = Color(0xfffafafa);
Color fillColour = Colors.white70;
Color buttonBackgroundColour = Color(0xFFC1E6EC);
Color appBarColour = Colors.cyan.shade100;
Color scaffoldBackgroundColour = Color(0xFFA5DBE3);
Color greenDecoration = Color(0xFF57D549);
Color greenDecoration2 = Colors.green;
Color lightGreenDecoration = Color(0xFF97E0BB);
Color gradientYellow = Color(0xFFF9E3AD);
Color defaultYellow = Color(0xFFF7F797);
Color textColour = Color(0xFF006000);
Color textColour2 = Color(0xFF5DBC9D);
Color textColour3 = Color(0XFF265D0C);
Color textColour4 = Color(0XFFBA0C2F);
Color shadowColour = Colors.black12;

//colours used for insights UI
Color insightsShadowColour = Colors.grey;
Color insightsBackgroundColour = Color(0xFFE9E4FF);
Color insightsCardColour = Color(0xFFEFE5FD);
Color insightsCardShadow = Colors.purpleAccent;
Color insightsColour = Color(0xFFE8BAFE);
Color insightsColour2 = Color(0xFF756AD0);
Color insightsColour3 = Color(0xFf9188D9);
Color insightsColour4 = Color(0xFFD5C1FD);
Color insightsColour5 = Colors.pinkAccent;
Color insightsColour6 = Colors.lightBlueAccent;
Color insightsColour7 = Colors.greenAccent;

//text style functions
//TEXT STYLE 1 COLLECTION
TextStyle baseTextStyle(double fontSize, {Color colour, FontStyle fontStyle}) =>
    TextStyle(
        color: colour,
        fontFamily: 'PatrickHand',
        fontSize: fontSize,
        fontStyle: fontStyle);

TextStyle textStyle(double fontSize) =>
    baseTextStyle(fontSize, colour: textColour);

TextStyle textStyleDefaultColour(double fontSize) => baseTextStyle(fontSize);

TextStyle textStyleItalic(double fontSize, {Color colour}) =>
    baseTextStyle(fontSize, colour: textColour, fontStyle: FontStyle.italic);

TextStyle textStyleBold({double fontSize, Color colour}) =>
    TextStyle(fontSize: fontSize, color: colour, fontWeight: FontWeight.bold);

//TEXT STYLE 2 COLLECTION
TextStyle baseTextStyle2(double fontSize,
        {Color colour, FontStyle fontStyle, FontWeight fontWeight}) =>
    TextStyle(
        color: colour,
        fontFamily: 'Asap',
        fontSize: fontSize,
        fontStyle: fontStyle,
        fontWeight: fontWeight);

TextStyle textStyle2(double fontSize) =>
    baseTextStyle(fontSize, colour: textColour);

TextStyle textStyle2DefaultColour(double fontSize) => baseTextStyle2(fontSize);

TextStyle textStyle2Italic(double fontSize, Color colour) =>
    baseTextStyle(fontSize, colour: colour, fontStyle: FontStyle.italic);

TextStyle textStyle2Bold(double fontSize, {Color colour}) =>
    baseTextStyle2(fontSize, colour: colour, fontWeight: FontWeight.bold);

//SPECIAL UI USE CASES

TextStyle hintStyle = TextStyle(color: textColour3);

TextStyle textStyleLoginOrSignUp = TextStyle(
  color: textColour3,
  decoration: TextDecoration.underline,
);
TextStyle whiteFont(double fontSize, {FontStyle fontStyle}) =>
    TextStyle(fontSize: fontSize, color: whiteColour, fontStyle: fontStyle);

//DEFAULT COLLECTION
TextStyle defaultTextStyle = TextStyle(
  color: textColour,
  fontFamily: 'PatrickHand',
);
TextStyle defaultItalic(double fontSize) =>
    TextStyle(fontSize: fontSize, fontStyle: FontStyle.italic);

TextStyle textStyleColour(Color textColour) => TextStyle(color: textColour);
