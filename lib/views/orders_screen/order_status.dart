import 'package:flutter_emart1/consts/consts.dart';

Widget orderStatus({icon, color, title, showDone}) {
  return ListTile(
    leading: Icon(
      icon,
      color: color,
    ).box.border(color: color).roundedSM.padding(const EdgeInsets.all(4)).make(),
    // Add Expanded to prevent text overflow
    title: Row(
      children: [
        Expanded(
          child: "$title".text.color(darkFontGrey).make(),
        ),
        showDone
            ? const Icon(
          Icons.done,
          color: Colors.green,
        )
            : Container(),
      ],
    ),
  );
}