import 'package:flutter_emart1/consts/consts.dart';

Widget orderPlaceDetails({title1, title2, d1, d2}) {
  // Handle null values with empty strings to prevent "null" from displaying
  final t1 = title1 ?? "";
  final t2 = title2 ?? "";
  final data1 = d1 ?? "";
  final data2 = d2 ?? "";

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // First column - Expanded to take available space
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              "$t1".text.fontFamily(semibold).make(),
              "$data1".text.color(redColor).fontFamily(semibold).make()
            ],
          ),
        ),

        // Second column with fixed width but wrapped in Flexible
        // to prevent overflow when content is too long
        Flexible(
          child: SizedBox(
            width: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                "$t2".text.fontFamily(semibold).make(),
                "$data2".text.make(),
              ],
            ),
          ),
        )
      ],
    ),
  );
}