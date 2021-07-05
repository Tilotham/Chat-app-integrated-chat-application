import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget appBarMain(BuildContext context, String nameToBeOnAppbar) {
  return AppBar(
    backwardsCompatibility: false,
    systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.blue[700],
        statusBarIconBrightness: Brightness.light),
    title: Text(nameToBeOnAppbar),
    elevation: 0.0,
    centerTitle: false,
  );
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.black54),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)));
}

TextStyle simpleTextStyle() {
  return TextStyle(
      fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 18);
}

TextStyle biggerTextStyle() {
  return TextStyle(
      fontWeight: FontWeight.w300, color: Colors.black, fontSize: 19);
}
