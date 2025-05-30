import 'package:flutter/material.dart';
import 'package:flutter_emart1/consts/consts.dart';

Widget ourButton({onPress, color, textColor,String? title}){
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0), // Không bo tròn
      ),

    ),
      onPressed: onPress,
      child: title!.text.color(textColor).fontFamily(bold).make());
}