import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emart1/consts/consts.dart';
import 'package:flutter_emart1/consts/lists.dart';
import 'package:flutter_emart1/controllers/product_controller.dart';
import 'package:flutter_emart1/views/category_screen/category_detail.dart';
import 'package:flutter_emart1/widgets_common/bg_widget.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ProductController());
    return bgWidget(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: categories.text.fontFamily(bold).white.make(),
        ),
        body: Container(
          padding: EdgeInsets.all(12),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: categoriesList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, mainAxisExtent: 200),
            itemBuilder: (context, index){
              return Column(
                children: [
                  Image.asset(categoriesImages[index], height: 120, width: 200, fit: BoxFit.cover),
                  10.heightBox,
                  categoriesList[index].text.color(darkFontGrey).align(TextAlign.center).make(),
                ],
              ).box.white.rounded.clip(Clip.antiAlias).outerShadowSm.make().onTap((){
                controller.getSubCategories(categoriesList[index]);
                Get.to(() => CategoryDetail(title: categoriesList[index]));
              });
            },),
        ),
      )
    );
  }
}
